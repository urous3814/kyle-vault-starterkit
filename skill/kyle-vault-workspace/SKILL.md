---
name: kyle-vault-workspace
description: Set up or verify a Kyle-style shared vault, agent instructions, Conductor workspace setup, conductor.json, worktree boundaries, live logging, and reusable starterkit files for coding agents.
---

# Kyle Vault Workspace

Use this skill when a repo should share a `./kyle` vault across local worktrees or Conductor workspaces.

## Operating Model

- Conductor creates and owns Conductor workspaces. Do not create nested worktrees inside a Conductor workspace.
- The current git checkout is the code boundary.
- `./kyle` is optional shared context. Use it when present; continue without it when absent.
- `.context/` is local, gitignored collaboration state for Conductor and agents.
- Agent instructions should be durable in `AGENTS.md`; setup mechanics belong in scripts.
- Vault logs are append-only. Add new entries instead of editing old entries.

## Quick Start

From the skill directory:

```bash
scripts/install-starterkit.sh --repo-root /path/to/repo
scripts/verify-starterkit.sh
```

The installer is conservative:

- Existing files are preserved by default.
- `--force` backs up changed files before replacement.
- `--dry-run` prints actions without changing files.
- `--vault-name NAME` creates the shared vault at `$workspace_root/NAME` while keeping the repo link as `./kyle`.
- `--vault-root PATH` uses an exact shared vault path; do not combine it with `--vault-name`.
- `--install-codex-skill` copies this skill to `$CODEX_HOME/skills/kyle-vault-workspace`.
- `--install-claude-skill` copies this skill to `$CLAUDE_HOME/skills/kyle-vault-workspace`.
- `--install-agent-skills` installs both Codex and Claude Code skill copies.
- `--skip-repo-files` skips repo template installation for skill-only setup.

## What Gets Installed

- Repo files: `AGENTS.md`, `CLAUDE.md`, `conductor.json`, `scripts/conductor-setup.sh`, `scripts/test-conductor-setup.sh`.
- Workspace files: optional parent-level `AGENTS.md` and `CLAUDE.md`.
- Vault seed: `AGENT_ENTRY.md`, `Index.md`, and core `06-ops` documents.
- Local links: `./kyle` points to the shared vault when possible.

## Verification

Run:

```bash
bash scripts/verify-starterkit.sh
```

For a target repo after installation:

```bash
bash scripts/test-conductor-setup.sh
jq empty kyle/06-ops/agent-live-log.json
git status --short
```

Expected result: scripts parse, JSON is valid, and local symlinks/context files are ignored.
