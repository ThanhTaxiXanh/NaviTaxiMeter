# BẢN BÀN GIAO DỰ ÁN — NAVITAXIMETER

**Loại: BÀN GIAO BẮT BUỘC — LƯỢT 7/7**
**Thời điểm:** 15/11/2026, giờ Việt Nam (UTC+07:00), bắt đầu từ lệnh 20:14.
**Trạng thái:** Nền tảng Android đang phát triển; CI debug và kiểm thử giao thức/SQLite xanh; CHƯA ĐỦ ĐIỀU KIỆN THU CƯỚC KHÁCH.
**AI_REPLY_COUNT:** 7/7 khi hoàn tất lượt AI này. Cuộc trò chuyện MỚI bắt đầu với AI_REPLY_COUNT=0. Nếu tiếp tục TRONG CÙNG cuộc trò chuyện thì phải bàn giao lại ở lượt 14/21/28...
**Căn cứ:** quy tắc bàn giao 7 lượt và bản bàn giao 7/7 mà người dùng tải lên, đối chiếu GitHub trực tiếp ngày 15/11/2026. Không giả định tệp trong chat cũ có sẵn ở chat mới.

**Repo code:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter
**Branch:** feature/navitaximeter-foundation
**HEAD CODE CÓ CI ĐÃ XÁC MINH TRƯỚC COMMIT HỒ SƠ:** c0af5ef6960a6358013b000fb9a947b6b8564a2a
**PR #1:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1 , OPEN, DRAFT, NOT MERGED.
**main:** 539ff788b62be69135e5b3ad2c554dca005249a5 , KHÔNG MERGE.
**Repo tham chiếu TTX:** https://github.com/ThanhTaxiXanh/TTX-AATaximeter , nhánh feature/flutter-taximeter-foundation, SHA a40c246de6fd3799aaddedce3ed0d3b1d9dd524d, KHÔNG CHỈNH SỬA.
**Build CI đã xác minh:** Foundation Flutter Android run 43717172307 SUCCESS:
https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43717172307
**Zero Cost:** PR run 43717172335 SUCCESS; push run 43717167051 SUCCESS:
https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43717172335
**Debug-only APK artifact:** 14163112245, tên navitaximeter-native-gps-safety-DEBUG-only, 84.086.198 bytes (ZIP artifact), không phải release ký, không phải APK thu cước thương mại.
**GitHub issues còn mở:** #2 Android thực https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2 ; #3 service/writer https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3 .
**Lưu ý:** Khi commit tài liệu bàn giao mới, HEAD GitHub sẽ có thể thay đổi do CHỈ tài liệu. Kiểm tra commit/Actions mới tại thời điểm tiếp quản; không gán CI cũ cho HEAD mới.

## 3.1. TỔNG QUAN DỰ ÁN

Tên: NaviTaxiMeter; Flutter package navitaximeter; Android applicationId vn.navitaximeter; version 0.1.4+5.
Mục tiêu: ứng dụng đồng hồ taxi GPS đáng tin cậy dành cho tài xế taxi cá nhân, có bản đồ lái xe theo hướng xe (2D/3D), tìm kiếm/định tuyến địa phương, giá cước theo bảng giá đã xác nhận, lưu các chuyến và doanh thu SQLite, hóa đơn, VietQR, backup/restore và chẩn đoán GPS. Yêu cầu dựng theo bảy mockup hình ảnh đã cung cấp.
Nền tảng: Android trước, Flutter/Dart >=3.11 và Kotlin Android native, iOS chỉ sau khi Android ổn định. Chủ dự án thường làm việc qua iPhone và GitHub Actions; không được yêu cầu máy tính như điều kiện duy nhất để tiếp tục.
Trạng thái: đã có core và UI phòng thử kỹ thuật, nhưng KHÔNG phải ứng dụng thương mại đã hoàn tất. Chưa có seven-screen UI thật, renderer bản đồ hợp pháp/offline, tuyến đường thật, thực nghiệm GPS trên máy Android, production trip FGS, signed release hay xác nhận phí thực.

## 3.2. YÊU CẦU CỨNG KHÔNG ĐƯỢC THAY ĐỔI

