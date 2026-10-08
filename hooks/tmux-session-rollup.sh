#!/usr/bin/env bash
# Claude Code -> tmux activity indicator (session-level rollup).
# Aggregates the per-pane @claude_prio values across every pane in a session,
# computes the MAX priority, and surfaces a session-level display string as a
# session-scoped tmux option (@claude_session_state).
#
# No `set -e`: tmux calls may fail harmlessly if a pane/session has vanished.
set -u

session="${1:-}"
[ -z "$session" ] && exit 0

max=0
any=0
# List every pane in the session and read its @claude_prio option.
while IFS= read -r p; do
  # A non-empty value means a pane has Claude state (even "0" = idle/open).
  [ -n "$p" ] && any=1
  # Treat empty / non-numeric values as 0 for the max computation.
  case "$p" in
    ''|*[!0-9]*) p=0 ;;
  esac
  [ "$p" -gt "$max" ] && max="$p"
done <<EOF
$(tmux list-panes -s -t "$session" -F '#{@claude_prio}' 2>/dev/null)
EOF

# If no pane has any @claude_prio set, the session has no Claude activity at all
# -> unset the session options so choose-tree shows no suffix (blank).
if [ "$any" -eq 0 ]; then
  tmux set-option -u @claude_session_state 2>/dev/null || true
  tmux set-option -u @claude_session_prio 2>/dev/null || true
  exit 0
fi

# At least one pane has Claude state. Map the max priority to a display string.
# 0=idle (Claude open, finished its turn), 1=running, 2=waiting.
# (no pane has Claude -> handled above -> options unset -> blank)
case "$max" in
  2) display="◐ waiting" ;;
  1) display="● running" ;;
  *) display="○ idle" ;;
esac

# Store as session-scoped options. Ignore errors (session may have vanished).
# @claude_session_state drives the status-bar text; @claude_session_prio drives
# the gruvbox pill color (0=idle/gray, 1=running/green, 2=waiting/orange).
tmux set-option -t "$session" @claude_session_state "$display" 2>/dev/null || true
tmux set-option -t "$session" @claude_session_prio "$max" 2>/dev/null || true

exit 0
