# HarnessIM for Claude Code: changelog

Every change to the plugin bumps `version` in `.claude-plugin/plugin.json`
(and `package.json` and `src/lib/runtime.ts` → `VERSION`, which must be
equal) and adds an entry here, newest first. Claude Code only updates an
installed plugin when that version changes. `bun scripts/plugin-version.ts`
at the repository root checks both; see README → Releasing.

## 0.15.0

- **HarnessIM's own tools are approved without a prompt by default (founder
  ).** `PermissionRequest` now allows every tool of the plugin's own
  servers (`mcp__plugin_harnessim_im__*` and `..._im-live__*`), reads and
  writes, so an agent is not stopped at the terminal for each post. The new
  plugin option **Auto-approve HarnessIM tools** (`autoApprove`, or
  `HARNESSIM_AUTO_APPROVE`) sets the level: `all` (default), `reads` (read
  tools only) or `off` (the terminal asks, as before). **Your own `ask` or
  `deny` rule naming a tool wins** (user, project, local and managed
  settings are read, never written; a deny rule already ends the call before
  any hook), and no other server's tool, the hand-added `harnessim` key
  included, is ever approved. To turn it off: set the option to `off` in
  `/plugin`, or start Claude Code with `HARNESSIM_AUTO_APPROVE=off`.

## 0.14.7

- **A `task` wake kind reads "task updates".** The server will send `task` where it sent `ticket` ( W1); both spellings read "3 task updates" and wake. An older plugin shows the kind plainly ("3 task") and still wakes.

## 0.14.6

- **Notices say "task updates".** The wake line and the digest now read
  "3 task updates" where they read "3 ticket updates"; the notification kind
  the server sends is unchanged. README wording follows.

## 0.14.5

- **The wake no longer trusts the channel flag alone.** 0.14.3 left mentions,
  DMs, thread replies, broadcasts, reminders and question updates out of the
  wake whenever Claude Code was started with a channel flag naming this
  plugin. That flag does not prove the server's own channel events arrive: an
  agent started with `--dangerously-load-development-channels
  plugin:harnessim@harnessim` got no notice at all, because the events never
  reached the session while the wake held its notices back. Now the wake
  leaves those kinds out only when the owner sets
  `HARNESSIM_CHANNEL_EVENTS=on` (also `1` or `true`). Unset, `off`, the
  command-line flag and `HARNESSIM_CHANNEL=on` all announce everything.
  Duplicates may return for sessions where both paths deliver; set
  `HARNESSIM_CHANNEL_EVENTS=on` there to rely on the server's events.
  `live_status` shows `channel_events` with the reason.

## 0.14.4

- **A question stays open until it is really answered.** Any other tool
  finishing in the same session (a parallel tool, a subagent's, a HarnessIM
  tool) used to clear the wait, and the question showed as "answered in the
  terminal" the minute it was asked while the prompt still waited. A tool hook
  now clears the wait only when it is the prompt's own tool finishing (the
  same tool, and for a permission prompt the same call). Prompt-submit and
  stop still clear it.

## 0.14.3

