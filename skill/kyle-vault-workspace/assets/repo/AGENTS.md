# Project Agent Rules

## Workspace Boundary

- Treat the current git checkout as the code boundary.
- Do not inspect sibling worktrees unless the user explicitly asks.
- Conductor owns workspace/worktree creation. Do not run local worktree-creation scripts from inside a Conductor workspace.
- Use ./kyle as the shared vault when it exists. If it is missing, continue with repo-local context and report that vault setup is unavailable.
- Use `.context/` for local handoff notes or generated context. Do not commit `.context/`.

## Kyle Vault

- Start from `./kyle/AGENT_ENTRY.md` when it exists.
- Use `./kyle/Index.md` to find product, planning, design, and ops documents.
- If `./kyle/06-ops/agent-live-log.json` exists, append a JSON-compatible entry for work start, handoff, blocker, and completion states.
- Planning or design documents should live in the relevant vault domain folder and be linked from `./kyle/Index.md` under `Planning Hub`.

## Conductor

- Setup, run, and archive scripts run from the workspace directory.
- Use `CONDUCTOR_ROOT_PATH` when a setup script needs files from the original repo root.
- Use `CONDUCTOR_PORT` for dev servers started from Conductor.
- Do not commit Conductor-created symlinks or local files such as `./kyle`, `.context/`, `.claude/agents`, or `.env.local`.

## Development

- Before changing code, check:

```bash
pwd
git rev-parse --show-toplevel
git branch --show-current
git status --short
```

- Prefer existing project patterns over new abstractions.
- Keep diffs small, reviewable, and reversible.
- Do not revert user changes unless the user explicitly asks.
- Verify changed behavior before claiming completion.

## Git

- Commit only when the user asks.
- Keep local symlinks, vault files, generated context, and environment files out of commits unless the user explicitly requests otherwise.
