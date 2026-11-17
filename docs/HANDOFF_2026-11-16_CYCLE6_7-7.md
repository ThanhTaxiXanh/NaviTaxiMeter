# BẢN BÀN GIAO DỰ ÁN — NAVITAXIMETER

**Loại: BÀN GIAO BẮT BUỘC — LƯỢT 7/7 (CHU KỲ 6).**  
**Thời điểm:** 16/11/2026, múi giờ Việt Nam UTC+07; sau tin người dùng 13:01:42 UTC+07.  
**Trạng thái:** Android DEBUG foundation và GNSS safety proof PASS CI ở code SHA; issue #2 physical NOT TESTED; Issue #3 production NOT IMPLEMENTED.  
**AI_REPLY_COUNT hiện tại:** 7/7; cuộc trò chuyện **mới** reset 0/7; nếu ở lại cùng chat, lần tiếp theo là 8, bàn giao tiếp ở 14/21...

## Bằng chứng điều khiển và thay đổi ưu tiên quan trọng nhất

- Repository: `ThanhTaxiXanh/NaviTaxiMeter`; **nhánh DUY NHẤT được ghi**: `feature/navitaximeter-foundation`; PR #1 https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1 **OPEN/DRAFT/chưa merge**. Không ghi `main` hoặc TTX reference; không force push.
- **Mốc code CI đã xác minh:** `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24`. Foundation PR run https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43811708123 **SUCCESS, build-test và Android 14 emulator**. Zero Cost PR run https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43811708180 **SUCCESS**. Push Foundation cùng SHA có thể CANCELLED do concurrency; ưu tiên PR run đúng SHA.
- Issue #2 https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2 **OPEN / NOT TESTED ON PHYSICAL ANDROID**. Issue #3 https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3 **OPEN / one production GNSS owner & one production SQLite writer CHƯA LÀM**.
- **Thay đổi ưu tiên theo câu hỏi của chủ dự án lượt 7:** KHÔNG tiếp tục lặp lại GNSS mock/JVM/emulator khi chưa có lỗi thực; **ưu tiên ngay Issue #2 trên điện thoại Android thật** với APK/đúng nút/bằng chứng. Song song nghiên cứu đường production thực sự của Issue #3, không coi DEBUG proof là sản phẩm.
- **APK test có thật đã được tải và kiểm tra bytes:** trong run 43811708123, artifact GitHub ID `14200424290`, `navitaximeter-native-gps-safety-DEBUG-only`, ZIP SHA-256 `363824f62aa6d02ed50c380a38f452a9fb182b8b2d42af123a529bc0fb623cd5`. ZIP chỉ chứa `app-debug.apk`, 165929486 bytes, **APK SHA-256 `7ec6a8bbd39252cc27663566f6c280110ab23fb235a54fae71b6d73962dc540e`**. Đã kiểm từ ZIP thật bằng Python/hashlib trong môi trường của cuộc trò chuyện lượt 7, không phải hash suy đoán. Đường sandbox tạm của chat có thể không dùng lại được trong chat mới; GitHub Actions artifact là nguồn tái tải. **Không có báo cáo test vật lý**. Xem `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`.
- Handoff docs mới nằm tại `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md` và trạng thái đếm ở `docs/AI_HANDOFF_STATE.md`. **Lưu ý SHA HEAD đổi sau commit tài liệu; KHÔNG chuyển kết quả CI code SHA sang docs SHA**, phải kiểm lại Actions của HEAD.

## 3.1. Tổng quan dự án

- NaviTaxiMeter, Flutter app `navitaximeter`, Android applicationId `vn.navitaximeter`, Android-first cho tài xế taxi Việt Nam, iOS sau khi Android ổn định.
- Sản phẩm kỳ vọng: đồng hồ tính tiền chính xác theo GNSS thật và tariff lái xe xác nhận, lịch sử chuyến/doanh thu/receipt, tiền mặt/chuyển khoản/VietQR, bản đồ VN 2D/3D online/offline, điều hướng. Code hiện tại là nền tảng kỹ thuật và các trang thử; CHƯA được phép tính cước hành khách.
- Chủ dự án có thể thao tác chỉ bằng điện thoại; hướng dẫn thử Android phải không mặc định PC/ADB. **Bài test cần điện thoại Android thực, iPhone không thể cài APK**.
- 7 ảnh mockup 863×1822 trong chat nguồn: `IMG_4488.png` đến `IMG_4494.png`, chưa đảm bảo ở GitHub/chat mới.

