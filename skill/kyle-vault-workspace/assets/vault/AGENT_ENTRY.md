# Agent Entry

Status: active
Audience: Codex, Claude, and other coding agents

## 0. Start Check

Run these before code changes:

```bash
pwd
git rev-parse --show-toplevel
git branch --show-current
git status --short
```

Rules:

- Current worktree is the code boundary.
- Do not inspect sibling worktrees unless explicitly requested.
- If `./kyle` exists, use it for product and operating context.
- If `./kyle` is missing, continue with repo-local context and report the missing vault.

## 1. Required Reading

Minimum entry order:

1. [[Index]]
2. [[06-ops/development-conventions|development-conventions]]
3. [[06-ops/agent-live-log|agent-live-log]]
4. [[06-ops/deprecated-decisions|deprecated-decisions]]
5. [[06-ops/vault-foldering-rules|vault-foldering-rules]]
6. [[06-ops/ONBOARDING|ONBOARDING]] when it exists
7. Current task domain documents

Use [[Index#Planning Hub]] when creating or finding planning documents.

## 2. Live Log

If `kyle/06-ops/agent-live-log.json` exists, append a new entry for work start, handoff, blocker, and completion states.

Rules:

- Do not edit or delete existing entries.
- Append a new object to the `entries` array.
- Use JSON-compatible values only.
- Use ISO 8601 timestamps.
- Use `[]` for empty blocker lists.

## 3. Work Style

- Record scope, decisions, and tradeoffs in the vault when the task needs planning.
- Make code changes only in the current worktree.
- Keep changes narrow unless the user asks for broader cleanup.
- Do not revive deprecated decisions.

## 4. Verification

Choose checks based on the change:

```bash
git diff --check
npm test
npm run lint
npm run typecheck
```

If a command is unavailable, report the gap and run the next useful check.