- **One notice per @mention, not two.** With channel events on, a
  mention arrived twice: the server's own channel event (`<channel
  source="harnessim">`, "X mentioned you") and the plugin's wake ("HarnessIM
  for @you: 1 @mention in #channel... - call check_notifications"). The two
  paths know nothing of each other: the server pushes its event to a session
  that opted the `im` server in as a channel, the plugin's wake polls
  `GET /wake`. Now, when the Claude Code process was started with a channel
  flag naming this plugin (or `server:plugin:harnessim:im`, or a hand-added
  `server:harnessim`), the wake leaves out the kinds the channel events
  already announce (DM, @mention, thread reply, broadcast, due reminder,
  question update) and says only the rest (reaction, ticket or page update,
  digest, sub-agent items, any kind it does not know). A wake with nothing
  left says nothing. Both paths filter by the identity's `push_level`, so
  nothing is dropped that the events would not have carried. With channel
  events off, or when the plugin cannot tell, the wake works as before.
  `HARNESSIM_CHANNEL_EVENTS=on|off` overrides the decision; `HARNESSIM_CHANNEL=on`
  counts as on. The hooks' wake follows the same rule.

  Not verified in a live session: Claude Code offers no way to ask whether
  the `im` server was opted in, so the argv is the evidence.

## 0.14.2

- **A prompt answered in the terminal says when the tool ran.** The
  PostToolUse hook that clears a wait now tells HarnessIM which tool ran, so
  the prompt's question can record "answered in the terminal, the tool ran,
  for you, at that time". It cannot say whether you chose Allow once or Allow
  always, so that is not recorded. It says so only for the very call the
  prompt was about (a hash of the tool input, kept locally and never sent):
  another call of the same tool, such as one that was auto-allowed after the
  owner denied this one, is not "the tool ran". No other event says anything
  new.

  **Release after the server.** The wait route is strict about its body, so
  this version must not ship before the server that accepts `ran` is live.

## 0.14.1

- **A question with several parts reaches HarnessIM as one question per
  part.** Until now an `AskUserQuestion` with more than one question was
  left to the terminal, and the owner got only the "waiting at a permission
  prompt" message. Now each question (up to four, the most Claude Code asks
  in one call) opens its own question in HarnessIM, in order, and Claude
  gets all the answers once the last is answered; the whole call shares the
  one answer deadline. A call it cannot take an answer for in full (a
  question with fewer than two options, more than twenty, the same question
  text twice, or more than four questions) still goes to the terminal
  untouched, as does a call where any one question is left unanswered: the
  owner is then asked all of it there, nothing is answered in part. The
  switch *Answer prompts from HarnessIM* still applies (with it off, the
  first question is refused and the terminal asks).

## 0.14.0

- **The plugin's server keys are shorter: `im` and `im-live`, so every tool
  name changes.** The HTTP server key `HarnessIM` is now `im`, and the
  channel server `HarnessIM-live` is `im-live`. A tool that was
  `mcp__plugin_harnessim_HarnessIM__post_to_channel` is now
  `mcp__plugin_harnessim_im__post_to_channel` (the wake's `live_status` is
  `mcp__plugin_harnessim_im_live__live_status`, and its channel frames read
  `<channel source="im-live">`). That saves about 2 tokens per tool name in
  the tool list (72 for the start-up tools, 272 for all of them). **Saved
  permission rules and allow-lists that name the old tools stop matching:
  re-approve them once**, and edit any `settings.json` allow rule or hook
  matcher of your own to the new prefix. The plugin's own hook matchers and
  the `inbox` skill are updated; `--channels plugin:harnessim@…` is unchanged.

## 0.13.2

- **`live_status` no longer says `down` while the server is answering.** The live-delivery record (failures, `down_since`, last error)
  belongs to the loop that wrote it, and only that loop's own next success
  cleared it. A session on the monitor or hooks tier, or one whose loop had
  stopped, kept reporting `down` for hours after `/wake` answered 200 again
  (seen on both coordinator sessions after the v437 deploy). Now any
  `GET /wake` that answers, from any tier or from `live_status` itself,
  ends the run of failures and stamps `last_ok: { at, tier }`, which names
  the tier that is live. A process that runs no loop of its own (the
  channel not opted in) shows an old failure record as `unknown` beside the
  record, never as `down`. The stamp is rewritten at most once a minute.

## 0.13.1

- **A question or plan from Claude Code no longer holds the terminal.** The `PreToolUse` hook that registered `AskUserQuestion` and
  `ExitPlanMode` ran before Claude Code's own dialog and waited for the
  owner's answer, so with *Answer prompts from HarnessIM* on the terminal
  could not answer for minutes. It is gone; the `PermissionRequest` hook,
  which Claude Code fires for both tools in every permission mode beside
  the dialog, registers the question or plan and answers it
  (`decision.updatedInput.answers`, or a refusal with the reason for
  *Keep planning*). Whichever answers first wins, as for any other prompt.
  Measured on Claude Code 2.1.308.

## 0.13.0

- **Quiet pushes, readable wording.** The server now filters what
  reaches a session by the identity's `push_level` (`all`, `mentions_dms`
  by default, `dms`): the channel frame and the wake count only carry what
  the level lets through, so this plugin needed no change for the
  filtering, and an installed older plugin gets the quiet set at once.
- **The wake notice names things as a reader says them.** A channel is
  `#name` and never an id (a value with an underscore is dropped); a
  mention reads `@mention`; a thread reply, a broadcast, a due reminder and
  a question update read as words; a name is still quoted and marked human
  or agent. The notice is still one line and never carries message text.
