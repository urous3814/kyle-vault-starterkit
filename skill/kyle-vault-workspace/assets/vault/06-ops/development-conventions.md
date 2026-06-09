# Development Conventions

Status: active

## Workspace

- The current worktree is the code boundary.
- Shared context lives in `./kyle` when the symlink exists.
- The vault is optional. Missing vault context should not block code work.
- Do not inspect sibling worktrees unless explicitly requested.
- In Conductor, Conductor owns workspace creation.

## Start Check

```bash
pwd
git rev-parse --show-toplevel
git branch --show-current
git status --short
```

## Code

- Prefer existing project patterns.
- Prefer deletion and reuse over new abstractions.
- Keep diffs small and reversible.
- Do not revert user changes unless explicitly requested.
- Add comments only where they clarify non-obvious decisions.

## Documentation

- Decisions, scope, tradeoffs, and excluded work belong in the vault.
- Follow [[vault-foldering-rules]] when choosing where a new vault document belongs.
- Planning docs live in the relevant domain folder and are linked from [[../Index#Planning Hub|Index Planning Hub]].
- Deprecated choices are recorded in [[deprecated-decisions]].
- Work state is appended to [[agent-live-log]] and `agent-live-log.json`.

## Verification

Run the smallest checks that prove the claim. Common checks:

```bash
git diff --check
npm test
npm run lint
npm run typecheck
```

Report any unavailable checks explicitly.
