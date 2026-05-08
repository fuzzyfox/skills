# Repository Guidance

This repository is the canonical source for installable skills.

## Rules

- Put authored skills in `skills/<skill-name>/`.
- Keep local install directories such as `.agents/`, `.claude/`, and `.cursor/` out of version control.
- Do not copy third-party skills into this repo.
- When adding or changing a visible skill, update `README.md`.
- Treat the top-level `LICENSE` as applying to authored content only.

## Validation

- Prefer validating repo discovery with `npx skills add . --list`.
- Ensure every installable skill has a valid `SKILL.md` with `name` and `description` frontmatter.
