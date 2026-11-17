# BẢN BÀN GIAO DỰ ÁN NAVITAXIMETER — CHU KỲ 8, LƯỢT 7/7

**Loại:** **BÀN GIAO BẮT BUỘC — LƯỢT 7/7** theo `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`.

**Thời điểm:** 17/11/2026, giờ Việt Nam UTC+07, sau khi nhận video A2-07A khoảng 07:09. **AI_REPLY_COUNT=7/7 khi hoàn tất lượt này**; cuộc trò chuyện mới khởi tạo 0/7, nếu tiếp tục chat hiện tại thì lượt tiếp theo là 8/14 và bàn giao tại 14/14, **không reset tự động giữa chat**.

**Phạm vi thực tế:** foundation Android Flutter/Kotlin + safety diagnostics DEBUG; nhiều ca GPS trên Xiaomi Android 13 đã **AI REVIEWED PHONE VIDEO/SCREENSHOTS** có giới hạn; **chưa có production TripLocationService/one SQLite writer, chưa được phép thu cước khách, chưa merge main**.

## Mốc xác minh cần đọc đầu tiên

- **Repo:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter. Chỉ ghi **`feature/navitaximeter-foundation`**. PR #1 https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1 **OPEN/DRAFT**. `main` và kho TTX tham chiếu **READ-ONLY**. Issue #2 https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2 **OPEN**; Issue #3 https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3 **OPEN**.
- **HEAD trước khi tạo file bàn giao này:** `ca74ad453c6eac6a871c77f299b146e11bad3537`, gồm commit chứng cứ A2-07A `b75e1cd70bc982afd8aa6a2e8586c37e4451212b` và update runbook `ca74ad453c6eac6a871c77f299b146e11bad3537`. Tạo file bàn giao, cập nhật state sau đó sẽ sinh SHA mới: **lấy lại HEAD và CI đúng SHA**, không báo SUCCESS của SHA trước cho SHA sau.
- **Code app đang được thử:** mốc mã `db4dcab34432c3a1c5a31903e30b0d0ff9b31def`; Foundation PR [43826864218](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43826864218) **SUCCESS**, Zero Cost PR [43826864300](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43826864300) **SUCCESS**. Mốc docs gần trước đó `9e80462f9ce759f39ca27391fbaeeb99da6a2b9c`: Foundation PR [43903252545](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43903252545) **SUCCESS**, Zero Cost PR [43903252549](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43903252549) **SUCCESS**. HEAD `8e7afa0f9f2d66a107566813ce1573240e3059e2`: Zero Cost PR [43983951135](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43983951135) **SUCCESS**, Foundation PR [43983951133](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43983951133) **CANCELLED** do concurrency, không gọi PASS. Không thay đổi app code ở Cycle 8.
- **APK:** `navitaximeter-native-gps-safety-DEBUG-only`, artifact tham chiếu ID `14216620325` từ Foundation [43846686647](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43846686647) SUCCESS, ZIP digest do GitHub công bố `sha256:a400d9d0182e6e1215d609b8b08b270cc3e2002bcc00ca8cbeb3c0668ea80713`. **SHA-256 APK đã giải nén và đúng binary đang cài trên Xiaomi vẫn UNVERIFIED**. Không yêu cầu gỡ/cài lại/xóa dữ liệu chỉ để đoán SHA.
- **Bằng chứng điện thoại mới nhất:** video MP4 **29,5506s** ngày 17/11 (đồng hồ ~07:08, user gửi ~07:09), Xiaomi Redmi Note 12 Pro/Android 13 do user xác nhận: **A2-07A Stop nhanh SAU ACK PASS THEO VIDEO UI**. Chỉ mô tả đã lược tọa độ tại `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md` mục 2H, Issue #2 comment **6933424447**. **Stop trước ACK và replay notification STOP của phiên cũ NOT TESTED**.
- **Cứng:** Zero Paid API 0 USD theo hợp đồng (cần 30-day cost audit), SQLite `navitaximeter_v1.db` v3 + `navi_confirmed_tariffs_v1` bảo toàn, no fake GPS/fare, no destructive migration, no passenger fares, GNSS/SQLite unclear ⇒ SUSPENDED, recovery PAUSED + RESUME thủ công.

## 3.1. Tổng quan dự án

NaviTaxiMeter là ứng dụng Android-first dành cho tài xế taxi tại Việt Nam, package/app id `vn.navitaximeter`, hướng tới đồng hồ cước theo GNSS thật và bảng giá tài xế xác nhận, hành trình, lịch sử/doanh thu, hóa đơn/biên nhận, chuyển khoản/VietQR được ngân hàng xác nhận và điều hướng bản đồ Việt Nam online/offline 2D/3D. Chỉ cân nhắc iOS sau khi Android ổn định. Không có tính năng thương mại đã được chủ dự án phê duyệt.

