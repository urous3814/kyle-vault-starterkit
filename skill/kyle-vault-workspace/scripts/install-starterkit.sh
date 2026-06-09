#!/usr/bin/env bash
set -euo pipefail

STARTERKIT_DRY_RUN="${STARTERKIT_DRY_RUN:-0}"
STARTERKIT_FORCE="${STARTERKIT_FORCE:-0}"
STARTERKIT_INSTALL_CODEX_SKILL="${STARTERKIT_INSTALL_CODEX_SKILL:-0}"
STARTERKIT_INSTALL_CLAUDE_SKILL="${STARTERKIT_INSTALL_CLAUDE_SKILL:-0}"
STARTERKIT_CREATE_REPO_FILES="${STARTERKIT_CREATE_REPO_FILES:-1}"
STARTERKIT_CREATE_WORKSPACE_FILES="${STARTERKIT_CREATE_WORKSPACE_FILES:-1}"
STARTERKIT_CREATE_VAULT="${STARTERKIT_CREATE_VAULT:-1}"
STARTERKIT_CREATE_ONBOARDING="${STARTERKIT_CREATE_ONBOARDING:-auto}"
STARTERKIT_VAULT_NAME="${STARTERKIT_VAULT_NAME:-kyle}"

usage() {
  cat <<'USAGE'
Usage: scripts/install-starterkit.sh [options]

Options:
  --repo-root PATH          Target git repository root. Defaults to current git root or cwd.
  --workspace-root PATH     Parent workspace root. Defaults to repo parent.
  --vault-root PATH         Shared vault path. Defaults to workspace-root/kyle.
  --vault-name NAME         Shared vault directory name under workspace-root. Defaults to kyle.
  --dry-run                 Print actions without writing files.
  --force                   Backup and replace changed existing files.
  --install-codex-skill     Copy this skill into $CODEX_HOME/skills/kyle-vault-workspace.
  --install-claude-skill    Copy this skill into $CLAUDE_HOME/skills/kyle-vault-workspace.
  --install-agent-skills    Install both Codex and Claude Code skills.
  --skip-repo-files         Do not install repo AGENTS.md/CLAUDE.md/conductor files.
  --skip-workspace-files    Do not install parent workspace AGENTS.md/CLAUDE.md.
  --skip-vault              Do not create or seed the shared vault.
  --with-onboarding         Create kyle/06-ops/ONBOARDING.md from the template.
  --no-onboarding           Do not create ONBOARDING.md and do not prompt.
  -h, --help                Show this help.

Environment:
  STARTERKIT_DRY_RUN=1
  STARTERKIT_FORCE=1
  STARTERKIT_INSTALL_CODEX_SKILL=1
  STARTERKIT_INSTALL_CLAUDE_SKILL=1
  STARTERKIT_CREATE_REPO_FILES=0
  STARTERKIT_CREATE_WORKSPACE_FILES=0
  STARTERKIT_CREATE_VAULT=0
  STARTERKIT_CREATE_ONBOARDING=1|0|auto
  STARTERKIT_VAULT_NAME=kyle
USAGE
}

log() {
  printf '%s\n' "$*"
}