1. ZERO PAID API POLICY: mục tiêu tổng phí API bằng 0 USD/tháng khi 1/50/100 người dùng chạy liên tục 30 ngày (720/36.000/72.000 người-giờ). Không API phải trả phí, đăng ký máy chủ trả phí bắt buộc, SDK navigation tính tiền, free quota có nguy cơ tự phát sinh phí, hoặc vi phạm điều khoản. Không tự bật Google Cloud Billing hoặc tạo API key. Zero Cost Gate chỉ quét source, KHÔNG xác minh hóa đơn/console thật; chưa có báo cáo 30 ngày.
2. MAP: mong muốn Google Maps SDK Android thông thường, tilt 2D/3D và tòa nhà 3D nếu phí và điều khoản hợp lệ. KHÔNG Google Navigation, Immersive, Places/Routes/Directions/Roads/Speed Limits/Geocoding hoặc Map Tiles tính phí, Map ID phát sinh SKU có phí. Nếu Google không đáp ứng yêu cầu zero-cost, nghiên cứu MapLibre + OSM offline hợp pháp, nguồn dữ liệu có attribution và tuân thủ license. Không bulk-prefetch tile.openstreetmap.org, dùng Google imagery trái quyền hoặc tạo bản đồ/tuyến/POI giả.
3. SOVEREIGNTY CONTENT theo yêu cầu hiển thị của chủ dự án: dùng tên Biển Đông, thể hiện Hoàng Sa/Trường Sa thuộc Việt Nam, các ranh giới/nhãn phù hợp yêu cầu; khi có dataset/style phải kiểm tra tile, attribution, nhãn và screenshot. Chưa được kiểm thử thực tế; không khẳng định đã đạt. Không che logo Google trái điều khoản.
4. GPS: chỉ vị trí GNSS thực đã được xác minh, độc lập với camera-map smoothing, mới được dùng trong engine cước. Lọc mock/stale/accuracy/speed/drift/jump/multipath; thiếu dịch vụ/quyền/fix/SQLite thì fail-closed SUSPENDED. Không bù km hay giây bị mất GPS. Khôi phục sau kill/restart phải PAUSED, chỉ tài xế xác nhận RESUME với fix mới; chia segment.
5. TARIFF: driver-confirmed tariff, snapshot đóng băng từ đầu chuyến; không áp demo tariff cho cước thương mại. Tiền/km/tariff rounding phải được đo, đối chiếu độc lập trước phát hành. Việc map/POI lỗi không thể gây mất dữ liệu chuyến.
6. STORAGE: SQLite offline cho trip/history/revenue/route/receipt, SharedPreferences cho settings và confirmed tariffs; không upload vị trí hay ngân hàng; chống trùng/ghi đè, kiểm tra integrity, backup thống nhất/hash/preflight/rollback và kiểm chứng update APK không làm mất chuyến. Không tự thay schema/migrate nếu chưa có backup/parity tests.
7. PAYMENT: chỉ Tiền mặt và Chuyển khoản. VietQR thực được tạo local từ tài khoản hợp lệ và kiểm bằng app ngân hàng, không fake QR.
8. UI: tiếng Việt, bảy màn bắt buộc: (1) home map/GPS, (2) search địa chỉ/POI, (3) tuyến có điểm dừng, (4) lái xe + meter, (5) lịch sử/doanh thu, (6) chi tiết chuyến/hóa đơn/VietQR, (7) cài đặt. Phụ: bảng giá, xe, ngân hàng, backup, GPS diagnostics. Mockup IMG_4488.png tới IMG_4494.png, 863x1822; ảnh chỉ có ở cuộc trò chuyện gốc, KHÔNG có trong repo. Dark Navy/Cyan: #071827 #10263C #12334D #00D8F0 #28F4FF #FFFFFF #A9C5D3 #20DFA5 #FFB020 #FF5266.
9. MAP CAMERA: FOLLOW_HEADING / NORTH / FREE_EXPLORE / RECENTER / TRIP_OVERVIEW, giữ hướng camera mượt không làm sai fix tính tiền. Mục tiêu gần 60 FPS, không ANR/leaks, tối ưu pin/RAM, nhưng chưa đo thực tế. Android Auto chỉ nghiên cứu, không giả ứng dụng được Android Auto hỗ trợ.
10. RELEASE: Android ARM64 release phải được ký bằng keystore ổn định, test update/migration/backup, kiểm toán license/phí và 1/50/100 tải liên tục. Cần chủ dự án phê duyệt trước khi merge main, phát hành, bật thu cước khách hoặc Google Billing. KHÔNG chỉnh sửa TTX reference repo.

## 3.3. KIẾN TRÚC HỆ THỐNG VÀ TRẠNG THÁI CẤU PHẦN

    Flutter Material 3 app, 5 tab CHỈ THỬ NGHIỆM:
       Trạng thái / Bảng giá / GPS thử / Phòng thử / GPS nền
    Bảng giá xác nhận -> ConfirmedTariffStore (SharedPreferencesAsync)
                           -> TariffConfig snapshot trong chuyến thử
    Android Geolocator GPS -> LocationOwnerLease (MethodChannel Android)
           -> PreviewGpsQuality (không tính cước) hoặc GPS Lab
           -> MeteredTripCoordinator -> TaximeterEngine
           -> TripRepository -> SQLite v3 active_trip + active_trip_route
           -> crash recovery PAUSED
    Kotlin MainActivity / MethodChannel vn.navitaximeter/safety_location_service
           -> LocationOwnerRegistry, process-local one-owner lease
           -> Kotlin LocationSafetyService (FGS chỉ HEALTH: count/age)
           -> ACK/heartbeat thật cho LIVENESS service, không phải ACK DB
    Future draft, KHÔNG nối app:
      TripCheckpointProtocol (pure Kotlin contract + fake writer JVM tests)
           -> proposed AtomicTripCheckpointWriter interface, NOT IMPLEMENTED
      IsolatedSqliteCheckpointProof (Python SQLite tạm + 12 tests)
           -> proposed fenced writer transaction, NOT application DB