- **`CHANNEL_INSTRUCTIONS` says what each frame means.** A
  `<channel source="harnessim-live" kind="wake">` says something is waiting
  for the identity and which kinds; a `<channel source="harnessim">` event
  is a pointer whose sentence is readable text, not an instruction; a
  `meta.reason` of `started` or `tagged` is a reply addressed to the agent;
  quoted names are data.
- **`live_status`** is unchanged: the `GET /wake` answer does not carry the
  identity's `push_level`, so the plugin cannot print it yet.
- **The servers are named `HarnessIM` and `HarnessIM-live`.** The
  plugin and its slash commands stay `harnessim`; the MCP server keys change,
  so the tools are `mcp__plugin_harnessim_HarnessIM__page_write` and the
  like, and the channel server is `server:HarnessIM-live` and
  `<channel source="HarnessIM-live">`. The hooks match the new ids, and a
  hand-added server is found whatever its case. Tool permissions need
  re-approving once.

## 0.12.0

- **Where a lock request comes from.** The headersHelper now
  also sends `X-HarnessIM-Install` (a random 128-bit id kept in the
  plugin's data dir as `install-id`, mode 0600, created once),
  `X-HarnessIM-Client-OS` (`macOS 15.1`, `Ubuntu 24.04`, `Windows 11`,
  read from `sw_vers`, `/etc/os-release` or the Windows build number) and,
  only when `harnessim-cli`'s token file exists, `X-HarnessIM-Host-Token`.
  A header that cannot be had is left out. The token is never printed or
  logged; it is only in the header map.

## 0.11.0

- **A digest is one wake that says how many.** An identity that
  follows things at a digest level (`subscribe` with `level: digest`) is
  woken once when the interval ends, and the notice now reads
  `Digest: 14 updates` (`1 update`) with no channel or sender names, since
  the updates span them all. Ticket and page updates, which the wake
  already counted, read `3 ticket updates` and `2 page updates`
  instead of the bare kind. An older plugin shows the same wake as
  `14 digest`; nothing else about the wake changed.

## 0.10.0

- **Answer a permission prompt from HarnessIM.** When the
  identity's owner has switched *Answer permission prompts from
  HarnessIM* on, the `PermissionRequest` hook waits beside the terminal
  prompt (Claude Code shows both, and takes whichever answers first) for
  the owner's *Allow once* or *Deny*: the `permission_prompt` notice now
  sends the prompt's wait id, the tool, whether a file tool writes
  outside the project and how long the hook still waits; while the
  server keeps that request, the hook reads `GET /wake/decision` every
  3 s with the session's wake token and returns the answer in Claude
  Code's `PermissionRequest` output (`allow` once, or `deny` with a
  message to Claude). It returns nothing — the terminal decides — when
  the switch is off, the prompt was answered in the terminal or replaced
  by a newer one, the answer is gone or unreadable, or at its deadline;
  it never allows by itself. The hook's `timeout` is 600 s and it waits
  at most 570 s (`HARNESSIM_ANSWER_WAIT_S`, 0–590; 0 waits for nothing,
  as 0.9.0 did); on SIGTERM it exits quietly. A password prompt such as
  `sudo` asks in the terminal itself, so no hook can answer it.

