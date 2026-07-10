# Reference

## Sources

- Conventional Commits 1.0.0: https://www.conventionalcommits.org/en/v1.0.0/
- Keep a Changelog 1.1.0: https://keepachangelog.com/en/1.1.0/
- Gitmoji: https://gitmoji.dev/

## Core conventions

Conventional Commit shape:

```text
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

The Quick start in `SKILL.md` shows the Gitmoji-prefixed variant this skill emits; see `EXAMPLES.md` for worked examples.

## Conventional Commit rules

- `feat` means a new feature.
- `fix` means a bug fix.
- Other common types include `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `style`, `chore`, and `revert`.
- `scope` is optional and should be a stable noun that names a subsystem.
- `!` marks a breaking change in the subject.
- `BREAKING CHANGE:` in a footer explains the migration impact.
- Bodies and footers are optional and should earn their space.

## Keep a Changelog guidance for commit authors

Good commit messages make changelog curation easier. Favor subject and body wording that cleanly maps to these categories:

- `Added`: new user-facing features or capabilities.
- `Changed`: meaningful behavior changes, improvements, or migrations.
- `Deprecated`: features or APIs that still exist but should stop being used.
- `Removed`: features, APIs, files, or compatibility layers that are gone.
- `Fixed`: bug fixes.
- `Security`: security fixes and hardening.

Practical implications:

- Prefer outcome language over implementation detail.
- Mention deprecations, removals, and breaking changes explicitly.
- Use the body for user impact, migration notes, or rationale.
- Avoid noisy bodies that read like `git diff` summaries.
- Documentation-only, formatting-only, or internal chores are often not notable changelog items even if they deserve commits.

## Recommended Gitmoji mapping

Use one Gitmoji per commit. Pick the strongest match for the dominant intent.

| Intent                   | Preferred Gitmoji | Typical type             | Keep a Changelog category             |
| ------------------------ | ----------------- | ------------------------ | ------------------------------------- |
| New feature              | `✨`               | `feat`                   | `Added`                               |
| Bug fix                  | `🐛`              | `fix`                    | `Fixed`                               |
| Critical hotfix          | `🚑️`             | `fix`                    | `Fixed` or `Security`                 |
| Breaking change          | `💥`              | any with `!` or footer   | `Changed`, `Removed`, or `Deprecated` |
| Docs                     | `📝`              | `docs`                   | usually not notable                   |
| Performance              | `⚡️`              | `perf`                   | `Changed`                             |
| Refactor                 | `♻️`              | `refactor`               | usually `Changed` if behavior matters |
| Tests                    | `✅`               | `test`                   | usually not notable                   |
| Failing test added first | `🧪`              | `test`                   | usually not notable                   |
| Build system             | `👷` or `🔨`      | `build` / `ci`           | usually not notable                   |
| CI fixes                 | `💚`              | `ci`                     | usually not notable                   |
| Dependency add           | `➕`               | `build` / `chore`        | `Added` or `Changed`                  |
| Dependency upgrade       | `⬆️`              | `build` / `chore`        | `Changed`                             |
| Dependency removal       | `➖`               | `build` / `chore`        | `Removed`                             |
| Config update            | `🔧`              | `build` / `chore`        | `Changed` if user-visible             |
| Security fix             | `🛂`              | `fix`                    | `Security`                            |
| Accessibility            | `♿️`              | `feat` / `fix`           | `Added` or `Fixed`                    |
| UI styling               | `💄`              | `feat` / `fix` / `style` | `Changed`                             |
| Move or rename           | `🚚`              | `refactor` / `chore`     | usually `Changed`                     |
| Remove code/files        | `🔥` or `⚰️`      | `refactor` / `chore`     | `Removed`                             |
| Revert                   | `⏪️`              | `revert`                 | mirrors reverted category             |

## Choosing among close options

- Prefer `💥` when the headline is the breaking nature of the change.
- Prefer `✨` over `💄` when UI work adds new capability, not just polish.
- Prefer `🐛` over `🩹` unless the change is a very small non-critical patch and the team already uses `🩹`.
- Prefer `🛂` over `🐛` when the primary value is security hardening.
- Prefer `♻️` only for internal restructuring without user-facing fixes as the main story.
- When two Gitmoji both fit, prefer the more general, widely understood option.

## Subject writing rules

- Use imperative mood: `add`, `fix`, `remove`, `deprecate`, `rename`.
- Be specific about the affected behavior.
- Avoid vague descriptions like `update stuff` or `misc fixes`.
- Keep scope short and recognizable.
- Avoid stacking multiple concerns in one subject.

## Body and footer patterns

Body example:

```text
Reject empty payloads before schema validation to avoid noisy downstream errors.
```

Breaking change footer example:

```text
BREAKING CHANGE: remove the legacy token exchange endpoint; clients must use OAuth2.
```

Issue footer example:

```text
Refs: #4821
```