**Thiết kế trải nghiệm:** 7 màn hình đích gồm bản đồ Home, tìm địa chỉ/POI, tuyến/điểm dừng, điều hướng kết hợp đồng hồ cước, lịch sử/doanh thu, receipt/VietQR, cài đặt (bảng giá/xe/ngân hàng/backup/GPS diagnostics). Palette navy/cyan; 7 mockup người dùng đưa trong chat nguồn `IMG_4488.png` đến `IMG_4494.png` không tự suy luận là asset đã commit.

**Màn hiện có thực sự:** 5 tab `Trạng thái`, `Bảng giá`, `GPS thử`, `Phòng thử`, `GPS nền`; mục tiêu duy nhất hiện tại là thử/đo tính an toàn và lưu thử nội bộ, **không tính cước khách**.

## 3.2. Yêu cầu cứng phải bảo toàn

1. **Phạm vi code:** Flutter/Dart + Kotlin Android, Java 17 CI; chỉ ghi trên `feature/navitaximeter-foundation`; PR #1 Draft, không merge main, không sửa TTX, không rewrite history, signing key hay tự phát hành production.
2. **Zero Paid API tuyệt đối:** không tự thêm Google Billing, Maps/Places/Routes/Navigation SDK trả phí, Google Cloud Billing, paid tiles/paid routing, API key; mục tiêu chi phí 0 USD/tháng phải được kiểm 1/50/100 người dùng × 30 ngày, kiểm source không chứng minh hóa đơn cloud.
3. **Dữ liệu và tiền:** giữ `navitaximeter_v1.db` schema SQLite v3, `navi_confirmed_tariffs_v1`, frozen confirmed tariff, active route, immutable receipts; cấm xóa/cài lại app để reset dữ liệu; KHÔNG auto-migrate v4, tạo fare demo hoặc nhảy sang Kotlin monetary engine. Trước migration phải có backup, checksum, clone test, rollback và chủ dự án duyệt.
4. **GNSS/FGS:** không fake GPS/mock, không lấy map camera/network/coarse smoothing làm tiền; không nội suy quãng đường hoặc thời gian chờ qua khoảng mất tín hiệu; GPS/permission/provider/ACK/SQLite mơ hồ ⇒ **SUSPENDED fail-closed**. Sau crash/reboot/kill ⇒ **PAUSED**, tài xế tự RESUME với fix GNSS mới, segment mới.
5. **Kiến trúc mục tiêu:** **một** Android native GNSS/FGS owner và **một** durable app SQLite trip writer, ACK chỉ sau COMMIT/readback và được fence theo session/generation/seq. Prototype/test-only không chứng minh production.
6. **Bản đồ Việt Nam:** online/offline 2D/3D, tòa nhà 3D, đường/làn, mũi tên hướng đi, biển báo/giới hạn tốc độ, POI, địa chỉ, routing; tuân thủ bản quyền nguồn dữ liệu, ghi attribution, không scrape trái phép; kiểm hiển thị theo yêu cầu chủ dự án: **Biển Đông**, **Hoàng Sa** và **Trường Sa** thuộc Việt Nam, không hiển thị nhãn/ranh giới trái với yêu cầu đã chốt. Hiện **MAP RENDERER/SOVEREIGNTY CHECK NOT IMPLEMENTED/NOT TESTED**, không bịa PASS.
7. **Thanh toán:** chưa phát hành hóa đơn thương mại; VietQR chỉ sau khi ngân hàng/thông tin chuyển khoản được người dùng xác nhận, thử độc lập; không tự tạo giao dịch hoặc thu phí khách.
8. **Thử trên máy:** luôn áp dụng **NGUYÊN VĂN PHỤ LỤC A** dưới đây và `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` mục 9. Phải có ca, mục tiêu, bản APK/SHA/run, chuẩn bị, **nút chính xác**, từng bước, PASS/FAIL/NOT TESTED, ảnh/video che tọa độ/PII gửi trong chat, phân biệt CI/emulator và máy thật, tuyệt đối không thử khi có khách hay đang lái.
9. **Quy trình mã nguồn:** theo quy tắc 10 Phụ lục C, đọc `AGENTS.md` → handoff mới nhất → `.agents/skills/navi-code-commander/SKILL.md` → các skill `navi-*` liên quan → source/HEAD/CI → thay đổi tối thiểu + test; không đọc toàn bộ 29 skills.
10. **Bàn giao:** mỗi 7 lượt AI, lượt 7/14/21 phải lập hồ sơ đầy đủ độc lập 3.1–3.10 và phụ lục về điện thoại; cập nhật `docs/AI_HANDOFF_STATE.md`. Chat mới reset bộ đếm 0/7, cùng chat thì không tự reset.

