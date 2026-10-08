#!/usr/bin/env bash
# nvim -> tmux fzf popup picker.
#
# Lists every pane anywhere on the server whose foreground command is `nvim`
# (detected LIVE via tmux's `#{pane_current_command}` filter, so it is always
# accurate without any stored state) and lets the user fuzzy-pick one to jump
# to. Intended to be launched from a tmux `display-popup -E` so the popup closes
# when this script exits.
#
# Glyph/color convention matches the nvim status indicator:
#   nvim -> gruvbox blue colour109  ✎
# We emit raw 256-color ANSI escapes (this is a normal program, NOT a tmux
# format string) and rely on `fzf --ansi` to render them.
#
# No `set -e`: tmux calls may fail harmlessly if a pane/window has vanished and
# we want to keep going regardless. `set -u` to catch unset-var mistakes.
set -u

FZF="/opt/homebrew/bin/fzf"

# $1: window id (e.g. `@7`) to exclude from the list — the window this was
# invoked from, so we never offer a jump to where we already are. The tmux.conf
# binding supplies it; it cannot be worked out from in here (inside a popup
# TMUX_PANE is unset and `display-message -p` resolves to an arbitrary client's
# window). Absent, nothing is excluded.
EXCLUDE_WINDOW="${1:-}"

# Pane ids of the excluded window, wrapped in spaces so `%1` never matches `%12`.
excluded_panes=' '
if [ -n "$EXCLUDE_WINDOW" ]; then
  excluded_panes=" $(tmux list-panes -t "$EXCLUDE_WINDOW" -F '#{pane_id}' 2>/dev/null | tr '\n' ' ')"
fi

# True if pane $1 lives in the excluded window.
is_excluded() {
  case "$excluded_panes" in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

# --- ANSI helpers ----------------------------------------------------------
ESC=$'\033'
RESET="${ESC}[0m"
C_NVIM="${ESC}[38;5;109m"      # gruvbox blue
C_BRANCH="${ESC}[38;5;245m"    # gray

# --- build fzf input ---------------------------------------------------------
# Emit one TAB-delimited line per nvim pane:
#   <pane_id>\t<colored glyph> <session>:<window_index>.<pane_index>
# Field 1 (pane_id) is hidden from fzf display via --with-nth=2.. but stays in
# the returned line so the caller can cut -f1 it back out.
#
# Deterministic ordering: sort by session_name, window_index, pane_index so the
# list is stable across invocations.
build_lines() {
  local raw
  raw="$(tmux list-panes -a \
      -f '#{==:#{pane_current_command},nvim}' \
      -F '#{pane_id}	#{session_name}	#{window_index}	#{pane_index}	#{pane_current_path}' \
      2>/dev/null)" || return 0
  [ -z "$raw" ] && return 0

  local sorted
  sorted="$(printf '%s\n' "$raw" | LC_ALL=C sort -t$'\t' -k2,2 -k3,3n -k4,4n)"

  # Pass 1: collect fields and find max label width.
  local -a pids=() labels=() branches=()
  local max_label=0
  local pid sess widx pidx pane_path branch label
  while IFS=$'\t' read -r pid sess widx pidx pane_path; do
    [ -z "$pid" ] && continue
    is_excluded "$pid" && continue
    sess="$(printf '%s' "$sess" | LC_ALL=C tr -d '\000-\037\177')"
    label="$sess:$widx.$pidx"
    branch="$(git -C "$pane_path" branch --show-current 2>/dev/null)"
    pids+=("$pid")
    labels+=("$label")
    branches+=("$branch")
    (( ${#label} > max_label )) && max_label=${#label}
  done <<EOF
$sorted
EOF

  # Pass 2: emit padded, colored lines.
  local i
  for (( i=0; i<${#pids[@]}; i++ )); do
    printf '%s\t%s✎%s %-*s%s\n' \
      "${pids[$i]}" \
      "$C_NVIM" "$RESET" \
      "$max_label" "${labels[$i]}" \
      "${branches[$i]:+  ${C_BRANCH} ${branches[$i]}${RESET}}"
  done
}

# --- jump --------------------------------------------------------------------
# Make pane $1 the active pane of its window, that window the current window of
# its session, and point the client at that session.
jump_to() {
  local p="$1" sess
  [ -z "$p" ] && return 0
  sess="$(tmux display -t "$p" -p '#{session_name}' 2>/dev/null)" || return 0
  [ -z "$sess" ] && return 0
  tmux select-pane   -t "$p"    2>/dev/null
  tmux select-window -t "$p"    2>/dev/null
  tmux switch-client -t "$sess" 2>/dev/null
}

# --- main --------------------------------------------------------------------
main() {
  local lines
  lines="$(build_lines)"

  if [ -z "$lines" ]; then
    tmux display-message 'No other nvim panes' 2>/dev/null
    exit 0
  fi

  local sel
  sel="$(printf '%s\n' "$lines" | "$FZF" \
      --ansi \
      --no-multi \
      --reverse \
      --cycle \
      --delimiter='\t' \
      --with-nth=2.. \
      --prompt='nvim ▸ ' \
      --header='enter jump · esc cancel')"

  [ -z "$sel" ] && exit 0

  local pid
  pid="$(printf '%s' "$sel" | cut -f1)"
  jump_to "$pid"
}

main "$@"
