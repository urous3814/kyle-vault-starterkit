#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
starterkit_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
skill_dir="$starterkit_root/skill/kyle-vault-workspace"

required_files=(
  "$starterkit_root/README.md"
  "$skill_dir/SKILL.md"
  "$skill_dir/scripts/install-starterkit.sh"
  "$skill_dir/scripts/verify-starterkit.sh"
  "$skill_dir/assets/repo/AGENTS.md"
  "$skill_dir/assets/repo/CLAUDE.md"
  "$skill_dir/assets/repo/conductor.json"
  "$skill_dir/assets/repo/scripts/conductor-setup.sh"
  "$skill_dir/assets/repo/scripts/test-conductor-setup.sh"
  "$skill_dir/assets/workspace/AGENTS.md"
  "$skill_dir/assets/workspace/CLAUDE.md"
  "$skill_dir/assets/vault/AGENT_ENTRY.md"
  "$skill_dir/assets/vault/Index.md"
  "$skill_dir/assets/vault/06-ops/development-conventions.md"
  "$skill_dir/assets/vault/06-ops/agent-live-log.md"
  "$skill_dir/assets/vault/06-ops/agent-live-log.json"
  "$skill_dir/assets/vault/06-ops/deprecated-decisions.md"
  "$skill_dir/assets/vault/06-ops/vault-foldering-rules.md"
  "$skill_dir/assets/optional/vault/06-ops/ONBOARDING.md"
)

for file in "${required_files[@]}"; do
  [ -f "$file" ] || fail "missing required file: ${file#$starterkit_root/}"
done

grep -q 'install-starterkit.sh' "$starterkit_root/README.md" ||
  fail "README.md must explain how to run install-starterkit.sh"
grep -q -- '--with-onboarding' "$starterkit_root/README.md" ||
  fail "README.md must document onboarding creation"
grep -q 'verify-starterkit.sh' "$starterkit_root/README.md" ||
  fail "README.md must document starterkit verification"
grep -q -- '--vault-name' "$starterkit_root/README.md" ||
  fail "README.md must document vault name configuration"

grep -q '^name: kyle-vault-workspace$' "$skill_dir/SKILL.md" ||
  fail "SKILL.md must define name: kyle-vault-workspace"
grep -q '^description: .*Conductor' "$skill_dir/SKILL.md" ||
  fail "SKILL.md description must mention Conductor so it triggers for Conductor setup"

for script in \
  "$skill_dir/scripts/install-starterkit.sh" \
  "$skill_dir/scripts/verify-starterkit.sh" \
  "$skill_dir/assets/repo/scripts/conductor-setup.sh" \
  "$skill_dir/assets/repo/scripts/test-conductor-setup.sh"; do
  bash -n "$script" || fail "shell syntax failed: ${script#$starterkit_root/}"
done

json_check() {
  local json_file="$1"
  if command -v jq >/dev/null 2>&1; then
    jq empty "$json_file" >/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$json_file" >/dev/null
  elif command -v node >/dev/null 2>&1; then
    node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$json_file"
  else
    fail "no JSON validator found for ${json_file#$starterkit_root/}"
  fi
}

json_check "$skill_dir/assets/repo/conductor.json"
json_check "$skill_dir/assets/vault/06-ops/agent-live-log.json"

grep -q 'Conductor owns workspace/worktree creation' "$skill_dir/assets/repo/AGENTS.md" ||
  fail "repo AGENTS.md must include Conductor worktree ownership rule"
grep -q 'Use ./kyle as the shared vault when it exists' "$skill_dir/assets/repo/AGENTS.md" ||
  fail "repo AGENTS.md must include ./kyle shared vault fallback rule"
grep -q 'CONDUCTOR_PORT' "$skill_dir/assets/repo/scripts/conductor-setup.sh" ||
  fail "conductor setup script must mention CONDUCTOR_PORT guidance"
grep -q 'CONDUCTOR_ROOT_PATH' "$skill_dir/assets/repo/scripts/conductor-setup.sh" ||
  fail "conductor setup script must use CONDUCTOR_ROOT_PATH"
grep -q 'STARTERKIT_DRY_RUN' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must support dry-run mode"
grep -q 'STARTERKIT_FORCE' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must support explicit force mode"
grep -q 'STARTERKIT_CREATE_ONBOARDING' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must support onboarding creation control"
grep -q 'STARTERKIT_VAULT_NAME' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must support configurable vault name"
grep -q -- '--vault-name' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must support --vault-name"
grep -q -- '--with-onboarding' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must support --with-onboarding"
grep -q -- '--no-onboarding' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must support --no-onboarding"
grep -q 'read -r onboarding_answer' "$skill_dir/scripts/install-starterkit.sh" ||
  fail "installer must ask before creating ONBOARDING.md in interactive mode"
grep -q '01-product' "$skill_dir/assets/vault/06-ops/vault-foldering-rules.md" ||
  fail "vault foldering rules must describe numbered domain folders"
grep -q 'ONBOARDING.md' "$skill_dir/assets/vault/Index.md" ||
  fail "Index must mention optional ONBOARDING.md"

if grep -R -nE '\b(T[B]D|T[O]DO|F[I]XME)\b' "$skill_dir" >/tmp/kyle-starterkit-placeholders.$$ 2>/dev/null; then
  cat /tmp/kyle-starterkit-placeholders.$$ >&2
  rm -f /tmp/kyle-starterkit-placeholders.$$
  fail "starterkit contains unresolved placeholders"
fi
rm -f /tmp/kyle-starterkit-placeholders.$$

printf 'starterkit verification passed: %s\n' "$skill_dir"