## 3.3. Kiến trúc và dữ liệu hiện tại

```text
Flutter Android UI: Trạng thái | Bảng giá | GPS thử | Phòng thử | GPS nền
  - GPS thử: Geolocator Preview, read-only; không tính tiền, không lưu route
  - Phòng thử: Dart MeteredTripCoordinator + TaximeterEngine
      -> TripRepository SQLite v3 test/lab checkpoints; không fares khách
  - Bảng giá: tài xế xác nhận, SharedPreferences key riêng
  - GPS nền: Dart MethodChannel -> MainActivity Kotlin
      -> LocationOwnerRegistry process-local lease
      -> LocationSafetyService (non-exported location FGS)
      -> Android LocationManager + GnssFixTrustGate/GnssHealthPublication
      -> chỉ sức khỏe GPS / count / tuổi fix; không coordinates sang Dart,
         không ghi app SQLite, không tính tiền
  - DEBUG only: HeadlessSqliteProbeService, injected FlutterEngine /
    sqflite disposable DB, callback fence, ACK sau COMMIT/readback
  - Tests: Python SQLite transactional proof, Kotlin JVM protocol/owner,
    Dart FFI/sqlite and coordinator tests, Android 14 emulator DEBUG
FUTURE (NOT DEPLOYED):
  TripLocationService (ONE GNSS/FGS owner)
    -> typed session/generation/sequence IPC
    -> headless Dart TripSessionWorker (existing TaximeterEngine)
    -> ONE durable app DB writer (route/header/session fence/ACK)
    -> ACK strictly post-COMMIT; recovered PAUSED, manual RESUME
```

- `lib/src/data/trip_repository.dart` hiện lưu `trips`, `active_trip`, `active_trip_route` dưới SQLite v3; xử lý replay cùng seq (bản ghi giống là idempotent, khác tọa độ/tốc độ bị từ chối). Không có bảng sản xuất `checkpoint_fence` / `checkpoint_ack`.
- `android_native/TripCheckpointProtocol.kt` pure contract + fake writer; SQLite transaction test Python/FFI/Android DEBUG dùng DB rời và service probe thử, không phải **one real production writer**.
- `android_native/LocationOwnerRegistry.kt` giới hạn process-local owner, không là cross-process durable fence. `LocationSafetyService.kt` có FGS thông báo và nút Stop; ACK heartbeat không đồng nghĩa GNSS trusted hoặc tiền bền vững.
- Dependences: `geolocator`, `geolocator_android`, `sqflite`, `shared_preferences`, `crypto`, `path`. Không có online/offline map renderer, offline GIS dataset, Google Billing/paid SDK được cho phép ở production.

## 3.4. Công việc đã hoàn thành, phân loại bằng chứng

### Thành phần mã / CI có thật trước Cycle 8

- Flutter/Dart five-tab foundation, `GPS thử` read-only Geolocator Preview, `Phòng thử` MeteredTripCoordinator/TaximeterEngine, quản lý bảng giá đã xác nhận, SQLite v3 TripRepository checkpoint/replay conflict checks.
- Android `LocationOwnerRegistry` process-local lease, `MainActivity` MethodChannel, `LocationSafetyService` foreground health/heartbeat/native notification STOP, `GnssFixTrustGate` phân biệt physical GNSS/fine permission; chẩn đoán không chuyển tọa độ sang Flutter/money.
- Prototype `TripCheckpointProtocol.kt` dùng fake injected writer; Python standard-library SQLite real transaction proof trong DB **tạm**, `HeadlessSqliteProbeService` + Android 14 emulator dùng DB disposable DEBUG, FFI/JVM regression tests. **KHÔNG phải real production writer hoặc real GPS/fare end-to-end**.
- Lỗi Flutter Preview: `GPS_BUSY` từng bị UI cleanup ghi đè, sửa trong `8864154...`/`ca93b99...` và import `PlatformException` ở `db4dcab...`, CI đúng code SHA SUCCESS; trên Xiaomi đã quan sát `GPS_BUSY`.
- Mã nguồn app, Android SQLite v3, signing, tariff prefs **không sửa trong Cycle 8**; các commit Cycle 8 chỉ là markdown docs và issue comments.

### Cycle 8: công việc đã làm trên GitHub

