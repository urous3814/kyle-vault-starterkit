# Vault Foldering Rules

Status: active

## Purpose

Keep shared agent context searchable and durable. The vault is for decisions, product context, operating rules, handoffs, and planning records. It is not a scratchpad for generated build output or repo-local runtime state.

## Standard Folders

Use numbered top-level folders so agents can infer document ownership quickly:

```text
kyle/
├── AGENT_ENTRY.md
├── Index.md
├── 01-product/      # product requirements, user flows, policy context
├── 02-design/       # design system, visual decisions, UX references
├── 03-engineering/  # architecture, technical plans, API/data contracts
├── 04-ops/          # deployment, runbooks, environment, reliability
├── 05-checklists/   # acceptance, manual QA, launch, regression lists
├── 06-ops/          # agent conventions, live log, foldering, onboarding
├── 07-critique/     # reviews, audits, risk findings, adversarial checks
├── 08-security/     # security model, permissions, audit, threat notes
└── assets/          # source materials, screenshots, policy files, starterkits
```

If a project has stronger domain folders, keep its existing names and preserve these responsibilities. Do not rename a mature vault just to match this template.

## Placement Rules

- Product requirements and user-facing behavior go in `01-product`.
- Visual design decisions, screenshots, and design-system notes go in `02-design`.
- Architecture, schema, API, migration, and implementation plans go in `03-engineering` unless a project-specific domain folder is more precise.
- Deployment, local setup, incident notes, and runbooks go in `04-ops` or the existing ops folder.
- Checklists go in `05-checklists`.
- Agent operating rules, live logs, deprecated decisions, foldering rules, and onboarding go in `06-ops`.
- Reviews, critiques, and independent verification handoffs go in `07-critique`.
- Auth, authorization, privacy, secrets, audit logging, and threat model documents go in `08-security`.
- Raw source materials and reusable templates go in `assets`.

## Naming

- Use lowercase kebab-case filenames: `admin-permission-plan.md`.
- Prefix dates only when the date is part of the record identity: `review-2026-06-09.md`.
- Prefer one durable document per decision area over scattered notes.
- When a document becomes obsolete, add an entry to [[deprecated-decisions]] instead of deleting useful history.

## Indexing

- Link all planning documents from `Index.md` under `Planning Hub`.
- Link operational rules from the ops section.
- Keep links short and descriptive.
- If an agent creates a planning/design document, it must update `Index.md` in the same pass.

## Live Log

- `agent-live-log.json` is append-only.
- Start, blocker, handoff, and completion entries should name the current workspace, branch, touched files, and verification evidence.
- Never edit older entries to make history look cleaner.
