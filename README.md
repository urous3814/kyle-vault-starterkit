# Kyle Vault Starterkit

Kyle-style shared vault and agent workspace starterkit.

This starterkit installs a reusable coding-agent setup for repos that need:

- a shared `./kyle` vault across local worktrees or Conductor workspaces
- repo and workspace `AGENTS.md` / `CLAUDE.md` templates
- Conductor-safe setup via `conductor.json` and `scripts/conductor-setup.sh`
- append-only agent live logging
- standard vault foldering rules
- optional `ONBOARDING.md` creation for first-day repo context

## Layout

```text
.
├── README.md
├── scripts/
│   └── verify-starterkit.sh
└── skill/kyle-vault-workspace/
    ├── SKILL.md
    ├── scripts/
    │   ├── install-starterkit.sh
    │   └── verify-starterkit.sh
    └── assets/
        ├── repo/       # files copied into a target git repo
        ├── workspace/  # optional parent workspace files
        ├── vault/      # default shared kyle vault seed
        └── optional/   # opt-in files such as ONBOARDING.md
```

## Install Into A Repo

Run from this repository or from any shell that can reach the starterkit:

```bash
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root /path/to/repo \
  --workspace-root /path/to/workspace
```

Defaults:

- `--repo-root` defaults to the current git root or current directory.
- `--workspace-root` defaults to the repo parent directory.
- `--vault-name` defaults to `kyle`.
- `--vault-root` defaults to `$workspace_root/$vault_name`.
- Existing files are preserved.
- `./kyle`, `.context/`, `.claude/agents`, and `.env.local` are added to local git exclude.

## Vault Name

Use `--vault-name` when the shared vault directory under the workspace root should not be named `kyle`:

```bash
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root /path/to/repo \
  --workspace-root /path/to/workspace \
  --vault-name product-vault
```

This creates:

```text
/path/to/workspace/product-vault/
/path/to/repo/kyle -> /path/to/workspace/product-vault
```

The repo symlink remains `./kyle` so agent instructions can stay stable across projects. To choose an exact vault path instead of a workspace-local name, use `--vault-root /absolute/path/to/vault`. Use either `--vault-name` or `--vault-root`, not both.

## Safety Options

```bash
# Preview without writing files
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root /path/to/repo \
  --dry-run

# Backup and replace changed existing files
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root /path/to/repo \
  --force
```

`--force` renames changed existing files with a `.starterkit-backup.<timestamp>` suffix before writing replacements.

## Onboarding

The installer can create `kyle/06-ops/ONBOARDING.md` from the starter template.

```bash
# Always create ONBOARDING.md
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root /path/to/repo \
  --with-onboarding

# Never create ONBOARDING.md
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root /path/to/repo \
  --no-onboarding
```

Default behavior:

- In an interactive terminal, the installer asks before creating `ONBOARDING.md`.
- In non-interactive environments, it skips onboarding unless `--with-onboarding` or `STARTERKIT_CREATE_ONBOARDING=1` is set.

## Conductor

Conductor owns workspace and worktree creation. Do not run local worktree creation scripts inside a Conductor workspace.

The installed repo template includes:

```json
{
  "scripts": {
    "setup": "./scripts/conductor-setup.sh"
  }
}
```

The setup script:

- runs from the Conductor workspace directory
- uses `CONDUCTOR_ROOT_PATH` to find the original repo root when needed
- links `./kyle` to the shared vault when available
- links `.context/workspace-AGENTS.md` and `.context/workspace-CLAUDE.md` when parent workspace files exist
- preserves `.env.local` as a local symlink when possible
- uses `CONDUCTOR_SETUP_SKIP_INSTALL=1` for fast script verification

Run scripts should bind app servers to `CONDUCTOR_PORT` when the project supports configurable ports.

## Install As A Codex Skill

```bash
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root /path/to/repo \
  --install-codex-skill
```

This copies the skill to:

```text
${CODEX_HOME:-$HOME/.codex}/skills/kyle-vault-workspace
```

## Repository Defaults

The standalone GitHub repository includes:

- MIT license
- security policy
- contributing guide
- code of conduct
- issue templates
- pull request template
- GitHub Actions verification workflow

## Verify

Verify the starterkit itself:

```bash
bash scripts/verify-starterkit.sh
bash skill/kyle-vault-workspace/scripts/verify-starterkit.sh
```

Verify an installed repo:

```bash
bash /path/to/repo/scripts/test-conductor-setup.sh
jq empty /path/to/workspace/kyle/06-ops/agent-live-log.json
git -C /path/to/repo status --short
```

If you installed with `--vault-name product-vault`, replace `/path/to/workspace/kyle` with `/path/to/workspace/product-vault`.

Expected result:

- shell scripts parse
- JSON files are valid
- local symlinks and context files are ignored
- existing repo files were preserved unless `--force` was used

## Standard Vault Folders

The starterkit seeds these folders:

```text
01-product/
02-design/
03-engineering/
04-ops/
05-checklists/
06-ops/
07-critique/
08-security/
assets/
```

Detailed placement rules live in:

```text
kyle/06-ops/vault-foldering-rules.md
```

Do not rename a mature existing vault just to match this template. Keep existing domain folders when they are already clear and stable.

## License

MIT License. See `LICENSE`.