1. A2-05b revoke **quyền Vị trí riêng của app**: tạo `docs/ISSUE_2_XIAOMI_ANDROID13_A2_05B_APP_PERMISSION_RUNBOOK_2026-11-16.md`; user video 51,93s cho thấy trước revoke native active/trusted/ACK, đổi sang `Không cho phép`, sau reopen stopped/fresh false/owner none/ACK false, sau cấp lại quyền không auto Start, user bấm Start thủ công; **PASS theo video UI có giới hạn**, evidence mục 2E, không chứng minh từng mili giây.
2. A2-05c **precise ON → approximate-only OFF**: tạo `docs/ISSUE_2_XIAOMI_ANDROID13_A2_05C_APPROXIMATE_ONLY_RUNBOOK_2026-11-16.md`; video 56,45s lúc 22:32 ngày 16/11 là **PARTIAL PASS** (trước đổi đang acquiring); video bổ sung 54,60s lúc 06:44 ngày 17/11 đã ghi **trusted_gps/fresh true trước downgrade**, sau reopen stopped/ACK false, và coarse-only Start thủ công có ACK true **nhưng GPS fresh false/acquiring/acceptedCount 0**. Nâng thành **PASS THEO VIDEO cho hai hành vi quan sát**, evidence mục 2F–2G; không chứng minh continuous in-process permission transition hoặc mọi OEM.
3. A2-07A **quick Stop sau ACK**: runbook `docs/ISSUE_2_XIAOMI_ANDROID13_A2_07_QUICK_STOP_AND_STALE_NOTIFICATION_PLAN_2026-11-17.md` commit `a590ecc686320d86eb376e0fe5b786de0166be79`; video 29,55s ngày 17/11 ghi start ~2–3s, native ACK true ~3–4s, Stop ~5s, stopped/owner none/ACK false ~6s và nhiều lần đọc 8–14s; chuyển sang `GPS thử`, Preview Start ~16s, nhận cập nhật vị trí ~19–21s (**không đưa tọa độ vào GitHub**), Stop Preview ~22–23s, native vẫn stopped ~24–28s. **A2-07A PASS THEO VIDEO/UI** tại evidence mục 2H, commit `b75e1cd70bc982afd8aa6a2e8586c37e4451212b`, runbook status commit `ca74ad453c6eac6a871c77f299b146e11bad3537`, Issue comment `6933424447`.
4. Đã liên tục ghi `docs/AI_HANDOFF_STATE.md` ở các lượt 1–6, phân loại đúng bằng chứng, bảo vệ thông tin GPS và không upload raw screenshots/videos. **Bản bàn giao 7/7 mới đang được tạo tại file này**.

### Ma trận kiểm thử thiết bị Xiaomi đã xác minh

| Ca | Trạng thái | Giới hạn |
| --- | --- | --- |
| A2-01 native Start/ACK/GNSS fresh | **PASS theo ảnh UI** | `trusted_gps` do app công bố; chưa independent calibration |
| A2-02 `GPS_BUSY`, exclusive owner và chuyển giao tuần tự | **PASS theo ảnh UI** | Chưa stress mọi race/OS FGS overlap |
| A2-03 Stop từ app, Stop từ notification **hiện tại** | **PASS theo ảnh UI** | Không thử notification Stop token cũ |
| A2-04 Home/khóa màn ~60s | **PASS có điều kiện** | Ảnh trước/sau, chưa chứng minh liên tục trong lúc khóa |
| A2-05a tắt Vị trí **toàn hệ thống** | **PASS theo video** | Reopen/state; không đo mọi transition |
| A2-05b app-level permission `Không cho phép` | **PASS theo video UI giới hạn** | Android có thể restart process; chưa đo microsecond |
| A2-05c precise→coarse-only | **PASS theo video 2 cho hai nhánh an toàn** | Đã có trusted trước downgrade; continuous in-process, OEM khác NOT VERIFIED |
| A2-07A quick Stop **SAU ACK**, Preview được lease sau teardown | **PASS theo video 29,55s** | Không kiểm Stop trước ACK, OS overlap độc lập |
| A2-07B replay notification STOP token cũ | **NOT TESTED / UI không hỗ trợ** | Cần DEBUG/instrumented harness có token; không dùng Stop notification thông thường làm thay |
| A2 pre-ACK Stop | **NOT TESTED / UI khóa Stop khi Start `_busy`** | Cần kỹ thuật test riêng |
| A2-06 Lab/SQLite fault trên máy | **NOT TESTED** | Không dùng giá demo, dữ liệu khách, DB hiện hành để bẻ khóa test |
| Android 11–16 thiết bị khác, Doze/kill/reboot, time-shift, lâu dài, OEM battery, production meter | **NOT TESTED** | Android 14 emulator/Python proof không chứng minh máy thật |

**Tổng hợp:** nền tảng DEBUG có bằng chứng đúng phạm vi, **chưa đạt Issue #2 tổng thể và tuyệt đối chưa đủ điều kiện tính cước khách**.