Các luồng Preview/Lab Geolocator và native Kotlin FGS được *liên khóa theo tiến trình*: chỉ một owner preview/lab/native_safety có lease trong LocationOwnerRegistry, token/generation, stop-fence và heartbeat. Đây CHƯA phải một production service duy nhất: Geolocator và LocationSafetyService vẫn là hai cơ chế riêng, không có TripLocationService, và không chứng minh OS FGS không overlap trong quá trình hủy ngoài máy thật.

LocationSafetyService (Kotlin) dùng Android LocationManager, START_NOT_STICKY, type location, non-exported, chỉ bật khi Activity RESUMED, có quyền, notification Stop có token riêng, mỗi khoảng 3 giây phát heartbeat monotonic. Trả trạng thái health và tuổi fix, không export tọa độ, không ghi SQLite/tiền. Đã thêm requestSafetyStop để Stop trước START ACK giữ lease đến onDestroy; stop làm mất hiệu lực ACK. Không được dùng health counters làm cước.

TaximeterEngine Dart hỗ trợ mức giá theo bậc km, phí mở cửa, chờ/grace, BOT/phụ thu/giảm giá, trạng thái idle/running/paused/finished. MeteredTripCoordinator kiểm soát GPS thử nghiệm, checkpoint bất đồng bộ với SQLite, suspend lỗi, resume thủ công và recovery paused, KHÔNG là runtime nền chắc chắn. Flutter UI isolate không đảm bảo sống qua Home/kill.

TripRepository dùng navitaximeter_v1.db (schema version 3):
- trips(id PRIMARY KEY, started_at, total_fare, distance_km, payload)
- active_trip(id=1, payload, updated_at)
- active_trip_route(sequence INTEGER PRIMARY KEY [zero-based], latitude, longitude, recorded_at, accuracy_meters, speed_kmh, segment).
saveActiveIncremental ghi route + header trong cùng transaction, kiểm tra sequence/routeCount, hồi quy mới kiểm tra replay cùng sequence phải khớp *toàn bộ* row; xung đột rollback. completeActive chống receipt conflict/id trùng; có đường save legacy dùng REPLACE cần soát trước thương mại. Preferences confirmed tariffs key navi_confirmed_tariffs_v1; backup chung SQLite+Prefs chưa có.

Thư viện hiện tại pubspec.yaml: Flutter/Dart SDK >=3.11 <4, geolocator ^14.1.2, geolocator_android ^5.2.1, sqflite ^2.4.2+1, path ^1.9.1, shared_preferences ^2.5.6, crypto ^3.0.8; dev flutter_test, flutter_lints ^6.0.0, sqflite_common_ffi ^2.4.5, sqlite3 3.8.0. CI Java 17.

KHÔNG có Google Maps renderer, MapLibre/tiles offline, POI/search FTS5, routing A*/Dijkstra, camera guidance, map data, Mapillary runtime, VietQR UI, backup unified, production signed APK trong repo. 7 UI cuối chưa làm.

## 3.4. ĐÃ HOÀN THÀNH, ĐÃ KIỂM CHỨNG VÀ CHƯA KIỂM CHỨNG

Nền tảng (từ bàn giao trước):
- 0.1.0+1 commit 17fcb86d3a2acf0249a393ad825bee105af3f1b3: core meter, SQLite, domain/UI skeleton, CI, source Zero Cost.
- 0.1.1+2 f7aac734041d3c6f0a9999c1218352b5f11c1ed2: xác nhận bảng giá, GPS preview.
- 0.1.2+3 0e21de0ed690f49562b9e223fd6d5ef3ce58939a: GPS-meter-SQLite coordinator/receipt guards.
- 0.1.3+4 7b9f46c4db3593cecd6100a74cf3a43bf6336ed2: GPS Lab SQLite/manifest.
- Fix fa1f9a18021561a2137fdfccb1c92090a5ef5337: sửa aapt manifest order.
- 0.1.4+5 d474ebce008374c43f6c3499a24f2be03b11d880: native Kotlin GPS health FGS.
- Fix c0e5e15fc99bbcfad689cad47f45215dfc96b8de: bootstrap idempotency.
- Bàn giao nền a20d53674717646aece0b6dd49e6c50bd78bac90.

