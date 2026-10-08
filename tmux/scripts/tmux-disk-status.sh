#!/usr/bin/env bash
# Root-volume free-space indicator for the tmux status bar.
#
# On macOS `df /` is misleading: the boot volume is a sealed read-only snapshot
# whose "Capacity" column (~30%) describes the system files only, while the real
# data lives on /System/Volumes/Data. Both are APFS volumes sharing one
# container, so we read the Data volume when it exists and derive the
# percentage from available/total blocks rather than trusting Capacity.
set -u

vol=/System/Volumes/Data
[ -d "$vol" ] || vol=/

read -r total avail <<EOF2
$(df -Pk "$vol" 2>/dev/null | awk 'NR==2 { print $2, $4 }')
EOF2

[ -n "${total:-}" ] && [ "${total:-0}" -gt 0 ] || exit 0

free_pct=$(( avail * 100 / total ))

# Coloured on used%: under 80% used is green, 80-90% orange, over 90% red —
# i.e. more than 20% free, 10-20% free, and under 10% free respectively.
if [ "$free_pct" -gt 20 ]; then
	color=colour142
elif [ "$free_pct" -ge 10 ]; then
	color=colour208
else
	color=colour196
fi

# Free space in GiB, rounded, for context alongside the percentage.
free_gb=$(( (avail + 524288) / 1048576 ))

printf ' #[fg=%s]󰋊 %sG (%s%%)#[default] ' "$color" "$free_gb" "$free_pct"

exit 0