## 3.2. Yêu cầu cứng không được thay đổi

1. **Nền tảng:** Flutter/Dart + Kotlin Android + Java 17 CI, Android trước; không tự ý chuyển sang Kotlin fare engine hoặc iOS.
2. **Zero Paid API:** không Google Billing/Google Maps SDK/Places/Routes/paid tile/Navigation trả phí; chi phí 0 USD/tháng là mục tiêu cần audit 1/50/100 người dùng × 30 ngày, source-only gate không phải invoice audit.
3. **GIS/bản đồ:** Việt Nam online/offline 2D/3D, đường/làn, POI/địa chỉ, biển báo/giới hạn tốc độ, camera hướng/thu phóng, dẫn đường và công trình 3D khi có nguồn hợp pháp; ghi attribution, không scrape tiles hoặc bịa dữ liệu. Tiêu chí hiển thị theo chủ dự án: **Biển Đông**, Hoàng Sa và Trường Sa thuộc Việt Nam, cần kiểm style/dataset thực khi triển khai; hiện NOT TESTED.
4. **GPS tính tiền:** chỉ fix GNSS vật lý đã xác minh; network/coarse/mock/stale/camera smoothing không thay. Không nội suy km/thời gian khi mất tín hiệu. Mất GPS, FGS, quyền, SQLite/ACK => **SUSPENDED fail-closed**; recovery **PAUSED**, tài xế RESUME thủ công từ fresh fix/route segment mới.
5. **Kiến trúc mục tiêu:** một Kotlin `TripLocationService` là GNSS/FGS owner, một service-owned headless Dart `TripSessionWorker` dùng existing `TaximeterEngine` và **một** SQLite writer duy nhất. Đây vẫn là **ADR chưa production**.
6. **Dữ liệu:** `navitaximeter_v1.db` SQLite schema **v3**; SharedPreferences `navi_confirmed_tariffs_v1`; frozen confirmed tariff; receipt bất biến; không tự migrate v4, xóa DB, thay prefs, hoặc sửa dữ liệu tài xế; backup+hash+rollback trước migration tương lai.
7. **Tiền và hiệu chuẩn:** tài xế xác nhận tariff, không dùng demo, mock GNSS hoặc số liệu ảo cho cước; kiểm cự ly/waiting/grace/BOT/surcharge/discount/rounding/receipt; chỉ tiền mặt/chuyển khoản, VietQR từ thông tin ngân hàng đã được xác nhận và kiểm app ngân hàng.
8. **UI:** bảy màn tiếng Việt đã yêu cầu: Home bản đồ, tìm địa chỉ/POI, tuyến/điểm dừng, navigation+meter, history/doanh thu, receipt/VietQR, settings; thêm tariff, xe, ngân hàng, backup, GPS diagnostics. Palette navy/cyan chủ đạo, 7 mockup nói trên. Camera FOLLOW_HEADING/NORTH/FREE_EXPLORE/RECENTER/TRIP_OVERVIEW; mục tiêu mượt ~60 FPS, phải benchmark Android thật.
9. **Git/release:** chỉ `feature/navitaximeter-foundation`; PR #1 Draft; không merge main, không sửa TTX, không ký release, không bật Google Billing/Paid API, không khai thác thương mại trước explicit owner approval.
10. **Quy tắc test điện thoại, không được bỏ:** **đọc nguyên văn PHỤ LỤC A ở cuối file** và `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` mục 9. Không được yêu cầu thử với nút giả định, không test khách thật; phải cung cấp APK/run/SHA, các bước, PASS/FAIL/NOT TESTED, bằng chứng che thông tin và cách gửi AI.

## 3.3. Kiến trúc hệ thống, module, SDK và dữ liệu

**Hiện có (CHỈ runtime kỹ thuật):**

