# Issue #3 P2: Typed Dart IPC / one-writer contract (TEST ONLY)

Date: 2026-11-15. STATUS: experimental contract, no passenger fares.

Two source/test files:
- lib/src/lab/trip_ipc_contract.dart
- test/trip_ipc_contract_test.dart

This is a pure Dart IPC-envelope validator and serialized test-writer queue. It is NOT connected to Android MethodChannel, native GNSS, Flutter UI, TaximeterEngine, the real TripRepository, or the application SQLite database. It does not write route, receipt, fare, billing, or positions. It uses test-only opaque SHA-256-shaped hashes, not customer data.

Protocol proposal v1: sessionId, positive generation, zero-based sequence, GNSS elapsedRealtimeNanos, accuracyMeters, speedKmh, mocked, frozen tariff hash, and payload hash. ACK v1: same fence+sequence+hash and checkpointId, emitted only AFTER an injected writer Future resolves with matching identity. Conflicting replay, sequence gaps, timestamp discontinuity, mock/bad metadata, changed tariff or uncertainty => PAUSED. A stale session generation cannot mutate or suspend the current gate. A gate-level ACK delivery uncertainty immediately PAUSES, without automatic replay. Tests cover concurrent eight calls, exact duplicates/conflicts, writer failure, mismatched claims and late callback.

CONTRACT IS NOT DURABILITY: tests use a fake writer returning IpcCommitProof. This result can be fabricated by a fake; neither it nor the Dart queue proves SQLite COMMIT, flash persistence, process restart recovery, GNSS physical provenance or Android FGS ownership. A hash field is not provenance proof. Real GNSS metadata must be independently verified natively and in the future Dart worker. The persistent session/generation/sequence fence must come from the DB, not the current in-memory counters. No staging/meter state integration is implemented.

Next issue #3 gate: on anonymized COPIES of app schema v3 and confirmed SharedPreferences, test consistent backup/hash/restore, dry-run v3->v4 fence + ACK ledger and rollback; build an actual service-owned single sqflite writer with immutable staged candidate and route+header+fence+ACK ledger in one transaction. Inject before/after COMMIT and lost ACK, always recover PAUSED/manual RESUME. Keep production schema v3 intact until approved and tested. Issue #2 physical Android remains OPEN and NOT TESTED.

Previous verified Android 14 headless SQLite debug probe on 85cfa50: Foundation run 43725473578 SUCCESS. This does not prove new contract tests or production trip ACK. Check CI for the exact commit containing this note. No merge to main, no TTX edits, no Google Billing or paid APIs, no customer metering, no release approval.