Bảy commits công việc CHU KỲ HIỆN TẠI (tất cả trên feature branch):
1. f1764964ebc563deb8e2abfb3a4895601d98d292: Android LocationOwnerRegistry, Dart lease, start ACK/heartbeat, bootstrap, test, GPS_SINGLE_OWNER_INTERLOCK.
2. f8c51f158bc9e93f9f0d28c24af5352284c07513: giữ lease khi SQLite pause không chắc chắn, không hiển thị ACK stale; thiết kế TripLocationService.
3. b362958f4a2442fca9acb999cd016d38d2d815bf: SerializedGpsStop chặn double-Stop, Kotlin JUnit runtime mutex tests, CI Gradle testDebugUnitTest.
4. 1bf47af554708843800accbe184b045b00636789: notification Stop fencing token, permission/provider heartbeat, stale stop guard, thêm test.
5. d15cfda4fb3fd917aa36ac453d63e8b71f931151: chống race Start/Stop pending, chỉ release native lease khi service onDestroy, ACK mất hiệu lực khi stopRequested; SecureRandom generation.
6. 1ad8ae63b292da7dc0121ee5f78e89a248556000: prototype TripCheckpointProtocol Kotlin chưa wired, 13 JUnit tests; TripRepository phát hiện replay sequence trùng nhưng khác tọa độ/tốc độ, Dart SQLite FFI tests.
7. c0af5ef6960a6358013b000fb9a947b6b8564a2a: SQLite thực chỉ trong DB tạm Python, 12 tests commit-after-ACK/rollback/concurrency/recovery; CI riêng và tài liệu.

CI SUCCESS đúng code HEAD c0af5ef: Foundation Android 43717172307 gồm Python safety, 12 SQLite proof tests, Kotlin JVM, Flutter analyze/test, flutter build apk --debug, binary APK manifest, artifact upload. Zero Cost Source Gate 43717172335 (PR) và 43717167051 (push) SUCCESS. Hình APK artifact 14163112245 debug only. Các run push cancelled do concurrency và có run PR SUCCESS thay thế, không được nhầm với sản phẩm lỗi.

**ĐÃ HOÀN THÀNH VÀ ĐÃ KIỂM CHỨNG TỰ ĐỘNG:** Kotlin build/debug, launcher Flutter 5 tab thử, lease protocol, source tests, Python SQLite isolated tests, Kotlin JUnit tests, Dart tests và FFI SQLite v3 route replay, manifest. Không đồng nghĩa với kiểm thử điện thoại thật.
**ĐÃ VIẾT NHƯNG CHƯA KIỂM CHỨNG TRÊN THIẾT BỊ:** GNSS accuracy, live FGS overlap/teardown, Home/lock/Doze/OEM, permission revoke, notification Stop qua process death, định mức GPS/cước/độ bền flash.
**CHƯA ĐƯỢC TRIỂN KHAI:** một native TripLocationService sở hữu GNSS/chuyến, production SQLite fence/ACK writer, migration v3→v4, commercial metering, bản đồ/7 màn/VietQR/signed release.

## 3.5. CÔNG VIỆC ĐANG TRIỂN KHAI VÀ ĐIỂM DỪNG CHÍNH XÁC

Tại lượt 7/7 CHỈ BÀN GIAO, không mở tính năng mới. Thao tác code cuối: commit c0af5ef6960a6358013b000fb9a947b6b8564a2a (lượt 6) và xác minh đầy đủ CI ở run 43717172307; cập nhật PR #1, issue #3. Trạng thái code và CI được kiểm tra lại vào 15/11/2026; HEAD vẫn c0af5ef trước khi commit tài liệu bàn giao.
Tệp vừa thêm gần đây: tool/checkpoint_sqlite_contract.py, tool/test_checkpoint_sqlite_contract.py, docs/SQLITE_ACK_TRANSACTION_PROOF.md, docs/TRIP_LOCATION_SERVICE_CONTRACT.md và GitHub workflow. Phép thử SQLite dùng DB tạm DISPOSABLE_TEST_ONLY.db. Hai bảng fence/ACK chỉ là TEST TABLES, không thêm vào app schema v3, không trộn dữ liệu với navitaximeter_v1.db.

Đầu việc đang dang dở tại issue #3: cần quyết định kiến trúc **một SQLite writer runtime duy nhất** và người sở hữu TaximeterEngine khi app background; không mặc định Dart UI isolate sống, không chuyển thuật toán tiền sang Kotlin nếu chưa có parity/rounding tests hoặc phê duyệt. Sau đó thiết kế backup+migration từ v3 sang v4, test rollback/độ bền, rồi mới tích hợp production native FGS + GNSS + writer + transaction ACK. Kotlin contract hiện tách rời app, Python SQLite proof cũng tách rời. Không tuyên bố đã làm production ACK.

Issue #2 là blocker test máy Android thật: quyền GPS chính xác/gần đúng, Android 11–16, Home/lock, disable provider, stale notification Stop, Stop-before-ACK, kill/reboot, Doze/OEM, đồng hồ hệ thống, SQLite fault, đo OS location FGS thực và so sánh status. Issue #2 còn OPEN, chưa có bằng chứng thiết bị thật được ghi nhận.

**LƯỢT KẾ TIẾP SAU BÀN GIAO:** Ở cuộc trò chuyện mới: reset AI_REPLY_COUNT=0, xác minh GitHub HEAD/PR/CI; đọc tài liệu contract và 4 file TripCheckpointProtocol/TripRepository/tool SQLite; chọn một hướng writer/runtime với proof-test plan, KHÔNG tích hợp thu cước. Nếu tiếp tục cùng chat, chu kỳ kế tiếp là các lượt 8–14, không reset ở giữa.

## 3.6. LỖI ĐÃ SỬA VÀ VẤN ĐỀ CHƯA XỬ LÝ

