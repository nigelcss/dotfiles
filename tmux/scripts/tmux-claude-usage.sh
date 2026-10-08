#!/usr/bin/env bash
# Claude.ai account usage indicator for the tmux status bar.
#
# `claude -p "/usage"` is the only supported way to read a user's session/week
# rate-limit usage (there's no local cache file and no public HTTP API for it),
# but it makes a real network round-trip and itself counts as usage, so we
# can't afford to run it on every 5s status-interval tick. Instead we cache the
# last result to disk and only kick off a fresh async refresh once the cache
# is older than REFRESH_INTERVAL; the status bar always reads the cache
# instantly and never blocks on the refresh itself.
set -u

CACHE_DIR="$HOME/.cache/tmux-claude-usage"
CACHE_FILE="$CACHE_DIR/usage.txt"
LOCK_FILE="$CACHE_DIR/refresh.lock"
REFRESH_INTERVAL=300

mkdir -p "$CACHE_DIR"

now=$(date +%s)
cache_age=$REFRESH_INTERVAL
if [ -f "$CACHE_FILE" ]; then
	cache_mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
	cache_age=$(( now - cache_mtime ))
fi

# Stale cache and no refresh already in flight: kick one off in the background.
# The lock file is removed unconditionally in the subshell so a crashed/killed
# refresh can't wedge future ticks.
if [ "$cache_age" -ge "$REFRESH_INTERVAL" ] && [ ! -f "$LOCK_FILE" ]; then
	(
		touch "$LOCK_FILE"

		# Alongside "% used" we also show "% of the window elapsed" (session
		# windows reset every 5h, weekly ones every 7d), so a high used% late
		# in its window reads very differently from the same used% right
		# after a reset. `/usage` only reports a reset timestamp, not elapsed
		# time, so we derive it. Session elapsed uses wall-clock time, while
		# weekly elapsed is based on configured working hours (Mon-Fri
		# 8am-8pm), not the full 7-day calendar period.
		PARSE_SCRIPT="$CACHE_DIR/parse_usage.py"
		cat > "$PARSE_SCRIPT" <<'PYEOF'
import re
import sys
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

WORK_DAYS = {0, 1, 2, 3, 4}
WORK_START = 8
WORK_END = 20

text = sys.stdin.read()
LINE_RE = r"Current {label}: (\d+)% used . resets (\w+ \d+) at (\d+:?\d*)(am|pm) \(([^)]+)\)"


def working_seconds(start, end, work_days, work_start, work_end):
	total = 0
	current = start.replace(hour=0, minute=0, second=0, microsecond=0)
	while current < end:
		if current.weekday() in work_days:
			day_work_start = current.replace(hour=work_start)
			day_work_end = current.replace(hour=work_end)
			overlap_start = max(start, day_work_start)
			overlap_end = min(end, day_work_end)
			if overlap_start < overlap_end:
				total += (overlap_end - overlap_start).total_seconds()
		current += timedelta(days=1)
	return total


def elapsed_pct(label, period_seconds, work_hours_only=False):
	m = re.search(LINE_RE.format(label=re.escape(label)), text)
	if not m:
		return None
	used_pct, date_str, time_str, ampm, tz = m.groups()
	if ":" not in time_str:
		time_str += ":00"
	tzinfo = ZoneInfo(tz)
	now = datetime.now(tzinfo)
	reset_dt = datetime.strptime(f"{date_str} {now.year} {time_str}{ampm}", "%b %d %Y %I:%M%p")
	reset_dt = reset_dt.replace(tzinfo=tzinfo)
	if reset_dt < now - timedelta(hours=1):
		reset_dt = reset_dt.replace(year=now.year + 1)
	if work_hours_only:
		window_start = reset_dt - timedelta(seconds=period_seconds)
		total_secs = working_seconds(window_start, reset_dt, WORK_DAYS, WORK_START, WORK_END)
		elapsed_secs = working_seconds(window_start, now, WORK_DAYS, WORK_START, WORK_END)
		pct = round(elapsed_secs / total_secs * 100) if total_secs > 0 else 0
	else:
		remaining = (reset_dt - now).total_seconds()
		pct = round((period_seconds - remaining) / period_seconds * 100)
	pct = max(0, min(100, pct))
	return used_pct, pct, reset_dt.astimezone().strftime("%H:%M")


session = elapsed_pct("session", 5 * 3600, work_hours_only=False)
week = elapsed_pct("week (all models)", 7 * 24 * 3600, work_hours_only=True)
if session and week:
	print(f"{session[0]} {session[1]} {session[2]} {week[0]} {week[1]}")
PYEOF

		parsed=$(claude -p "/usage" 2>/dev/null | python3 "$PARSE_SCRIPT" 2>/dev/null)
		if [ -n "$parsed" ]; then
			printf '%s\n' "$parsed" > "$CACHE_FILE.tmp"
			mv "$CACHE_FILE.tmp" "$CACHE_FILE"
		else
			# Bump the mtime so a failing refresh (e.g. expired auth) backs off
			# for REFRESH_INTERVAL instead of respawning claude every tick.
			touch "$CACHE_FILE"
		fi
		rm -f "$LOCK_FILE"
	) >/dev/null 2>&1 &
	disown
fi

[ -f "$CACHE_FILE" ] || exit 0
read -r session_used session_elapsed session_reset week_used week_elapsed < "$CACHE_FILE"
[ -n "${session_used:-}" ] && [ -n "${week_used:-}" ] || exit 0

# Colour by pace, not raw used%: a window is only a problem if usage is
# outrunning the clock (used% ahead of elapsed%), since e.g. 59% used at 31%
# elapsed means the account will exhaust the window well before it resets.
# Red once a window is actually exhausted, orange while outpacing elapsed
# time, green while usage is tracking at or behind the window's pace.
status() {
	used=$1 elapsed=$2
	if [ "$used" -ge 100 ]; then
		echo 2
	elif [ "$used" -gt "$elapsed" ]; then
		echo 1
	else
		echo 0
	fi
}

status_to_color() {
	case "$1" in
		2) echo colour196 ;;
		1) echo colour208 ;;
		*) echo colour142 ;;
	esac
}

session_status=$(status "$session_used" "$session_elapsed")
week_status=$(status "$week_used" "$week_elapsed")

session_color=$(status_to_color "$session_status")
week_color=$(status_to_color "$week_status")

worst=$session_status
[ "$week_status" -gt "$worst" ] && worst=$week_status
worst_color=$(status_to_color "$worst")

printf ' #[fg=%s]⚡#[fg=%s] S:%s%%:%s%%(%s)#[fg=%s] W:%s%%:%s%%#[default] ' \
	"$worst_color" "$session_color" "$session_used" "$session_elapsed" "$session_reset" \
	"$week_color" "$week_used" "$week_elapsed"

exit 0
