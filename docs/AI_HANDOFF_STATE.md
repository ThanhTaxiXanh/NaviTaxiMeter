# CHU KỲ BÀN GIAO THỨ NHẤT: HOÀN THÀNH 7/7 (15/11/2026, ICT)

**AI_REPLY_COUNT: 7/7** sau khi AI kết thúc lượt trả lời này. Bàn giao đã hoàn tất đầy đủ 3.1–3.10 trong tài liệu độc lập:

**docs/HANDOFF_2026-11-15_CYCLE_7-7.md**
https://github.com/ThanhTaxiXanh/NaviTaxiMeter/blob/feature/navitaximeter-foundation/docs/HANDOFF_2026-11-15_CYCLE_7-7.md

- Đã đọc lại quy tắc 7 lượt và bản bàn giao gốc; xác minh trực tiếp repo/PR/CI/issues.
- Code HEAD **trước commit chỉ thêm tài liệu này**: c0af5ef6960a6358013b000fb9a947b6b8564a2a .
- Flutter Android/SQLite/Kotlin CI 43717172307 **SUCCESS**; Zero Cost Gate 43717172335 và 43717167051 **SUCCESS**; debug artifact 14163112245. Đó là kết quả của code HEAD c0af5ef, không tự suy ra cho SHA commit hồ sơ.
- PR #1 OPEN/DRAFT/NOT MERGED; main 539ff788b62be69135e5b3ad2c554dca005249a5; TTX tham chiếu SHA a40c246de6fd3799aaddedce3ed0d3b1d9dd524d, KHÔNG CHỈNH SỬA.
- Công việc dở: issue #2 chưa kiểm tra Android thật và OS FGS, issue #3 chưa có production TripLocationService/single-writer SQLite/fence ACK; 12 Python SQLite proof dùng DB tạm, Kotlin protocol dùng fake writer, không mở tính cước khách.
- Bước đầu tiên khi tiếp quản: xác minh docs-only commit HEAD mới và CI thực, sau đó tiếp tục lựa chọn writer/runtime theo issue #3 và xác minh máy Android theo issue #2.
- Chat **mới** đặt AI_REPLY_COUNT=0. Nếu vẫn trong chat **này**, chu kỳ tiếp tục 8–14 và lại bàn giao ở 14/14, không reset sai.
- Giữ Zero Paid API, không merge main, không sửa TTX, không Google Billing/paid APIs, không phát hành hoặc thu cước thương mại chưa được chủ dự án phê duyệt.

---

## CẬP NHẬT CHU KỲ HIỆN TẠI: LƯỢT 6/7 (15/11/2026)

- **Đếm:** `AI_REPLY_COUNT=6` sau khi hoàn tất câu trả lời này.
  **LƯỢT TIẾP THEO 7/7 BẮT BUỘC BÀN GIAO ĐẦY ĐỦ** các mục 3.1–3.10;
  không mở nhiệm vụ mới ở lượt thứ 7. Sau khi chuyển sang cuộc trò chuyện
  mới, đặt lại AI_REPLY_COUNT=0 theo quy tắc.
- **Trước khi làm:** HEAD nhánh `feature/navitaximeter-foundation` là
  `1ad8ae63b292da7dc0121ee5f78e89a248556000`, CI Foundation run
  `43715705970` SUCCESS, Zero Cost Gate run `43715705900` SUCCESS,
  PR #1 vẫn Draft/unmerged, main
  `539ff788b62be69135e5b3ad2c554dca005249a5`.
- **Việc mới:** `tool/checkpoint_sqlite_contract.py` minh họa
  transactional checkpoint ACK trên SQLite **thật nhưng cách ly hoàn
  toàn** với DB ứng dụng. Tạo DB `DISPOSABLE_TEST_ONLY.db` trong thư
  mục tạm, sao chép dạng cột schema v3 và thêm hai bảng fence/ACK chỉ
  dùng kiểm thử. `tool/test_checkpoint_sqlite_contract.py`: 12 test
  cho commit/rollback, mất ACK sau commit, stale token, duplicate,
  corruption, 8 writer cạnh tranh, recovery PAUSED.
- **Đã chạy tại chỗ:** 12/12 PASS với CPython sqlite3. GitHub CI cần
  xác minh ở đúng commit chứa code này; không suy rộng PASS local thành
  Android native/physical GPS PASS.
