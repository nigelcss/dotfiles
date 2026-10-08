#!/usr/bin/env bash
set -u

for sess in $(tmux list-sessions -F '#{session_name}' 2>/dev/null); do
  pane_path="$(tmux display -t "$sess" -p '#{pane_current_path}' 2>/dev/null)" || continue
  repo=""
  if [ -n "$pane_path" ]; then
    repo="$(git -C "$pane_path" branch --show-current 2>/dev/null)"
  fi
  tmux set -t "$sess" @git_repo "$repo" 2>/dev/null
done

tmux choose-tree -s -O name -F \
  "#{?session_format,#{?session_attached,(attached)  ,}#{?#{!=:#{@git_repo},},#[fg=colour109] #{@git_repo}#[default]  ,}#{?#{!=:#{@claude_session_state},},#{?#{==:#{@claude_session_prio},2},#[fg=colour208],#{?#{==:#{@claude_session_prio},1},#[fg=colour142],#[fg=colour245]}}#{@claude_session_state}#[default]  ,}#{?#{!=:#{@run_session},},#[fg=colour214]▶ #{@run_session}#[default]  ,}#{?#{!=:#{@nvim_session},},#[fg=colour109]✎ nvim#[default],},#{?window_format,#{window_index}: #{window_name}#{window_flags},#{pane_current_command}}}"