Lỗi đã có bằng chứng sửa:
- aapt manifest argument order 0.1.3; cố định bằng fa1f9a... và CI 43703032204 SUCCESS.
- bootstrap Android manifest không idempotent; sửa c0e5e15... CI 43704654095 SUCCESS.
- rủi ro FGS Preview/Lab vs native song song: thêm process-local interlock, token, ACK heartbeat, Dart stop barrier, Kotlin tests; PASS CI nhưng KHÔNG xác nhận phần OS thực.
- race pending Start/Stop và notification stale: đã gia cố fencing token, stopRequested, native release khi onDestroy; kiểm thử JVM PASS, device chưa.
- lỗi replay dữ liệu SQLite: trước đó INSERT OR IGNORE có thể bỏ qua sequence trùng nhưng khác nội dung; sửa so toàn bộ trường persisted row, thêm FFI tests PASS trong run 43715705970 và mới nhất 43717172307.

Rủi ro chưa được khắc phục/không đủ bằng chứng:
1. Vẫn có hai cơ chế Android location subscriptions/FGS thí nghiệm, dù đã có process-local exclusive lease. Chưa có một production TripLocationService duy nhất hay kiểm chứng trên Android thật rằng Geolocator FGS đã dừng hoàn toàn trước khi đổi owner. Phát hiện nguồn, chưa chứng minh lỗi thực địa.
2. Nếu Android nhận lệnh startForegroundService nhưng không bao giờ gọi onStartCommand/onDestroy, lease có thể stuck fail-closed đến khi restart; không dùng timeout mù để thả lock. Phải đo OEM/Android.
3. Kotlin health ACK/heartbeat chứng minh SERVICE LIVENESS, **không chứng minh GNSS hợp lệ cho tiền hay SQLite durable ACK**. Kotlin TripCheckpointProtocol dùng fake writer, không kết nối FGS; 12 Python SQLite tests dùng bản sao DB tạm, không chứng minh Android SQLiteDatabase/fsync hay migration.
4. SQLite schema v3 chưa persist sessionId/generation/sequence GNSS monotonic/commitId/hash cho future trip writer; Dart TripRepository có legacy save(record) dùng REPLACE, cần đánh giá tính bất biến khi production. Backup thống nhất SQLite và preferences và migration v3→v4 chưa có.
5. Dart fare-engine tính tiền và km bằng double trong nhiều phần; chưa đo/đối chiếu giá cước, rounding/accuracy chuẩn, parser/receipt và parity nếu chuyển runtime Kotlin.
6. Android 11–16 Home/lock/Doze/OEM battery, Android 14+ FGS restrictions, force-stop/kill/reboot/đổi giờ/notification Stop, revoked GPS/notification, gián đoạn GPS dài và lỗi SQLite trên thiết bị thật đều CHƯA CÓ BẰNG CHỨNG.
7. Bản đồ/định tuyến/GIS/Mapillary/speed signs/lanes/POI 2D/3D, bản đồ offline, nội dung biển đảo Việt Nam, 7 màn UI, VietQR bank-app proof, performance 60 FPS/battery, Zero Cost real 30 ngày và bản signed ARM64 release đều chưa hoàn thành.
8. README.md và docs/FOUNDATION_STATUS.md có nội dung giai đoạn đầu cũ; tài liệu GPS/Trip contract và bản bàn giao này là điểm bắt đầu chính xác hơn. Không báo cấu hình billing đã được kiểm toán thật chỉ vì CI scan PASS.
9. Khi tạo docs-only handoff commit cuối chu kỳ, phải phân biệt CI SUCCESS của HEAD code c0af5ef với CI của SHA docs-only mới cho đến khi Github Actions xác minh.

Không có thông báo lỗi CI mở trên HEAD code c0af5ef tại thời điểm đối chiếu; một số run push CANCELLED theo concurrency, các run pull_request tương ứng SUCCESS. Không giấu thiếu sót hoặc gán PASS cho thử máy thật.

## 3.7. MÃ NGUỒN, TỆP, DỮ LIỆU, LỆNH BUILD

Tệp dưới đây đã được kiểm tra có trong Git tree của HEAD c0af5ef (65 tệp tracked, 15/11/2026):