- **Tài liệu:** `docs/SQLITE_ACK_TRANSACTION_PROOF.md`, phụ lục trong
  `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, issue #3.
- **Phân biệt:** Kotlin `TripCheckpointProtocol` từ lượt 5 vẫn
  **chưa có SQLite writer thật**; Python SQLite proof không kết nối
  app hay Android, không thay đổi DB `navitaximeter_v1.db` hoặc schema v3.
- **Còn thiếu:** lựa chọn một SQLite writer sản xuất duy nhất, runtime
  nền Dart/Kotlin và engine parity, backup/migration v3→v4, native
  Android SQLite ACK, đo FGS/GNSS trên thiết bị Android 11–16/OEM,
  máy thử với số liệu, 7 UI/maps/offline/POI/VietQR, release signed.
- **Không đổi:** không merge main, không sửa TTX gốc, không Google
  Billing/paid APIs, không tính tiền khách, không bản đồ hoặc điểm
  GPS giả làm dữ liệu thật.
- **Điểm tiếp tục:** kiểm tra kết quả GitHub Actions chính xác của commit
  thử nghiệm mới và cập nhật PR/issue. Nếu CI đỏ sửa trong lượt 6;
  lượt 7 tổng hợp BÀN GIAO BẮT BUỘC đầy đủ.

---

## CẬP NHẬT CHU KỲ HIỆN TẠI: LƯỢT 5/7 (15/11/2026)

- **Bộ đếm:** `AI_REPLY_COUNT = 5` khi hoàn tất lượt này;
  còn 2 lượt trước bàn giao 7/7 bắt buộc.
- **HEAD đã kiểm tra trước khi chỉnh sửa:** `d15cfda4fb3fd917aa36ac453d63e8b71f931151`;
  Flutter Android run `43713186652` SUCCESS và Zero Cost Gate
  `43713186643` SUCCESS. PR #1 vẫn Draft/open, main
  `539ff788b62be69135e5b3ad2c554dca005249a5`.
- **Triển khai lượt này:** `android_native/TripCheckpointProtocol.kt`
  và `TripCheckpointProtocolTest.kt`, chỉ **contract JVM thử nghiệm**
  không nối Android FGS, GPS thật, Flutter hay SQLite. `tool/bootstrap_android.py`
  cài cả hai vào skeleton để chạy Gradle JUnit tests.
- **Phát hiện và sửa từ code thật:** SQLite schema v3 có giao dịch
  header+route nhưng chưa có metadata session/generation/checkpoint ACK
  ở giao dịch native. `active_trip_route.sequence` bắt đầu từ 0.
  Đã sửa `TripRepository.saveActiveIncremental()` để kiểm tra
  **toàn bộ nội dung hàng lưu** khi replay trùng sequence và từ chối
  khác tọa độ/speed thay vì `INSERT OR IGNORE`. Thêm SQLite FFI tests
  về rollback và replay khớp. Không thay đổi schema hay mở thu cước.
- **Tài liệu mới:** `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`;
  phân biệt rất rõ fake writer/JVM tests với writer SQLite có commit thật.
  Khi JVM writer báo lỗi, protocol SUSPENDED, không tự resume.
- **Chưa triển khai:** production `TripLocationService`, atomic SQLite
  writer và ACK thật, migrate v3→v4, test Android thực 11–16/OEM,
  trả cước hành khách, Google Billing, bản đồ/7 màn hình/VietQR.
- **CI:** kiểm tra GitHub Actions mới đúng HEAD commit tiếp theo trước
  khi tuyên bố thành công. Source/test mới không được coi là đã PASS
  trước khi Gradle chạy thực tế.
- **Tiếp theo:** nếu CI FAIL, sửa trên feature branch; nếu PASS, tạo
  test plan cho writer adapter single-owner + migration và phối hợp
  thử Android thật theo issue #2, issue #3.
- **Ràng buộc:** không merge main, không sửa TTX tham chiếu; Zero Paid
  API; không phát hành APK có tính tiền khi chưa phê duyệt.

---

## CẬP NHẬT CHU KỲ HIỆN TẠI: LƯỢT 4/7 (15/11/2026)

- `AI_REPLY_COUNT=4` sau khi hoàn tất lượt này; bàn giao bắt buộc ở 7/7.
- Trước khi sửa: HEAD `1bf47af554708843800accbe184b045b00636789`;
  PR #1 Draft/open; main `539ff788b62be69135e5b3ad2c554dca005249a5`;
  Flutter CI run 43711305353 và Zero Cost Gate 43711305398 SUCCESS.
- Phát hiện xử lý: Start/Stop bất đồng bộ có thể trả reservation trước khi
  service onStartCommand chạy. Bổ sung cờ stopRequested trong
  `LocationOwnerRegistry.kt`; chỉ release ở Service onDestroy, START
  pending được promote FGS rồi mới stop, không đăng ký GPS; ACK bị vô
  hiệu khi stopRequested. Seed token bằng SecureRandom mỗi process.
- Kiểm thử: thêm Kotlin JVM test cho stop-before-start, stop lặp,
  generation cũ; Python source checks. **Chưa kiểm thử máy thật**.
- Cần kiểm tra CI/HEAD mới sau commit trước khi xác nhận PASS.
- Công việc kế tiếp: kiểm thử instrumented Android tại issue #2; hoàn thiện
  thiết kế một TripLocationService + SQLite transactional ACK tại issue #3,
  nhưng không bật thu cước, không phát hành APK thương mại.
- Ràng buộc không đổi: chỉ branch feature; không merge main, không sửa
  TTX; Google Billing/paid maps/API key chưa bật; tính cước khách bị khóa.

---

## CẬP NHẬT CHU KỲ HIỆN TẠI: LƯỢT 3/7 (15/11/2026)

- **Đếm:** `AI_REPLY_COUNT = 3` sau khi hoàn tất lượt trả lời này;
  bản bàn giao bắt buộc tiếp theo ở `7/7`, còn bốn lượt.
- **GitHub đã xác minh trước chỉnh sửa:** HEAD `b362958f4a2442fca9acb999cd016d38d2d815bf`,
  Flutter Android run `43710328017` SUCCESS, Zero Cost Gate run
  `43710328023` SUCCESS, PR #1 còn Draft, `main` ở
  `539ff788b62be69135e5b3ad2c554dca005249a5`.
- **Đầu việc mới:** gia cố token của Android notification STOP và
  `MainActivity.stop`, chặn `cancelPendingSafety` release sai token;
  heartbeat tái kiểm tra quyền vị trí và provider; mở rộng test registry
  JVM + Python. Chi tiết: `docs/GPS_SINGLE_OWNER_INTERLOCK.md`.
- **Kiểm thử:** cần xem GitHub Actions tại HEAD mới của commit chứa thay
  đổi ở trên. Không tự coi kết quả CI cũ là kiểm chứng code mới.
- **Chưa làm:** test máy thật Android 11-16 và FGS/Geolocator teardown,
  trip-owning service + ACK SQLite, phát hành thương mại.
- **Giới hạn:** không merge main, không sửa TTX, không Google Billing,
  không bật thu cước thật, không tạo vị trí/bản đồ/hóa đơn giả.
- **Tiếp theo:** nếu CI đỏ, sửa lỗi tại branch; nếu xanh, kiểm thử Android
  device/lifecycle, sau đó thiết kế thêm nguồn GNSS thật một owner có
  checkpoint SQLite `PAUSED` fail-closed.

---

## CẬP NHẬT CHU KỲ HIỆN TẠI: LƯỢT 2/7 (15/11/2026)

- **Bộ đếm:** AI_REPLY_COUNT = 2 sau lượt trả lời tiếp tục này;
  kỳ bàn giao tiếp theo khi đạt 7/7 (còn 5 lượt).
- **Phạm vi:** Chỉ chỉnh sửa nhánh `feature/navitaximeter-foundation`.
  Không merge `main`, không sửa repo TTX, không bật Google Billing,
  không mở tính cước thật.
- **Việc bổ sung:** gộp các yêu cầu dừng Geolocator đồng thời bằng
  `SerializedGpsStop`; bổ sung Dart tests dừng/release đúng thứ tự;
  bổ sung **Kotlin JUnit runtime tests** và CI
  `./gradlew :app:testDebugUnitTest --no-daemon`, patch Gradle
  idempotent trong bootstrap Android.
- **Rủi ro chưa giải quyết:** Kotlin test chỉ xác minh mutex trong
  tiến trình; chưa chứng nhận Geolocator FGS dừng hết trước khi Android
  release lease. Cần đo trên điện thoại Android thật.
- **Bước chính xác sau:** kiểm tra workflow CI mới và sửa lỗi nếu có;
  nếu PASS thì cập nhật SHA/Actions. Sau đó instrumented Android tests,
  phân tích tính đúng đắn ACK/heartbeat của service và mô hình
  một `TripLocationService` với SQLite checkpoint.
- **Bản bàn giao chu kỳ trước giữ nguyên ở dưới.**

---

# CẬP NHẬT TIẾP QUẢN (15/11/2026, chu kỳ trả lời mới)

**Thứ tự ưu tiên:** Phần này cập nhật trạng thái so với bản bàn giao 7/7
lưu bên dưới; không xóa/ghi đè lịch sử kiến trúc hoặc ràng buộc.

- **AI_REPLY_COUNT:** đặt về 0 khi nhận bàn giao, và **1/7 sau khi
  hoàn thành lượt trả lời này**; chu kỳ bàn giao hiện tại là thứ 2,
  kỳ bàn giao đầy đủ tiếp theo ở lượt thứ 7 của cuộc trò chuyện mới.
- **Trạng thái nhánh:** `feature/navitaximeter-foundation`, PR #1 Draft/open
  chưa merge. `main` vẫn `539ff788b62be69135e5b3ad2c554dca005249a5`.
- **Đã làm:** một khóa owner Android `LocationOwnerRegistry` có token
  độc quyền giữa Geolocator Preview, Geolocator Lab và Kotlin safety FGS;
  live startup ACK + heartbeat monotonic; lớp Dart lease, test và tài
  liệu `docs/GPS_SINGLE_OWNER_INTERLOCK.md`.
- **Commit đã qua CI:** `f1764964ebc563deb8e2abfb3a4895601d98d292`.
  Foundation Flutter Android run **43708626667 SUCCESS**, Zero Cost Gate
  run **43708623657 SUCCESS**. Chỉ là kiểm thử tự động/Debug APK,
  **chưa có thử máy Android thật**.
- **Bổ sung sau CI:** tăng an toàn khi SQLite suspend lỗi và khi service
  status đọc lỗi; các sửa đổi bổ sung cần **CI riêng ở commit mới**.
- **Điểm tiếp tục:** xác minh CI của HEAD mới nhất; chạy các ca đối kháng
  Preview → Safety, Lab → Safety, Safety → Geolocator, Home/lock/notification
  stop, permission revoke, kill/reboot/Doze/OEM. Chưa chứng minh
  reliability thực tế của khóa trên máy Android.
- **Kiến trúc đích chưa triển khai:** một Kotlin TripLocationService thực
  làm nguồn GNSS duy nhất, ACK checkpoint SQLite sau giao dịch, chống
  duplicate với sessionId/sequence, recovery PAUSED và manual resume.
  Tầng tính cước Dart hiện tại không thể mặc nhiên được dùng chạy nền.
- **Không thay đổi:** Zero Paid API (0 USD), không Google Billing/key,
  không sửa TTX-AATaximeter, không merge main, không release có thu cước,
  không giả lập vị trí/đường đi/hóa đơn/QR; giữ 7 PNG, màu dark navy/cyan,
  chính sách bản đồ và tên Biển Đông/Hoàng Sa/Trường Sa theo yêu cầu,
  bảo mật SQLite và dữ liệu cá nhân.

---

# BẢN BÀN GIAO DỰ ÁN — NAVITAXIMETER

**Loại:** BÀN GIAO BẮT BUỘC — LƯỢT 7/7  
**Ngày lập:** 15/11/2026, múi giờ ICT (UTC+07:00).  
**Trạng thái dự án:** Đang phát triển nền tảng; bản Android Debug 0.1.4+5 qua CI, chưa sẵn sàng tính cước cho hành khách.  
**Bộ đếm:** AI_REPLY_COUNT = 7/7 sau khi hoàn tất lượt này, chu kỳ bàn giao đầu tiên. Khi bắt đầu cuộc trò chuyện mới phải đặt AI_REPLY_COUNT = 0 và tiếp tục bàn giao sau mỗi 7 lượt. Nếu tiếp tục cùng cuộc trò chuyện này, kỳ bàn giao kế tiếp ở lượt 14.

> **LƯU Ý NGUYÊN TẮC:** Dự án độc lập, tuyệt đối không merge `main`, không chỉnh sửa TTX-AATaximeter gốc, không tự bật Google Cloud Billing, không phát hành APK thu cước, không dùng dữ liệu GPS/tuyến/hóa đơn giả ngoài test.

## 3.1. Tổng quan dự án

- **Tên:** NaviTaxiMeter. **Android applicationId / Flutter package:** `vn.navitaximeter` / `navitaximeter`. **Phiên bản:** `0.1.4+5`.
- **Người dùng:** tài xế taxi cá nhân, chủ yếu quản lý qua iPhone và GitHub, không bắt buộc có máy tính.
- **Mục tiêu:** đồng hồ tính cước GPS đáng tin cậy, bản đồ điều hướng 2D/3D, dữ liệu tìm đường/địa điểm offline, hành trình, lịch sử/doanh thu, VietQR, sao lưu, chẩn đoán, UI tiếng Việt theo 7 ảnh mockup.
- **Ưu tiên:** Android trước, Flutter/Dart + Kotlin/Android SDK, SQLite; không quảng cáo/đăng nhập/bắt buộc dùng server thuê phí. iOS chỉ cân nhắc sau khi Android ổn định.
- **Trạng thái thực:** các mô hình tính cước, SQLite, quản lý bảng giá, GPS thử và dịch vụ native chẩn đoán đã có mã/kiểm thử tự động; **chưa có ứng dụng thu cước thật** và chưa có bản đồ/tìm tuyến offline trong Navi.

## 3.2. Yêu cầu cứng và thứ tự ưu tiên

1. **ZERO PAID API**: mục tiêu USD 0/tháng cho 1, 50, 100 người dùng hoạt động 24 giờ/ngày trong 30 ngày, tương ứng 720, 36.000, 72.000 người-giờ. Không dùng API trả phí theo lượt/phiên, miễn phí có ngưỡng rồi tự thu, SDK dẫn đường có phí, dịch vụ server/thuê bao bắt buộc, hoặc mẹo vượt hạn mức. Máy phải làm việc offline cho cước, SQLite và phần bản đồ đã cấp dữ liệu. Quét source không đồng nghĩa chứng nhận hóa đơn USD 0.
2. **Google Maps có điều kiện, không phải quyền phê duyệt Billing:** master prompt ưu tiên Google Maps SDK Android thông thường khi chứng minh được SKU/chi phí và chủ dự án đồng ý kết nối Google Billing. Chưa được đồng ý, không cài SDK/khóa, không bật Billing. Không dùng Google 3D Immersive, Navigation, Places, Routes, Directions, Geocoding, Roads, Speed Limits, Static Maps tính phí, Map Tiles tính phí hay Map ID làm phát sinh Dynamic Maps SKU. Nếu không đáp ứng đồng thời Zero Cost, giấy phép và dữ liệu địa lý, chọn renderer/dữ liệu mở hợp pháp như MapLibre + OSM được cấp phép; không tải trước tiles từ máy chủ OSMF công cộng.
3. **Cước và GPS**: chỉ bảng giá do tài xế nhập/xác nhận, không tự kích hoạt `TariffConfig.demo()`. Hai luồng riêng: tọa độ đã xác minh để tính cước, camera/map làm mượt để hiển thị. GPS cũ, mock, nhiễu, nhảy, thiếu chính xác hoặc mất FGS phải tạm ngừng, không lấp chỗ trống bằng km/thời gian tính tiền. Đứt quãng khôi phục thủ công, sao lưu trạng thái vào SQLite; không khẳng định Force Stop luôn sống sót.
4. **Dữ liệu/nghiệp vụ**: SQLite lưu trip/route/receipt và thống kê thật, giao dịch nguyên tử, chống trùng/ghi đè; SharedPreferences chỉ cho cấu hình thông thường. Mỗi chuyến đóng băng bảng giá gốc; riêng `PaymentMethod` là tiền mặt hoặc chuyển khoản. VietQR phải tạo từ thông tin hợp lệ, không QR mẫu. Không upload GPS/tài khoản ngân hàng lên cloud mặc định; keys/secret không commit.
5. **7 mockup bắt buộc** (ảnh `IMG_4488.png` tới `IMG_4494.png`, 863x1822, gắn ở cuộc trò chuyện gốc, chưa đưa lên GitHub): (1) Trang chủ/map; (2) Tìm địa điểm; (3) Lập tuyến đường; (4) Lái xe và đồng hồ cước; (5) Lịch sử/doanh thu; (6) Chi tiết chuyến/thanh toán/VietQR; (7) Cài đặt. Ngoài ra trang quản lý bảng giá, xe, ngân hàng/QR, backup, chẩn đoán. Cần screenshot visual regression trên thiết bị, không tuyên bố giống 100% khi chưa đo.
6. **Màu giao diện**: nền `#071827`, nền phụ `#10263C`, card `#12334D`, cyan `#00D8F0`/`#28F4FF`, chữ `#FFFFFF`/`#A9C5D3`, success `#20DFA5`, warning `#FFB020`, danger `#FF5266`. Camera follow heading/north/free/recenter/trip overview và khối nhà 3D chỉ khi renderer cung cấp đúng tính năng; ưu tiên tính cước đúng hơn hiệu ứng.
7. **Yêu cầu hiển thị bản đồ Việt Nam của chủ dự án:** Biển Đông; Hoàng Sa và Trường Sa thuộc Việt Nam theo yêu cầu hiển thị; không dùng nhãn/ranh giới mâu thuẫn với yêu cầu đã chốt. Khi triển khai phải kiểm định ảnh render, dữ liệu nguồn, quy định và giấy phép độc lập, không lạm dụng overlay hoặc sửa/che logo/nội dung Google sai phép. **Chưa triển khai hoặc kiểm thử kiểm định này**.
8. **Hiệu năng**: FPS mục tiêu gần 60 trên thiết bị phù hợp, không ANR, không leak, tránh rebuild UI từng GPS fix, không update polyline toàn tuyến mỗi giây, giới hạn hoạt ảnh camera, tiết kiệm pin/RAM. Chưa đo thực tế, không tuyên bố đạt.
9. **An toàn pháp lý/Android Auto:** chưa hỗ trợ Android Auto; không khai báo sai app category hoặc né chính sách. Cần APK ARM64 Release ký bằng keystore ổn định và thử upgrade không mất SQLite, có chủ dự án phê duyệt trước khi phân phối. Quy tắc kiểm toán chi phí/phát hành luôn ưu tiên cao hơn map đẹp.