## 3.5. Công việc đang triển khai, điểm chính xác cần tiếp tục

- **Đã xử lý xong trong lượt 7:** đối chiếu video A2-07A, cập nhật evidence mục 2H và runbook, bình luận Issue #2; viết handoff Cycle 8. Không cần chủ dự án gửi lại clip hoặc làm lại A2-07A.
- **P0 Issue #2 đang OPEN:** còn `A2-07B` stale notification stop, pending-Start/Stop trước ACK, Android FGS OS-level observation và stress race; `A2-06` Lab/SQLite (chỉ khi không đụng dữ liệu chuyến thật); Doze/kill/reboot/clock change/OEM battery và thiết bị Android khác. Không ép user làm test bất khả thi chỉ vì nó xuất hiện trong ma trận.
- **P0 test-only code kế tiếp có thể cân nhắc**: thiết kế regression/instrumented DEBUG để tái phát `ACTION_STOP` mang old leaseId khi service new lease hoạt động. Điều kiện PASS: old STOP không hủy new lease, old START không phá current service, không có owner overlap; tests Kotlin JVM source + Android instrumented (nếu khả thi) + physical. Không thêm API điều khiển token trong bản release hoặc mở money. Cần đọc skills và kiểm source hiện tại trước khi chạm code.
- **P1 Issue #3 OPEN**: future real Android `TripLocationService` single GNSS owner + one durable app SQLite writer và ACK hậu COMMIT/readback theo session/generation/seq; vẫn design/proof DEBUG, chưa có app production integration. Thẩm định Dart worker uptime dưới FGS, migration v3 backup/rollback/receipt safety, storage-fault tests trước khi implement.
- **P2 UX/maps/finance**: 7 màn đích, 2D/3D buildings/roads/lanes/POI/online/offline, sovereignty Biển Đông/Hoàng Sa/Trường Sa, license/attribution, VietQR xác nhận ngân hàng, cost 1/50/100 ×30 ngày. Những mục này đa số **PLANNED/NOT VERIFIED**.
- **Công việc chờ người dùng:** hiện không yêu cầu thêm test ngay. Nếu có thiết bị hoặc muốn chạy ca mới, trước tiên **cung cấp từng bước đầy đủ** và xác nhận UI/APK phù hợp. Người dùng thao tác chủ yếu bằng điện thoại, không mặc định có PC/ADB.

## 3.6. Lỗi, rủi ro và vấn đề chưa giải quyết

**Đã fix xác minh:** Preview mất thông điệp `GPS_BUSY` và Flutter `PlatformException` import, code `db4dcab...`; Build/test SUCCESS SHA code đã ghi. Trên Xiaomi có phản hồi `GPS_BUSY`.

**Chưa được coi là lỗi đã sửa hoặc PASS:**
- `_busy` ở `safety_service_page.dart` khóa `Dừng GPS nền thử` trong `_start()`. Không thể chứng minh race pre-ACK bằng thao tác UI hiện tại. Cần DEBUG harness/source regression.
- Notification `PendingIntent` STOP có URI lease riêng; Android thay thông báo hiện hành. User không có cách tái phát old `PendingIntent` thực qua UI; stale-token test vẫn NOT TESTED. `LocationOwnerRegistry` fence hiện dùng process memory, không phải durable cross-process security.
- Mọi ACK ở `LocationSafetyService` chỉ là heartbeat của service, **không phải proof trusted GNSS** và hoàn toàn không là ACK app SQLite. FGS chưa có production trip writer/liveness guarantee, chưa báo sản phẩm dùng thu tiền.
- APK cài trên Xiaomi không chứng minh được hash; MIUI/HyperOS firmware, exact Android build, lifecycle logs/OS FGS state chưa có; 1 device Android 13 không đủ đại diện Android 11–16.
- Crash/reboot/Doze/force-stop, stale notification race, Lab SQLite injected failure, approximate-only continuous transition, real distance/rounding, 30-day billing/cost, legal map license/sov map QA, offline storage, backup/rollback chưa đủ chứng cứ.
- **Không có app charge bug mới được kết luận từ A2-07A.** Video chứng minh UI behaviour mà không chứng minh nguyên nhân OS-level hay trạng thái giữa các frame.
- Video A2-07A có trang `GPS thử` hiển thị tọa độ/địa chỉ kỹ thuật cá nhân: evidence chỉ được tóm tắt, **không upload raw file/frame và không sao chép dữ liệu tọa độ**.

## 3.7. Mã nguồn, tài liệu, lệnh kiểm thử, CI và rollback

**Repository:** `https://github.com/ThanhTaxiXanh/NaviTaxiMeter`; `feature/navitaximeter-foundation`, PR #1 Draft. Không dùng TTX tham chiếu làm working tree.

