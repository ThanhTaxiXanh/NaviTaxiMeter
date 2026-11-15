# NaviTaxiMeter - AI handoff checkpoint (15/11/2026)

AI_REPLY_COUNT = 5/7 after this reply. On the seventh assistant reply, write a FULL self-contained handoff (not merely a summary), including repository, branch, all commits, CI evidence, decisions, source code paths, risks, blockers, outstanding approvals and next exact steps. New chat resets the counter.

Project: NaviTaxiMeter, separate Android Flutter/Dart + Kotlin when needed. Repo ThanhTaxiXanh/NaviTaxiMeter. Working branch feature/navitaximeter-foundation, PR #1 DRAFT, NEVER merge to main without owner permission. Original independent TTX-AATaximeter source repo (feature/flutter-taximeter-foundation, SHA a40c246de6fd3799aaddedce3ed0d3b1d9dd524d) MUST NOT be edited.

Previous verified commits: foundation 17fcb86d3a2acf0249a393ad825bee105af3f1b3 (0.1.0+1), confirmed tariffs+GPS preview f7aac734041d3c6f0a9999c1218352b5f11c1ed2 (0.1.1+2), metered coordinator checkpoint + immutable receipt 0e21de0ed690f49562b9e223fd6d5ef3ce58939a (0.1.2+3). Current task version 0.1.3+4 adds actual Android GPS test-lab page, safety admission gate and compiled APK manifest verification; read GitHub branch HEAD for exact new commit SHA. Prior CI for 0.1.2+3 flutter tests / code scan / debug build SUCCESS. Verify fresh CI for 0.1.3+4.

Required source paths:
lib/main.dart (4 tabs, non-operational caution)
lib/src/ui/gps_lab_page.dart (NEW: live GPS laboratory UI, never displays money or emits receipts, LAB marker, permission/foreground stream, force suspend on activity pause, confirm deliberate clearing of test-only active checkpoint)
lib/src/ui/gps_preview_page.dart (read-only GPS)
lib/src/ui/tariff_management_page.dart (confirmed driver tariff)
lib/src/core/lab_session_safety.dart (NEW: trusted fresh GPS, confirmed tariff, visible activity, subscribed stream)
lib/src/core/metered_trip_coordinator.dart (validated GPS, SQLite checkpoint, forced suspension, manual resume, immutable receipt save methods)
lib/src/data/trip_repository.dart (SQLite v3 active_trip + active_trip_route, atomic completed receipt, disallow overwrite)
lib/src/domain/confirmed_tariffs.dart
tool/bootstrap_android.py
tool/verify_apk_manifest.py (NEW binary APK manifest verification)
tool/test_verify_apk_manifest.py
.github/workflows/flutter-foundation.yml
.github/workflows/zero-cost-gate.yml
docs/PHASE2_LAB_ANDROID_GPS.md (this release)

Hard constraints: no Google Cloud billing activation, no paid APIs, no invented GPS/fare/turns, separation GPS-meter vs smoothed map, 7 user-provided mockups (dark navy/cyan), locally verified taxi fares, VietQR cash/bank-only, local SQLite, 1/50/100 stress plan, Vietnam map publishing/license review, no merge main or TTX modifications, no claim operational taxi certification. No device or signed release verified.

Follow-up: inspect workflow results, fix compile/aapt if needed. Next implement independent Kotlin Android location FGS ownership, durable coordinator lifecycle, lab-only device tests and strict watchdog. Passenger-facing charging must stay blocked until validated. End current reply with "Trạng thái bàn giao: 5/7".
