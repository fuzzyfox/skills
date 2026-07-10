---
name: review
description: >
  Review the changes since a fixed point along three independent axes —
  Standards (does the code follow this repo's documented conventions and avoid
  known smells?), Spec (does it do what the issue/PRD asked?), and Architecture
  (does the change belong in the system and raise its evolvability — working
  with the grain of the existing seams, domain model, and layers to leave the
  architecture cheaper to change next — rather than lowering it?). Runs three
  parallel sub-agents that never share context and reports them side by side.
  The strongest architectural opportunity gets a concrete follow-up the operator
  can run. Use when the user wants to review a branch, a PR, or work-in-progress
  changes, or asks to "review since X".
license: MIT
metadata:
  author: William Duyck
  version: "0.2"
  sources:
    - Matt Pocock, skills/engineering/code-review
    - Matt Pocock / AI Hero, codebase-design + improve-codebase-architecture
    - Cursor team, thermonuclear-code-quality-review
---

Three-axis review of the diff between a fixed point the user supplies and `HEAD`:

- **Standards** — does the code conform to this repo's documented conventions, and does it steer clear of the smell baseline below?
- **Spec** — does the code faithfully implement the originating issue / PRD / spec?
- **Architecture** — does the change go with the **grain**, keeping the system **coherent** and cheaper to change — or cut across it?

Each axis runs as a **parallel sub-agent** so they don't pollute each other's context, then this skill aggregates their findings. The separation is the point: a change can pass one axis and fail another, and a single reviewer collapses them.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Note the commit list via `git log <fixed-point>..HEAD --oneline`.

Confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty before going further. A bad ref or empty diff fails here — not inside three parallel sub-agents.

### 2. Locate the inputs (do this once, hand to the sub-agents)

- **Spec source**, in order: issue refs in commit messages (`#123`, `Closes #45`) → a path the user passed → a PRD/spec under `docs/`, `specs/`, `.scratch/` matching the branch → else ask; if there is none, the Spec axis skips and reports "no spec available".
- **Standards sources**: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `CONTEXT.md`, `docs/adr/` (ADRs *are* standards), any `STYLE.md`/`STANDARDS.md`. Note machine-enforced config (`.editorconfig`, `eslint`, `tsconfig`, `biome`, `prettier`) but tell the agent NOT to re-check what tooling already enforces.
- **Architecture inputs**: `CONTEXT.md` — the domain model that names the system's real concepts and good seams — and `docs/adr/`, the decisions that fix where the architecture is heading. The Architecture axis needs both: `CONTEXT.md` to tell a canonical concept from a reinvented one, ADRs to tell a course-correction from a violation.

### 3. Spawn three sub-agents in parallel (one message, three Agent calls)

Use the `general-purpose` sub-agent for all three. Each brief carries everything the agent needs — the agents share no context with each other or with you.

**Standards brief** — include the diff command, the commit list, the standards-source files from step 2, **plus the smell baseline below pasted in full** (the agent has no other access to it):

