# Flow: prune

Remove mailboxes that are no longer wanted — delete their inbox trees and drop
their entries from the registry. This is **rare and operator-directed**: the root
lives in `/tmp` and the OS temp cleaner reclaims dead inboxes on its own
([protocol §9](protocol.md)), so prune is for tidiness *now* rather than waiting —
freeing a friendly name for reuse, or clearing clutter the operator can see. It is
deliberately **not** codified in the engine; you do it by hand under operator
direction.

When you reach for this:

- **Free a name** — the operator wants to re-register a name a dead session still holds.
- **Clear clutter** — stale mailboxes from finished work are piling up.

The functions this flow needs (full interface in [engine.md](engine.md)):

| Function | Does |
|---|---|
| `mb_names` | list registered names |
| `mb_lookup <name>` | name → `<id>\t<inbox>` (locate what to delete) |
| `mb_dir <id>` | the inbox tree to remove |

## Steps

1. List the mailboxes and present them to the operator. Let them choose which to
   remove — **never prune unprompted**.

   ```bash
   . "<this skill's path>/scripts/mailbox.sh"
   for n in $(mb_names); do
     id="$(mb_lookup "$n" | cut -f1)"
     printf '%s\t%s\n' "$n" "$(mb_dir "$id")"
   done
   ```

2. For each name the operator approves, delete its inbox tree and drop its registry
   entry. The registry is `<root>/registry.json`, and the root is the fixed
   `/tmp/agent-mailbox`:

   ```bash
   root="/tmp/agent-mailbox"
   id="$(mb_lookup "alice" | cut -f1)"
   rm -rf "$(mb_dir "$id")"                       # delete the inbox tree
   if command -v jq >/dev/null 2>&1; then         # drop "alice" from the registry
     tmp="$(mktemp)"
     jq 'del(.alice)' "$root/registry.json" > "$tmp" && mv -f "$tmp" "$root/registry.json"
   else
     : # edit $root/registry.json by hand — remove the "alice" object, keep it valid JSON
   fi
   ```

3. Confirm to the operator exactly what was removed.

## Caveats

- **No liveness check.** Liveness is structurally unobservable (an idle agent runs
  no loop; the registry `pid` is a passive hint). Do **not** prune a live session —
  the operator is responsible for confirming it has exited before you remove it.
- **Destructive.** Any unread mail in that inbox is lost. That is usually fine — a
  pruned mailbox is an abandoned one — but check before removing a mailbox that may
  still hold a pending reply.
- Dropping the registry entry **frees the friendly name** for re-registration.
