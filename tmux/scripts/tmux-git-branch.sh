#!/usr/bin/env bash
set -u

pane_path="$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)"

if [ -n "$pane_path" ]; then
	branch="$(git -C "$pane_path" rev-parse --abbrev-ref HEAD 2>/dev/null)"
fi

if [ -n "${branch:-}" ]; then
	printf '#[fg=colour245]› #[fg=colour109]%s ' "$branch"
fi
