# BẢN BÀN GIAO DỰ ÁN NAVITAXIMETER — CHU KỲ 7, LƯỢT 7/7

**Ngày:** 16/11/2026, múi giờ Việt Nam UTC+07. **Trạng thái:** Foundation Flutter/Kotlin DEBUG có CI PASS; các phép thử UI/GPS nền thật trên Xiaomi Android 13 đã tiến triển qua A2-05; ứng dụng **CHƯA ĐƯỢC PHÉP THU CƯỚC KHÁCH**.  
**AI_REPLY_COUNT:** **7/7** khi kết thúc lượt AI hiện tại. Mở cuộc trò chuyện mới thì khởi tạo 0/7; nếu tiếp tục cùng chat thì lượt tiếp theo là 8/7, tạo bản bàn giao lần tới tại lượt 14/14 (mỗi bội số 7), không tự reset.

## Mốc xác minh quan trọng nhất

- **Repository:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter. **Nhánh DUY NHẤT được ghi:** `feature/navitaximeter-foundation`. **PR #1:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1, **OPEN / DRAFT / chưa merge**. `main` và kho TTX tham chiếu **READ-ONLY**, không force push.
- **Issue #2:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2, **OPEN**. Có bằng chứng Android thật, nhưng **chỉ đạt theo từng ca đã quan sát**, chưa đạt ma trận Android 11–16 và tình huống lỗi hiếm. **Issue #3:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3, **OPEN**; một TripLocationService production và một writer SQLite ứng dụng bền vững **CHƯA IMPLEMENT**.
- **HEAD trước lượt bàn giao file này:** `6dccc485d0138b176c8ba1150eede6e680e046f7` (docs-only evidence). Các commit tài liệu bàn giao/cập nhật trạng thái ngay sau mốc này sẽ làm HEAD thay đổi: **phải truy vấn HEAD mới và CI đúng SHA**, không gán PASS của SHA cũ cho SHA mới.
- **Mốc code hiện hành đã xác minh:** `db4dcab34432c3a1c5a31903e30b0d0ff9b31def`, Flutter/Kotlin/Android DEBUG [Foundation CI 43826864218](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43826864218) **SUCCESS**, [Zero Cost 43826864300](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43826864300) **SUCCESS**. Mốc docs trước video `68c0c915482bddd797db4786898261e9e89088cf` có [Foundation CI 43830682170](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43830682170) **SUCCESS** và Zero Cost 43830682148 **SUCCESS**, cùng SHA. Không suy diễn Android vật lý từ CI.
- **APK DEBUG gốc đã xác minh ZIP + APK:** code SHA `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24`, Foundation run `43811708123` SUCCESS, artifact `14200424290`, ZIP SHA-256 `363824f62aa6d02ed50c380a38f452a9fb182b8b2d42af123a529bc0fb623cd5`, extracted APK SHA-256 `7ec6a8bbd39252cc27663566f6c280110ab23fb235a54fae71b6d73962dc540e`. **APK DEBUG mới** từ code `db4dcab...` ở artifact `14206464796`, GitHub artifact ZIP digest `fc6f2ac2eb1b46a0efb454827a86b61fef22602cf95fbbb43de42ad75c69cc5d`; **chưa xác minh riêng extracted APK SHA trên máy**. Không khẳng định bản cài trên Xiaomi có hash nào chỉ từ màn hình.
- **Thiết bị vật lý:** chủ dự án khai báo **Xiaomi Redmi Note 12 Pro, Android 13**, MIUI/HyperOS build **CHƯA XÁC MINH**; không cần PC/ADB. Ảnh/video người dùng gửi riêng đã đối chiếu nhưng KHÔNG đăng public vì có dữ liệu vị trí/định danh nhạy cảm. Bản ghi chỉ thông tin kỹ thuật: `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md`.

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

## 3.4. Công việc đã hoàn thành có bằng chứng

**Trước và trong Cycle 6:** Kotlin native GPS health, lease/token safety, heartbeat ACK, Stop thông báo, GNSS source/fresh gate; Dart fare-domain/confirmed tariff, lab, SQLite v3 route durability/replay, Python real SQLite transaction proof và Kotlin/JVM contract, DEBUG Android 14 emulator. Xem `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md` và `docs/HANDOFF_2026-11-16_CYCLE5_7-7.md` cho danh sách commit cũ không được làm mất.