## 3.3. Kiến trúc hiện có và dự kiến

**Nền tảng đã chạy kiểm thử:**

```text
Android LocationManager  ──> Kotlin LocationSafetyService
        │                     (health only; no coordinates or fare)
        └──> MethodChannel status/start/stop ──> Flutter tab GPS nền

Android geolocator Foreground Stream ──> PreviewGpsQuality
        ├──> GPS Preview tab (read-only)
        └──> Phòng thử: MeterGpsObservation → LabSessionSafety
                                      ↓
                              MeteredTripCoordinator
                                      ↓
                 TaximeterEngine + LocationTrackingPolicy
                                      ↓
                  TripRepository SQLite v3 transaction
                         active_trip + active_trip_route
                                      ↓
                          recover as paused / no fare UI

Driver tariff form → ConfirmedTariffBook/Store → SharedPreferencesAsync
                         ↓
                  frozen tariff in trip snapshot
```

- `TaximeterEngine` lưu trạng thái `idle/running/paused/finished`, bậc giá, waiting grace, phí BOT/phụ thu/giảm giá, lọc và tích lũy quãng đường.
- `MeteredTripCoordinator` nhận mẫu GPS đủ mới, chống timestamp/độ chính xác bất thường; checkpoint hành trình và meter trong SQLite; gap >12 giây tạm ngắt, không tự tăng cước từ timer; khôi phục nguyên bảng giá và ở trạng thái paused. Có kiểm thử mô phỏng.
- `TripRepository`: `navitaximeter_v1.db`, SQLite schema v3, bảng `trips`, `active_trip`, `active_trip_route`; `beginActive`, `saveActiveIncremental`, `loadActive`, `completeActive` nguyên tử, chặn ghi đè receipt xung đột và xác nhận route count.
- `ConfirmedTariffStore` lưu danh mục đã xác nhận trong SharedPreferencesAsync, khóa `navi_confirmed_tariffs_v1`. **Chưa thống nhất backup transaction giữa prefs và SQLite.**
- Flutter hiện có **5 tab kỹ thuật**: Trạng thái, Bảng giá, GPS thử, Phòng thử, GPS nền. Đây không phải 7 mockup sản phẩm.
- Kotlin native `LocationSafetyService` riêng dùng `LocationManager`, monotonic elapsed time, notification dừng, `START_NOT_STICKY`, `android:exported="false"`, type `location`; chỉ xuất số lượng/tuổi mẫu GPS. **Nó KHÔNG sở hữu đồng hồ cước, KHÔNG chuyển fix đến SQLite và KHÔNG được dùng để suy đoán chuyến chạy nền.**
- Android project hiện được tạo trong CI bằng `flutter create . --platforms=android --org vn --project-name navitaximeter`, rồi `tool/bootstrap_android.py` chép `android_native/MainActivity.kt` và `LocationSafetyService.kt`, thêm manifest. Thư mục `android/` generated **không phải source tree được commit**.
- Map renderer, offline OSM dataset, Search FTS5, routing graph A*/Dijkstra, Mapillary/GIS data, camera smoothing, VietQR UI, bank account book, unified backup UI, navigation instructions: **chưa tích hợp vào repo Navi**, chỉ nằm trong kế hoạch/TTX reference.