**Rule & handoffs:** `AGENTS.md`; `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`; `docs/AI_HANDOFF_STATE.md`; `docs/HANDOFF_2026-11-16_CYCLE7_7-7.md`; **`docs/HANDOFF_2026-11-17_CYCLE8_7-7.md`** (file này). `project/NaviTaxiMeter/README-INTEGRATION.md` và dossier là yêu cầu/đề xuất, không thay code đã xác minh. `.agents/skills/navi-code-commander/SKILL.md`, `navi-location-background`, `navi-github-actions`, `navi-safe-change`, `navi-red-green` tùy task, **chỉ đọc skill liên quan**.

**Android Kotlin:** `android_native/MainActivity.kt`; `LocationSafetyService.kt`; `LocationOwnerRegistry.kt`; `GnssFixTrustGate.kt`; `TripCheckpointProtocol.kt`; `HeadlessSqliteProbeService.kt`; tests Kotlin JVM theo `tool/bootstrap_android.py` vào Android Flutter skeleton.

**Flutter/Dart:** `lib/main.dart`; `lib/src/ui/safety_service_page.dart`, `gps_preview_page.dart`, `gps_lab_page.dart`, `tariff_management_page.dart`; `lib/src/core/metered_trip_coordinator.dart`; `lib/src/data/trip_repository.dart`; `lib/src/lab/headless_sqlite_probe.dart`, `debug_checkpoint_transport.dart`. Tests điển hình: `test/gps_preview_start_failure_test.dart`, `test/location_owner_gate_test.dart`, `test/trip_repository_ffi_test.dart`, Kotlin tests, Python `tool/test_checkpoint_sqlite_contract.py`. Không suy đoán tên các file ngoài source/handoff.

**Dữ liệu:** `navitaximeter_v1.db` SQLite schema 3 gồm `active_trip`, `active_trip_route`, `trips`; confirmed prefs `navi_confirmed_tariffs_v1`. Không copy/delete trực tiếp app data. Python `tool/checkpoint_sqlite_contract.py` dùng database test **disposable riêng**, không phải app DB. Chưa có map dataset production.

**GPS + evidence docs:** `docs/GPS_SINGLE_OWNER_INTERLOCK.md`, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, `docs/SQLITE_ACK_TRANSACTION_PROOF.md`, `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md` (mục 2E–2H), `docs/ISSUE_2_XIAOMI_ANDROID13_A2_05B_APP_PERMISSION_RUNBOOK_2026-11-16.md`, `docs/ISSUE_2_XIAOMI_ANDROID13_A2_05C_APPROXIMATE_ONLY_RUNBOOK_2026-11-16.md`, `docs/ISSUE_2_XIAOMI_ANDROID13_A2_07_QUICK_STOP_AND_STALE_NOTIFICATION_PLAN_2026-11-17.md`.

**Build/tests (tham khảo workflow chính thức, không tự nhận đã chạy ở lượt 7):** `.github/workflows/flutter-foundation.yml`, `.github/workflows/zero-cost-gate.yml`; GitHub CI tự chạy Flutter analyze/test, Android Kotlin Gradle JVM, Python SQLite proof, build APK Debug và Android 14 emulator DEBUG checks. Tại máy dev có Flutter SDK phù hợp: `flutter pub get`, `flutter analyze`, `flutter test`; Python: `python3 -m unittest discover -s tool -p 'test_checkpoint_sqlite_contract.py' -v`; Kotlin JVM test nằm trong generated Android skeleton bootstrapped bởi `tool/bootstrap_android.py` theo workflow. Không suy đoán lệnh chạy Gradle từ repo root nếu chưa kiểm workflow. Java 17. Người dùng chủ yếu trên điện thoại, không mặc định có CLI.

**Rollback:** chỉ `git revert` commit phạm vi trên feature branch nếu cần và có review/test; không force-push, không merge `main`, không xóa DB/cài lại để làm sạch, không tự migrate v4.

## 3.8. Kiến trúc / quyết định đã được chốt

- Đã dùng Android `LocationManager` và Geolocator để lấy dữ liệu GPS; không mua API GPS, không giả lập sensor. Health FGS khác hoàn toàn production trip service. Không lặp lại chỉ test emulator nếu đã có bug/phone evidence cụ thể.
- Source UI fix được kiểm bằng điện thoại; bảo đảm owner chỉ ở phạm vi kịch bản thử, không công bố single owner production đã được chứng nhận.
- Tiếp tục nền tảng tiền Dart và v3 app DB, không di chuyển money engine native không có parity/approval; design one native owner + one durable writer phải review theo future protocol.
- Fail-closed/PAUSED/manual RESUME, no backfill, no billing, no unapproved schema/paid map, không khách thật. Quy trình 7/7 và bảo mật evidence là phần không thể bỏ.

