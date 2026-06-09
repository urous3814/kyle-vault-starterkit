# Shared Workspace Agent Rules

- Repositories in this workspace may have isolated worktrees.
- The shared vault lives at `./kyle` relative to the workspace root when available.
- Individual repo worktrees should link `./kyle` to that shared vault.
- Product decisions, scope notes, handoffs, and operating conventions belong in the shared vault rather than scattered chat history.
- Current worktree code is the edit boundary. Do not inspect or modify sibling worktrees unless the user explicitly asks.
- Conductor workspaces are created by Conductor. Do not create nested local worktrees from inside them.
- Keep local-only files out of commits: `kyle`, `.context/`, `.claude/agents`, `.env.local`, and tool runtime state.