```text
Flutter UI: 5 tab Trạng thái | Bảng giá | GPS thử | Phòng thử | GPS nền
  |- Preview geolocator -> Android GPS stream (no fare)
  |- GPS Lab -> MeteredTripCoordinator -> Dart TaximeterEngine
  |                                  -> TripRepository -> sqflite v3 app DB
  |- tariff -> SharedPreferences confirmed tariff
  '- MainActivity MethodChannel -> LocationOwnerRegistry (process-local lease)
                                  -> LocationSafetyService Android FGS
                                      -> LocationManager GPS + GnssFixTrustGate
                                      -> aggregate health ONLY; no coords/SQLite/fare

DEBUG manifest only:
HeadlessSqliteProbeService (bound, not GNSS-FGS)
 -> independent FlutterEngine -> Dart headlessSqliteProbeMain
 -> disposable SQLite probe/callback fence/lease post-COMMIT readback

FUTURE, NOT WIRED:
TripLocationService native GNSS owner -> typed session/generation/seq IPC
 -> service-owned headless TripSessionWorker -> staged TaximeterEngine candidate
 -> single app DB transaction(route + header + tariff fence + ack ledger)
 -> post-COMMIT ACK -> committed-only UI / recovery PAUSED
```

- `lib/src/data/trip_repository.dart` v3 tables: `trips`, `active_trip`, `active_trip_route`. `saveActiveIncremental` validates equal replay, rejects different route rows, begin initial fix and header atomically. No production `checkpoint_fence` / `checkpoint_ack` tables.
- `android_native/LocationSafetyService.kt` does use Android `LocationManager.requestLocationUpdates` and FGS notification, but health only. `GnssFixTrustGate.kt` requires GPS provider, fine permission, reasonable accuracy/monotonic timestamps, locks on fault; `GnssHealthPublication` guards `fresh` from stale state. **No antenna attestation or passenger GNSS proof**.
- `LocationOwnerRegistry` process-local lease prevents Preview/Lab/Native overlapping in healthy process, but Android 11–16/OEM physical proof still needed.
- Pure Kotlin `TripCheckpointProtocol` has fake `AtomicTripCheckpointWriter` in JVM tests, no real native trip DB.
- Python `DISPOSABLE_TEST_ONLY.db` real SQLite transaction proof, Dart sqflite FFI fixtures/clone, emulator DEBUG disposable DB proof are distinct from actual production app writer, no automatic schema v4 migration.
- Dart dependencies include `geolocator`, `geolocator_android`, `sqflite`, `shared_preferences`, `path`, `crypto`; Flutter stable, Android Gradle/Java 17. No production map renderer, paid Maps SDK or offline map dataset integrated.

## 3.4. Công việc đã hoàn thành, có bằng chứng

- Trước chu kỳ 6: Kotlin owner registry, location health/FGS, Dart coordinator and DB v3 consistency, staged copy-on-write state, tariff confirmation, Python 12 transaction tests, Kotlin protocol fake writer, Flutter FFI tests, Android14 DEBUG probe pipeline. Chi tiết lịch sử tại `docs/HANDOFF_2026-11-16_CYCLE5_7-7.md`.
- **Chu kỳ 6, lượt 1:** `0e73d2e1dc150faf354630541f6b112170763a2b`: test Android Service khi writer lease đang bị chiếm. `e5b37d6b4da77f223366c252c012025a5410660f`: verifier XML bắt buộc 3 instrumented tests. `3a9bae2681420db30d4f392c4b38e18db775c1bf`: cập nhật handoff state.
- **Lượt 2:** `4dac227f22816d1a0a9bcddf5ecb9f5dea174759`: fix import JUnit assertNull; `b319d77c15969fd4cae4777d7d5898ffaea318b2`: isolate callback RuntimeException khi Service teardown. Foundation PR 43803533022 SUCCESS, Zero Cost 43803533033 SUCCESS.
- **Lượt 3:** `347f50745bb8b80f799d4031b73c5e302271f674`: kiểm tra lease tại ACK delivery; `67e80be7727a701aa57cc31e20802d482376c600`: update static Python assertion; `65104dc613ce4de9f99ca3c979950d3d88c67c38`: state. Foundation PR 43805570648 SUCCESS, Zero Cost 43805570643 SUCCESS.
- **Lượt 4:** `628e5ca8e4f0d3e8b2f12fd8840e833e705efe9f`: Android instrumentation 4th callback-after-destroy test + strict XML; `7fcfeb11452ad3e913cc42324899b9c0f289f64c`: Python source gate adapted. Foundation PR 43807137317 SUCCESS, Zero Cost 43807137292 SUCCESS.
- **Lượt 5:** `c2ba39c7d1232247ec720641eb429fb58bf7b317`: `GnssFixTrustGate`, 6 JVM metadata tests, wired into `LocationSafetyService`; Foundation PR 43809329429 SUCCESS, Zero Cost 43809329511 SUCCESS.
- **Lượt 6:** `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24`: `GnssHealthPublication` fresh requires trusted status + heartbeat; +2 JVM tests + Python assertion; Foundation PR **43811708123 SUCCESS build-test & Android14 emulator**, Zero Cost PR **43811708180 SUCCESS**.
- **Lượt 7:** no new product code. Retrieved **real CI debug APK ZIP and verified SHA-256 of ZIP AND extracted APK**, prepared repeatable phone instructions `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`. This is a completed **test preparation**, **not** physical test execution.
- External cost reality: source gate passes but no 30-day cloud invoice/charge verification, maps licensing audit or physical GNSS accuracy calibration; DO NOT claim commercial release.

