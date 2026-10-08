#!/usr/bin/env bash
# Shared detector for "dev server" panes: `overmind` (vendor_risk) and `make`
# (n8n's `make run`).
#
# Unlike nvim, these do NOT reliably show up in `#{pane_current_command}` with
# enough detail — `make build run` reports simply as `make`, and we want the
# argv so the picker can show what's actually running. So we take ONE `ps`
# snapshot of the whole process table and match it against each pane's tty,
# picking the pane's foreground process (stat contains `+`).
#
# One ps call total, not one per pane, so this is cheap enough to run on every
# 5s status-interval.
#
# Output: one TAB-delimited line per matching pane
#   <pane_id>\t<session>\t<window_index>\t<pane_index>\t<kind>\t<cmdline>\t<pane_path>
# where <kind> is `overmind` or `make`.
set -u

# --- process snapshot --------------------------------------------------------
# Reduce the process table to "<tty>\t<kind>\t<argv>" for foreground overmind /
# make processes only. Keep the FIRST match per tty (the outermost process, e.g.
# `make build run` rather than anything it spawned).
snapshot() {
	ps -ax -o tty=,stat=,command= 2>/dev/null | awk '
		{
			tty = $1; stat = $2
			if (tty == "??" || tty == "-") next
			if (stat !~ /\+/) next            # foreground processes only

			# Rebuild argv (fields 3..NF) and take the basename of argv[0].
			argv = ""
			for (i = 3; i <= NF; i++) argv = argv (i > 3 ? " " : "") $i
			base = $3
			sub(/.*\//, "", base)

			if (base != "overmind" && base != "make") next
			if (seen[tty]++) next

			# Normalise argv[0] to its basename so long toolchain paths
			# (/Library/Developer/.../make) do not blow out the display.
			rest = argv
			sub(/^[^ ]+/, "", rest)
			printf "%s\t%s\t%s%s\n", tty, base, base, rest
		}'
}

main() {
	local snap panes
	snap="$(snapshot)"
	[ -z "$snap" ] && return 0

	panes="$(tmux list-panes -a \
		-F '#{pane_id}	#{session_name}	#{window_index}	#{pane_index}	#{pane_tty}	#{pane_current_path}' \
		2>/dev/null)" || return 0
	[ -z "$panes" ] && return 0

	local pid sess widx pidx tty pane_path short hit kind cmdline
	while IFS=$'\t' read -r pid sess widx pidx tty pane_path; do
		[ -z "$pid" ] && continue
		short="${tty#/dev/}"
		hit="$(printf '%s\n' "$snap" | awk -F'\t' -v t="$short" '$1 == t { print; exit }')"
		[ -z "$hit" ] && continue
		kind="$(printf '%s' "$hit" | cut -f2)"
		cmdline="$(printf '%s' "$hit" | cut -f3)"
		sess="$(printf '%s' "$sess" | LC_ALL=C tr -d '\000-\037\177')"
		printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
			"$pid" "$sess" "$widx" "$pidx" "$kind" "$cmdline" "$pane_path"
	done <<EOF
$panes
EOF
}

main "$@"