**Cycle 7, công việc repo:**
- Chuẩn bị runbook dành cho Xiaomi `docs/ISSUE_2_XIAOMI_REDMI_NOTE_12_PRO_ANDROID13_RUNBOOK_2026-11-16.md`, commit `98933437ec20a0ad55931ee8a9e3aeee608eab86`, chỉ dùng nút có thật; bằng chứng chi tiết lưu `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md`.
- Sửa điểm mù UI Preview: `8864154eba60afdf8ee4a36795298d4aa2dceb28` giữ thông báo `GPS_BUSY` sau cleanup, `ca93b99f0443a84773833d161b951317400c7676` thêm 3 regression tests; lần CI đầu FAIL tại `flutter analyze` do thiếu import `PlatformException` (run `43825544314`).
- Khắc phục đúng lỗi import bằng commit `db4dcab34432c3a1c5a31903e30b0d0ff9b31def`, chỉ thêm `package:flutter/services.dart`; Foundation PR run `43826864218` SUCCESS, Zero Cost PR run `43826864300` SUCCESS, debug artifact `14206464796` (SHA ZIP từ GitHub đã ghi ở đầu).
- Chủ dự án đã cung cấp **bằng chứng máy Xiaomi Android thật**, đã đọc 7 ảnh đầu, 7 ảnh vòng hai, 3 ảnh A2-02, 3 ảnh A2-04 và MOV khoảng 56,5 giây A2-05. **KHÔNG đưa file ảnh/video riêng tư hoặc tọa độ lên GitHub.**

**Ma trận Android thật sau vòng test, ghi đúng phạm vi:**

| Mã | Trạng thái | Bằng chứng và giới hạn |
| --- | --- | --- |
| A2-01 Start/ACK/GNSS fresh | **PASS theo ảnh UI** | Native active, owner `native_safety`, ACK, `trusted_gps`, acceptedCount tăng. Tin cậy do phần mềm công bố, không GNSS calibration độc lập. |
| A2-02 exclusive owner, Preview GPS_BUSY, sequential handoff | **PASS theo ảnh UI** | Hiện nguyên văn `GPS_BUSY` trên GPS thử khi GPS nền đang dùng; sau dừng owner none, Preview có mẫu accuracy hiển thị 10,3m/tốc độ 0.0, không ghi tọa độ. Chưa chứng minh mọi race. |
| A2-03 Stop trong app | **PASS theo ảnh UI** | `stopped`, owner none, ACK false. |
| A2-03 Stop từ notification | **PASS theo ảnh UI** | Notification Stop và trạng thái service đã dừng; stale notification token vẫn NOT TESTED. |
| A2-04 Home/lock ~60 giây | **PASS CÓ ĐIỀU KIỆN** | 15:17 accepted 1, active/ACK; 15:19 accepted 33, active/ACK; sau stop none/ACK false. Ảnh không tự chứng minh thời lượng khóa hay liên tục từng mili giây. |
| A2-05 tắt Vị trí hệ thống (provider off) | **PASS THEO VIDEO** | MOV ~56,5s: ban đầu active/trusted/ACK, Quick Settings báo `Truy cập vị trí đã tắt`; khi quay về app `stopped`, fresh false, owner none, ACK false; bật lại Vị trí nhưng app vẫn stopped tại thời điểm xem; bấm khởi động thủ công mới thì `acquiring`, ACK true nhưng fresh false; sau đó stop. |
| A2-05 thu hồi quyền app / chỉ approximate | **NOT TESTED** | Tắt vị trí OS toàn hệ thống KHÁC với thu hồi runtime permission riêng của NaviTaxiMeter. |
| A2-06 Lab/SQLite on-phone | **NOT TESTED** | Không dùng dữ liệu chuyến khách, không cài demo fare. |
| Doze/kill/reboot/stale notification/clock drift/Android 11–16 OEM matrix | **NOT TESTED** | Không nâng ca điện thoại Xiaomi hiện tại thành production qualification. |

## 3.5. Công việc đang làm và điểm tiếp nối