## 3.5. Công việc đang triển khai và điểm tiếp nối chính xác

1. **P0 Issue #2 physical (user explicitly reprioritized):** use exact verified DEBUG APK from code SHA `fff1c65...`, run guided A2-01...A2-05 on actual Android, collect redacted phone model/OS/permissions/observations, mark each PASS/FAIL/NOT TESTED, investigate failures before more emulation. User's ability to provide an Android handset has NOT been confirmed. Do not imply test happened automatically.
2. **P1 Issue #3 production:** native `TripLocationService` ONE GNSS/FGS owner, service-owned Dart TripSessionWorker with ONE durable app SQLite writer, typed session/generation/sequence; gate GNSS trust; after COMMIT/readback ACK; process kill/timeout/replay recovery PAUSED. **Not implemented**.
3. **P2 backup/migration compatibility:** clone v3+confirmed prefs, hash/preflight/rollback before any schema v4 durable ACK change; protect immutable historical receipts and real app data. NO automatic migration.
4. **P3 Android 11–16/OEM, battery saver, Home/lock, notification stale token, forced kill, Doze, reboot, process/power issue, independent distance/fare calibration**. Avoid passenger charging until explicit project-owner release approval.
5. **P4 7-screen UI, Việt Nam map labels/borders/licensing, offline/online 2D/3D, bank-verified VietQR and Zero Paid API 30-day audit**. Not integrated.

## 3.6. Lỗi đã sửa và vấn đề còn mở

- Lượt 1/2 Kotlin `assertNull` unresolved caused Foundation fail run 43801904302; fixed `4dac227f`, later CI PASS.
- Lượt 3 `tool/test_bootstrap_android.py` expected obsolete `callbackFence.resolve(requestId, result, null)`, failed runs 43805338505 / 43805338478; fixed `67e80be`, later PASS.
- Lượt 4 Python source assertion assumed 2 call sites; new test hook introduced third call; fail 43807082760; fixed `7fcfeb11`, later PASS.
- GNSS safety health previously accepted NETWORK_PROVIDER if accurate and could expose stale fresh on provider state change; fixed `c2ba39c7`, `fff1c65a`, both exact-SHA CI PASS. This does NOT certify real GNSS.
- Open: no physical Android Issue #2 results; no native production TripLocationService; no production DB transaction ACK/stream lifecycle; no fsync/power-cut claim; no 30-day cost/permissions/OEM evidence; no signed release/approval; schema v4 and data backup not authorized.
- Potential compatibility risk: `GnssFixTrustGate` locks health on any rejected sample, may be conservative on real device. Collect real-device behaviour, do not silently weaken fail-closed for convenience.

## 3.7. Mã nguồn, tệp quan trọng, CI/rollback

