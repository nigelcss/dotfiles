#!/usr/bin/env bash
# Focus-aware macOS notification for the Claude -> tmux "Notification" (waiting)
# event. Called as: tmux-notify.sh "$pane" "$session"
#
# Goal: grab attention ONLY when I'm NOT already looking at the pane that needs
# input. Decision matrix:
#   - terminal NOT frontmost (I'm in another app)        -> NOTIFY
#   - terminal frontmost  AND pane is on-screen          -> SUPPRESS
#   - terminal frontmost  AND pane is a bg tmux session  -> NOTIFY
#
# DRY-RUN: if $TMUX_NOTIFY_DRYRUN is non-empty, print the decision + title/body
# to stdout instead of firing a real banner (used by the test harness).
#
# Do NOT use `set -e`: every external call (lsappinfo, tmux, osascript) is
# guarded and we always exit 0 — a failure to notify must never break the hook.
set -u

# --- Terminal identity -------------------------------------------------------
# The macOS terminal app hosting tmux. Bundle id is matched first (most stable);
# display name is the fallback. Change these two constants to retarget another
# terminal (e.g. iTerm: com.googlecode.iterm2 / "iTerm2").
TERMINAL_BUNDLE_ID="com.mitchellh.ghostty"
TERMINAL_NAME="Ghostty"

pane="${1:-}"
session="${2:-}"

# --- Helpers -----------------------------------------------------------------
# lsappinfo emits values wrapped like  "LSDisplayName"="Ghostty"  — strip the
# `"key"="value"` wrapper down to the bare value. Returns empty on no match.
unwrap_lsappinfo() {
  # Input: a full lsappinfo line; Output: the inner value with quotes removed.
  printf '%s' "$1" | sed -n 's/^"[^"]*"="\(.*\)"$/\1/p'
}

# --- Determine the frontmost app --------------------------------------------
front_asn="$(lsappinfo front 2>/dev/null)"
front_name=""
front_bundle=""
if [ -n "$front_asn" ]; then
  front_name="$(unwrap_lsappinfo "$(lsappinfo info -only name "$front_asn" 2>/dev/null)")"
  front_bundle="$(unwrap_lsappinfo "$(lsappinfo info -only bundleID "$front_asn" 2>/dev/null)")"
fi

# Is the hosting terminal the frontmost app? Prefer bundle id, fall back to name.
terminal_frontmost=0
if [ -n "$front_bundle" ] && [ "$front_bundle" = "$TERMINAL_BUNDLE_ID" ]; then
  terminal_frontmost=1
elif [ -n "$front_name" ] && [ "$front_name" = "$TERMINAL_NAME" ]; then
  terminal_frontmost=1
fi

# --- Determine whether the triggering pane is on-screen ----------------------
# On-screen = its session is attached AND its window is active AND its pane is
# active. A detached/background session, or a non-active window/pane, is OFF.
pane_onscreen=0
if [ -n "$pane" ]; then
  flags="$(tmux display-message -t "$pane" -p '#{session_attached} #{window_active} #{pane_active}' 2>/dev/null)"
  # shellcheck disable=SC2086
  set -- $flags
  s_attached="${1:-0}"
  w_active="${2:-0}"
  p_active="${3:-0}"
  if [ "${s_attached:-0}" -gt 0 ] 2>/dev/null && [ "$w_active" = "1" ] && [ "$p_active" = "1" ]; then
    pane_onscreen=1
  fi
fi

# --- Decision ----------------------------------------------------------------
decision="notify"
if [ "$terminal_frontmost" = "1" ] && [ "$pane_onscreen" = "1" ]; then
  # I'm looking right at the pane that wants input — don't bother me.
  decision="suppress"
fi

title="Claude · ${session}"
body="Needs your input"

# --- Act ---------------------------------------------------------------------
if [ -n "${TMUX_NOTIFY_DRYRUN:-}" ]; then
  printf 'DECISION=%s\n' "$decision"
  printf 'TITLE=%s\n' "$title"
  printf 'BODY=%s\n' "$body"
  exit 0
fi

if [ "$decision" = "suppress" ]; then
  exit 0
fi

# Fire the banner. Dynamic strings are passed as ARGV (never interpolated into
# the AppleScript body) to defeat AppleScript injection via the session name.
osascript - "$title" "$body" <<'APPLESCRIPT' 2>/dev/null || true
on run argv
  display notification (item 2 of argv) with title (item 1 of argv)
end run
APPLESCRIPT

exit 0