- **P0 Issue #2:** đã qua nhánh provider OFF A2-05. Tiếp tục bằng ca **A2-05b quyền ứng dụng** với thao tác an toàn **chỉ khi đã chuẩn bị hướng dẫn cụ thể**, thử `Cài đặt → Ứng dụng → NaviTaxiMeter → Quyền → Vị trí → Không cho phép` lúc GPS nền chạy, chụp trước/sau, đánh giá ACK/fresh/owner; khôi phục permission và chỉ bật lại thủ công. Nếu Android force-stop app khi revoke, ghi observed state sau mở lại, không coi mất ACK là thiếu bằng chứng nếu không có màn hình, phải phân biệt NOT VERIFIED. Không vội đòi test nhiều ca trong một lượt.
- **P0 bổ sung**: test nhấn Stop nhanh, notification stale token, kill/Doze, battery OEM, Home/lock dài, đổi giờ, thí nghiệm revoke provider/notification và Lab fail/SQLite checkpoint; ưu tiên rủi ro có khả năng tái hiện trên Xiaomi. Mở issue lỗi riêng khi có FAIL thật. Android 11–16 máy khác chỉ khi có thiết bị thực.
- **P1 Issue #3:** thiết kế/triển khai theo review có kiểm soát **single native TripLocationService**, worker Dart headless và **one production app SQLite writer** với fenced post-commit ACK; chưa làm. Cần rollback, permission/OEM, process-kill/recovery PAUSED, không duplicate receipt. Không suy diễn từ DEBUG probe.
- **P2:** backup clone v3 + prefs, hashes/rollback, parity rounding/discontinuity/calibrate GNSS real route trước mọi proposal migration.
- **P3:** 7 màn sản phẩm, GIS Việt Nam legal licenses/sovereignty labels, maps online/offline/2D/3D và VietQR đã xác nhận; Zero Paid API audit, không bật paid SDK.
- **P4:** phân tích release signing/permissions/offline/storage 1/50/100 × 30 ngày, review và chỉ khi owner cho phép mới xuất bản/thu cước.

## 3.6. Lỗi sửa xong và giới hạn mở

- **Đã sửa:** Flutter Preview trước đó ghi đè lỗi `GPS_BUSY` bằng `Đã dừng xem GPS` khi cleanup; fix + 3 regression tests, Android thật có màn `GPS_BUSY` sau update. Build ban đầu FAIL vì thiếu import `PlatformException`, fix commit `db4dcab...` và CI đúng SHA PASS.
- **Đã kiểm trên Xiaomi có giới hạn:** vị trí tắt gây service stop, không giữ trạng thái GPS fresh/ACK; user re-enable OS location rồi có manual new Start. Đây là **video chẩn đoán** chứ không kiểm cước/độ chính xác km.
- **Còn mở:** chưa thật sự xác minh binary APK cài trên máy bằng hash; MIUI/HyperOS build chưa được báo; không có Device OS logs độc lập, không có pressure/high concurrency proof; chưa thực hiện revoke app location permission; chưa Lab SQLite fault; chưa process kill/reboot/Doze/power cut/long run, không stress nhiều thiết bị; chưa map cost/license compliance audit; không sản phẩm signed/approved.
- **Rủi ro an toàn:** `LocationOwnerRegistry` process-local; native health stream không có bền vững session/fare DB; giá trị `trusted_gps` chẩn đoán không chứng nhận GNSS chống giả mạo hoặc khoảng cách hợp lệ để tính tiền.

## 3.7. Files, CI, nguồn và rollback

- Handoff: `docs/HANDOFF_2026-11-16_CYCLE7_7-7.md` (**file này**); prior `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md`; `docs/AI_HANDOFF_STATE.md`; `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`; `AGENTS.md`.
- Điện thoại/evidence: `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`, `docs/ISSUE_2_XIAOMI_REDMI_NOTE_12_PRO_ANDROID13_RUNBOOK_2026-11-16.md`, `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md` (văn bản kỹ thuật đã lược PII).
- Native: `android_native/MainActivity.kt`, `LocationOwnerRegistry.kt`, `LocationSafetyService.kt`, `GnssFixTrustGate.kt`, `GnssHealthPublication.kt`, `TripCheckpointProtocol.kt`, `HeadlessSqliteProbeService.kt` + các JVM/instrumented test và callback fence files.
- Flutter: `lib/main.dart`, `lib/src/ui/gps_preview_page.dart`, `safety_service_page.dart`, `gps_lab_page.dart`, `tariff_management_page.dart`, `lib/src/core/metered_trip_coordinator.dart`, `lib/src/data/trip_repository.dart`, `lib/src/lab/debug_checkpoint_transport.dart`, `headless_sqlite_probe.dart`; tests `test/gps_preview_start_failure_test.dart`, `test/location_owner_gate_test.dart`, `test/gps_preview_quality_test.dart`, `test/trip_repository_ffi_test.dart`.
- CI: `.github/workflows/flutter-foundation.yml` + `zero-cost-gate.yml`; use GitHub Actions **exact HEAD SHA**, check first primary failure, not just final log tail. Android 14 emulator tests ≠ physical GPS.
- **Rollback:** only `git revert` on feature branch of specific code change with safe regression/CI, not force push, not destructive SQLite resets/migration. On uncertain GPS/ACK → stop or SUSPENDED, avoid automatic fare recovery.