- Kotlin native: `android_native/MainActivity.kt`, `LocationOwnerRegistry.kt`, `LocationSafetyService.kt`, `GnssFixTrustGate.kt`, `GnssFixTrustGateTest.kt`, `TripCheckpointProtocol.kt` and test, `DebugWriterOwnershipRegistry.kt`, `HeadlessSqliteProbeService.kt`, `HeadlessSqliteProbeInstrumentedTest.kt`, `HeadlessProbeCallbackFence.kt` and test.
- Flutter/Dart: `lib/main.dart`, `lib/src/ui/gps_preview_page.dart`, `gps_lab_page.dart`, `safety_service_page.dart`, `lib/src/core/metered_trip_coordinator.dart`, `lib/src/data/trip_repository.dart`, `lib/src/lab/debug_checkpoint_transport.dart`, `lib/src/lab/headless_sqlite_probe.dart`.
- Test/bootstrap: `tool/bootstrap_android.py`, `tool/test_bootstrap_android.py`, `tool/verify_android_probe_results.py`, `tool/test_verify_android_probe_results.py`; workflow `.github/workflows/flutter-foundation.yml` uses `flutter create`, bootstrap twice incl check, Python, Kotlin JVM, Flutter analyze/test/build DEBUG APK and Android14 emulator `connectedDebugAndroidTest` with executed XML. `zero-cost-gate.yml` is source-only.
- Docs: `AGENTS.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, `docs/AI_HANDOFF_STATE.md`, `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, `docs/GPS_SINGLE_OWNER_INTERLOCK.md`, `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`, this handoff.
- Rollback any code commit only via `git revert` on **feature** with CI evidence. No reset DB or history, no force push; keep PR Draft. GitHub connector usable directly, no local Flutter/Android SDK guaranteed.

## 3.8. Quyết định kỹ thuật đã thống nhất

- Android already provides location via `LocationManager`; no need to invent another GPS service/device/API. Geolocator is adapter for Flutter UI labs. Distinguish receiving a location from trusting real GNSS/background availability and money durability.
- Do not waste further cycles only building emulator probes when physical Issue #2 is blocked; use verified APK + redacted phone evidence now. A missing Android phone cannot be emulated into a real-device PASS.
- Preserve one Kotlin GNSS owner + service-owned Dart fare/SQLite writer as design candidate, pending physical and migration/transaction proof; do not port Dart money algorithm to Kotlin without parity and approval.
- Fail closed GPS and ACK, no backfill, recovery PAUSED/manual RESUME. No fake routes/tariffs/QR, no paid maps, no auto schema v4, no passenger fares.
- Test-only Python/JVM/DEBUG Android proofs stay isolated; process-local lease not a durable cross-process fence; do not advertise DEBUG APK as production.

## 3.9. Kế hoạch ưu tiên sau bàn giao và tiêu chí

| Ưu tiên | Đầu việc | Tiêu chí |
|---|---|---|
| **0** | Xác minh docs HEAD mới / CI, PR Draft và artifact code SHA | Đọc lại live branch, CI runs theo SHA; code baseline fff1c65a SUCCESS |
| **1** | **Issue #2 trên Android thật**, hỏi đúng 1 thông tin còn thiếu: có điện thoại Android model/OS nào? | Dùng hướng dẫn `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`, APK SHA, mỗi ca A2-01...05 có PASS/FAIL/NOT TESTED và ảnh/log che tọa độ, gửi trong chat |
| 2 | Điều tra mọi FAIL trên thiết bị, tách follow-up issue | Chi tiết bước tái hiện, OEM/OS/permission, expected/actual, no made-up PASS |
| 3 | Issue #3 single native owner + one durable app DB writer | Real post-COMMIT fence/ACK, lifecycle, no duplicate fare, test hardware + migration-on-clone |
| 4 | SQLite v3 backup+Prefs/checksum/rollback, future v4 only if approved | Bảo toàn receipts/active routes/tariffs; no data loss |
| 5 | 7 màn sản phẩm, GIS Việt Nam/licensing, tính cước độc lập, VietQR, Android release | UI/device evidence, bank QR validation, Zero Paid audit, project owner approval |

**Nhắc quy tắc điện thoại:** phải dùng đầy đủ **Phụ lục A** bên dưới, đúng tên nút/tab, chạy thử không có hành khách, không cần PC/ADB, PASS/FAIL/NOT TESTED, upload ảnh/video đã che tọa độ vào chat. Không có Android thì Issue #2 vẫn NOT TESTED, ghi blocker, không tạo PASS máy ảo. APK code commit `fff1c65a` có sẵn và SHA256 đã kiểm.

## 3.10. Chỉ thị bắt buộc cho AI tiếp quản