- Root: pubspec.yaml, lib/main.dart, README.md.
- Domain/Core: lib/src/core/{taximeter_engine.dart, metered_trip_coordinator.dart, location_tracking_policy.dart, lab_session_safety.dart, location_owner_gate.dart, serialized_gps_stop.dart}.
- Domain: lib/src/domain/{confirmed_tariffs.dart, quote_calculator.dart, revenue_summary.dart, trip_record.dart, trip_route_point.dart}.
- Data: lib/src/data/{trip_repository.dart, trip_session_snapshot.dart, tariff_codec.dart}.
- UI: lib/src/ui/{gps_preview_page.dart, gps_lab_page.dart, safety_service_page.dart, tariff_management_page.dart}; launcher 5 tab nằm lib/main.dart.
- Kotlin: android_native/{MainActivity.kt, LocationSafetyService.kt, LocationOwnerRegistry.kt, TripCheckpointProtocol.kt}; JVM tests android_native/{LocationOwnerRegistryTest.kt, TripCheckpointProtocolTest.kt}.
- Build/tool: tool/{bootstrap_android.py, verify_apk_manifest.py, check_zero_cost_policy.py, checkpoint_sqlite_contract.py, test_checkpoint_sqlite_contract.py, test_bootstrap_android.py, test_verify_apk_manifest.py, test_zero_cost_policy.py}.
- Flutter tests: test/{app_shell_test.dart, confirmed_tariffs_test.dart, gps_gap_recovery_test.dart, gps_preview_quality_test.dart, lab_session_safety_test.dart, location_owner_gate_test.dart, location_tracking_policy_test.dart, metered_trip_coordinator_test.dart, revenue_summary_test.dart, safety_service_status_test.dart, serialized_gps_stop_test.dart, strict_tariff_codec_test.dart, taximeter_engine_test.dart, tiered_fare_test.dart, tiered_quote_test.dart, trip_history_pagination_test.dart, trip_recovery_test.dart, trip_repository_ffi_test.dart, trip_route_persistence_test.dart}.
- GitHub CI: .github/workflows/flutter-foundation.yml và .github/workflows/zero-cost-gate.yml.
- Tài liệu: docs/AI_HANDOFF_STATE.md, docs/GPS_SINGLE_OWNER_INTERLOCK.md, docs/TRIP_LOCATION_SERVICE_CONTRACT.md, docs/SQLITE_ACK_TRANSACTION_PROOF.md, docs/PHASE2_TARIFF_GPS.md, docs/PHASE2_METER_SQLITE.md, docs/PHASE2_LAB_ANDROID_GPS.md, docs/NATIVE_GPS_SAFETY_SERVICE.md, docs/FOUNDATION_STATUS.md. Handoff mới ở docs/HANDOFF_2026-11-15_CYCLE_7-7.md.
- DB thật được tạo runtime, KHÔNG commit: navitaximeter_v1.db schema 3. Preferences key navi_confirmed_tariffs_v1. Test DB chỉ tạo trong tempfile DISPOSABLE_TEST_ONLY.db, KHÔNG phải app database.
- Android skeleton/android/AndroidManifest.xml được flutter create sinh tại CI; tool/bootstrap_android.py copy Kotlin vào android/app/src/main/kotlin/vn/navitaximeter/, test Kotlin vào src/test; không tự bịa đường dẫn android/ tracked. Repo chưa chứa tiles/POI offline, map style/dataset thật hoặc assets 7 mockup.
- Tệp upload ở chat gốc cần cung cấp lại nếu chat mới không đọc được: IMG_4488.png đến IMG_4494.png và quy tắc/bản bàn giao, master prompt không chắc truy cập được. Hồ sơ giai đoạn 1 NaviTaxiMeter_GiaiDoan1_HoSo_KhoiDong.zip nằm ở chat cũ, KHÔNG xác minh trong repo hiện tại.

Lệnh build/check sau git clone & checkout branch (môi trường có Flutter stable/Java 17/Android SDK):

    git clone https://github.com/ThanhTaxiXanh/NaviTaxiMeter.git
    cd NaviTaxiMeter
    git checkout feature/navitaximeter-foundation
    flutter create . --platforms=android --org vn --project-name navitaximeter
    python3 tool/bootstrap_android.py
    python3 tool/bootstrap_android.py --check
    python3 -m unittest discover -s tool -p 'test_checkpoint_sqlite_contract.py' -v
    python3 -m unittest discover -s tool -p 'test_*.py' -v
    flutter pub get
    rm -f test/widget_test.dart
    ( cd android && ./gradlew :app:testDebugUnitTest --no-daemon )
    flutter analyze --no-fatal-infos --no-fatal-warnings
    flutter test
    flutter build apk --debug
    python3 tool/verify_apk_manifest.py
    python3 tool/check_zero_cost_policy.py

Lệnh test SQLite chứng minh 12 cases hoạt động với Python sqlite3 trên DB tạm; lệnh source Zero Cost chỉ quét source. CI ở run 43717172307 đã chạy workflow tương ứng và PASS. GitHub Actions có artifact debug, không có đường dẫn file APK được gắn sẵn trong cuộc trò chuyện mới; dùng trang Actions/artifact ID.

## 3.8. QUYẾT ĐỊNH KỸ THUẬT ĐÃ THỐNG NHẤT

