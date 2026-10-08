#!/usr/bin/env bash
# Global dev-server presence indicator for the tmux status bar.
#
# Counterpart to tmux-nvim-status.sh, for `overmind` (vendor_risk) and `make`
# (n8n's `make run`) panes. Detection is LIVE via tmux-run-detect.sh (a single
# `ps` snapshot matched against pane ttys), so it is inherently self-healing:
# when the server exits its process leaves the table and it simply drops out on
# the next status-interval. No event hooks, no stored per-pane state, no
# reconciler.
#
# As a convenience we also maintain a session-scoped @run_session option holding
# the kinds running in that session ("overmind", "make", or "overmind+make"), so
# the session switcher can show a dev-server suffix. Rebuilt from scratch each
# run, so it self-heals too.
set -u

DETECT="/Users/nigel.slack-smith/.config/tmux/scripts/tmux-run-detect.sh"

# Live snapshot: one line per dev-server pane, reduced to "<session>\t<kind>".
panes="$("$DETECT" 2>/dev/null | cut -f2,5)"

count="$(printf '%s' "$panes" | grep -c .)"

# Rebuild @run_session across ALL sessions so it self-heals: set it on sessions
# that have a dev server, clear it on those that don't. Fed via a here-doc (not
# a pipe) so the loop runs in THIS shell, matching the other tmux scripts.
while IFS= read -r s; do
	[ -z "$s" ] && continue
	kinds="$(printf '%s\n' "$panes" | awk -F'\t' -v sess="$s" '$1 == sess { print $2 }' | LC_ALL=C sort -u | paste -sd'+' -)"
	if [ -n "$kinds" ]; then
		tmux set-option -t "$s" @run_session "$kinds" 2>/dev/null || true
	else
		tmux set-option -t "$s" -u @run_session 2>/dev/null || true
	fi
done <<EOF
$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
EOF

# Nothing to show: print nothing.
[ "$count" -gt 0 ] && printf ' #[fg=colour214]▶ %s#[default] ' "$count"

exit 0