1. Đọc **từ đầu hết toàn bộ** bản bàn giao này, mục 3.1–3.10, Phụ lục A; tiếp đó `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` và các tài liệu phù hợp.
2. Trước mọi code change đọc `AGENTS.md` → **handoff mới nhất** → `.agents/skills/navi-code-commander/SKILL.md` → skill trực tiếp liên quan (`navi-location-background`, `navi-safe-change`, `navi-red-green`, `navi-github-actions`, `navi-root-cause` nếu lỗi) → HEAD/CI/current source. Không đọc toàn bộ 29 skills.
3. Chat mới reset `AI_REPLY_COUNT=0`, mỗi câu trả lời xong +1, lượt 7/14... lại bàn giao. Nếu vẫn chat cũ sau 7/7 thì lượt 8, không reset tùy tiện.
4. Kiểm branch `feature/navitaximeter-foundation`, PR #1 DRAFT/unmerged, issues #2/#3 OPEN, workflows theo **exact HEAD SHA**; main/TTX reference chỉ đọc; không force push.
5. Chủ dự án đã yêu cầu giải thích vì sao GPS test lâu: **GPS Android đã dùng rồi**, các debug safety tests cần thiết nhưng đã đi quá lâu, **ưu tiên Issue #2 trực tiếp**. Không lặp lại test mô phỏng chỉ vì chưa biết chạy gì tiếp.
6. APK đã xác minh tại code SHA `fff1c65a`, SHA256 `7ec6a8...540e`, run 43811708123, artifact 14200424290. Cung cấp đường tải tin cậy và hướng dẫn nút chính xác; không dùng APK/sha bất kỳ, không buộc người dùng có PC.
7. Test Android phải phân biệt run CI/emulator, người dùng báo kết quả và AI đã đối chiếu bằng chứng; nếu chưa có bằng chứng, Issue #2 **NOT TESTED**. Gửi ảnh/video che GPS coords, khách/ngân hàng/keystore/nhạy cảm trong chat, không post public.
8. Issue #3 production **không được coi đã xong**: no TripLocationService production, no one durable v3 writer/fence, no proof kill/OEM/fare lifecycle; mọi uncertain path => SUSPENDED/recovery PAUSED, manual RESUME/new GNSS; no fake GPS.
9. Không sửa user DB SQLite v3, confirmed prefs, immutable receipts, không migration tự động, không Google Billing/paid APIs, không ký release hay thu cước khách. Chỉ được xem xét sau physical distance/rounding + data backup + licensing/cost + owner explicit approval.
10. Duy trì `docs/AI_HANDOFF_STATE.md`, bằng chứng SHA CI, links và Issue #2 per-case evidence. Nếu chi tiết không kiểm được ghi rõ **NOT TESTED/UNVERIFIED**, không đoán.

### Lệnh khởi động chat mới

> Tiếp quản **NaviTaxiMeter** từ `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md`, đọc hết 3.1–3.10, Phụ lục A, `AGENTS.md`, quy tắc 7 lượt, code commander skill, và HEAD/CI. Reset AI_REPLY_COUNT=0 trong chat mới. Chỉ ghi `feature/navitaximeter-foundation`; PR #1 Draft, main/TTX read-only, Zero Paid API, không thu cước. Code SHA `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24` Foundation run 43811708123 SUCCESS, Zero Cost run 43811708180 SUCCESS. APK DEBUG artifact 14200424290 đã xác minh, APK SHA-256 `7ec6a8bbd39252cc27663566f6c280110ab23fb235a54fae71b6d73962dc540e`. **ƯU TIÊN ngay Issue #2 Android thật** với `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`, theo từng nút/bằng chứng riêng tư; chưa có phone results => NOT TESTED. Issue #3 one native GNSS owner + one durable production writer vẫn NOT IMPLEMENTED. Không làm thêm emulator proof nếu không có lỗi thực.

---

## PHỤ LỤC A — NGUYÊN VĂN QUY TẮC 9: TEST/CHỨNG CỨ ĐIỆN THOẠI

## 9. QUY TẮC CỨNG BỔ SUNG: HƯỚNG DẪN KIỂM THỬ/KIỂM CHỨNG TRÊN ĐIỆN THOẠI
**Ngày bổ sung:** 15/11/2026. **Mức độ ưu tiên:** BẮT BUỘC, áp dụng xuyên suốt NaviTaxiMeter và mọi chu kỳ bàn giao 7 lượt.