## 3.8. Kiến trúc / quyết định đã được chốt

- Đã dùng Android `LocationManager` và Geolocator để lấy dữ liệu GPS; không mua API GPS, không giả lập sensor. Health FGS khác hoàn toàn production trip service. Không lặp lại chỉ test emulator nếu đã có bug/phone evidence cụ thể.
- Source UI fix được kiểm bằng điện thoại; bảo đảm owner chỉ ở phạm vi kịch bản thử, không công bố single owner production đã được chứng nhận.
- Tiếp tục nền tảng tiền Dart và v3 app DB, không di chuyển money engine native không có parity/approval; design one native owner + one durable writer phải review theo future protocol.
- Fail-closed/PAUSED/manual RESUME, no backfill, no billing, no unapproved schema/paid map, không khách thật. Quy trình 7/7 và bảo mật evidence là phần không thể bỏ.

## 3.9. Kế hoạch ưu tiên ngay sau bàn giao

| Thứ tự | Hành động | Tiêu chí kết quả |
| --- | --- | --- |
| 1 | Mở HEAD/CI mới sau các docs commits, PR #1 Draft, Issue #2/#3 | Ghi đúng SHA của mỗi Foundation/Zero Cost, phân biệt pending/cancelled/success; không suy diễn CI từ code SHA sang docs SHA |
| 2 | Cập nhật bảng A2-05 provider OFF đã PASS video và xem kế hoạch **A2-05b runtime permission** | Không yêu cầu test lặp lại provider OFF; quy trình nút chính xác, che GPS/PII, PASS/FAIL/NOT TESTED từng ca |
| 3 | Theo dõi any true Android OEM failure và thêm regression tối thiểu | Repro steps, OS/settings, observed vs expected, PRIVACY, no invalid PASS |
| 4 | Tiếp tục Issue #3 production design sau physical gate | Kiểm real GNSS FGS + ONE durable app SQLite writer + post-COMMIT ACK; không nhận debug emulator làm chứng cứ kinh doanh |
| 5 | Backup/migration v3, độc lập hiệu chuẩn cước & maps/VietQR legal/cost | Owner approval, no data loss, 30-day 1/50/100 audit, no paid APIs |

**PHẢI dùng đủ Phụ lục A dưới đây cho mọi thử điện thoại**, không nhờ người dùng đo GPS chung chung. Không đăng hình/clip chứa tọa độ hoặc thông báo riêng tư lên repository.

## 3.10. Chỉ thị bắt buộc cho AI tiếp quản