**Dependency đã commit:** Flutter, Dart SDK >=3.11, `geolocator ^14.1.2`, `geolocator_android ^5.2.1`, `sqflite ^2.4.2+1`, `path ^1.9.1`, `shared_preferences ^2.5.6`, `crypto ^3.0.8`; test `flutter_test`, `sqflite_common_ffi ^2.4.5`, `sqlite3 3.8.0`. Java 17 cho CI. Không có Google Maps SDK/Billing.

## 3.4. Công việc đã thực hiện và kiểm chứng

### Lịch sử commit xác minh trên repo Navi (không phải TTX)
| Mốc | Commit SHA | Phạm vi |
|---|---|---|
| 0.1.0+1 | `17fcb86d3a2acf0249a393ad825bee105af3f1b3` | 29 tệp Flutter domain/SQLite/tests/Zero Cost Gate/CI, UI trạng thái |
| 0.1.1+2 | `f7aac734041d3c6f0a9999c1218352b5f11c1ed2` | Bảng giá tài xế xác nhận + UI, Geolocator GPS preview |
| 0.1.2+3 | `0e21de0ed690f49562b9e223fd6d5ef3ce58939a` | MeteredTripCoordinator, GPS checkpoint SQLite, receipt identity guard |
| 0.1.3+4 | `7b9f46c4db3593cecd6100a74cf3a43bf6336ed2` | Phòng thử GPS thật + SQLite, compiled APK manifest checker |
| Fix 0.1.3+4 | `fa1f9a18021561a2137fdfccb1c92090a5ef5337` | Sửa thứ tự tham số aapt, test hồi quy |
| 0.1.4+5 | `d474ebce008374c43f6c3499a24f2be03b11d880` | Native Kotlin location safety FGS + tab GPS nền + test |
| Fix 0.1.4+5 | `c0e5e15fc99bbcfad689cad47f45215dfc96b8de` | Bootstrap Android idempotent, CI xanh |

**CI đã xác minh thành công trên commit `c0e5e15f...`:**
- Flutter Android run **43704654095**: SUCCESS, Python safety tests **15/15 PASS**, `flutter analyze` PASS, `flutter test` PASS, Kotlin/Debug APK build PASS, kiểm tra manifest đã biên dịch PASS, upload artifact PASS. Link: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43704654095
- Zero Cost Source Gate run **43704654097**: SUCCESS. **Đây là scanner tĩnh**, không phải xác nhận phí cloud.
- APK ZIP Artifact **`navitaximeter-native-gps-safety-DEBUG-only`**, ID **14158551181**, kích thước ZIP **84.069.448 bytes**; tải qua trang run trên GitHub (có thể cần đăng nhập).
- Mốc trước: CI 0.1.3+4 đã thành công sau fix, run **43703032204**; 0.1.2+3 run **43701237196** thành công. Không suy diễn kiểm thử thiết bị từ CI.
- Mã dùng GPS thực ở phòng thử, nhưng các `test/` sử dụng mẫu tổng hợp **chỉ cho kiểm thử**, không phát sinh GPS mẫu trong UI thật.

