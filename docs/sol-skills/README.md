# NaviTaxiMeter SOL Coding Skills | Repository Integration

This branch integrates 29 NaviTaxiMeter coding skill topics in `.agents/skills/navi-*/` (each with `SKILL.md` and `agents/openai.yaml`) plus 12 dossier files under `project/NaviTaxiMeter/`. These are **repo-adapted and reconciled** versions of prior user download packages, not bitwise copies of the old ZIP files. See `project/NaviTaxiMeter/README-INTEGRATION.md` for precedence and known conflicts.

## Quick use
- Start at repository `AGENTS.md`, then `.agents/skills/navi-code-commander/SKILL.md`.
- Pick a specific skill for the task and read current `docs/HANDOFF_2026-11-16_CYCLE4_7-7.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`.
- Leave `main` and PR #1 merge state untouched.
- No SDK enabling Google Billing/paid Maps without owner decision, even if the older dossier requested Google Maps UI.
- For all reports, label actual GitHub Actions run and committed SHA. Passing a source scan does not prove real-cost or Android GNSS field checks.

## Skill scope
29 procedures: repo mapping, spec, architecture, safe changes, TDD, root cause, review, Actions, location, trip, tariff, waiting, QR, revenue, backup, data migration, maps, speed data, map QA, UI, tests, profiling, privacy, signing and handoff.

## Evidence baseline
Integration adds **documentation/skills only**; no runtime Flutter/Android files, CI workflows, databases or keystores are modified by these commits.
