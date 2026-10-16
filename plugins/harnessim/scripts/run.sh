#!/bin/sh
# run.sh <entry> [args...] — start one of the plugin's entrypoints.
#
# Runs the prebuilt JavaScript in node/ with Bun or Node; with neither,
# exit 0 silently so the hook or monitor is simply skipped (the headers
# helper prints `{}`). Never prints anything else of its own.
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
name=$1
shift
case "$name" in
  session-start|prompt-submit|post-set-identity|post-tool|watch|channel-server|headers-helper) ;;
  *) exit 0 ;;
esac
if [ -n "$HARNESSIM_RUNTIME" ]; then runtime=$HARNESSIM_RUNTIME
elif command -v bun >/dev/null 2>&1; then runtime=bun
elif [ -x "$HOME/.bun/bin/bun" ]; then runtime="$HOME/.bun/bin/bun"
elif command -v node >/dev/null 2>&1; then runtime=node
else
  # headersHelper must still answer JSON, or the MCP connection fails.
  [ "$name" = headers-helper ] && echo '{}'
  exit 0
fi
exec "$runtime" "$root/node/$name.mjs" "$@"