**Đã viết nhưng CHƯA kiểm thử thực tế**: Kotlin FGS khi app về Home/lockscreen/doze, kill/reboot, quyền gần đúng, mất GPS, bản đồ cục bộ, tích hợp thương mại. Bản Release ký tên và thiết bị thực chưa có.

## 3.5. Công việc đang dở / thao tác cuối

- Giai đoạn hiện tại: nền tảng Android GPS/SQLite, chưa qua acceptance test máy thật.
- Thao tác gần nhất trước bàn giao: xác nhận GitHub head `c0e5e15f...`, CI Flutter/Zero Cost đều `success`, Draft PR #1 `open`, `merged=false`. Không khởi động feature mới trong lượt 7.
- **Rủi ro kỹ thuật cần xử lý ngay:** `GpsLabPage` (geolocator) và `SafetyServicePage` (Kotlin LocationManager) có thể cùng sở hữu 2 FGS location; chưa có điều phối độc quyền hay ACK/heartbeat của một service owner duy nhất. Chưa có kiểm thử xung đột pin/callback. Không nối native health `active=true` trực tiếp vào logic tính cước.
- Phòng thử GPS chỉ có tạm ngắt/chấm điểm cục bộ. Khi app ở nền, chưa có service sở hữu trip/SQLite độc lập với UI. Đừng bật cước thương mại bằng cách bỏ điều kiện tạm dừng.
- `README.md`, `docs/FOUNDATION_STATUS.md` có một vài dòng mô tả trạng thái nền ban đầu còn cũ; tài liệu giai đoạn mới và bản bàn giao này là nguồn cập nhật chính xác hơn. Sửa tài liệu cũ có kiểm tra, tránh xóa chứng cứ lịch sử.
- Bản đồ, GPS, cước thật, snapshot/restore across OS process kill, hồi quy khi cập nhật APK chưa được đo ngoài phòng test.

## 3.6. Lỗi đã gặp, đã sửa, và rủi ro chưa giải quyết

**Đã sửa + có kiểm chứng CI:**
1. 0.1.3+4 ban đầu build APK thành công nhưng manifest gate FAIL vì `aapt dump xmltree` truyền tên `AndroidManifest.xml` trước đường dẫn APK. Fix `fa1f9a18...`, CI `43703032204` SUCCESS.
2. 0.1.4+5 ban đầu Zero Cost Gate/Flutter workflow FAIL ở test `test_bootstrap_android.AndroidBootstrapTests.test_idempotent`: chạy bootstrap lần 2 thêm khoảng trắng trước `<application>`. Fix `c0e5e15f...`; run `43704654095` và `43704654097` SUCCESS.
3. Một vài workflow bị `cancelled` do concurrency giữa push/PR cùng commit; có run hoàn thành thay thế đã thành công, không coi `cancelled` là lỗi production.

**Chưa giải quyết, không được giấu:**
- Chưa thử FGS trên thiết bị Android thật, chưa chứng minh quyền thông báo/vị trí lúc chạy, tiến trình bị giết, tắt màn hình, GPS chết, pin, service interlock.
- Native `start()` trả `true` xác nhận đã gửi lệnh Android, **không xác nhận FGS đã hoạt động**. Status `active` trong bộ nhớ tiến trình cũng không bảo đảm luôn sống sau OS kill. Cần heartbeat và thiết kế ACK.
- Hai FGS có thể trùng nhau; yêu cầu chặn xung đột và thống nhất owner.
- `TripRepository` lưu tiền/quãng đường dạng số thực; với giá tiền thực cần đối chiếu quy tắc làm tròn/đo chuẩn và tổng tiền trên thiết bị; không có chứng nhận.
- Bảng giá settings ở SharedPreferences, trip ở SQLite; backup thống nhất chưa có.
- Không có chứng cứ phí Google bằng 0 hoặc đối soát Billing vì không có Google Billing.
- Bản đồ chưa có GIS dữ liệu nguồn/giấy phép/công bố chủ quyền; không có dataset thực trong repo.
- Chưa có thiết bị đo GPS/tariff calibration, kiểm thử stress 1/50/100 trong 30 ngày, báo cáo an toàn/certification, signed ARM64 release.

## 3.7. Mã nguồn / tệp / lệnh quan trọng

**Repository chính:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter  
**Nhánh:** `feature/navitaximeter-foundation`  
**Draft Pull Request:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1  
**Main head (không thay đổi tại lúc xác minh):** `539ff788b62be69135e5b3ad2c554dca005249a5`  
**Repo tham chiếu TTX (độc lập, không sửa):** https://github.com/ThanhTaxiXanh/TTX-AATaximeter ; branch `feature/flutter-taximeter-foundation`, HEAD `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d`.

**Tệp nguồn đang tồn tại trong Navi:**
- Flutter shell: `lib/main.dart`.
- Engine/policy: `lib/src/core/taximeter_engine.dart`, `location_tracking_policy.dart`, `lab_session_safety.dart`, `metered_trip_coordinator.dart`.
- Domain: `lib/src/domain/confirmed_tariffs.dart`, `trip_record.dart`, `trip_route_point.dart`, `revenue_summary.dart`, `quote_calculator.dart`.
- Data: `lib/src/data/trip_repository.dart`, `trip_session_snapshot.dart`, `tariff_codec.dart`.
- UI: `lib/src/ui/tariff_management_page.dart`, `gps_preview_page.dart`, `gps_lab_page.dart`, `safety_service_page.dart`.
- Native: `android_native/MainActivity.kt`, `android_native/LocationSafetyService.kt`.
- CI/tool: `pubspec.yaml`, `.github/workflows/flutter-foundation.yml`, `.github/workflows/zero-cost-gate.yml`, `tool/bootstrap_android.py`, `tool/verify_apk_manifest.py`, `tool/check_zero_cost_policy.py`, `tool/test_bootstrap_android.py`, `tool/test_verify_apk_manifest.py`, `tool/test_zero_cost_policy.py`.
- Dart tests: `test/taximeter_engine_test.dart`, `tiered_fare_test.dart`, `gps_gap_recovery_test.dart`, `location_tracking_policy_test.dart`, `trip_repository_ffi_test.dart`, `trip_recovery_test.dart`, `trip_route_persistence_test.dart`, `trip_history_pagination_test.dart`, `tiered_quote_test.dart`, `revenue_summary_test.dart`, `app_shell_test.dart`, `strict_tariff_codec_test.dart`, `confirmed_tariffs_test.dart`, `gps_preview_quality_test.dart`, `lab_session_safety_test.dart`, `metered_trip_coordinator_test.dart`, `safety_service_status_test.dart`.
- Docs: `docs/FOUNDATION_STATUS.md`, `PHASE2_TARIFF_GPS.md`, `PHASE2_METER_SQLITE.md`, `PHASE2_LAB_ANDROID_GPS.md`, `NATIVE_GPS_SAFETY_SERVICE.md`, `AI_HANDOFF_STATE.md` (bản này).
- Giai đoạn nghiên cứu ban đầu chỉ có tại thư mục conversation `/mnt/data/NaviTaxiMeter_GiaiDoan1/` và ZIP `/mnt/data/NaviTaxiMeter_GiaiDoan1_HoSo_KhoiDong.zip`, có `docs/ARCHITECTURE.md`, `FEATURE_MATRIX.md`, `ROADMAP.md`, `MOCKUP_FIDELITY.md`, `API_COST_AUDIT.md`, `MAP_PROVIDER_COMPLIANCE.md`, `STRESS_TEST_100_USERS.md`, `ZERO_COST_POLICY.md`, `KNOWN_LIMITATIONS.md`. **Không giả định các file giai đoạn 1 đã được push hết vào GitHub.**
- Tệp hướng dẫn của user: `Văn bản đã dán (1).txt` (master prompt 1.200+ dòng), `QUY TẮC CỨNG — BÀN GIAO DỰ ÁN SAU MỖI 7 LƯỢT TRẢ LỜI AI.md`, 7 ảnh `IMG_4488.png` đến `IMG_4494.png`. **Nếu phiên chat mới không nhìn thấy, cần chuyển lại bản bàn giao và các ảnh; không tự bịa nội dung ảnh.**

