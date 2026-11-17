# NaviTaxiMeter | Handoff Template

**MANDATORY:** Read `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, including rules for assistant reply count and mobile testing. If counter cannot be verified, mark `KHÔNG XÁC MINH ĐƯỢC` and hand off early rather than guessing.

## 3.1 Overview
Name/package, scope, stage, hardware access and user workflow (iPhone-only).

## 3.2 Hard constraints
Branch and Draft PR protection, zero paid API, no fake fare/GPS, SQLite v3 safety, privacy, live provenance, sovereignty presentation requirement and physical phone test instructions.

## 3.3 Architecture
Actual UI/service/GPS/fare/SQLite path, ownership, IPC, lifecycle, data schema and state machine; explicitly separate test-only from production.

## 3.4 Work done
Changes by exact commit and files, observed Actions runs and results. Never recycle a past run to claim the latest commit passed.

## 3.5 Outstanding
Issue links, failures, unknown tests, blockers, reversible next small step.

## 3.6–3.10
Technical decisions, outstanding risks, test on phone steps with expected/actual, reproducible diagnostics, project continuation and safe rollback. Redact secrets/GPS/bank numbers.

**Current canonical reference:** `docs/HANDOFF_2026-11-16_CYCLE4_7-7.md` until a newer live handoff supersedes it.
