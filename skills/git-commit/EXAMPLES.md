# Examples

## Simple subjects

```text
✨ feat(auth): add password reset emails
🐛 fix(queue): drop duplicate retry scheduling
📝 docs(api): clarify webhook signature validation
♻️ refactor(cache): collapse duplicate invalidation paths
⚡️ perf(search): cache normalized query tokens
✅ test(parser): cover nested tuple parsing
🛂 fix(session): rotate expired refresh tokens
💥 feat(config)!: remove legacy env fallback
⏪️ revert: restore previous webhook retry backoff
```

## Subjects with bodies and footers

```text
🐛 fix(api): reject empty webhook payloads

Reject empty payloads before schema validation to avoid noisy downstream errors
and to return a consistent 400 response for malformed requests.

Refs: #4821
```

```text
💥 feat(auth)!: remove legacy token exchange

The old exchange path kept two authentication flows alive and blocked cleanup of
the new OAuth2-only login sequence.

BREAKING CHANGE: clients must use the OAuth2 token endpoint.
```

```text
♿️ feat(nav): add keyboard shortcuts for sidebar navigation

Improves keyboard-only navigation for power users and screen-reader workflows.
```

## Decision examples

- New capability with UI work: prefer `✨ feat(ui): add bulk edit toolbar` over `💄`.
- Security hardening: prefer `🛂 fix(auth): reject unsigned session cookies` over `🐛`.
- Internal cleanup without behavior change: prefer `♻️ refactor(api): remove duplicate serializer paths`.
- Small non-user-facing build tweak: prefer `🔧 chore(ci): align node version` or `👷 ci: cache pnpm store`.