- Flutter/Dart domain fare engine + SQLite v3 là nền hiện hữu; không tự chuyển thuật toán cước sang Kotlin hoặc thay DB khi chưa có thiết kế parity/migration được duyệt.
- Offline first; physical GNSS trust independent of smoothed camera. No fabricated route/fare/POI/map. Confirmed immutable tariff for each trip.
- SQLite checkpoint atomic with route; receipt completion guards; recovery must PAUSED, never resume/bill automatically. Driver explicitly resumes new GPS segment.
- Process-local Android lease interlock là lớp PHÒNG THỬ, không tự nâng thành service production. Kotlin LocationSafetyService health-only, MethodChannel native ACK/heartbeat, STOP fencing token, Android foreground service user control; Geolocator Preview/Lab không được cùng sở hữu lease.
- Production target là **một** TripLocationService sở hữu GNSS và **một** writer atomic SQLite với ACK after committed transaction. Runtime engine Dart hay Kotlin CHƯA CHỐT; bắt buộc phân tích thời gian sống background và parity/rounding trước khi quyết định. Không được mặc nhiên coi Python proof / Kotlin fake writer là đã tích hợp.
- Zero Paid API là điều kiện chặn, map Google chỉ nếu legal + no Billing. MapLibre/OSM offline hợp lệ là phương án thay thế; chưa chọn nhà cung cấp/data license cuối cùng. Không chế tạo dữ liệu để đạt giao diện.
- PR Draft, main/TTX nguyên trạng, không billing/thu cước/signed release khi chưa được chủ dự án duyệt. GitHub Actions là bằng chứng CI chứ không thay test Android thật.

## 3.9. KẾ HOẠCH TIẾP TỤC THEO ƯU TIÊN, CÓ TIÊU CHÍ ĐẠT

P0. XÁC MINH GITHUB:
  Mục tiêu: biết state thật sau docs-only commit.
  Thành phần: feature branch, PR #1, GitHub Actions, issue #2/#3, main/TTX.
  Bước: fetch HEAD SHA; so sánh với mã kiểm thử c0af5ef và docs commit; xem CI đúng HEAD, artifact, Zero Cost; không merge.
  Đạt: bằng chứng SHA/run chính xác, PR Draft/unmerged, main/TTX không đổi.

P1. ANDROID GPS SAFETY GATE trên thiết bị thật:
  Mục tiêu: xác minh không chồng FGS và fail-closed.
  Thành phần: LocationOwnerRegistry, MainActivity, LocationSafetyService, Preview/Lab, serialized stop.
  Bước: matrix issue #2 Android 11–16 khi có máy, precise/approx permission, start/stop-before-ACK, notification stale token, Home/lock, Doze/OEM, revoke permission, GPS off, kill/reboot/time change/SQLite fault, quan sát OS FGS; không dùng khách.
  Đạt: log/screenshot redacted có model/OS/commit/PASS/FAIL; mọi case thiếu phải ghi NOT TESTED, lỗi thì issue riêng.

P2. CHỌN MỘT WRITER/ENGINE RUNTIME:
  Mục tiêu: một GNSS owner, một SQLite writer, không phụ thuộc Flutter UI isolate chưa kiểm chứng.
  Thành phần: issue #3, MeteredTripCoordinator, TaximeterEngine, TripCheckpointProtocol, TripRepository.
  Bước: so sánh phương án native Android service + Dart background isolate có bằng chứng hoạt động với phương án Kotlin-native processing có parity/rounding tests, kiểm soát đời service/transaction.
  Đạt: design doc được review, định nghĩa rõ owner, idempotency, ACK after durable commit, lifecycle failure handling; KHÔNG triển khai fare production khi chưa duyệt.

P3. BACKUP/MIGRATION & SQL CONTRACT THẬT:
  Mục tiêu: metadata fence bền vững gắn với chuyến mà không mất SQLite v3/Prefs.
  Thành phần: TripRepository, migration v3→v4 (dự kiến, chưa áp dụng), confirmed tariffs prefs, legacy receipts.
  Bước: backup preflight/hash, thử migration trên bản sao dữ liệu, rollback, stale generation, duplicate mismatch, force-kill ở ranh giới commit, mất ACK, restored PAUSED, compatibility v2/v3.
  Đạt: SQLite real-device integration tests, không mất trip/receipt/setting, chống ghi đè, ACK đúng chỉ sau COMMIT; không chuyển schema của app trước khi đạt.

P4. THỰC HIỆN MỘT TripLocationService DUY NHẤT:
  Mục tiêu: Kotlin FGS duy nhất nhận GNSS real và điều phối writer, các Flutter tab là client, không tạo FGS riêng.
  Bước: đưa GNSS trust filter thành contract, ánh xạ sessionId/generation/sequence monotonic với durable checkpoint, server-side ACK fail-closed; bảo đảm pause/stop/restart và driver-confirmed resume. Không cấp tiền từ health counters.
  Đạt: instrumented + Android physical tests vượt matrix, không double charging, không tính km/giây mất GPS. Chỉ phát hành sau phê duyệt.

P5. DOMAIN FARE, CALIBRATION, RECEIPTS:
  Mục tiêu: chứng minh số tiền/km/bảng giá/vé thực chính xác; không dùng demo.
  Bước: thử quãng đường chuẩn, GPS urban canyon/jump, giá bậc/wait/BOT/rounding, receipt ID immutable, history/revenue/backup.
  Đạt: báo cáo so số đo thực, xác nhận tariff immutable, parity runtime nếu port Kotlin.