## 3.9. Kế hoạch ưu tiên chính xác cho phiên tiếp theo

| Ưu tiên | Việc cần làm | Quy trình và PASS/giới hạn |
| --- | --- | --- |
| P0.1 | **Kiểm HEAD/CI thật** sau commit handoff/state | Mở branch feature và PR #1, xem SHA, các PR runs Foundation/Zero Cost đúng SHA, job/test result và artifact; phân biệt SUCCESS/CANCELLED/IN_PROGRESS, không coi cancelled là PASS |
| P0.2 | **Giữ chứng cứ A2-07A** không test lặp | Xem evidence mục 2H + Issue #2 comment 6933424447, xác nhận A2-07A PASS theo UI, Stop pre-ACK và stale notification STOP NOT TESTED, không yêu cầu user đưa lại clip |
| P0.3 | **Thiết kế test-only stale token/pre-ACK harness** khi có nhiệm vụ phát triển | Đọc quy tắc 10/skills; review Kotlin token + race; viết test tối thiểu cô lập không sửa production trip; CI đúng SHA, Android instrumentation nếu có; test lease cũ không dừng phiên mới, pending Start/Stop không leak owner |
| P0.4 | **Hoàn thiện Issue #2 trên máy thật** khi ca có thể thao tác | Trước mọi test đưa mã ca, thiết bị Android 13, Debug APK/run/hash-status, quyền, chính xác các nút, từng bước/chờ, expected PASS/FAIL/NOT TESTED, cách gửi ảnh/video đã che PII **theo nguyên văn Phụ lục A**. Chỉ phân loại bằng chứng đã quan sát; không đưa tọa độ vào GitHub |
| P1 | **Issue #3 native GNSS owner + durable app SQLite writer design** | Quyết định one writer, session/generation/seq, post-COMMIT ACK/readback, v3 backup/rollback, Dart parity, crash recovery PAUSED/manual RESUME; không implement thương mại trước approval |
| P2 | **Bản đồ, dữ liệu, VietQR, cost & release gate** | Bản đồ Việt Nam sovereignty/licensing, 2D/3D/road/POI/offline, VietQR được xác nhận, 30-day 1/50/100 zero-cost audit, OEM matrix + physical calibration + owner approval |

**BẮT BUỘC với bất kỳ yêu cầu test điện thoại nào:** dùng nguyên văn `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` mục 9 và **Phụ lục A** bên dưới. Người dùng đã trực tiếp nhắc lại ngày 17/11 rằng chỉ nói “test Stop nhanh và thông báo Stop phiên cũ” mà **không hướng dẫn từng bước** là không đạt yêu cầu. Chỉ giao ca user thực hiện được; **không bảo user cố tìm nút pre-ACK hoặc notification cũ**.

## 3.10. Chỉ thị bắt buộc cho AI ở cuộc trò chuyện mới

