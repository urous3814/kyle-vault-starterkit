#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
script="$repo_root/scripts/conductor-setup.sh"

[ -f "$script" ] || {
  echo "Missing $script" >&2
  exit 1
}

bash -n "$script"

grep -q 'CONDUCTOR_ROOT_PATH' "$script" || {
  echo "Setup script must use CONDUCTOR_ROOT_PATH" >&2
  exit 1
}

grep -q 'CONDUCTOR_PORT' "$script" || {
  echo "Setup script must mention CONDUCTOR_PORT for Conductor run scripts" >&2
  exit 1
}

grep -q 'CONDUCTOR_SETUP_SKIP_INSTALL' "$script" || {
  echo "Setup script must expose a skip-install path for verification" >&2
  exit 1
}

grep -q '/kyle' "$script" || {
  echo "Setup script must ignore or link ./kyle" >&2
  exit 1
}

grep -q '/.context/' "$script" || {
  echo "Setup script must ignore .context/" >&2
  exit 1
}

echo "conductor setup script check passed"