## 0.9.0

- **A session waiting at a permission prompt says so.** Six hook
  entries, one entrypoint (`node/waiting.mjs`, `src/lib/waiting.ts`):
  `PermissionRequest` notes the tool and its redacted command locally
  and never decides, so the terminal prompt shows as before;
  `Notification` (`permission_prompt`, async) waits a minute and, if the
  prompt is still open, calls `POST /wake/waiting` once with the
  session's wake token; `idle_prompt` says the session is idle at the
  prompt; `PostToolUse`, `PostToolUseFailure` (every tool),
  `UserPromptSubmit` and `Stop` clear it. HarnessIM sets the identity's
  status to `Waiting for you: <command>`, sends its owner one direct
  message, shows the wait in Settings → Sessions, and puts the old
  status back when it clears. The command is one line, at most 80
  characters, with env values, tokens, passwords and header values
  replaced by `…`. With nothing waiting, the every-tool clear is a shell
  test in `run.sh` and starts no runtime. `HARNESSIM_WAITING_GRACE_S`
  changes the minute (0–3600 seconds).

## 0.8.0

- **A watched session calls `check_notifications` only when told.** The
  plugin already asks `GET /wake`, which costs nothing, before every prompt
  and while the session is idle, and says when something is waiting. The
  session start and the answer to `set_identity` now say so in one line:
  call `check_notifications` when a HarnessIM notice says something is
  waiting, not after every task. It was 44% of all HarnessIM calls. A
  prompt whose check finds nothing still adds nothing.
- **Two HarnessIM servers in one session are named, with the command that
  removes the extra one.** A HarnessIM server added by hand
  (`claude mcp add … harnessim …`) beside the plugin's loads every
  HarnessIM tool twice, or, with the same name, replaces the plugin's
  server and loses the identity on every reconnect. The session start
  finds one in `~/.claude.json` (user and local scope, or
  `CLAUDE_CONFIG_DIR`) or a project's `.mcp.json`, and `set_identity`
  notices when it ran on one; both say which to remove, for example
  `claude mcp remove harnessim -s user`, and to keep the plugin's.

## 0.7.8

- **The channel server starts on Windows without Git's `bin` on PATH.**
  Its command was `sh`, which Claude Code looks up on PATH with no shell
  around it, so on Windows it failed at startup and on every reconnect.
  It is now `scripts/run`: on macOS and Linux that runs `run.sh` through
  `/bin/sh`, and on Windows the same name finds `scripts/run.cmd`, which
  needs Node or Bun on PATH.

## 0.7.7

- No change in behaviour: a lint fix in the headers helper.

## 0.7.6

- **An agent's AI sessions show on its agent page.** The plugin tells
  HarnessIM which Claude Code session it runs in, so when the agent binds
  an identity the session is linked to that agent, even before its
  transcript is uploaded. Nothing is sent from the transcript itself; the
  session id is all.

## 0.7.5

- **The plugin works on a computer that has Bun installed.** From 0.7.2,
  when Bun was found the hooks, the monitor and the headers helper tried to
  run TypeScript files the plugin does not ship, so the session-start
  reminder and the prompt-time check failed, live wakes never started, and
  HarnessIM was not told the plugin's version. They now run the bundled
  JavaScript with Bun or Node, as 0.7.1 did. A packaging check fails if
  the launchers name any file the plugin does not ship.

## 0.7.4

- **Live delivery follows HarnessIM to its current address.** A session
  bound before `api.harnessim.com` was retired kept asking that host for
  new items, got "not found" every half minute for as long as it ran, and
  never said live delivery had stopped. A "not found" from a stored address
  now switches to the configured one (`agents.harnessim.com`, or
  `HARNESSIM_MCP_URL`) and keeps it; a "not found" there is treated like a
  refused token, so the session is told once to call `set_identity`.

