# Agent Live Log

Status: active
JSON file: `agent-live-log.json`

## Purpose

Track parallel agent work, handoffs, blockers, and completion evidence in one append-only file.

## Rules

- Append-only: do not edit or delete existing entries.
- Add a new entry for start, major status transition, handoff, blocker, and completion.
- Each entry is independent.
- Timestamps use ISO 8601.
- Values must be JSON-compatible.

## Entry Shape

```json
{
  "timestamp": "2026-01-01T09:00:00+09:00",
  "agent": "Codex",
  "workspace": "main/example",
  "branch": "feature/example",
  "type": "start",
  "summary": "Short task summary",
  "files": [],
  "verification": [],
  "blockers": []
}
```