1. Đọc hết từ đầu tới cuối hồ sơ này **3.1–3.10 và PHỤ LỤC A/C**, rồi `AGENTS.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, `docs/AI_HANDOFF_STATE.md`, code-commander và chỉ skill trực tiếp liên quan; xác minh HEAD/CI.
2. Mới chat reset `AI_REPLY_COUNT=0`, mỗi phản hồi hoàn tất +1, lượt 7,14,... lập bản bàn giao mới. **Nếu không mở chat mới, tiếp tục lượt 8 chứ không reset**.
3. Chỉ ghi `feature/navitaximeter-foundation`, PR #1 Draft, Issue #2/#3 open. Không main/TTX, merge, force push, billing/key, commercial fare, schema migration hoặc đụng tài khoản ngân hàng.
4. Bằng chứng thực **có thật**: A2-01, A2-02, A2-03 PASS UI, A2-04 PASS có điều kiện theo ảnh, A2-05 system provider OFF PASS theo video; **không test lại tất cả chỉ vì bắt đầu chat mới**. A2-05 revoke permission/app riêng biệt NOT TESTED. Ảnh/video gốc riêng tư chưa công khai.
5. APK/debug phải rõ code SHA, workflow run, artifact/digest; màn hình điện thoại KHÔNG chứng minh binary SHA. Nếu phát bản mới, kiểm ZIP/APK hash, khả năng cài/không ghi đè dữ liệu, hướng dẫn từ nguồn tin cậy và bảo vệ dữ liệu.
6. Issue #3 actual one native GNSS owner / one durable production SQLite writer **NOT IMPLEMENTED**; không nhập hệ thống thử Python/Kotlin/JVM/DEBUG thành production. Mọi uncertain path SUSPENDED, recovery PAUSED + manual resume.
7. Kiểm kỹ user-reported Xiaomi Android 13, settings precise ON, notification ON, recommended battery mode; MIUI release chưa được ghi. Không hỏi lại điều chủ dự án đã cung cấp.
8. Duy trì `docs/AI_HANDOFF_STATE.md` + Issue #2 per-case, chỉ văn bản sanitized. Khi lỗi build, lấy earliest log and exact SHA, sửa tối thiểu với test rồi kiểm lại CI.
9. Mọi mốc mở bản đồ/cước/VietQR cần phối hợp yêu cầu sovereignty/zero paid API/licensing, backup migration, independent distance+rounding calibration và **explicit owner approval**.
10. Thông báo trạng thái theo mức **PROPOSED / CODE WRITTEN / CI PASS / PHONE USER-REPORTED / AI REVIEWED PHONE EVIDENCE / NOT TESTED**, không tự tuyên bố PASS toàn bộ app.

### Lệnh khởi động chat mới

> Tiếp quản NaviTaxiMeter từ `docs/HANDOFF_2026-11-16_CYCLE7_7-7.md` (đọc hết 3.1–3.10 và Phụ lục A/C). Đọc `AGENTS.md` và quy tắc 7 lượt; reset AI_REPLY_COUNT=0/7 trong chat mới. Chỉ ghi `feature/navitaximeter-foundation`; PR #1 Draft, Issue #2/#3 OPEN, main/TTX READ-ONLY, Zero Paid API, không tính cước khách. Code SHA `db4dcab34432c3a1c5a31903e30b0d0ff9b31def` Foundation 43826864218 SUCCESS, Zero Cost 43826864300 SUCCESS; docs HEAD phải đối chiếu mới nhất. Xiaomi Redmi Note 12 Pro Android 13: A2-01/A2-02/A2-03 phone UI PASS, A2-04 Home/lock conditional PASS, A2-05 tắt Vị trí hệ thống video PASS; **A2-05 revoke app permission và A2-06 vẫn NOT TESTED**, không lặp test đã xong. Evidence sanitized trong `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md`. Issue #3 one production GNSS owner + durable writer còn NOT IMPLEMENTED, cấm thu tiền/paid APIs/auto SQLite migration.

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

## PHỤ LỤC B — MA TRẬN THIẾT BỊ VÀ BẰNG CHỨNG CỤ THỂ

- Thiết bị do user báo: **Xiaomi Redmi Note 12 Pro, Android 13**, firmware MIUI/HyperOS **chưa xác minh**. Quyền: `Chỉ cho phép khi dùng ứng dụng`, precise ON, notification ON, pin ứng dụng `Tiết kiệm pin (kiến nghị)` (ảnh ngày 16/11). Không kết luận được hiệu suất 30 ngày.
- 7 ảnh ca Start/Stop 13:57–14:00, 7 ảnh A2-02 trước fix/notification 14:30–14:32, 3 ảnh A2-02 sau fix 15:07–15:09, 3 ảnh A2-04 15:17–15:19, video MOV ~56.54s với đồng hồ 16:55–16:56 và lần user gửi khoảng 17:01. **Không lưu ảnh/video public, không chép vĩ/kinh độ**.
- Trong A2-05, sau công tắc `Vị trí` OFF Android báo `Truy cập vị trí đã tắt`, service stopped/owner none/ACK false. Sau bật ON vẫn stopped ở thời điểm quan sát; user nhấn `Bật GPS nền thử` → dialog `Bật dịch vụ thử` để tạo phiên mới; service ACK khi `acquiring` vẫn fresh false, sau đó dừng.
- **PASS/UNVERIFIED rõ:** A2-01 PASS UI, A2-02 PASS UI, A2-03 UI/notification PASS, A2-04 PASS có điều kiện theo quy trình, A2-05 provider OFF PASS video, A2-05 runtime permission NOT TESTED, A2-06 Lab NOT TESTED, kill/Doze/reboot/OEM matrix NOT TESTED. App vẫn **KHÔNG THU CƯỚC**.
- Nút/tab nguồn xác nhận: `GPS nền` -> `Bật GPS nền thử` -> dialog `Bật dịch vụ thử`; `Đọc lại trạng thái` / `Dừng GPS nền thử`; notification action `DỪNG GPS AN TOÀN`; `GPS thử` -> `Bắt đầu xem GPS` / `Dừng GPS thử`. Không đoán nút chưa thấy.
- Giữ quyền riêng tư: KHÔNG post raw video/ảnh chứa GPS, địa chỉ, thông báo ứng dụng khác, thông tin tài chính/keystore/API key. Gửi chat đã che dữ liệu để AI đối chiếu. Không test khi lái xe/chở khách.

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