**Nguyên văn yêu cầu của chủ dự án:**
> Nếu muốn tôi kiểm thử hay kiểm chứng trên điện thoại thì phải hướng dẫn chi tiết, kiểm thử cái gì, kiểm chứng cái gì, làm thế nào để cho bạn biết là đã kiểm thử hay kiểm chứng thành công để đưa cho bạn xem.

**Quy tắc thực thi cho AI:**
1. Mỗi khi nhờ chủ dự án kiểm thử/kiểm chứng trên điện thoại, **bắt buộc cung cấp một quy trình thao tác cụ thể, theo từng bước**, phù hợp người dùng chủ yếu vận hành qua điện thoại, không mặc nhiên có máy tính hoặc ADB.
2. Trước khi thao tác, ghi rõ **mục tiêu đang kiểm thử**, chức năng/rủi ro cần kiểm chứng, mã commit SHA, loại bản Android APK (DEBUG/RELEASE), link GitHub Actions/artifact khi đã xác minh, điều kiện tiên quyết, Android/OEM và trạng thái quyền GPS cần quan sát. Không đặt link/artifact không tồn tại, không nhận CI PASS thay cho kiểm thử điện thoại thật.
3. Hướng dẫn **cách tải, cài và mở đúng bản APK thử nghiệm**, có cảnh báo về nguồn tải hoặc giới hạn cài đặt; hướng dẫn chính xác nút/màn/tab cần mở, thứ tự bấm, thời gian chờ hoặc dấu hiệu nhìn thấy. Nếu chưa có đúng bản APK hoặc tính năng kiểm chứng thì ghi **CHƯA THỂ TEST**, không yêu cầu bấm nút giả định.
4. Với **mỗi ca test**, trình bày: (a) đang thử điều gì; (b) từng bước thao tác; (c) **kết quả mong đợi (PASS)**; (d) dấu hiệu **FAIL** và lúc nào phải dừng; (e) cách xử lý nếu không thấy nút hoặc màn hình khác tài liệu. Không dùng chỉ dẫn mơ hồ như “thử GPS rồi báo lại”.
5. Ghi rõ **cần thu thập bằng chứng gì**, chụp ảnh màn hình/video/ghi lại biểu hiện ở đúng bước, cách tìm phiên bản Android và model thiết bị, thời gian test, quyền vị trí, tình trạng khóa màn hình, mã APK/run/SHA. Có thể dùng checklist ngắn để người dùng chỉ việc điền **PASS / FAIL / NOT TESTED** và mô tả điều quan sát thực tế.
6. Hướng dẫn **gửi bằng chứng về cho AI** ngay trong cuộc trò chuyện: đính kèm ảnh/video hoặc văn bản, kèm mã ca test, bước số, kết quả quan sát được và thông tin máy/phiên bản Android đã kiểm tra. AI phải nêu tiêu chí để đối chiếu và **chỉ công nhận PASS sau khi bằng chứng đủ rõ**; nếu chưa đủ thì đánh dấu **CHƯA XÁC MINH**, chỉ yêu cầu bổ sung phần thiếu.
7. **Quy tắc riêng về bảo mật:** ảnh/video/log phải che hoặc cắt bỏ tọa độ, địa chỉ nhà, hành trình khách, số tài khoản ngân hàng, thông báo riêng tư, mã token, API key, keystore và dữ liệu cá nhân. Không yêu cầu đăng công khai bằng chứng nhạy cảm lên GitHub; không thu phí khách, không dùng hành khách thật để thử; nếu hành vi GPS/FGS không an toàn thì dừng ngay.
8. Luôn phân biệt **“đã chạy thao tác”**, **“người dùng báo PASS”**, **“AI đã đối chiếu bằng chứng”**, **“CI PASS”** và **“Android vật lý được kiểm chứng”**. Chưa quan sát được không được suy diễn là PASS. Nếu test FAIL, ghi nguyên hiện tượng, bước tái hiện và điều kiện; không đánh dấu issue #2 hoặc #3 hoàn tất trước khi có bằng chứng đầy đủ.
9. Khi có bản bàn giao 7/7, **phải chép nguyên vẹn quy tắc bổ sung này hoặc liên kết kèm đầy đủ văn bản và nhắc bắt buộc** trong mục 3.2, 3.9 và 3.10 để AI tiếp quản áp dụng từ lượt đầu tiên. Bản quy tắc phải lưu trong repository NaviTaxiMeter trên nhánh được phép, không sửa TTX/main.