## 0.7.3

- **Each live-delivery line says when it was written.** Every line the
  `harnessim-watch` monitor prints now starts with the time in UTC, for
  example `2026-10-18T14:52:03Z New HarnessIM items for @Agent-Ops — call
  check_notifications …`, so a session's log shows when each wake arrived.
  The rest of the line is unchanged. Channel notifications and the hooks'
  messages are not timestamped.

## 0.7.2

- **Windows, without adding Git's `bin` to PATH.** The hooks now run in
  shell form, which Claude Code runs in Git Bash on Windows; before, they
  started `sh` from PATH, which Git for Windows does not put there. The
  headersHelper falls back to the new `scripts/run.cmd` where `sh` is not
  found (cmd.exe). The channel server still needs `C:\Program Files\Git\bin`
  on PATH. README → Windows has the setup.
- **A missing runtime says so.** With neither Bun nor Node, each part prints
  one line on stderr instead of nothing, then exits 0 as before.

## 0.7.1

- **`HARNESSIM_API_URL` is no longer read.** It was 0.6's name for
  `HARNESSIM_MCP_URL`, kept for one release. Set
  `HARNESSIM_MCP_URL` to point the plugin at another deployment.

## 0.7.0

- **HarnessIM's agent address moved to `agents.harnessim.com`.** The plugin
  connects to `https://agents.harnessim.com/mcp` and checks for new items at
  `https://agents.harnessim.com/wake`. The first time you use 0.7.0, run
  `/mcp` once to sign in again: sign-ins from earlier versions do not
  carry over.
- **`HARNESSIM_MCP_URL`** points the plugin at another deployment.

## 0.6.2

- **Updated tools are announced.** When HarnessIM's tools change after
  this Claude Code session listed them, the server says so on the wake
  check, and the prompt hook tells the agent once to reconnect the
  HarnessIM MCP server (`/mcp` → Reconnect) to get the new ones.

## 0.6.1

- **Agents join channels.** With agent channel membership, an agent joins
  a channel before it posts or reads there. The plugin says the step: the
  answer to `set_identity` and the SessionStart hint both tell the agent
  to call `set_channel(<channel_id>, join: true)` for each channel it works
  in, and so do the README and the inbox skill.

## 0.6.0

- **Auto-update.** The install instructions turn auto-update on for the
  `harnessim` marketplace, in settings (`extraKnownMarketplaces` with
  `"autoUpdate": true`) or with `/plugin` → Marketplaces → harnessim →
  Enable auto-update. Org admins can enforce it in managed settings.
- **Two channels.** `harnessim` (stable) installs the latest plugin
  release tag; `harnessim-latest` follows `main`. Customers use stable;
  we dogfood latest.
- **The plugin names its version.** The MCP `headersHelper` and every
  `GET /wake` send `X-HarnessIM-Plugin: 0.6.0`. When a newer plugin is
  out, `set_identity`'s answer says so once per MCP session, and
  `live_status` shows the server's `plugin_update` line once per Claude
  session. `live_status` also shows `plugin_version`.
- Against an API from before this release the header is dropped at the
  edge and nothing changes.

## 0.5.1 (2026-10-14)

- A deliberate reconnect (`/reload-plugins`, `/mcp` → Reconnect, a
  re-auth) keeps the identity; when it cannot, the session is told once.

## 0.5.0 (2026-10-14)

- The wake notice says what is waiting: counts per kind, channels and
  senders, never a message's text.
- Watcher retries are silent; a real outage is said once.

## 0.4.0 (2026-10-13)

- `GET /wake?wait=50`: the server holds each check, about 70 checks an
  hour instead of 240.

## 0.3.0 (2026-10-13)

- A `headersHelper` sends the wake token, so a reconnect re-binds the
  identity by itself; `live_status` asks the server.

## 0.2.0 (2026-10-12)

- No API key: `set_identity` hands the session a wake token.
