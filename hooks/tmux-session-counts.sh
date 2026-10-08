#!/usr/bin/env bash
# Global Claude session-count indicator for the tmux status bar.
#
# Tallies every tmux session by its session-scoped @claude_session_prio option
# (maintained per session by the rollup hook):
#   0 = idle, 1 = running, 2 = waiting; UNSET = session has no Claude (ignored).
#
# Emits compact, color-coded segments in the order idle, waiting, running,
# omitting any state whose count is 0. When all counts are 0 it prints nothing.
set -u

idle=0
waiting=0
running=0

# Feed the per-session prio values via a here-doc into the loop so the counters
# persist in THIS shell (a pipe would run the loop in a subshell and lose them).
# Sessions with the option unset emit an EMPTY line, which the case ignores.
while IFS= read -r prio; do
	case "$prio" in
	0) idle=$((idle + 1)) ;;
	1) running=$((running + 1)) ;;
	2) waiting=$((waiting + 1)) ;;
	esac
done <<EOF
$(tmux list-sessions -F '#{@claude_session_prio}' 2>/dev/null)
EOF

out=""
if [ "$idle" -gt 0 ]; then
	out="$out #[fg=colour245]○ $idle#[default]"
fi
if [ "$waiting" -gt 0 ]; then
	out="$out #[fg=colour208,blink]◐ $waiting#[default]"
fi
if [ "$running" -gt 0 ]; then
	out="$out #[fg=colour142]● $running#[default]"
fi

# Nothing to show: print nothing.
[ -z "$out" ] && exit 0

printf '%s ' "$out"
