#!/bin/sh
# The inbox watcher: a plugin monitor, so every line it prints wakes the
# Claude Code session with that line.
#
# It asks HarnessIM for the key's identity's unread notifications without
# marking them read (the agent does that when it calls check_notifications
# itself), and prints one line whenever the answer changes. It needs the
# optional API key from the plugin's settings; without one it waits quietly.
data=${1:?data directory}
api=${HARNESSIM_API:-https://api.harnessim.com}
interval=${HARNESSIM_WATCH_SECONDS:-30}
session=""
last=""
id=0

rpc() { # method, params -> response body; the session id lands in $data/.headers
  id=$((id + 1))
  curl -sS --max-time 30 -D "$data/.headers" \
    -H "Authorization: Bearer $key" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    ${session:+-H "Mcp-Session-Id: $session"} \
    --data "{\"jsonrpc\":\"2.0\",\"id\":$id,\"method\":\"$1\",\"params\":$2}" \
    "$api/mcp"
}

status() { sed -n '1s/^HTTP[^ ]* \([0-9]*\).*/\1/p' "$data/.headers"; }

open_session() {
  session=""
  rpc initialize '{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"harnessim-plugin-watch","version":"0.1.0"}}' >/dev/null || return 1
  [ "$(status)" = 200 ] || return 1
  session=$(tr -d '\r' < "$data/.headers" | sed -n 's/^[Mm]cp-[Ss]ession-[Ii]d: *//p' | head -1)
  [ -n "$session" ] || return 1
  rpc notifications/initialized '{}' >/dev/null 2>&1
  return 0
}

while :; do
  key=$(cat "$data/api-key" 2>/dev/null)
  if [ -z "$key" ]; then session=""; sleep 60; continue; fi
  if [ -z "$session" ] && ! open_session; then sleep "$interval"; continue; fi
  body=$(rpc tools/call '{"name":"check_notifications","arguments":{"mark_read":false}}')
  code=$(status)
  if [ "$code" = 404 ] || [ "$code" = 400 ] || [ "$code" = 401 ]; then
    session=""; sleep "$interval"; continue
  fi
  # The tool's text, as one line: the first "text" field, unescaped enough to read.
  text=$(printf '%s' "$body" | sed -n 's/.*"text":"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -1 | sed 's/\\n/ · /g; s/\\"/"/g')
  case "$text" in
    ""|"No unread notifications"*) last="" ;;
    *)
      if [ "$text" != "$last" ]; then
        printf 'HarnessIM: new messages. Call check_notifications and answer them. %s\n' "$(printf '%s' "$text" | cut -c1-600)"
        last=$text
      fi
      ;;
  esac
  sleep "$interval"
done
