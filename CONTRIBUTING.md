# Contributing

## Development

Run the starterkit checks before opening a pull request:

```bash
bash scripts/verify-starterkit.sh
bash skill/kyle-vault-workspace/scripts/verify-starterkit.sh
```

Run an install smoke test when changing installer behavior:

```bash
tmp="$(mktemp -d)"
mkdir -p "$tmp/repo"
git -C "$tmp/repo" init
bash skill/kyle-vault-workspace/scripts/install-starterkit.sh \
  --repo-root "$tmp/repo" \
  --workspace-root "$tmp" \
  --vault-name docs-vault \
  --with-onboarding
bash "$tmp/repo/scripts/test-conductor-setup.sh"
```

## Guidelines

- Keep the skill body concise.
- Put reusable output files under `skill/kyle-vault-workspace/assets/`.
- Preserve existing target files by default.
- Do not add dependencies unless they are needed for deterministic setup or verification.
- Avoid project-specific secrets, internal paths, or organization-specific policy text.
