#!/usr/bin/env bash
# Claude Code -> tmux activity indicator (per-pane state).
# Reads the hook event from JSON on STDIN, maps it to a display string and a
# numeric priority, stores both as pane-scoped tmux options, then triggers a
# session-level rollup.
#
# Do NOT use `set -e`: tmux calls may fail harmlessly if a pane has closed, and
# we want to keep going / exit 0 regardless.
set -u

# Read the JSON payload from STDIN once (stdin can only be consumed a single
# time), then parse fields out of the captured variable.
payload="$(cat)"
event="$(printf '%s' "$payload" | jq -r '.hook_event_name // empty' 2>/dev/null)"

# If we are not running inside tmux there is nothing to update.
pane="${TMUX_PANE:-}"
[ -z "$pane" ] && exit 0

# Map event -> display string, priority, and window-status-style.
#
# Priorities: 0=idle, 1=running, 2=waiting (higher wins in the rollup).
#
# UserPromptSubmit/PreToolUse/PostToolUse all mean "Claude is actively working".
# PreToolUse/PostToolUse matter because approving a permission prompt does NOT
# fire UserPromptSubmit -- without them a pane that hit a permission prompt
# (-> waiting) would stay stuck on "waiting" for the rest of the turn. The
# tool-lifecycle events flip it back to running once work resumes.
#
# SessionStart sources: startup/resume/clear -> idle (show the pill immediately
# on launch rather than staying blank until the first prompt); compact -> leave
# the pane's current state unchanged (mid-session auto-compaction keeps working).
# SessionEnd is special: it CLEARS this pane's state (unsets the options) so the
# activity pill disappears once Claude exits.
case "$event" in
  SessionEnd)
    # Unset this pane's state (the -u flag unsets; -p = pane scope).
    tmux set-option -pu @claude_state 2>/dev/null || true
    tmux set-option -pu @claude_prio 2>/dev/null || true
    tmux set-option -pu @claude_style 2>/dev/null || true
    # Recompute the rollup so the session reflects any panes still running.
    session="$(tmux display-message -pt "$pane" -F '#{session_name}' 2>/dev/null || true)"
    if [ -n "$session" ]; then
      "$HOME/.claude/hooks/tmux-session-rollup.sh" "$session" 2>/dev/null || true
    fi
    exit 0
    ;;
  UserPromptSubmit|PreToolUse|PostToolUse)
    display="● running"
    prio=1
    style="bg=colour142,fg=colour235"   # green
    ;;
  Stop)
    display="○ idle"
    prio=0
    style="bg=colour241,fg=colour223"   # gray
    ;;
  SessionStart)
    src="$(printf '%s' "$payload" | jq -r '.source // empty' 2>/dev/null)"
    if [ "$src" = "compact" ]; then
      # Mid-session compaction: Claude keeps working after compacting context,
      # so do NOT reset a busy pane to idle. Leave the current state untouched.
      exit 0
    fi
    # startup/resume/clear: show idle immediately, same as Stop.
    display="○ idle"
    prio=0
    style="bg=colour241,fg=colour223"   # gray
    ;;
  Notification)
    # Two kinds of Notification reach us:
    #   - permission/action requests ("Claude needs your permission to use ..."):
    #     Claude genuinely needs the user -> waiting (prio 2, orange).
    #   - idle-input reminders ("Claude is waiting for your input"): the turn has
    #     already ended (Stop fired earlier) and Claude wants nothing -> treat as
    #     idle so a walked-away session does NOT masquerade as needing action.
    msg="$(printf '%s' "$payload" | jq -r '.message // empty' 2>/dev/null)"
    case "$msg" in
      *"waiting for your input"*)
        display="○ idle"
        prio=0
        style="bg=colour241,fg=colour223"   # gray
        ;;
      *)
        display="◐ waiting"
        prio=2
        style="bg=colour208,fg=colour235"   # orange
        ;;
    esac
    ;;
  *)
    # Unknown event: nothing to do.
    exit 0
    ;;
esac

# Short-circuit if the pane is already in this priority. PreToolUse/PostToolUse
# fire on EVERY tool call, so without this the common "already running" case
# would needlessly rewrite options and recompute the rollup on every tool. It
# also avoids re-raising a banner when a second Notification repeats "waiting".
cur_prio="$(tmux show-options -pqv @claude_prio 2>/dev/null || true)"
if [ "$cur_prio" = "$prio" ]; then
  exit 0
fi

# Store pane-scoped state. Ignore errors (pane may have vanished).
tmux set-option -pt "$pane" @claude_state "$display" 2>/dev/null || true
tmux set-option -pt "$pane" @claude_prio "$prio" 2>/dev/null || true
tmux set-option -pt "$pane" @claude_style "$style" 2>/dev/null || true

# Resolve this pane's session and recompute the session-level rollup.
session="$(tmux display-message -pt "$pane" -F '#{session_name}' 2>/dev/null || true)"
if [ -n "$session" ]; then
  "$HOME/.claude/hooks/tmux-session-rollup.sh" "$session" 2>/dev/null || true
fi

# On the waiting (Notification) event only, ask the focus-aware notifier whether
# to raise a macOS banner. It self-gates and is best-effort (never blocks).
if [ "$event" = "Notification" ] && [ "$prio" = "2" ] && [ -n "$session" ]; then
  "$HOME/.claude/hooks/tmux-notify.sh" "$pane" "$session" 2>/dev/null || true
fi

exit 0
