#!/usr/bin/env bash
# Jump to the next Claude Code or nvim pane in the CURRENT session.
#
# Designed to be bound to a root-table key so a single keystroke toggles
# between a Claude Code pane and an nvim pane. Scope is the current session
# only: invoked via `run-shell`, tmux's implied target is the active pane, so
# `list-panes -s` (no -t) lists every pane in every window of that session.
#
# Detection reuses the two conventions already established in this repo:
#   nvim   pane -> `#{pane_current_command}` is `nvim` (live, self-healing —
#                  same detection as tmux-nvim-status.sh / tmux-nvim-fzf.sh)
#   Claude pane -> pane-scoped @claude_prio is non-empty (set by
#                  ~/.claude/hooks/tmux-status.sh, cleared by the reconciler
#                  when the process dies — same as tmux-claude-fzf.sh)
#
# Ordering is "left to right": window_index, then pane_left, then pane_top as
# a tiebreaker for stacked panes. We locate the ACTIVE pane in that full
# ordered list and jump to the first matching pane strictly after it,
# wrapping around to the first match if none follows.
#
# No `set -e`: tmux calls may fail harmlessly if a pane/window has vanished
# (or we are run outside tmux) and we want to exit quietly regardless. `set -u`
# to catch unset-var mistakes.
set -u

main() {
  # No tmux -f filter: the active pane must remain in the ordered list even when it is not a match.
  local raw
  raw="$(tmux list-panes -s \
      -F '#{pane_id}	#{window_index}	#{pane_left}	#{pane_top}	#{&&:#{pane_active},#{window_active}}	#{pane_current_command}	#{@claude_prio}' \
      2>/dev/null)" || exit 0
  [ -z "$raw" ] && exit 0

  local sorted
  sorted="$(printf '%s\n' "$raw" | LC_ALL=C sort -t$'\t' -k2,2n -k3,3n -k4,4n)"

  # Here-doc (not a pipe) keeps the loop in the current shell so the match variables survive it.
  local pid widx pleft ptop active cmd prio
  local first_match='' next_match='' seen_active=0
  while IFS=$'\t' read -r pid widx pleft ptop active cmd prio; do
    [ -z "$pid" ] && continue
    [ "$active" = "1" ] && seen_active=1
    if [ "$cmd" = "nvim" ] || [ -n "$prio" ]; then
      [ -z "$first_match" ] && first_match="$pid"
      if [ "$active" != "1" ] && [ "$seen_active" = "1" ] && [ -z "$next_match" ]; then
        next_match="$pid"
      fi
    fi
  done <<EOF
$sorted
EOF

  if [ -z "$first_match" ]; then
    tmux display-message 'No Claude/nvim panes' 2>/dev/null
    exit 0
  fi

  local target="${next_match:-$first_match}"
  tmux select-window -t "$target" 2>/dev/null
  tmux select-pane   -t "$target" 2>/dev/null
}

main "$@"