**Chuỗi build kiểm thử Android từ source (không phải lệnh chứng nhận sản xuất):**
```bash
git clone https://github.com/ThanhTaxiXanh/NaviTaxiMeter.git
cd NaviTaxiMeter
git checkout feature/navitaximeter-foundation
flutter create . --platforms=android --org vn --project-name navitaximeter
python3 tool/bootstrap_android.py
python3 tool/bootstrap_android.py --check
python3 -m unittest discover -s tool -p 'test_*.py' -v
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
python3 tool/verify_apk_manifest.py
python3 tool/check_zero_cost_policy.py
```
Quy trình CI cũng chạy `rm -f test/widget_test.dart` trước test vì file mẫu do `flutter create` sinh không thuộc suite của dự án. Nếu chạy tay từ checkout sạch, thực hiện bước đó trước `flutter test`. Chỉ tải APK Debug thử nghiệm tại GitHub Actions, không chia sẻ như bản cước thật.

## 3.8. Quyết định đã chốt và ràng buộc quyền

- Branch riêng + PR Draft, không chỉnh sửa TTX gốc, không merge `main` không có chấp thuận. iPhone có thể xem PR/Actions/Artifacts, không yêu cầu người dùng mua PC.
- Giữ Zero Cost cao hơn sở thích Google Maps. Google Maps bình thường chỉ được cân nhắc có phê duyệt và hồ sơ phí; MapLibre/OSM có thể dùng thay cho tính năng có xung đột, nhưng chưa có bản đồ thực được duyệt.
- Chỉ dùng verified GPS cho fare; camera smoothing và vị trí UI không đi vào engine.
- Không có giá ví dụ kích hoạt tự động; data corrupted fail closed, snapshot đóng băng tariff.
- Native FGS là diagnostic monitor không nhận nhiệm vụ billing; lab GPS SQLite chỉ thử nghiệm, tự suspend khi Activity vô hình.
- Chế độ cash/bankTransfer, chưa có quy trình VietQR để khách dùng; không tự dùng ngân hàng hay QR giả.
- Đã triển khai kiểm tra tĩnh source & APK, nhưng không có quyền tự tạo billing cloud, gỡ/rải APK, ký release hoặc phát hành.

## 3.9. Kế hoạch chính xác cho AI tiếp nhận

| Thứ tự | Việc phải làm | Nơi làm | Tiêu chí đạt |
|---:|---|---|---|
| 1 | Đọc HEAD/PR/CI hiện tại, kiểm chứng không có thay đổi ngoài dự kiến, đọc handoff và các file chính | GitHub branch + Actions | Báo đúng SHA, PR Draft, CI PASS/FAIL, không tự suy đoán |
| 2 | Thêm interlock chặn chạy cùng lúc GPS lab Geolocator và Kotlin Safety FGS; thiết kế owner service duy nhất, lệnh start/stop có ACK và trạng thái permission/lifecycle fail-closed | `gps_lab_page.dart`, `safety_service_page.dart`, Kotlin MainActivity/Service, tests | Từ chối start khi monitor khác đang chạy; không thể cộng cước từ health counter; fake/permission failure test |
| 3 | Viết ma trận/instrumented Android test cho start từ Activity resumed, Home, lockscreen, notification stop, GPS outage, permission revoke, airplane mode, Doze/OEM kill, force stop/reboot, clock reversal, storage fault | `android_native/`, `test/`, `docs/` | Có log thiết bị thật với độ tuổi fix và trạng thái service; không giả định kết quả |
| 4 | Sau khi lớp giám sát an toàn được kiểm chứng, thiết kế ONE trip-owning location FGS truyền fix qua native→meter→SQLite với ACK ghi; không phát hành passenger fare khi chưa kiểm thử | Kotlin/Dart core + TripRepository | Không mất/trùng cước; recovery paused; không tăng tiền khi mất GPS; checkpoint atomic và test dài |
| 5 | Nâng cấp backup và tariff consistency, test SQLite migration/restore/update APK, validate receipt immutable | `trip_repository.dart`, `confirmed_tariffs.dart`, data layer | Backup preflight, checksum, rollback, upgrade không mất trip |
| 6 | Dựng 7 màn hình mockup thật + screenshot regression; chưa cho nút Bắt đầu thu cước hoạt động nếu service chưa chấp thuận | `lib/src/ui/`, 7 PNG | Ảnh màn hình thực tế đối chiếu mockup, không fake route/fare |
| 7 | Chọn renderer map hợp pháp zero-cost, ingest OSM tiles/POI đã kiểm giấy phép, local FTS5/search/route A*, road intelligence; kiểm tra Biển Đông/Hoàng Sa/Trường Sa theo yêu cầu hiển thị | map/search/routing module mới (chưa tồn tại) | Không có network API có phí, attribution đầy đủ, dữ liệu & nhãn kiểm thử trên ảnh |
| 8 | VietQR/bank book, lịch sử/doanh thu, báo cáo, backup, chẩn đoán | payment/data/UI | VietQR kiểm bằng ngân hàng thật, doanh thu từ SQLite, không có dữ liệu giả |
| 9 | Stress 1/50/100 × 30 ngày, GPS pin/RAM/FPS, billing/SKU/license audit, ARM64 release ký ổn định | tool/CI/Android thực | Bằng chứng đo thực tế; người dùng duyệt mới phát hành |

**Ưu tiên ngắn hạn khi nhận “Tiếp tục” trong chat mới:** bước 1 → bước 2, trên `feature/navitaximeter-foundation`, có unit tests và CI xanh; không bắt đầu bản đồ trước khi đóng các lỗ hổng GPS gây sai cước.

## 3.10. Chỉ thị tiếp quản bắt buộc