**Mẫu tối thiểu cho mỗi yêu cầu test điện thoại:** `Mã ca | Mục tiêu | APK/SHA | Chuẩn bị | Bước 1,2,3... | PASS khi | FAIL khi | Bằng chứng cần chụp | Cách gửi AI | Kết quả PASS/FAIL/NOT TESTED`.

**Quy tắc này không cấp phép triển khai production:** vẫn giữ Zero Paid API, single GNSS owner, fail-closed/PAUSED, không Billing, không thương mại và không merge main.
---

---

## PHỤ LỤC B — TÌNH TRẠNG GATE THIẾT BỊ

- Đã có APK TEST DEBUG verifiable, code SHA+ZIP SHA+APK SHA. **Không có kết quả điện thoại Android vật lý hoặc đồng ý của chủ dự án về model/OEM để thử.**
- Năm tab đang có: Trạng thái, Bảng giá, GPS thử, Phòng thử, GPS nền. Tên nút chắc chắn từ source: GPS nền `Bật GPS nền thử`, `Dừng GPS nền thử`, `Đọc lại trạng thái`, dialog `Bật dịch vụ thử`, notification action `Dừng GPS an toàn`, GPS thử `Bắt đầu xem GPS`/`Dừng GPS thử`.
- Test matrix step-by-step `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`. Checklist toàn bộ **NOT TESTED** trước khi người dùng cung cấp bằng chứng.
- User can use direct verified APK link in current chat, but temporary sandbox path not portable to new chat. Alternative GitHub run artifact ID 14200424290 while available.

---

## PHỤ LỤC C — NGUYÊN VĂN QUY TẮC 10: ĐỌC HỒ SƠ VÀ SKILLS

## 10. QUY TẮC CỨNG: ĐỌC AGENTS.md, BÀN GIAO VÀ CHỌN SKILL THEO NHIỆM VỤ

**Ngày bổ sung:** 16/11/2026. **Mức độ:** BẮT BUỘC cho mọi nhiệm vụ phát triển mã nguồn NaviTaxiMeter.

1. **Trước mọi nhiệm vụ phát triển mã nguồn**, đọc `AGENTS.md` tại gốc repository NaviTaxiMeter; kiểm tra **hồ sơ bàn giao mới nhất** và đối chiếu HEAD/CI thực tế, không dựa vào bản bàn giao cũ khi repository đã thay đổi.
2. Sau đó đọc `.agents/skills/navi-code-commander/SKILL.md` để xác định và chọn đúng kỹ năng chuyên môn `navi-*` cho nhiệm vụ hiện tại. Đọc nội dung từng skill được chọn trước khi áp dụng.
3. **Không kích hoạt hoặc đọc toàn bộ 29 skills theo mặc định.** Chỉ sử dụng kỹ năng liên quan trực tiếp; bổ sung skill khác khi phạm vi công việc thực sự đòi hỏi.
4. Mọi thay đổi phải tuân thủ **bảo vệ dữ liệu và quyền riêng tư**, giới hạn nhánh GitHub được phép, PR Draft, kiểm thử và bằng chứng CI theo đúng SHA, quy tắc **Zero Paid API**; tuyệt đối không tự bật Google Billing, API trả phí hoặc thay đổi dữ liệu chuyến xe thật.
5. Phân biệt **đã đề xuất / đã viết / đã kiểm thử / chưa xác minh**. Không dùng kết quả emulator, JVM hoặc source scan để tuyên bố Android vật lý, GNSS production, chi phí thực tế hoặc tính cước hành khách đã đạt.
6. Mỗi lần bàn giao 7/7 phải nhắc lại quy trình này để AI tiếp quản thực hiện **trước khi chỉnh sửa mã nguồn**.

**Thứ tự bắt buộc:** `AGENTS.md` → hồ sơ bàn giao mới nhất → `.agents/skills/navi-code-commander/SKILL.md` → skill chuyên môn liên quan → kiểm tra HEAD/CI/source → thay đổi tối thiểu → kiểm thử và báo cáo bằng chứng.
