---
name: goals
description: 'Use this skill whenever the user wants goal-based autonomous repo work: create a goals/ system, break a large topic or PRD into atomic goals, execute the next goal, execute all goals, report goals status, recover partially completed goals, or archive/retire goals. Trigger on phrases like "create goals", "work through goals", "next goal", "all goals", "goal status", "archive goals", "turn this roadmap into goals", or requests for an agent to work autonomously across a repo.'
---

# Goals

Use this skill to manage a repo-local `goals/` system for decomposing large work
into atomic implementation goals that an agent can execute autonomously.

The key idea: `goals/index.md` is not a prompt. It is the operating manual the
agent follows when the user says, "Read `goals/index.md` and continue until all
goals are completed." Each goal file is an executable contract with scope,
acceptance criteria, definition of done, verification, and status.

## Modes

Infer the mode from the user's request:

- **Initialize**: create `goals/` and `goals/index.md` if missing.
- **Plan**: break a topic, PRD, roadmap, issue, or design into goal files.
- **Status**: inspect current goals, detect inconsistencies, and summarize state.
- **Next**: execute the first unchecked non-blocked goal.
- **All**: execute goals in order until complete or blocked.
- **Archive/retire**: move completed or obsolete goals into `goals/archive/` and
  update the index.

If the user gives a broad request like "use goals for this repo", initialize or
status-check first, then ask only the questions needed to plan safely.

## Repository Setup

Before changing files:

1. Check `git status --short`.
2. Read repo guidance files if present: `AGENTS.md`, `CLAUDE.md`, `README.md`,
   `CONTRIBUTING.md`, Makefile, package manifests, and existing planning docs.
3. If the worktree has unrelated user changes, preserve them. Do not overwrite.
4. If the repo is not a git repo and the user wants execution/commits, ask
   whether to initialize git before proceeding.

Use `rg` for searches and targeted file reads. Keep context small by summarizing
findings instead of loading large files repeatedly.

## Model Selection

If model selection is available:

- Use a high-reasoning coding model for planning, architecture, schemas, public
  APIs, concurrency, retries, migrations, or broad refactors.
- Use a normal coding model for implementation with clear acceptance criteria.
- Use a lighter model only for mechanical docs/status/archive work.

If model selection is unavailable, proceed with the current model and compensate
with tighter tests, explicit assumptions, and careful verification.

## Creating Or Repairing `goals/index.md`

If `goals/index.md` does not exist, create it. If it exists but lacks the sections
below, repair it before adding or executing goals.

Required sections:

```markdown
# <project> goals

<short purpose statement>

## Operating Rules

- Work goals in queue order.
- Complete one goal per commit.
- Do not begin the next goal with uncommitted changes from the previous goal.
- Stop and ask the user when blocked by missing decisions, credentials, or unsafe
  changes.

## Model And Token Guidance

<repo-appropriate model selection and token discipline>

## Goal File Format

<describe required goal file sections>

## Execution Loop

<ordered steps for next/all execution>

## Definition Of Done

<baseline done checklist>

## Verification

<repo-specific verification commands>

## Blocking And Recovery

<how to mark blocked and when to stop>

## Queue

- [ ] [G01 - Title](01-title.md)
```

Adapt the wording to the repo. The index should be complete enough that a new
agent can run from only this file and the goal files.

## Goal File Format

Each goal file must use this format:

```markdown
# GNN - Title

Status: planned

## Objective

<one outcome>

## Source / context

<PRD section, issue, user request, design doc, or discovery notes>

## Scope

- <included work>

## Non-goals

- <explicitly excluded work>

## Implementation notes

- <constraints, likely files, edge cases, design direction>

## Acceptance criteria

- <externally visible behavior that must be true>

## Definition of done

- Acceptance criteria are met.
- Focused tests are added or updated.
- Relevant docs are updated.
- Required verification commands pass.
- Status is changed to `complete`.
- `goals/index.md` marks this goal complete.
- The work is committed in one focused commit.

## Verification

- `<build command>`
- `<test command>`
- `<lint command>`
```

Allowed statuses: `planned`, `in_progress`, `blocked`, `complete`, `retired`.
If a goal is blocked, add:

```markdown
## Blocked notes

- Blocker:
- Tried:
- Needed from user:
```

If a goal is complete, optionally add:

