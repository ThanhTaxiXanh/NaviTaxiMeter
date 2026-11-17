# Issue #2 — Xiaomi Redmi Note 12 Pro / Android 13: hướng dẫn thử GPS nền thật

**Cập nhật:** 2026-11-16 (Việt Nam UTC+7). **Trạng thái:** PREPARED, **TẤT CẢ CA NOT TESTED**. Người dùng xác nhận model **Xiaomi Redmi Note 12 Pro**, Android **13**. Chưa có ảnh/log hoặc kết quả test điện thoại vật lý. Phiên bản MIUI/HyperOS **chưa được xác minh**, không đoán tên menu đặc thù.

## 1. Mục tiêu, bằng chứng artifact và an toàn

- Repo `ThanhTaxiXanh/NaviTaxiMeter`, branch **DUY NHẤT được ghi** `feature/navitaximeter-foundation`, PR #1 **DRAFT / không merge**.
- **APK DEBUG gốc cho các ca dưới:** code SHA `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24`; Foundation PR run [43811708123](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43811708123) **SUCCESS** (CI + Android 14 emulator, KHÔNG phải thử trên Xiaomi). Artifact `navitaximeter-native-gps-safety-DEBUG-only` ID **14200424290**, có một `app-debug.apk`.
- ZIP SHA-256 `363824f62aa6d02ed50c380a38f452a9fb182b8b2d42af123a529bc0fb623cd5`. APK 165929486 bytes, SHA-256 `7ec6a8bbd39252cc27663566f6c280110ab23fb235a54fae71b6d73962dc540e`. Các hash này đã đối chiếu lại với ZIP tải từ GitHub.
- Mở GitHub Actions run bên trên trên điện thoại, cuộn đến **Artifacts**, đăng nhập GitHub nếu được yêu cầu, tải `navitaximeter-native-gps-safety-DEBUG-only`, giải nén và cài **app-debug.apk**. Nếu đã được gửi tệp APK qua chat, chỉ dùng tệp có cùng hash. Không tin APK từ link lạ.
- **Chỉ chẩn đoán, KHÔNG tính cước, KHÔNG dùng khi có hành khách, KHÔNG phát hành hóa đơn.** Không gỡ hoặc ghi đè bản đang lưu dữ liệu cần giữ; không xóa dữ liệu ứng dụng/SQLite/prefs. Không cần PC/ADB. Chỉ thao tác khi dừng xe tại nơi an toàn.
- Nếu Android hỏi quyền cài từ ứng dụng đang mở APK, chỉ cho phép tạm thời từ nguồn đã xác minh, sau đó tắt lại. Nếu chặn/cảnh báo, ghi màn hình và dừng; không cố vượt cơ chế bảo vệ.

## 2. Chuẩn bị riêng cho Redmi Note 12 Pro (Android 13)

1. Mở **Cài đặt → Giới thiệu điện thoại**, xem **Android 13**, tên máy, và ghi **phiên bản MIUI hoặc HyperOS nếu hiện trên màn**. Không gửi IMEI, số serial, số điện thoại.
2. Bật **Vị trí** toàn hệ thống. Vào **Cài đặt → Ứng dụng → Quản lý ứng dụng / NaviTaxiMeter → Quyền ứng dụng**; nếu Xiaomi bố trí khác, sử dụng ô tìm kiếm của Cài đặt để tìm `NaviTaxiMeter`, `Vị trí` và `Thông báo`. Tên menu có thể khác tùy bản MIUI/HyperOS.
3. Khi ứng dụng hỏi quyền vị trí, chọn **Cho phép khi dùng ứng dụng** và **Vị trí chính xác** (nếu có). Nếu Android hỏi quyền thông báo trên Android 13, cấp quyền để thử notification Stop; ghi nếu máy không cho. **Không giả định đã có quyền chạy nền liên tục.**
4. Ghi mức pin, chế độ **Tiết kiệm pin** đang bật/tắt, cấu hình tiết kiệm pin riêng của ứng dụng và quyền thông báo. **Không tự đổi cài đặt tối ưu hóa pin ở lượt thử đầu**, để giữ bằng chứng hành vi Xiaomi mặc định. Sau này mới A/B thử sau khi có kết quả.
5. Mở NaviTaxiMeter. Trước khi test phải thấy 5 tab: **Trạng thái · Bảng giá · GPS thử · Phòng thử · GPS nền** và dòng **CHƯA SẴN SÀNG THU CƯỚC**. Nếu không đúng, ghi **NOT TESTED**, gửi ảnh đã che thông tin; không đoán nút.