1. **Đọc đầy đủ** file handoff Cycle 8 này, mục 3.1–3.10 và toàn văn **PHỤ LỤC A/C**, `AGENTS.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, `docs/AI_HANDOFF_STATE.md`; sau đó `.agents/skills/navi-code-commander/SKILL.md` và các skills `navi-*` đúng nhiệm vụ. Không đọc tràn 29 skills.
2. Xác minh repo GitHub, chỉ ghi `feature/navitaximeter-foundation`, PR #1 phải OPEN/DRAFT, Issue #2/#3 OPEN, `main`/TTX READ-ONLY. Không force push, merge, billing/key, commercial release, signing change nếu không có chủ dự án duyệt.
3. **Mới chat đặt AI_REPLY_COUNT=0/7**, lượt AI hoàn tất +1, bàn giao bắt buộc 7/14/21…; nếu đang tiếp tục chat cũ thì lượt 8/14 sau file này, không reset.
4. Không yêu cầu người dùng nhắc lại model Xiaomi/Android 13 hoặc làm lại A2-05a/b/c, A2-07A và các ca PASS; chỉ hướng dẫn chi tiết đúng phần chưa kiểm. A2-07A Stop after ACK **PASS video**, A2-07B stale token/pre-ACK **NOT TESTED**, A2-06 **NOT TESTED**.
5. **No passenger fare**. Health service không sở hữu meter/SQLite, không chuyển GPS giả/smoothed/numeric acceptedCount thành quãng đường/tiền. GNSS/permission/provider/heartbeat/DB unknown => SUSPENDED, recovery PAUSED với tài xế tự RESUME + GNSS fresh segment.
6. SQLite v3 + confirmed tariff prefs/receipts/routes bất biến, không reset/migrate thực, không dùng fake tariffs. Future one production GNSS owner + one durable app SQLite writer fenced ACK hậu COMMIT **NOT IMPLEMENTED**.
7. No Google Billing/paid APIs/Maps SDK; maps 2D/3D Việt Nam + Biển Đông/Hoàng Sa/Trường Sa sovereignty và attribution/licensing vẫn phải thẩm định. Không báo map complete nếu chưa có code/tests thực.
8. Khi user gửi video/ảnh GPS, **xem trực tiếp**, mô tả mốc chính xác, phân loại PASS/FAIL/NOT TESTED; **KHÔNG copy tọa độ, địa chỉ, notifications, tài khoản, file gốc hay ảnh riêng tư ra GitHub**. Khi có lỗi thật, tạo issue riêng với steps sanitized, không đoán.
9. Mỗi lần chỉnh code kiểm `AGENTS.md` → handoff → commander → relevant skill → source/HEAD/CI → minimal regression → evidence đúng SHA; xem CI earliest primary failure, rollback an toàn, không nhận emulator làm physical device proof.
10. Sau mỗi lượt ghi state, trước bàn giao mới 7/7 viết đầy đủ 3.1–3.10 và chép **PHỤ LỤC A/C nguyên vẹn**, báo đường dẫn file & HEAD/CI. Nếu không truy cập được repo, không giả SHA/test.
11. **Theo sát quy tắc yêu cầu test điện thoại** ở Phụ lục A (đặc biệt nút/tab thật, PASS/FAIL/NOT TESTED, video riêng tư). **Theo sát quy tắc source/skills** ở Phụ lục C trước mọi code.
12. **Lệnh khởi động chat mới:** “Tiếp quản NaviTaxiMeter từ `docs/HANDOFF_2026-11-17_CYCLE8_7-7.md`; đọc 3.1–3.10 và Phụ lục A/C; chỉ ghi nhánh feature, PR Draft, Issue #2/#3 OPEN; không cước khách/paid API. Xiaomi Android 13 A2-07A Stop sau ACK PASS video, stale token/pre-ACK NOT TESTED; Issue #3 production one owner+writer NOT IMPLEMENTED; hãy đối chiếu HEAD/CI mới nhất và tiếp tục đúng phần dở. Reset AI_REPLY_COUNT=0/7 chỉ khi chat mới.”


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

## PHỤ LỤC B — MA TRẬN CHỨNG CỨ VÀ THÔNG SỐ ĐIỆN THOẠI

- Thiết bị người dùng khai báo **Xiaomi Redmi Note 12 Pro, Android 13**; firmware MIUI/HyperOS phiên bản cụ thể **UNVERIFIED**. User chủ yếu thao tác trên điện thoại; không mặc định có máy tính/ADB. Quyền `Chỉ cho phép khi dùng ứng dụng`, precise ON/OFF tùy từng test; sau video A2-05c 06:44 user để precise OFF, trước A2-07A được yêu cầu precise ON nhưng video A2-07A **không tự chứng minh Android settings chính xác tại thời điểm đó**. Đừng gán quyền đã bật chỉ từ instruction.
- Source code commit `db4dcab...` CI SUCCESS; installed APK hash **UNVERIFIED**, ZIP digest chỉ xác nhận artifact ZIP. Các video Android là **AI REVIEWED PHONE EVIDENCE** theo UI, không GNSS/monetary independent audit.
- A2-05a provider OFF 56,5s video PASS; A2-05b revoke app permission 51,93s video PASS; A2-05c video 56,45s partial + video 54,60s PASS các hành vi có chứng cứ; A2-07A video 29,55s PASS sau ACK. A2-01/02/03 ảnh PASS UI, A2-04 khóa màn conditional PASS. **Không đăng video/ảnh raw**.
- A2-07A mốc: ~3s native ACK; ~5s Stop; ~6s owner none/ACK false; ~16s Geolocator Preview start; ~19–21s có mẫu GPS thật **có tọa độ nhạy cảm trong video** (đã cố tình không ghi); ~22s Stop Preview; ~24–28s native vẫn stopped. Không có OS-level FGS overlap log, pre-ACK Stop hoặc stale notification replay.
- Bằng chứng cần tiếp tục: A2-06 SQLite Lab nếu có điều kiện bảo vệ dữ liệu; Android Doze/kill/reboot, clock/OS permission/notification, Android 11–16 matrix; stale PendingIntent requires debug harness.
- Phân loại **PASS** chỉ cho từng phần có bằng chứng; Issue #2 OPEN, Issue #3 OPEN, product **NOT READY FOR PASSENGER FARES**.


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
