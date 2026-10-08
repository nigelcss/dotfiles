#!/usr/bin/env bash
# Claude Code -> tmux fzf popup picker.
#
# Lists every pane anywhere on the server that has Claude state (pane-scoped
# @claude_prio set: 0=idle, 1=running, 2=waiting; unset = not a Claude pane) and
# lets the user fuzzy-pick one to jump to. Intended to be launched from a tmux
# `display-popup -E` so the popup closes when this script exits.
#
# Glyph/color convention matches the rest of the Claude tmux integration:
#   idle    -> gray   colour245  ○
#   running -> green  colour142  ●
#   waiting -> orange colour208  ◐
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
C_IDLE="${ESC}[38;5;245m"     # gray
C_RUN="${ESC}[38;5;142m"      # green
C_WAIT="${ESC}[38;5;208m"     # orange
C_BRANCH="${ESC}[38;5;109m"   # gruvbox blue

# Color (256-color ANSI) for a given @claude_prio value.
prio_color() {
  case "$1" in
    2) printf '%s' "$C_WAIT" ;;
    1) printf '%s' "$C_RUN" ;;
    *) printf '%s' "$C_IDLE" ;;
  esac
}

# Bare glyph for a given @claude_prio value.
prio_char() {
  case "$1" in
    2) printf '◐' ;;
    1) printf '●' ;;
    *) printf '○' ;;
  esac
}

# Status word for a given @claude_prio value.
prio_word() {
  case "$1" in
    2) printf 'waiting' ;;
    1) printf 'running' ;;
    *) printf 'idle' ;;
  esac
}

# --- build fzf input ---------------------------------------------------------
# Emit one TAB-delimited line per Claude pane:
#   <pane_id>\t<colored glyph> <session>:<window_index>.<pane_index>  <status_word>
# Field 1 (pane_id) is hidden from fzf display via --with-nth=2.. but stays in
# the returned line so the caller can cut -f1 it back out.
#
# Deterministic ordering: sort by session_name, window_index, pane_index so the
# list is stable across invocations.
build_lines() {
  local raw
  raw="$(tmux list-panes -a \
      -f '#{!=:#{@claude_prio},}' \
      -F '#{pane_id}	#{session_name}	#{window_index}	#{pane_index}	#{@claude_prio}	#{pane_current_path}' \
      2>/dev/null)" || return 0
  [ -z "$raw" ] && return 0

  local sorted
  sorted="$(printf '%s\n' "$raw" | LC_ALL=C sort -t$'\t' -k5,5rn -k2,2 -k3,3n -k4,4n)"

  # Pass 1: collect fields and find max column widths.
  local -a pids=() labels=() prios=() branches=()
  local max_label=0 max_word=0
  local pid sess widx pidx prio pane_path branch label word
  while IFS=$'\t' read -r pid sess widx pidx prio pane_path; do
    [ -z "$pid" ] && continue
    is_excluded "$pid" && continue
    sess="$(printf '%s' "$sess" | LC_ALL=C tr -d '\000-\037\177')"
    label="$sess:$widx.$pidx"
    branch="$(git -C "$pane_path" branch --show-current 2>/dev/null)"
    word="$(prio_word "$prio")"
    pids+=("$pid")
    labels+=("$label")
    prios+=("$prio")
    branches+=("$branch")
    (( ${#label} > max_label )) && max_label=${#label}
    (( ${#word} > max_word ))   && max_word=${#word}
  done <<EOF
$sorted
EOF

  # Pass 2: emit padded, colored lines.
  local i color glyph
  for (( i=0; i<${#pids[@]}; i++ )); do
    color="$(prio_color "${prios[$i]}")"
    glyph="$(prio_char "${prios[$i]}")"
    word="$(prio_word "${prios[$i]}")"
    printf '%s\t%s%s%s %-*s  %s%-*s%s%s\n' \
      "${pids[$i]}" \
      "$color" "$glyph" "$RESET" \
      "$max_label" "${labels[$i]}" \
      "$color" "$max_word" "$word" "$RESET" \
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
    tmux display-message 'No other active Claude panes' 2>/dev/null
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
      --prompt='claude ▸ ' \
      --header='enter jump · esc cancel')"

  [ -z "$sel" ] && exit 0

  local pid
  pid="$(printf '%s' "$sel" | cut -f1)"
  jump_to "$pid"
}

main "$@"
