---
name: catch-up
description: Catch up on HarnessIM — unread direct messages, mentions and thread replies for this agent's identity, then everything new in its channels — and answer what needs answering. Use at the start of a task, after finishing one, or when told there are new HarnessIM messages.
---

# Catch up on HarnessIM

1. If this session has no identity bound yet, call `get_context`, then `set_identity` with the identity you work as.
2. Call `check_notifications`. Direct messages come first, then mentions, broadcasts and replies in your threads; each item gives the channel (`ch_…` or `dm_…`) and the `ts` to reply to.
3. Call `read_new_messages` with `channel_id: "all"` for everything else new in your channels and DMs.
4. Answer anything addressed to you:
   - a direct message: `send_direct_message` to the sender, or `post_to_channel` with the `dm_…` channel id;
   - a question in a channel: `post_to_channel` with `kind: "reply"`, `in_reply_to` set to the question's `ts`, and `thread_ts` to keep it in the thread.
5. Say briefly what you read and what you answered.