1. Đọc toàn bộ bản bàn giao này và, nếu có, master prompt + quy tắc 7 lượt.
2. Không yêu cầu nhắc lại repo, branch, yêu cầu đã có. Nếu thiếu các ảnh/source riêng ngoài GitHub, nói rõ và đề nghị cung cấp khi cần so sánh.
3. Kiểm tra GitHub HEAD/PR/CI thật trước khi sửa; không dùng SHA cũ làm nguồn thực tại sau khi branch thay đổi.
4. Giữ tất cả ràng buộc chi phí/pháp lý/chủ quyền dữ liệu/thiết kế/tính cước. Không tự ý sửa kiến trúc chỉ vì thấy công nghệ khác.
5. Giữ PR ở Draft, không merge, phát hành hoặc kích hoạt Google Billing khi chưa được chấp thuận.
6. Không nói GPS tính cước chạy nền an toàn hoặc APK thương mại hoàn chỉnh khi mới chỉ có native diagnostic service và CI.
7. Ở chat mới đặt **AI_REPLY_COUNT = 0**, sau mỗi lượt tăng 1, bàn giao đầy đủ tại các lượt 7, 14, 21...
8. Không ghi access token, khóa ký APK hay thông tin cá nhân vào bản bàn giao hoặc log.

**Câu lệnh để chuyển sang chat mới:**
> Hãy tiếp quản NaviTaxiMeter từ bản bàn giao bắt buộc 7/7 này. Kiểm tra GitHub hiện tại, giữ toàn bộ yêu cầu cứng và các phần đã làm, tiếp tục xử lý xung đột hai dịch vụ GPS và thiết kế service owner duy nhất với CI kiểm thử. Không merge main, không sửa TTX gốc, không mở thu cước hoặc Google Billing. Khởi tạo bộ đếm AI_REPLY_COUNT = 0 và bàn giao lại sau mỗi 7 lượt.

**KẾT LUẬN:** Đã hoàn thành nền tảng có kiểm thử tự động. Chưa hoàn thành sản phẩm thương mại, chưa thử thiết bị thật, chưa có bản đồ, VietQR UI và 7 màn hình mockup. Mọi bước tiếp tục cần trung thực về trạng thái.


## Tiếp quản 2026-11-15 — Chu kỳ mới, lượt 1/7

- **AI_REPLY_COUNT:** ban đầu 0, sau lượt tiếp quản này = **1/7**. Bàn giao bắt buộc tiếp theo ở lượt 7; không reset giữa cùng cuộc trò chuyện.
- **Bản bàn giao nguồn:** `docs/HANDOFF_2026-11-15_CYCLE_7-7.md` và quy tắc cứng 7 lượt do chủ dự án cung cấp.
- **Đối chiếu trước thay đổi:** branch HEAD `05fd65f08631bba28d27fdb87ecd7a6d0713493d`, hơn code CI HEAD `c0af5ef6960a6358013b000fb9a947b6b8564a2a` đúng một docs-only commit. PR #1 OPEN/DRAFT/unmerged. main `539ff788b62be69135e5b3ad2c554dca005249a5`, TTX branch `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d`, không thay đổi khi kiểm tra. Foundation PR `43718739681` SUCCESS, Zero Cost PR `43718739693` SUCCESS trên `05fd65f`.
- **Tiến độ issue #3:** bổ sung `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`; hướng proof có điều kiện là một Kotlin TripLocationService duy nhất sở hữu GNSS + một Dart headless TripSessionWorker (service-owned FlutterEngine) sở hữu fare-engine và SQLite writes; ACK sau transaction commit. Chưa chứng minh worker/background/sqflite; không implement production writer, không đổi schema.
- **Điểm tiếp tục:** test lifecycle spike headless Android service với sqflite và non-overlap; yêu cầu ACK fence/sequence/ledger, staged state. Thiết kế v3→v4 backup/migration rồi mới instrumented tests. Issue #2 OPEN, chưa có device proof.
- **Chú ý CI:** hai commit docs-only trong lượt này có thể đưa branch HEAD lên SHA khác; phải xác minh Actions đúng SHA sau commit. CI cũ không chứng nhận HEAD mới cho đến khi chạy.
- **Không đổi:** main, TTX, Google Billing, thu cước khách, signed release, Google API key và logic fare.


## Tiếp tục issue #3, chu kỳ mới lượt 2/7 (15/11/2026)

- **AI_REPLY_COUNT:** sau lượt này = **2/7**; bản bàn giao đủ mục 3.1–3.10 tiếp theo ở lượt 7, không tự reset trong cùng cuộc trò chuyện.
- **Đối chiếu lúc bắt đầu:** HEAD `192160ffe7735012ba5113b398ae0549fde6d67b`, PR #1 OPEN/DRAFT, main `539ff788b62be69135e5b3ad2c554dca005249a5`; issue #2/#3 OPEN. CI mới trên HEAD đầu lượt còn chạy, không sử dụng CI của SHA trước cho SHA sau.
- **Code spike (thử nghiệm, không thu cước):** `lib/src/lab/headless_sqlite_probe.dart`, `android_native/HeadlessSqliteProbeService.kt`, `HeadlessSqliteProbeInstrumentedTest.kt`, `test/headless_sqlite_probe_test.dart`; sửa `lib/main.dart`, `tool/bootstrap_android.py` + Python tests, workflow compile `:app:assembleDebugAndroidTest`. Tài liệu `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`. Generated Android chỉ gắn service bound headless trong **debug manifest/source set**, không có GNSS/FGS, không ghi `navitaximeter_v1.db`; thử DB tên `navitaximeter_HEADLESS_PROBE_ONLY.db`.
- **Cần phân biệt:** Flutter FFI test chỉ dùng SQLite test temp trên runner; Android instrumented test mới **được CI biên dịch**, không được chạy nếu không có device/emulator; không có physical-device pass. Không có production TripLocationService, fare worker, migration v4, atomic ACK ledger, post-COMMIT Android proof hoặc thu cước khách.
- **Lỗi CI đã thấy và xử lý:** commit trung gian `bd6571f` có Python test fixture thiếu `defaultConfig` gây FAIL ở `test_gradle_unit_test_patch_idempotent`; sửa tại `ee00a41250b46d36593139767384bcb2bc7f595a`; Zero Cost PASS sau fix. Ngoài ra sửa lỗi escape newlines trong debug manifest generator tại `abf99990257c30152d580d4b0ff9f2b1cc3a03a2`. Không gán CI PASS cho HEAD mới nếu chưa kiểm tra.
- **Đã cam kết:** vẫn giữ PR Draft, không merge main, không sửa TTX, không Google Billing/API trả phí, không mở thu cước, không ký/phát hành release. Issue #2 bắt buộc còn OPEN đến khi có log Android 11–16 thật.
- **Điểm tiếp tục:** kiểm tra CI chính xác HEAD sau bản cập nhật này, sửa compile/analyze/test nếu fail. Sau đó chạy `connectedDebugAndroidTest` trên máy Android test (chưa có kết quả), xác nhận headless FlutterEngine plugin registration/lifecycle, rồi mới cân nhắc one-native GNSS service + single-Dart SQLite writer với staged candidate và ACK sau COMMIT. Giữ Python proof trên DISPOSABLE_TEST_ONLY.db phân biệt app SQLite.


## Chu kỳ mới lượt 3/7 — serialized headless probe (15/11/2026, giờ VN)

