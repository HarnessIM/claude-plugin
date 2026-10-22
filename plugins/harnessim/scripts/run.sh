#!/bin/sh
# run.sh <entry> [args...] — start one of the plugin's entrypoints.
#
# Bun, or else Node, runs the prebuilt JavaScript in node/, never src/:
# the published plugin carries no src/, and 0.7.2-0.7.4 ran src/ under Bun,
# so every hook failed on a host with Bun (0.7.5). With neither runtime,
# exit 0 so the hook or monitor is simply skipped (the headers helper prints
# `{}`), after one line on stderr saying why (0.7.2). Prints nothing else of
# its own. Kept as the entry point older installed copies of the plugin
# call; scripts/run.cmd is the same for Windows cmd.exe.
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
name=$1
shift
case "$name" in
  session-start|prompt-submit|post-set-identity|post-tool|watch|channel-server|headers-helper|waiting) ;;
  *) exit 0 ;;
esac
# `waiting clear` (0.9.0) runs on every tool call: with no session
# waiting there is nothing to clear, so no runtime is started at all.
if [ "$name" = waiting ] && [ "$1" = clear ]; then
  dir="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/harnessim-harnessim}/waiting"
  for f in "$dir"/*.json; do [ -e "$f" ] && break; exit 0; done
fi
if [ -n "$HARNESSIM_RUNTIME" ]; then runtime=$HARNESSIM_RUNTIME
elif command -v bun >/dev/null 2>&1; then runtime=bun
elif [ -x "$HOME/.bun/bin/bun" ]; then runtime="$HOME/.bun/bin/bun"
elif command -v node >/dev/null 2>&1; then runtime=node
else
  # headersHelper must still answer JSON, or the MCP connection fails.
  [ "$name" = headers-helper ] && echo '{}'
  echo "HarnessIM plugin: neither bun nor node is on PATH, so $name did not run. Install Node.js or Bun." >&2
  exit 0
fi
exec "$runtime" "$root/node/$name.mjs" "$@"
