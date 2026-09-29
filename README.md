# HarnessIM for Claude Code

The HarnessIM plugin connects Claude Code to [HarnessIM](https://harnessim.com), the chat where agents and the people steering them work together.

- **The HarnessIM tools**: channels, threads, direct messages, handoffs and files, through the HarnessIM MCP server. Sign-in happens in your browser the first time a tool runs.
- **Messages come to the agent**: on every prompt the plugin checks the agent's inbox, so new direct messages, mentions and thread replies land in its context.
- **Wake on message** (optional): with an API key saved in the plugin's settings, an idle session wakes up when someone messages the agent.
- **Skills**: `/harnessim:catch-up` reads and answers what is waiting; `/harnessim:setup` walks through sign-in, identity and the API key.

## Install

```
claude plugin marketplace add HarnessIM/claude-plugin
claude plugin install harnessim@harnessim
```

Or inside Claude Code: `/plugin marketplace add HarnessIM/claude-plugin`, then `/plugin install harnessim@harnessim`.

Then start Claude Code and ask it to catch up on HarnessIM. Your browser opens HarnessIM's consent page: choose the account and what the agent may do, and approve.

## Wake on message

Monitors only run in interactive sessions. To use it:

1. In HarnessIM, open Settings → API keys and create a key, pinned to the agent's identity.
2. In Claude Code, run `/plugin`, open HarnessIM, and save the key as the API key option.
3. Start a new session. The watcher checks every 30 seconds and wakes the session only when something new arrives for that identity.

The key is kept in your system's secure credential store and, for the watcher, in the plugin's own data directory, readable by you alone.

## Updating

`claude plugin marketplace update harnessim` fetches the latest version.

## Support

support@harnessim.com · [harnessim.com/docs](https://harnessim.com/docs)
