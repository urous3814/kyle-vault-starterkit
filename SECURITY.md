# Security Policy

## Supported Versions

Only the default branch is actively maintained.

## Reporting A Vulnerability

Please report security issues privately through GitHub Security Advisories when available. If advisories are unavailable, open a minimal issue that does not include exploit details or secrets.

Do not include credentials, tokens, private keys, production URLs, or sensitive workspace paths in public issues.

## Scope

This starterkit creates local files, symlinks, and GitHub/Conductor-oriented setup scripts. Security-sensitive areas include:

- `.env.local` handling
- local symlink creation
- git exclude rules
- generated agent instructions
- Conductor setup scripts

The installer preserves existing files by default. Use `--force` only after reviewing backups and expected changes.