- **AI_REPLY_COUNT = 3/7 sau khi hoàn tất lượt này.** Bản bàn giao bắt buộc kế tiếp ở lượt 7/7 trong cùng cuộc trò chuyện.
- **HEAD code CI đã xác minh:** `2ecc412e46206841c2ced76b187a35f23e2713b7`; Foundation Flutter Android pull_request run [43722503940](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43722503940) **SUCCESS** cho đúng SHA: Python, 12 SQLite proof trong DB tạm, Kotlin JVM, assembleDebugAndroidTest (chỉ **COMPILE**), Flutter analyze/test, Debug APK, manifest kiểm tra và artifact upload. Zero Cost Source Gate PR run [43722503944](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43722503944) **SUCCESS**, là scan source, KHÔNG phải Billing audit thực.
- **Mã vừa sửa:** `lib/src/lab/headless_sqlite_probe.dart` có `SerializedHeadlessProbeWriter` làm hàng đợi Dart duy nhất *CHO PROBE*, không phải trip writer. `test/headless_sqlite_probe_test.dart` thêm trường hợp 8 concurrent requests phải ghi count 1..8 và yêu cầu đường DB sai không làm hỏng hàng đợi. `android_native/HeadlessSqliteProbeInstrumentedTest.kt` thêm 8 lệnh MethodChannel song song, phải đọc count liên tiếp sau SQLite commit/reopen. Instrumentation TEST CHƯA CHẠY trên Android. Các commit: `1129b405efc9943a676708e366e8ac873130565f`, `55fee50980518b83a0624ceff54c7d36dcec89c3`, `2ecc412e46206841c2ced76b187a35f23e2713b7`.
- **Source audit issue #3:** `lib/src/ui/gps_lab_page.dart` line 30 vẫn tạo `TripRepository()`, line 33 tạo `MeteredTripCoordinator`, line 161 tạo Geolocator stream; coordinator trực tiếp gọi `saveActiveIncremental`, `beginActive`, `completeActive`. Preview cũng có Geolocator stream. Legacy `TripRepository.save(record)` vẫn dùng `ConflictAlgorithm.replace`. Chưa có single *production* SQLite writer authority hay TripLocationService. Trước production phải chuyển Lab/Preview thành client, chặn legacy ghi đè, kiểm chứng lifecycle/commit.
- **Tách bằng chứng:** Python `DISPOSABLE_TEST_ONLY.db` 12-case proof, Dart `navitaximeter_HEADLESS_PROBE_ONLY.db` FFI/probe, Kotlin fake writer và future `navitaximeter_v1.db` production là **bốn phạm vi khác nhau**. Không có app DB v4, GNSS native trip, durable fence/ACK ledger hoặc Android post-COMMIT ACK.
- **Issue #2 OPEN, NOT TESTED:** Android 11–16 physical GNSS/FGS overlap, Home/lock/Doze, token stale, reboot, GPS/permission revoke, SQLite failure, OS lifecycle. Không được dùng CI success hay compiled instrumentation thay PASS Android thực.
- **Điểm tiếp tục:** thực thi instrumented probe trên một Android emulator/test device có ghi rõ loại, OS/API/commit/log, vẫn giữ issue #2 physical blocker; sau đó thử service-owned FlutterEngine lifecycle/teardown và verify `sqflite` plugin, tiếp tục thiết kế staged meter candidate, atomic persistent v4 writer fence/ACK after COMMIT, backup/migration v3→v4 trên DB copy. Không thu cước khách và không port Dart fare sang Kotlin chưa parity/approval.
- **Cam kết:** branch feature + PR #1 Draft, main `539ff788b62be69135e5b3ad2c554dca005249a5` không merge, TTX `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d` không sửa, không Google Billing/API trả phí, không ký/ra release. Lưu ý: commit hồ sơ docs này làm HEAD GitHub đổi; CI `43722503940` chứng nhận HEAD **code** `2ecc412`, không tự động chứng nhận HEAD docs mới.


## Chu kỳ mới lượt 4/7 — Android emulator instrumented execution gate (15/11/2026)

- **AI_REPLY_COUNT sau lượt này = 4/7**. Bàn giao đầy đủ bắt buộc ở lượt 7/7. Bản bàn giao 7/7 trước đó: `docs/HANDOFF_2026-11-15_CYCLE_7-7.md`; hồ sơ lượt 1–3 nằm trong chính `docs/AI_HANDOFF_STATE.md`.
- **Mốc kiểm tra đầu lượt:** HEAD `86607bdc0c52dc1053925314e810d036fa0f00b3`; PR #1 OPEN/DRAFT/unmerged; issue #2 và #3 OPEN; main `539ff788b62be69135e5b3ad2c554dca005249a5`; TTX reference `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d` (không sửa). Foundation run `43723124187` còn IN PROGRESS ở đầu lượt; latest confirmed code run `43722503940` SUCCESS on `2ecc412`.
- **Mã mới:** `tool/verify_android_probe_results.py` bắt buộc có JUnit XML report của đúng `HeadlessSqliteProbeInstrumentedTest.boundHeadlessEngineCanOpenSqfliteAndReadCommittedProbe` đã chạy, không lỗi/skip, không nhân đôi. `tool/test_verify_android_probe_results.py` có 7 unit tests chống false PASS (trống report, sai tên, failure, skipped, duplicated). `.github/workflows/flutter-foundation.yml` bổ sung PR-only `emulator-probe` job `needs: build-test` trên standard public `ubuntu-latest` Android API 34 x86_64 emulator, chạy `:app:connectedDebugAndroidTest` và XML verifier; chỉ upload XML/reports thử nghiệm, retention 2 ngày, không có dữ liệu vị trí/chuyến. Code commit `7a2a18aa1e4b24745cc70991b29ac24db42008fe`.
- **CI phân biệt:** Zero Cost Source Gate trên code commit `7a2a18aa` run `43723659668` SUCCESS; Foundation run `43723659685` khi kiểm tra vẫn đang chạy `Kotlin Android location-owner JVM tests`, Python safety đã SUCCESS; emulator job chưa thực thi nên **KHÔNG tuyên bố Android emulator PASS**. Việc ghi tiếp tài liệu handoff này tạo HEAD docs mới, làm CI khởi chạy lại theo SHA; phải kiểm tra run cuối đúng SHA mới, không tái sử dụng kết quả trước.
- **Bằng chứng được phép nếu emulator PASS sau này:** chỉ xác nhận service bound DEBUG `HeadlessSqliteProbeService` có thể tạo headless FlutterEngine và mở `navitaximeter_HEADLESS_PROBE_ONLY.db` bằng sqflite, ghi 1 + 8 lệnh và đọc lại hàng. Không thể coi đây là `navitaximeter_v1.db` writer, native GNSS service, SQLite v4 durable checkpoint hay ACK-after-COMMIT cho khách.
- **Ranh giới chưa đổi:** Python proof `DISPOSABLE_TEST_ONLY.db` / Dart FFI probe / Kotlin fake writer / future Android production trip DB là các hệ thống khác nhau. Current Lab và Preview còn stream Geolocator, Lab `TripRepository` là đường ghi độc lập trong phòng thử; production one-owner + one-writer CHƯA HOÀN THÀNH. Issue #2 Android 11–16/OEM/Doze/kill/FGS physical tests vẫn NOT TESTED, blocker không bỏ.
- **Tiếp tục:** xác minh chính xác CI run mới và Android emulator instrumentation XML; nếu FAIL, đọc log tìm lỗi và sửa code *chỉ trong debug/test*. Sau đó kiểm thử service teardown/rebind và ACK loss trên emulator, thiết kế staging meter Dart, persistent session/generation/ACK ledger schema v4 và backup/migration trên DB copy. Chỉ sau device evidence issue #2 + calibration + approval mới cân nhắc sản phẩm.
- **Cấm:** không merge main, không sửa TTX gốc, không bật Google Billing/API trả phí, không bật cước/hóa đơn khách, không kí phát hành production.