## 3. Bộ ca cần chạy, theo đúng nút trong mã hiện tại

### A2-01 — Native GPS Start/ACK (đứng tại chỗ)

- **Thử:** Service/owner/ACK từ Android và tín hiệu GNSS thật không kết nối tới tính cước.
- **Các bước:** tab **GPS nền** → **Bật GPS nền thử** → hộp thoại **Bật dịch vụ GPS an toàn?** → **Bật dịch vụ thử** → đợi trạng thái trả về, bấm **Đọc lại trạng thái**; tại chỗ thoáng trời chờ tín hiệu thật, bấm đọc lại.
- **PASS phần Start/ACK:** `Dịch vụ: Đang chạy`, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`, không có cước. **PASS GNSS fresh** chỉ khi thêm `GPS mới: Có` và `Trạng thái: trusted_gps`. Nếu còn trong nhà/chưa có fix, phần GNSS là **NOT TESTED**, không tự ghi FAIL.
- **FAIL/dừng:** crash; hiển thị ACK hợp lệ khi service đã chết; bắt đầu tính tiền. Nếu không có nút, ghi NOT TESTED.
- **Bằng chứng:** ảnh các dòng `Dịch vụ`, `GPS mới`, `Trạng thái`, `Chủ GPS`, `ACK/heartbeat`, `Số mẫu GPS chấp nhận` (đã che dữ liệu cá nhân).

### A2-02 — Chống mở hai GPS cùng lúc

- **Thử:** khi native service vẫn chạy, không được mở Geolocator Preview song song.
- **Các bước:** từ A2-01 đang `native_safety`, chuyển tab **GPS thử** → bấm **Bắt đầu xem GPS** → chụp thông báo trạng thái → quay lại **GPS nền** → **Đọc lại trạng thái**.
- **PASS:** Preview từ chối quyền GPS với `GPS_BUSY` hoặc thông báo owner bận, không có hai stream cùng chạy.
- **FAIL/dừng:** hai stream đồng thời hoạt động, hoặc app crash. Nếu native đã tự dừng khi đổi tab, ghi NOT TESTED ca tranh chấp và mô tả.

### A2-03 — Stop trên ứng dụng và thông báo

- **Thử:** stop có token không giữ ACK cũ.
- **Các bước:** tab **GPS nền** → **Dừng GPS nền thử** → **Đọc lại trạng thái**. Tiếp theo bật lại bằng các nút A2-01 → kéo bảng thông báo xuống tìm **NaviTaxiMeter · Theo dõi an toàn** → bấm **Dừng GPS an toàn** → trở về tab **GPS nền**, bấm **Đọc lại trạng thái**.
- **PASS:** sau mỗi cách dừng, `Dịch vụ: Đã dừng`, `ACK/heartbeat: Chưa xác nhận`, không còn owner đang hoạt động.
- **FAIL/dừng:** service đã dừng nhưng vẫn ACK/owner cũ. Không có thông báo vì OEM/quyền thông báo: phần Stop notification NOT TESTED, ghi chính xác.

### A2-04 — Home/khóa màn hình 30–60 giây

- **Thử:** vòng đời foreground/background trên Xiaomi.
- **Các bước:** bật native như A2-01, ghi ACK → bấm Home → khóa màn 30–60 giây → quan sát thông báo nếu có → mở khóa → app/tab **GPS nền** → **Đọc lại trạng thái**.
- **PASS:** service vẫn có session/ACK hợp lệ **hoặc** service đã bị dừng nhưng ACK bị rút đúng, không có tính cước hoặc tự bù quãng đường.
- **FAIL/dừng:** công bố ACK giả khi service chết hoặc xuất hiện tính cước. Ghi chế độ tiết kiệm pin và tình trạng thông báo thực tế.

### A2-05 — Thu hồi quyền GPS hoặc tắt Vị trí

- **Thử:** thu hồi quyền dẫn đến fail-closed.
- **Các bước:** bật native A2-01 → Cài đặt Android → ứng dụng NaviTaxiMeter → Quyền → Vị trí → đổi sang **Từ chối**, hoặc tắt Vị trí hệ thống → quay về app/tab **GPS nền** → sau 5–15 giây **Đọc lại trạng thái**.
- **PASS:** service dừng hoặc ACK không còn được xác nhận / `GPS mới: Không`. **FAIL/dừng:** vẫn quảng bá GPS tin cậy và ACK đang chạy dù đã tắt điều kiện GPS. Nếu không thể đổi quyền, ghi NOT TESTED.
- Sau ca này có thể khôi phục quyền. **Không chấp nhận tự tiếp tục phiên cũ như PASS**; muốn thử tiếp phải dừng rồi bật thủ công.

### A2-06 — Phòng thử/SQLite (tùy chọn, mặc định NOT TESTED)

- **Không thực hiện** nếu chưa có giá cước thực đã xác nhận hoặc máy đang có dữ liệu quan trọng; không tạo giá ảo và không xóa checkpoint.
- Nếu cần thử sau, theo tài liệu gốc `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md`; không dùng chuyến xe khách.

## 4. Mẫu phản hồi và tiêu chí công nhận kết quả

Gửi **trong chat**, không đăng GPS/PII lên GitHub. Với mỗi ca ghi: `A2-0x | PASS / FAIL / NOT TESTED | bước | hiện tượng | ảnh đã che`.

| Ca | Kết quả hiện tại | Ghi chú |
| --- | --- | --- |
| A2-01 Start/ACK + fresh GNSS | NOT TESTED | Chưa có kết quả Xiaomi |
| A2-02 khóa owner | NOT TESTED | Chưa có kết quả Xiaomi |
| A2-03 UI/notification Stop | NOT TESTED | Chưa có kết quả Xiaomi |
| A2-04 Home/khóa màn | NOT TESTED | Chưa có kết quả Xiaomi |
| A2-05 thu hồi quyền/provider | NOT TESTED | Chưa có kết quả Xiaomi |
| A2-06 Lab/SQLite tùy chọn | NOT TESTED | Chỉ làm nếu đủ điều kiện |

Đính kèm: model **Redmi Note 12 Pro**, **Android 13**, MIUI/HyperOS **nếu biết**, ngày/giờ, quyền chính xác hay gần đúng, trạng thái thông báo, tiết kiệm pin, mã APK SHA/run bên trên. **Che/cắt tọa độ, địa chỉ, khách, điện thoại, IMEI/serial, tài khoản ngân hàng, keystore, API key, thông báo cá nhân.**

Chỉ ghi **Android physical PASS** sau khi có bằng chứng đủ rõ và đối chiếu ca cụ thể. **CI PASS/Android 14 emulator PASS không thay được Xiaomi PASS.** Mọi FAIL cần bước tái hiện và theo dõi trong issue riêng. Issue #2 vẫn OPEN; Issue #3 production single owner/SQLite writer vẫn NOT IMPLEMENTED. Không merge main, không bật billing/paid API, không thu cước khách.

## 5. Tài liệu nguồn và tiếp nối

- [Bàn giao Cycle 6](HANDOFF_2026-11-16_CYCLE6_7-7.md), mục 3.1–3.10 và **Phụ lục A** nguyên văn quy tắc kiểm thử điện thoại.
- [Kịch bản nền Issue #2](ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md), bao gồm các hướng dẫn chuẩn Android.
- [Quy tắc bàn giao 7 lượt](QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md) mục 9/10.
- Bước kế tiếp: nhận ảnh/text redacted A2-01 trước, đánh giá kết quả thật; tiếp tục A2-02...A2-05. Nếu không cài được APK ghi blocker cụ thể, không bịa PASS.
