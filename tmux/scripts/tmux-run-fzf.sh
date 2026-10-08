#!/usr/bin/env bash
# dev-server -> tmux fzf popup picker.
#
# Lists every pane anywhere on the server running a dev server — `overmind`
# (vendor_risk) or `make` (n8n's `make run`) — as detected LIVE by
# tmux-run-detect.sh, and lets the user fuzzy-pick one to jump to. Intended to
# be launched from a tmux `display-popup -E` so the popup closes on exit.
#
# Glyph/color convention matches the run status indicator:
#   overmind -> gruvbox yellow colour214  ▶
#   make     -> gruvbox aqua   colour108  ▶
#
# Mirrors tmux-nvim-fzf.sh: raw 256-color ANSI escapes rendered by `fzf --ansi`,
# pane_id hidden from display via --with-nth but kept in the returned line.
set -u

FZF="/opt/homebrew/bin/fzf"
DETECT="/Users/nigel.slack-smith/.config/tmux/scripts/tmux-run-detect.sh"

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
C_OVERMIND="${ESC}[38;5;214m" # gruvbox yellow
C_MAKE="${ESC}[38;5;108m"     # gruvbox aqua
C_CMD="${ESC}[38;5;245m"      # gray

build_lines() {
	local raw sorted
	raw="$("$DETECT" 2>/dev/null)" || return 0
	[ -z "$raw" ] && return 0
	sorted="$(printf '%s\n' "$raw" | LC_ALL=C sort -t$'\t' -k2,2 -k3,3n -k4,4n)"

	# Pass 1: collect fields and find max label width.
	local -a pids=() labels=() kinds=() cmds=()
	local max_label=0
	local pid sess widx pidx kind cmdline pane_path label
	while IFS=$'\t' read -r pid sess widx pidx kind cmdline pane_path; do
		[ -z "$pid" ] && continue
		is_excluded "$pid" && continue
		label="$sess:$widx.$pidx"
		pids+=("$pid")
		labels+=("$label")
		kinds+=("$kind")
		cmds+=("$cmdline")
		((${#label} > max_label)) && max_label=${#label}
	done <<EOF
$sorted
EOF

	# Pass 2: emit padded, colored lines.
	local i color
	for ((i = 0; i < ${#pids[@]}; i++)); do
		if [ "${kinds[$i]}" = "overmind" ]; then color="$C_OVERMIND"; else color="$C_MAKE"; fi
		printf '%s\t%s▶%s %-*s  %s%s%s\n' \
			"${pids[$i]}" \
			"$color" "$RESET" \
			"$max_label" "${labels[$i]}" \
			"$C_CMD" "${cmds[$i]}" "$RESET"
	done
}

# --- jump --------------------------------------------------------------------
jump_to() {
	local p="$1" sess
	[ -z "$p" ] && return 0
	sess="$(tmux display -t "$p" -p '#{session_name}' 2>/dev/null)" || return 0
	[ -z "$sess" ] && return 0
	tmux select-pane -t "$p" 2>/dev/null
	tmux select-window -t "$p" 2>/dev/null
	tmux switch-client -t "$sess" 2>/dev/null
}

main() {
	local lines
	lines="$(build_lines)"

	if [ -z "$lines" ]; then
		tmux display-message 'No other dev server panes' 2>/dev/null
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
		--prompt='run ▸ ' \
		--header='enter jump · esc cancel')"

	[ -z "$sel" ] && exit 0

	local pid
	pid="$(printf '%s' "$sel" | cut -f1)"
	jump_to "$pid"
}

main "$@"
