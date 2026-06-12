---
name: mailbox
description: Pure-filesystem inter-agent mailbox so any agent session can send a handoff document to another and pick up replies. Use when you need to set up your mailbox, send or reply to another agent, check for or wait on incoming messages, resolve another agent by name, take over / claim an existing mailbox identity (e.g. "take over Alice's mailbox"), or prune stale mailboxes from the registry. The fabric beneath the spawn, handback, and dispatch skills.
argument-hint: "[setup|check|send|wait|reply|takeover|prune]"
license: MIT
compatibility: Any *nix with coreutils. flock and fswatch are optional accelerants.
metadata:
  author: William Duyck
  version: "0.2"
---

A pure-filesystem return channel between agent sessions. No daemon, no network,
no harness-specific transport. Each session owns an inbox (a directory); a message
is a `handoff` document with a tiny YAML envelope carrying a return address.
Delivery is solved completely by the filesystem; **wake-up** is solved by whose
turn is open (the `wait` flow).

All protocol logic lives in [`scripts/mailbox.sh`](scripts/mailbox.sh). Source it
once, then call the `mb_*` functions — never hand-edit the inbox or registry:

```bash
. "<this skill's path>/scripts/mailbox.sh"
```

## Flows

Read the flow you need; each is a self-contained doc:

- **[setup](references/setup.md)** — ensure your inbox exists, register a friendly name, and report it to the operator.
- **[send](references/send.md)** — deliver a `handoff` document to another agent's inbox, resolved by name.
- **[reply](references/reply.md)** — answer a message you are holding, threaded back to its sender.
- **[check](references/check.md)** — drain your inbox, triaging by frontmatter only, archiving each as you ingest it.
- **[wait](references/wait.md)** — hold the turn open until mail arrives (bounded), then `check`.
- **[takeover](references/takeover.md)** — adopt an existing mailbox identity by name ("take over Alice's mailbox"), e.g. after a crash/resume or to map a screen to a name.
- **[prune](references/prune.md)** — list the registered mailboxes and remove the ones the operator names, freeing their friendly names.

When you instruct **another agent** to use the mailbox — anything you write into a
handoff or message body — name the **flow** ("run your mailbox skill's `reply`
flow"), never the `mb_*` engine functions. The flow doc carries the surrounding
discipline (archive-after-ingest, resolve-by-name-never-id, root reconciliation); a
bare function name strands the reader without it. The `mb_*` interface is for the
agent already inside a flow, not for cross-agent instruction.

## Direct Invocation

If the operator invokes this skill with a flow name (e.g. `/mailbox check`, `/mailbox prune`), treat 
that as a request to **run that flow now**: carry it through best-effort to completion, asking only

when the flow itself needs an answer (a recipient, a name to prune).

## Reference

- **[engine.md](references/engine.md)** — the `mb_*` function interface, the message envelope, and the root/identity contract.
- **[protocol.md](references/protocol.md)** — the raw on-disk wire protocol, so an agent or operator can participate by hand without `mailbox.sh`.
- Tests: `./tests/run.sh` (zero dependencies, any \*nix OS).