```markdown
## Completion notes

- Commit:
- Verification:
- Follow-ups:
```

## Breaking A Topic Into Goals

When planning from a topic:

1. Read the source material: PRD, issue, roadmap, user notes, existing code, or
   docs referenced by the user.
2. Identify outcomes, not tasks. A good goal leaves the repo in a useful,
   verified state.
3. Order goals by dependency and risk:
   - foundations before features
   - schema/API decisions before consumers
   - safety/verification before broad automation
   - user-visible operations before polish
4. Keep each goal atomic enough for one commit. If a goal cannot be tested or
   committed independently, split it.
5. Ask up to three concise questions only when planning would otherwise encode a
   risky assumption. Prefer sensible defaults for low-risk details.
6. Create goal files and update the index queue.
7. Run the repo's verification commands if practical, then commit the planning
   artifact if the user asked for durable goals.

Goal sizing guidance:

- **Small**: one command, one module, one behavior change.
- **Medium**: one user-facing feature with tests/docs.
- **Large**: likely split into multiple goals.

## Determining Status

For status requests:

1. Check `git status --short`.
2. Read `goals/index.md`.
3. Read each queued goal file's `Status`.
4. Report:
   - total goals
   - complete/planned/in_progress/blocked/retired counts
   - next executable goal
   - blocked goals and needed input
   - dirty worktree state
   - last goals-related commit if useful
5. If index checkbox and goal-file status disagree, report the inconsistency and
   offer to repair it. If the correct state is obvious, repair it and commit the
   repair only after verification.

## Executing The Next Goal

For "next goal":

1. Select the first unchecked queue item whose goal file is not `blocked` or
   `retired`.
2. Set that goal's status to `in_progress`.
3. Implement only that goal.
4. Add or update focused tests.
5. Update docs and project memory when behavior, schema, CLI, operating steps, or
   known limitations change.
6. Run verification.
7. Set goal status to `complete`, check it in `goals/index.md`, and add completion
   notes if useful.
8. Commit all related changes with one focused commit.
9. Stop after the commit unless the user asked for "all goals".

## Executing All Goals

For "all goals", repeat the next-goal loop until:

- every queue item is complete or retired, or
- a goal is blocked and needs user input, or
- verification fails for a reason that cannot be fixed within the current goal.

Do not batch multiple goals into one commit. A clean commit boundary is part of
the system's reliability.

If context is getting long, write enough progress into the current goal file or
index notes that another agent can resume, commit only if the repo is verified
and useful, then report the handoff point.

## Verification

Use repo-native gates. Detect them in this order:

1. If a Makefile has `build`, `test`, and `lint`, use:
   - `make build`
   - `make test`
   - `make lint`
2. Otherwise inspect package/tooling files:
   - Go: `go test ./...` and any documented lint/build commands
   - Node: package scripts for build/test/lint
   - Python: pytest/ruff/mypy or documented commands
   - Rust: `cargo test`, `cargo clippy`, `cargo build`
3. If no verification commands exist, add minimal tests or document the gap in the
   goal file and final response.

Rules:

- Tests must not require network access unless explicitly documented as optional
  live validation.
- Live checks must be read-only.
- Do not skip verification for docs-only goals if the repo has standard gates.

## Archiving And Retiring Goals

Use archive/retire when a goal is complete and no longer needs to stay in the
active queue, or when a planned goal is obsolete.

Process:

1. Create `goals/archive/` if missing.
2. Move the goal file to `goals/archive/YYYY-MM-DD-<slug>.md`, or keep it in
   place and set `Status: retired` if moving would break existing tooling.
3. Add archive metadata near the top of the file:
   - `Archived: YYYY-MM-DD`
   - `Archive reason: completed|obsolete|superseded|blocked-replaced`
   - `Superseded by: <goal/link>` when applicable
4. Remove it from the active queue or move it to an `Archived` section.
5. Commit the archive/index update after verification.

Do not delete goal files unless the user explicitly asks.

## Blocking Rules

Pause and ask the user when:

- A required decision is missing and multiple choices are materially different.
- Credentials, network access, paid services, or remote writes are required.
- User changes overlap the goal and cannot be safely preserved.
- The goal conflicts with repo instructions.
- Verification fails for an unrelated reason that cannot be isolated.

When blocked, update the goal file with `Status: blocked` and `Blocked notes`.
Do not mark the index item complete.
