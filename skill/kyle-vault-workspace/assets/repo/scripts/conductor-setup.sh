#!/usr/bin/env bash
set -euo pipefail

# Conductor assigns CONDUCTOR_PORT through CONDUCTOR_PORT+9 to each workspace.
# Run scripts should bind app servers to CONDUCTOR_PORT when the project supports it.

mkdir -p .context

link_if_missing() {
  local target="$1"
  local link="$2"

  if [ -L "$link" ] && [ ! -e "$link" ]; then
    rm "$link"
  fi

  if [ ! -e "$link" ] && [ ! -L "$link" ]; then
    ln -s "$target" "$link"
  fi
}

resolve_repo_root() {
  local repo_root="${CONDUCTOR_ROOT_PATH:-}"

  if [ -z "$repo_root" ] || [ ! -d "$repo_root" ]; then
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  fi

  CDPATH= cd -- "$repo_root" && pwd
}

resolve_workspace_root() {
  local repo_root="$1"
  local workspace_root=""
  local common_git common_git_abs common_repo_root

  common_git="$(git rev-parse --git-common-dir 2>/dev/null || true)"
  if [ -n "$common_git" ]; then
    case "$common_git" in
      /*) common_git_abs="$common_git" ;;
      *) common_git_abs="$(CDPATH= cd -- "$(dirname -- "$common_git")" && pwd)/$(basename -- "$common_git")" ;;
    esac

    common_repo_root="$(CDPATH= cd -- "$common_git_abs/.." && pwd)"
    if [ -d "$common_repo_root/../kyle" ]; then
      workspace_root="$(CDPATH= cd -- "$common_repo_root/.." && pwd)"
    fi
  fi

  if [ -z "$workspace_root" ] && [ -d "$repo_root/../kyle" ]; then
    workspace_root="$(CDPATH= cd -- "$repo_root/.." && pwd)"
  fi

  printf "%s" "$workspace_root"
}

link_workspace_context() {
  local repo_root="$1"
  local workspace_root="$2"

  if [ -n "$workspace_root" ]; then
    if [ -d "$workspace_root/kyle" ]; then
      link_if_missing "$workspace_root/kyle" ./kyle
    fi

    if [ -f "$workspace_root/AGENTS.md" ]; then
      link_if_missing "$workspace_root/AGENTS.md" .context/workspace-AGENTS.md
    fi

    if [ -f "$workspace_root/CLAUDE.md" ]; then
      link_if_missing "$workspace_root/CLAUDE.md" .context/workspace-CLAUDE.md
    fi

    if [ -d "$workspace_root/.claude/agents" ]; then
      mkdir -p .claude
      link_if_missing "$workspace_root/.claude/agents" .claude/agents
    fi
  fi

  if [ -f "$repo_root/.env.local" ]; then
    link_if_missing "$repo_root/.env.local" ./.env.local
  fi
}

update_git_excludes() {
  local git_dir

  git_dir="$(git rev-parse --git-dir 2>/dev/null || true)"
  if [ -z "$git_dir" ]; then
    return 0
  fi

  mkdir -p "$git_dir/info"
  for pattern in /kyle /.context/ /.claude/agents /.env.local; do
    grep -qxF "$pattern" "$git_dir/info/exclude" 2>/dev/null || printf "\n%s\n" "$pattern" >> "$git_dir/info/exclude"
  done
}

install_node_dependencies_if_needed() {
  if [ "${CONDUCTOR_SETUP_SKIP_INSTALL:-0}" = "1" ]; then
    echo "Skipping dependency installation because CONDUCTOR_SETUP_SKIP_INSTALL=1"
    return 0
  fi

  if [ -f package-lock.json ] && [ ! -d node_modules ]; then
    npm ci
  elif [ -f pnpm-lock.yaml ] && [ ! -d node_modules ] && command -v pnpm >/dev/null 2>&1; then
    pnpm install --frozen-lockfile
  elif [ -f yarn.lock ] && [ ! -d node_modules ] && command -v yarn >/dev/null 2>&1; then
    yarn install --frozen-lockfile
  fi
}

repo_root="$(resolve_repo_root)"
workspace_root="$(resolve_workspace_root "$repo_root")"

link_workspace_context "$repo_root" "$workspace_root"
update_git_excludes
install_node_dependencies_if_needed

echo "workspace=${CONDUCTOR_WORKSPACE_PATH:-$(pwd)}"
echo "repo_root=${CONDUCTOR_ROOT_PATH:-$repo_root}"
echo "workspace_root=${workspace_root:-unavailable}"
echo "conductor_port=${CONDUCTOR_PORT:-unassigned}"
ls -l ./kyle .context/workspace-AGENTS.md .context/workspace-CLAUDE.md .claude/agents ./.env.local 2>/dev/null || true