run() {
  if [ "$STARTERKIT_DRY_RUN" = "1" ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

resolve_path() {
  local path="$1"
  if [ -d "$path" ]; then
    CDPATH= cd -- "$path" && pwd
  else
    local parent base
    parent="$(dirname -- "$path")"
    base="$(basename -- "$path")"
    printf '%s/%s\n' "$(CDPATH= cd -- "$parent" && pwd)" "$base"
  fi
}

copy_file() {
  local source="$1"
  local target="$2"
  local target_dir

  target_dir="$(dirname -- "$target")"
  run mkdir -p "$target_dir"

  if [ -e "$target" ] || [ -L "$target" ]; then
    if cmp -s "$source" "$target" 2>/dev/null; then
      log "unchanged: $target"
      return 0
    fi

    if [ "$STARTERKIT_FORCE" != "1" ]; then
      log "preserved existing: $target"
      return 0
    fi

    local backup
    backup="$target.starterkit-backup.$(date +%Y%m%d%H%M%S)"
    run mv "$target" "$backup"
    log "backed up: $backup"
  fi

  run cp "$source" "$target"
  case "$target" in
    *.sh) run chmod +x "$target" ;;
  esac
  log "installed: $target"
}

copy_tree_files() {
  local source_root="$1"
  local target_root="$2"
  local file relative

  while IFS= read -r file; do
    relative="${file#$source_root/}"
    copy_file "$file" "$target_root/$relative"
  done < <(find "$source_root" -type f | sort)
}

create_standard_vault_dirs() {
  local vault_root="$1"
  local dir

  for dir in \
    01-product \
    02-design \
    03-engineering \
    04-ops \
    05-checklists \
    06-ops \
    07-critique \
    08-security \
    assets; do
    run mkdir -p "$vault_root/$dir"
  done
}

link_if_missing() {
  local target="$1"
  local link="$2"

  if [ -L "$link" ] && [ ! -e "$link" ]; then
    run rm "$link"
  fi

  if [ -e "$link" ] || [ -L "$link" ]; then
    log "preserved existing link/path: $link"
    return 0
  fi

  run ln -s "$target" "$link"
  log "linked: $link -> $target"
}

append_git_exclude() {
  local repo_root="$1"
  local pattern="$2"
  local git_dir

  git_dir="$(git -C "$repo_root" rev-parse --git-dir 2>/dev/null || true)"
  [ -n "$git_dir" ] || return 0

  case "$git_dir" in
    /*) ;;
    *) git_dir="$repo_root/$git_dir" ;;
  esac

  run mkdir -p "$git_dir/info"
  if [ "$STARTERKIT_DRY_RUN" = "1" ]; then
    log "[dry-run] ensure exclude $pattern in $git_dir/info/exclude"
    return 0
  fi

  grep -qxF "$pattern" "$git_dir/info/exclude" 2>/dev/null || printf '\n%s\n' "$pattern" >> "$git_dir/info/exclude"
}

install_agent_skill() {
  local agent_name="$1"
  local target_dir="$2"

  run mkdir -p "$(dirname -- "$target_dir")"
  if [ -e "$target_dir" ] || [ -L "$target_dir" ]; then
    if [ "$STARTERKIT_FORCE" != "1" ]; then
      log "preserved existing $agent_name skill: $target_dir"
      return 0
    fi

    run rm -rf "$target_dir"
  fi

  run cp -R "$skill_dir" "$target_dir"
  log "installed $agent_name skill: $target_dir"
}

should_create_onboarding() {
  case "$STARTERKIT_CREATE_ONBOARDING" in
    1|yes|true)
      return 0
      ;;
    0|no|false)
      return 1
      ;;
    auto)
      if [ "$STARTERKIT_DRY_RUN" = "1" ]; then
        log "onboarding=skipped dry-run auto mode"
        return 1
      fi

      if [ -t 0 ] && [ -t 1 ]; then
        local onboarding_answer
        printf 'Create kyle/06-ops/ONBOARDING.md from the starter template? [y/N] '
        read -r onboarding_answer
        case "$onboarding_answer" in
          y|Y|yes|YES)
            return 0
            ;;
        esac
      else
        log "onboarding=skipped non-interactive auto mode; use --with-onboarding to create it"
      fi
      return 1
      ;;
    *)
      printf 'Invalid STARTERKIT_CREATE_ONBOARDING value: %s\n' "$STARTERKIT_CREATE_ONBOARDING" >&2
      exit 2
      ;;
  esac
}

repo_root="${STARTERKIT_REPO_ROOT:-}"
workspace_root="${STARTERKIT_WORKSPACE_ROOT:-}"
vault_root="${STARTERKIT_VAULT_ROOT:-}"
vault_name="$STARTERKIT_VAULT_NAME"
vault_root_explicit=0
vault_name_explicit=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo-root)
      repo_root="$2"
      shift 2
      ;;
    --workspace-root)
      workspace_root="$2"
      shift 2
      ;;
    --vault-root)
      vault_root="$2"
      vault_root_explicit=1
      shift 2
      ;;
    --vault-name)
      vault_name="$2"
      vault_name_explicit=1
      shift 2
      ;;
    --dry-run)
      STARTERKIT_DRY_RUN=1
      shift
      ;;
    --force)
      STARTERKIT_FORCE=1
      shift
      ;;
    --install-codex-skill)
      STARTERKIT_INSTALL_CODEX_SKILL=1
      shift
      ;;
    --install-claude-skill)
      STARTERKIT_INSTALL_CLAUDE_SKILL=1
      shift
      ;;
    --install-agent-skills)
      STARTERKIT_INSTALL_CODEX_SKILL=1
      STARTERKIT_INSTALL_CLAUDE_SKILL=1
      shift
      ;;
    --skip-repo-files)
      STARTERKIT_CREATE_REPO_FILES=0
      shift
      ;;
    --skip-workspace-files)
      STARTERKIT_CREATE_WORKSPACE_FILES=0
      shift
      ;;
    --skip-vault)
      STARTERKIT_CREATE_VAULT=0
      shift
      ;;
    --with-onboarding)
      STARTERKIT_CREATE_ONBOARDING=1
      shift
      ;;
    --no-onboarding)
      STARTERKIT_CREATE_ONBOARDING=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
skill_dir="$(CDPATH= cd -- "$script_dir/.." && pwd)"
assets_dir="$skill_dir/assets"

if [ -z "$repo_root" ]; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
repo_root="$(resolve_path "$repo_root")"

if [ -z "$workspace_root" ]; then
  workspace_root="$(CDPATH= cd -- "$repo_root/.." && pwd)"
else
  workspace_root="$(resolve_path "$workspace_root")"
fi

if [ "$vault_root_explicit" = "1" ] && [ "$vault_name_explicit" = "1" ]; then
  printf 'Use either --vault-root or --vault-name, not both.\n' >&2
  exit 2
fi

if [ -z "$vault_name" ]; then
  printf 'Vault name cannot be empty.\n' >&2
  exit 2
fi

case "$vault_name" in
  */*|.*|*..*)
    printf 'Vault name must be a simple directory name: %s\n' "$vault_name" >&2
    exit 2
    ;;
esac

if [ -z "$vault_root" ]; then
  vault_root="$workspace_root/$vault_name"
else
  vault_root="$(resolve_path "$vault_root")"
fi

[ -d "$repo_root" ] || {
  printf 'Repository root does not exist: %s\n' "$repo_root" >&2
  exit 1
}

log "repo_root=$repo_root"
log "workspace_root=$workspace_root"
log "vault_name=$vault_name"
log "vault_root=$vault_root"

if [ "$STARTERKIT_CREATE_REPO_FILES" = "1" ]; then
  copy_tree_files "$assets_dir/repo" "$repo_root"
fi

if [ "$STARTERKIT_CREATE_WORKSPACE_FILES" = "1" ] && [ "$workspace_root" != "$repo_root" ]; then
  copy_tree_files "$assets_dir/workspace" "$workspace_root"
fi

if [ "$STARTERKIT_CREATE_VAULT" = "1" ]; then
  run mkdir -p "$vault_root"
  create_standard_vault_dirs "$vault_root"
  copy_tree_files "$assets_dir/vault" "$vault_root"
  if should_create_onboarding; then
    copy_tree_files "$assets_dir/optional/vault" "$vault_root"
  fi
  link_if_missing "$vault_root" "$repo_root/kyle"
fi

append_git_exclude "$repo_root" /kyle
append_git_exclude "$repo_root" /.context/
append_git_exclude "$repo_root" /.claude/agents
append_git_exclude "$repo_root" /.env.local

if [ "$STARTERKIT_INSTALL_CODEX_SKILL" = "1" ]; then
  codex_home="${CODEX_HOME:-$HOME/.codex}"
  install_agent_skill "Codex" "$codex_home/skills/kyle-vault-workspace"
fi

if [ "$STARTERKIT_INSTALL_CLAUDE_SKILL" = "1" ]; then
  claude_home="${CLAUDE_HOME:-$HOME/.claude}"
  install_agent_skill "Claude Code" "$claude_home/skills/kyle-vault-workspace"
fi

log "starterkit install complete"
