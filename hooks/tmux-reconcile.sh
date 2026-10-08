#!/usr/bin/env bash
# Claude Code -> tmux activity indicator (stale-state reconciler).
#
# The per-pane state is otherwise driven purely by hook events. If a pane is
# killed, its terminal closed, or Claude crashes, no Stop/SessionEnd fires and
# the pane stays stuck on its last state (typically "● running") forever.
#
# This reconciler is meant to run on the tmux status-interval. For every pane
# that currently carries Claude state, it checks whether a live `claude` process
# exists anywhere in that pane's process tree. If none does, the pane's state is
# unset and the affected sessions' rollups are recomputed. It only ever CLEARS
# state -- live panes are left untouched for the event hooks to manage.
#
# Prints nothing (it is embedded in a tmux status format). No `set -e`: tmux/ps
# calls may fail harmlessly if a pane/process has vanished mid-run.
set -u

# Panes that currently carry Claude state, as "<pane_id> <pane_pid>" lines.
# The format emits an empty line for panes with no @claude_prio, filtered below.
panes="$(tmux list-panes -a -F '#{?@claude_prio,#{pane_id} #{pane_pid},}' 2>/dev/null | grep .)"
[ -z "$panes" ] && exit 0

# Single process snapshot: "<pid> <ppid> <command...>". Detection keys on the
# command's argv[0] basename being exactly "claude" -- this matches the real
# `claude` binary while ignoring incidental matches such as `vim ~/.claude/...`
# (argv[0] there is "vim"). The dead pane ids are printed by awk.
dead="$(ps -axo pid=,ppid=,command= 2>/dev/null | awk '
  # First file: the ps snapshot. Build a ppid->children map and the claude set.
  FNR==NR {
    pid=$1; ppid=$2
    n=split($3, a, "/"); base=a[n]
    children[ppid]=children[ppid] " " pid
    if (base=="claude") isclaude[pid]=1
    next
  }
  # Second file: panes carrying state. Walk each pane subtree for a claude proc.
  {
    paneid=$1; root=$2
    alive=0; sp=0; stack[sp++]=root
    while (sp>0) {
      cur=stack[--sp]
      if (isclaude[cur]) { alive=1; break }
      m=split(children[cur], kids, " ")
      for (i=1; i<=m; i++) if (kids[i] != "") stack[sp++]=kids[i]
    }
    if (!alive) print paneid
  }
' /dev/stdin <(printf '%s\n' "$panes"))"

[ -z "$dead" ] && exit 0

# Clear each dead pane and remember its session for a single rollup pass.
sessions=""
for pid in $dead; do
  tmux set-option -p -t "$pid" -u @claude_state 2>/dev/null || true
  tmux set-option -p -t "$pid" -u @claude_prio 2>/dev/null || true
  tmux set-option -p -t "$pid" -u @claude_style 2>/dev/null || true
  s="$(tmux display-message -pt "$pid" -F '#{session_name}' 2>/dev/null || true)"
  [ -z "$s" ] && continue
  case " $sessions " in
    *" $s "*) ;;
    *) sessions="$sessions $s" ;;
  esac
done

for s in $sessions; do
  "$HOME/.claude/hooks/tmux-session-rollup.sh" "$s" 2>/dev/null || true
done

exit 0
