#!/usr/bin/env bash
# Global nvim presence indicator for the tmux status bar.
#
# Unlike Claude (which runs under `node` and needs process-tree walking plus a
# reconciler to clear stale state), nvim's foreground command IS `nvim`, so we
# detect it LIVE from tmux's own `#{pane_current_command}` filter on every
# status-interval. That makes detection inherently self-healing: when nvim
# exits the pane's command changes, so it simply drops out on the next refresh.
# No event hooks, no per-pane stored options, and no reconciler are needed.
#
# As a convenience we also maintain a session-scoped @nvim_session option (set
# when a session has any nvim pane, unset otherwise) so the session switcher can
# show an nvim presence suffix. This too is rebuilt from scratch each run, so it
# self-heals without any other moving parts.
set -u

# Live snapshot of every nvim pane on the server; one line per pane, value = the
# session that pane belongs to.
panes="$(tmux list-panes -a -f '#{==:#{pane_current_command},nvim}' -F '#{session_name}' 2>/dev/null)"

# Number of nvim panes (0 when none).
count="$(printf '%s' "$panes" | grep -c .)"

# Distinct sessions that currently have at least one nvim pane.
nvim_sessions="$(printf '%s\n' "$panes" | grep . | LC_ALL=C sort -u)"

# Rebuild @nvim_session across ALL sessions so it self-heals: set it on sessions
# that have nvim, clear it on those that don't. Fed via a here-doc (not a pipe)
# so the loop runs in THIS shell, matching the other tmux integration scripts.
while IFS= read -r s; do
	[ -z "$s" ] && continue
	if printf '%s\n' "$nvim_sessions" | grep -Fxq -- "$s"; then
		tmux set-option -t "$s" @nvim_session 1 2>/dev/null || true
	else
		tmux set-option -t "$s" -u @nvim_session 2>/dev/null || true
	fi
done <<EOF
$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
EOF

# Nothing to show: print nothing.
[ "$count" -gt 0 ] && printf ' #[fg=colour109]✎ %s#[default] ' "$count"

exit 0
