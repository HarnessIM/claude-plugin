#!/bin/sh
# SessionStart: hand the optional API key to the inbox watcher.
#
# Monitors receive no plugin options, so the key the user saved in the
# plugin's settings (CLAUDE_PLUGIN_OPTION_API_KEY, exported to hooks only)
# is written to the plugin's data directory, readable by this user alone.
# Nothing is printed: a SessionStart hook's stdout becomes context.
data=${1:?data directory}
mkdir -p "$data"
key=${CLAUDE_PLUGIN_OPTION_API_KEY:-}
if [ -n "$key" ]; then
  umask 077
  printf '%s' "$key" > "$data/api-key.tmp" && mv "$data/api-key.tmp" "$data/api-key"
else
  rm -f "$data/api-key"
fi
exit 0