> Report — per file/hunk — (a) every place the diff violates a documented standard: cite the standard (file + rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words, structural findings first, nits last.

Smell baseline (Fowler, _Refactoring_ ch.3 — each reads *what it is* → *how to fix*):

- **Mysterious Name** — a name that doesn't reveal what it does/holds. → rename; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape in more than one hunk/file. → extract the shape, call it from both.
- **Feature Envy** — a method reaching into another object's data more than its own. → move it onto the data it envies.
- **Data Clumps** — the same few fields/params travelling together. → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive standing in for a domain concept. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs. → polymorphism, or one shared map.
- **Shotgun Surgery** — one logical change forces scattered edits. → gather what changes together into one module.
- **Divergent Change** — one module edited for several unrelated reasons. → split so each changes for one reason.
- **Speculative Generality** — abstraction/params/hooks for needs the spec doesn't have. → delete it; inline until a real need shows.
- **Message Chains** — long `a.b().c().d()` the caller shouldn't depend on. → hide the walk behind one method.
- **Middle Man** — a class/function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass ignoring most of what it inherits. → drop the inheritance, use composition.

**Spec brief** — include the diff command, commit list, and the spec path/contents:

> Report: (a) requirements missing or partial; (b) behaviour not asked for (scope creep); (c) requirements that look implemented but wrong. Quote the spec line for each finding. Under 400 words.

If the spec is missing, skip this sub-agent and note it in the final report.

**Architecture brief** — include the diff command, commit list, the `CONTEXT.md` domain model, the ADR list, **plus the depth vocabulary below pasted in full**:

> The diff is your **starting point, not your bounds** — judge how the change sits in the *whole* system: does it keep it **coherent** and cheaper to change, or cut across the **grain**? Adding capability is fine — deepening a module or opening a clean seam *raises* evolvability; flag those that lower it, **ranked by impact**:
>
> **Fit — one coherent source of truth, or a second that drifts?** A domain concept **reinvented** under a name `CONTEXT.md` owns; a **bypass** around the canonical flow; logic in the **wrong layer**; a change contradicting an **ADR** (surface only if it warrants reopening).
>
> **Shape — deep module, load-bearing seam?** A **shallow module** — pass-through or forwarding wrapper; confirm with the **deletion test**. New behaviour behind **no seam** — untestable in isolation.
>
> **Direction — cheaper next time, or dearer?** A **code-judo** move that folds the change into an existing deep module and deletes a branch / helper / layer. A change that **scatters** — a file past ~1,000 lines, conditionals wanting a typed dispatch, or magical code where boring reads better.
>
> Tier each **Blocker** / **Concern** / **Nit**, in `CONTEXT.md` vocabulary — false positives are cheap. Under 200 words. Then one line — the strongest **`Opportunity:`**, a module and the move that raises evolvability most, or `Opportunity: none`.

Depth vocabulary (use these terms exactly — don't drift into "component", "service", "API", "boundary"):

- **Module** — anything with an interface and an implementation: a function, class, package, or tier-spanning slice.
- **Interface** — everything a caller must know to use it correctly: signature, invariants, ordering, error modes, config, performance.
- **Depth** — behaviour a caller/test exercises per unit of interface they must learn. **Deep** = large behaviour behind a small interface; **shallow** = interface nearly as complex as implementation.
- **Seam** _(Feathers)_ — a place you can alter behaviour without editing there; where a module's interface lives, and the surface tests cross.
- **Leverage / Locality** — depth buys callers more capability per unit of interface (leverage) and buys maintainers change/bugs/knowledge concentrated in one place (locality). Both are evolvability: leverage lowers the cost of the next caller, locality lowers the cost of the next change.

### 4. Aggregate

Present the three reports under `## Standards`, `## Spec`, and `## Architecture`, verbatim or lightly cleaned. Keep the Architecture findings in the sub-agent's evolvability ranking, and carry its `Opportunity:` line through to step 6. **Do not merge or rerank across axes** — the independence is what keeps one axis from masking another (see _Why three axes_).

End with a one-line summary: total findings per axis, and the worst issue *within each axis*. Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

### 5. Verdict (approval bar)

Close with **approve** / **request changes**, judged against this bar. Any one of these presumptive blockers justifies request-changes:

- a change that **lowers evolvability** at a load-bearing point: a reinvented domain concept, a bypass around the canonical flow, or logic landed in the wrong layer;
- a **shallow module** added at a seam that should have been deep;
- new behaviour with **no seam to test it** through its interface;
- a documented-standard hard violation;
- a spec requirement implemented wrong (not merely a missing nice-to-have).

Judgement-call smells and architecture nits inform the review but don't block on their own. A raise-evolvability **opportunity** never blocks — it takes the escape route below.

### 6. Escape route (Architecture axis only)

If the Architecture axis returned an `Opportunity:` naming a real deepening or code-judo move — one bigger than this change should swallow inline — end the review with a single concrete next step the operator can run:

> "Strongest architectural opportunity: **\<module\> — \<the move\>**. Run `/improve-codebase-architecture` on it for a before/after report and a grilling pass, or fold it in now if it's small."

One opportunity, the strongest, ranked by evolvability impact — not a backlog. If the axis returned `Opportunity: none`, omit this section. The escape route is a forward path the operator chooses to take; it is never a condition of approval.

## Why three axes

A change can pass one axis and fail another:

- Follows every standard, implements the wrong thing → **Standards pass, Spec fail.**
- Does exactly what the issue asked but breaks conventions → **Spec pass, Standards fail.**
- Clean and correct, but it forks the domain model — a second Order definition the next change has to keep in sync → **Standards + Spec pass, Architecture fail.**

Reporting them separately stops one axis from masking another.

## Tone (primes the agent's vocabulary)

Direct, serious, specific. Not rude. Reach for:

- "this forks the Order concept `CONTEXT.md` already owns — two definitions to keep in sync; fold it into the intake module."
- "this bypasses the repository and writes straight to the table — a second source of truth the next change has to find."
- "there's a code-judo move here: fold this behind the existing seam and the new layer disappears — cheaper to change next time."
- "correct, but there's no seam to test it through — can we inject X?"
- "this is clean, but it doesn't do what #123 asked for."

Don't flood the review with low-value nits when there are structural issues.