P6. GIAO DIỆN & MAP/ROUTING:
  Mục tiêu: bảy màn hình từ mockup, bản đồ online/offline hợp pháp và hướng dẫn thật.
  Bước: lấy lại 7 ảnh khi chat mới thiếu; dựng UI không fake; chọn legal map source; lưu style/tiles/POI/FTS5/routing OSM/Mapillary hợp lệ; visual regression, kiểm thử nội dung nhãn biển đảo và attribution.
  Đạt: screenshot Android so mockup, dataset/license/attribution rõ, tuyến GPS/POI thật, offline navigation đã thử.

P7. THANH TOÁN, CHI PHÍ, PHÁT HÀNH:
  Mục tiêu: VietQR thật và sản phẩm release an toàn.
  Bước: xác minh ngân hàng/VietQR bằng app bank, công cụ xuất lịch sử/doanh thu từ SQLite, stress 1/50/100 × 30 ngày, review Google Billing/API/SKU/license, pin/RAM/FPS, signed ARM64 APK, update tests.
  Đạt: kiểm toán 0 USD theo chính sách, giấy phép đầy đủ, owner duyệt riêng. Không merge main/bật thu cước trước cổng này.

ƯU TIÊN NGAY KHI NHẬN "Tiếp tục" TRONG CHAT MỚI: P0 → xem issue #3/docs/TRIP_LOCATION_SERVICE_CONTRACT.md và SQL proof → chọn writer runtime với kế hoạch test; issue #2 vẫn là cổng an toàn. Không làm lại interlock đã có CI trừ khi phát hiện lỗi thật.

## 3.10. CHỈ THỊ BẮT BUỘC CHO AI Ở CUỘC TRÒ CHUYỆN MỚI

1. Đọc toàn bộ tệp này và tệp quy tắc 7 lượt, plus hồ sơ 7 mockup/master prompt nếu có thể truy cập; nếu không có chỉ nói thiếu và yêu cầu tải lại lúc cần.
2. Giữ nguyên mọi yêu cầu cứng Zero Paid API, Android-first, Flutter/Kotlin, GNSS trust, SQLite integrity, GUI 7 màn, chủ quyền nội dung bản đồ theo yêu cầu, privacy, 2 payment methods, no fake data.
3. Không thiết kế lại hoặc port tiền sang Kotlin không có chứng minh kỹ thuật, test parity và phê duyệt.
4. Không yêu cầu người dùng nhắc lại thông tin trong bàn giao. Kiểm tra GitHub thực tế trước mọi thay đổi, phân biệt code HEAD đã CI SUCCESS và docs HEAD mới.
5. Chỉ sửa branch feature/navitaximeter-foundation, không merge main, không sửa repo TTX-AATaximeter, không kích hoạt Google Billing/API trả phí, không bật cước khách hoặc signed release khi chưa duyệt.
6. Tách "code/test CI PASS" khỏi "đã thử Android thật"; không bịa pass, tọa độ, tuyến, POI, hóa đơn, ngân hàng hay dữ liệu performance/billing.
7. Tiếp tục chính xác ở issue #3 một writer/engine lifecycle và issue #2 device safety, không bỏ qua blocker.
8. Không ghi secrets, API key, password, keystore, GPS cá nhân/khách hay dữ liệu ngân hàng vào GitHub issue/log/handoff.
9. BẮT ĐẦU CUỘC TRÒ CHUYỆN MỚI: AI_REPLY_COUNT=0. Mỗi lượt AI hoàn tất tăng 1; ở lượt 7/14/21/28... phải lập lại bàn giao toàn bộ mục 3.1–3.10; nếu vẫn đang cùng chat không reset giữa chu kỳ.
10. Duy trì docs/AI_HANDOFF_STATE.md, cập nhật SHA/CI/thời điểm/công việc dở và link handoff khi có quyền ghi; bản mới phải độc lập, không giả định chat mới có ngữ cảnh cũ.

### CÂU LỆNH TIẾP QUẢN CHO CHAT MỚI

Hãy tiếp quản NaviTaxiMeter từ BẢN BÀN GIAO BẮT BUỘC 7/7 này. Đọc đủ yêu cầu cứng và hồ sơ nguồn. Kiểm tra GitHub HEAD, PR #1 Draft và CI của feature/navitaximeter-foundation. Không merge main, không sửa TTX gốc, không bật Google Billing hoặc thu cước khách. Tiếp tục ở issue #3 (lựa chọn một writer SQLite và một service owner duy nhất với ACK sau COMMIT) và issue #2 (FGS/GPS trên Android thật); không đánh đồng 12 bài SQLite proof trên DB tạm với Android production writer. Khởi tạo AI_REPLY_COUNT=0 trong chat mới và bàn giao đầy đủ sau mỗi 7 lượt.

**KẾT LUẬN:** Nền Flutter/Kotlin/SQLite thí nghiệm và interlock đã PASS CI, nhưng một service GNSS sở hữu chuyến và writer SQLite/ACK thương mại vẫn CHƯA CÓ. 7 UI, bản đồ/offline/tìm kiếm/định tuyến, VietQR thực, test máy thật, audit Zero Paid 30 ngày và signed release đều chưa hoàn tất. Không dùng APK debug để thu cước.
