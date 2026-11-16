# Issue #2 — A2-05b: thu hồi quyền Vị trí RIÊNG của NaviTaxiMeter (Xiaomi Android 13)

**Ngày soạn:** 16/11/2026 (UTC+07). **Trạng thái:** PREPARED / **NOT TESTED**. Đây là ca MỚI, khác A2-05 tắt công tắc Vị trí toàn hệ thống đã PASS theo video; không yêu cầu lặp ca đó.

## 1. Mục tiêu và bản đang kiểm

- **Mục tiêu:** kiểm fail-closed khi thu hồi quyền Vị trí của **ứng dụng NaviTaxiMeter** trong lúc Android GPS nền chẩn đoán đang hoạt động. Phân biệt service dừng/ACK mất, tiến trình bị Android đóng, và dữ liệu không thể quan sát. Sau khi cấp lại quyền, **không tự nối lại phiên cũ**.
- **Thiết bị:** chủ dự án đã khai báo Xiaomi Redmi Note 12 Pro, Android 13; MIUI/HyperOS build chưa được xác minh. Không yêu cầu PC/ADB.
- **Repo/branch:** `ThanhTaxiXanh/NaviTaxiMeter` / `feature/navitaximeter-foundation`, PR #1 Draft. **HEAD đối chiếu trước khi tạo tài liệu:** `c77a4157a691620e69eeb0f3a6e46d8bdecbb862` (docs-only sau code `db4dcab34432c3a1c5a31903e30b0d0ff9b31def`).
- **CI của HEAD đối chiếu:** [Foundation Flutter Android run 43846686647](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43846686647) **SUCCESS**; [Zero Cost Source Gate run 43846686523](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43846686523) **SUCCESS**. Chúng KHÔNG kiểm được Xiaomi thật.
- **APK tham chiếu nếu chưa có bản thử:** artifact DEBUG `navitaximeter-native-gps-safety-DEBUG-only`, ID **14216620325**, trong Foundation run trên; ZIP digest do GitHub công bố `sha256:a400d9d0182e6e1215d609b8b08b270cc3e2002bcc00ca8cbeb3c0668ea80713`. **Chưa xác minh SHA-256 APK giải nén hoặc binary đang cài trên máy.** Không ghi rằng APK trên điện thoại khớp SHA chỉ từ ảnh.
- **Chỉ dùng ứng dụng CHỈ CHẨN ĐOÁN, KHÔNG TÍNH CƯỚC.** Không thử khi lái/chở khách, không xóa dữ liệu hay gỡ ứng dụng, không đổi bảng giá, không cài bản mới nếu có nguy cơ dữ liệu đang lưu. Nếu app thử hiện tại có đủ 5 tab và `GPS nền` chạy đúng, có thể làm trên bản đang cài và ghi `APK installed hash: UNVERIFIED`; **không cần cài lại**.

## 2. Chuẩn bị an toàn

1. Đỗ xe an toàn, không có chuyến/khách, không có Lab đang chạy. Pin đủ; giữ nguyên cấu hình tiết kiệm pin hiện tại để dễ so sánh. Không dùng mã cước hay GPS giả.
2. Bật **Vị trí** toàn hệ thống (không dùng Quick Settings để tắt vị trí trong ca này). Ở **Cài đặt → Ứng dụng → NaviTaxiMeter → Quyền ứng dụng → Vị trí**, kiểm tra hiện là **Chỉ cho phép khi dùng ứng dụng** + **Sử dụng vị trí chính xác** (nếu có). **Chụp ảnh đã che thông tin riêng tư** hoặc ghi bằng chữ; MIUI có thể thêm mục **Quản lý ứng dụng**.
3. Mở NaviTaxiMeter, xác nhận 5 tab `Trạng thái | Bảng giá | GPS thử | Phòng thử | GPS nền` và nhãn **CHỈ CHẨN ĐOÁN · KHÔNG TÍNH CƯỚC** trong GPS nền. Nếu không đúng, **NOT TESTED**, gửi tên màn/nút đã thấy; không bấm nút phỏng đoán.

## 3. Các thao tác A2-05b, chỉ MỘT ca

1. Mở tab **GPS nền** → **Bật GPS nền thử** → hộp thoại `Bật dịch vụ GPS an toàn?` → **Bật dịch vụ thử**. Chờ vài giây, bấm **Đọc lại trạng thái**. Chỉ tiếp tục khi hiện `Dịch vụ: Đang chạy`, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`. Nếu không khởi động được, ghi **NOT TESTED** và dừng; không ép thử.
2. **Bằng chứng TRƯỚC:** chụp trạng thái tab **GPS nền** đã che dữ liệu riêng tư; ghi giờ, `GPS mới`, `Trạng thái`, `Chủ GPS`, `ACK/heartbeat`. Số mẫu chấp nhận là chỉ số chẩn đoán, không phải quãng đường/cước.
3. Bấm **Home**, mở **Cài đặt Android → Ứng dụng → Quản lý ứng dụng (nếu có) → NaviTaxiMeter → Quyền ứng dụng → Vị trí → Không cho phép**. **Chỉ thu hồi quyền của NaviTaxiMeter**, không tắt công tắc Vị trí Android. Nếu MIUI đặt tên khác, tìm `NaviTaxiMeter` trong Cài đặt rồi vào `Quyền`. Nếu không tìm thấy, dừng và đánh dấu **NOT TESTED**, không thử ngẫu nhiên.
4. **Bằng chứng QUYỀN:** ghi/chụp màn `Vị trí: Không cho phép`, không lộ thông báo app khác. Android/Xiaomi **có thể đóng tiến trình ứng dụng khi thay đổi quyền**; đây không tự động là FAIL. Không mở lại dịch vụ lúc chưa có quyền.
5. Sau khoảng **5–15 giây**, mở NaviTaxiMeter qua biểu tượng ứng dụng (nếu đã bị Android đóng, mở lại bình thường) → tab **GPS nền** → **Đọc lại trạng thái**, đọc lại sau khoảng 3 giây nếu ứng dụng còn hoạt động. **Bằng chứng SAU:** ảnh các dòng service/fresh/state/owner/ACK; ghi app tự đóng, khởi động lại hay không và có thấy trạng thái hay không. **KHÔNG bấm Bật GPS nền thử** ở bước này.
6. **Phục hồi quyền an toàn:** vào **Cài đặt → Ứng dụng → NaviTaxiMeter → Quyền ứng dụng → Vị trí → Chỉ cho phép khi dùng ứng dụng**; bật lại **Sử dụng vị trí chính xác** như trước. Giữ Vị trí toàn hệ thống ON. Mở app → tab **GPS nền** → **Đọc lại trạng thái**; **không bấm Start** trước khi quan sát xem service có tự chạy lại không. Chụp 1 ảnh trạng thái sau cấp lại quyền. Nếu còn service hoạt động bất thường, nhấn **Dừng GPS nền thử** và ghi lại hiện tượng.
7. Kết thúc: nếu muốn thử lại GPS phải **chủ động** bấm `Bật GPS nền thử` và xác nhận hộp thoại như phiên hoàn toàn mới, nhưng thao tác khởi động lại này **không cần thiết** để hoàn tất A2-05b.

## 4. PASS / FAIL / NOT TESTED và giới hạn chứng cứ

- **PASS theo phạm vi màn hình đã quan sát:** có bằng chứng trước khi revoke service native active + ACK; sau revoke quyền app hoặc khi mở lại thì **không công bố GPS mới đáng tin**, không còn `ACK/heartbeat: Đã xác nhận` cho phiên đã mất quyền (`Dịch vụ: Đã dừng` / `Chủ GPS: none` là kết quả mong đợi); sau cấp quyền, **không tự khởi động lại** trước khi người dùng bấm Start. Nếu Android kết thúc tiến trình lúc revoke, chỉ xác nhận được trạng thái **sau mở lại**, không tuyên bố đã quan sát từng khoảnh khắc.
- **FAIL, dừng và lưu evidence:** sau khi `Vị trí: Không cho phép` đã được xác nhận và người dùng bấm `Đọc lại trạng thái`, ứng dụng vẫn cho thấy `GPS mới: Có` / `trusted_gps` **kèm ACK của phiên cũ**; hoặc sau khi cấp lại quyền ứng dụng tự resume dịch vụ/phiên cũ; hoặc app tính cước/ghi hóa đơn. Không thử thêm ca khác trước khi xem lỗi.
- **NOT TESTED / CHƯA XÁC MINH:** không thấy đúng nút, không được cấp quyền để bắt đầu, Android chặn thay đổi quyền, app không mở lại được, không chụp được trạng thái sau revoke, không biết APK nào đang chạy. **Mất tiến trình hoặc không có ảnh giữa lúc revoke không đủ để chứng minh PASS ngay tức thì.**
- Ca này **không xác minh** chuyển sang vị trí gần đúng (approximate-only), stale notification token, Doze, kill/reboot, real-distance calibration, APK SHA cài trên máy hoặc Android 11–16.

## 5. Gửi bằng chứng vào cuộc trò chuyện, không đăng GitHub

Gửi 3–4 ảnh **đã che**: (1) GPS nền trước revoke, (2) Android `Vị trí → Không cho phép`, (3) GPS nền sau revoke/khởi động lại, (4) GPS nền sau cấp lại quyền nhưng **trước** Start mới. Ghi:
`A2-05b | PASS/FAIL/NOT TESTED (tự báo) | thời gian VN | app có bị Android đóng không | hiện tượng cụ thể | MIUI/HyperOS nếu biết | APK hash installed: UNVERIFIED (nếu chưa xác minh)`.

**Ẩn tọa độ, địa chỉ, hành trình/khách, số điện thoại, IMEI/serial, thông báo riêng tư, tài khoản ngân hàng, keystore/token/API key.** Chỉ gửi trong chat đã che PII; repo Issue #2 chỉ ghi bản tóm tắt kỹ thuật sau khi AI xem bằng chứng. **Trạng thái hiện tại: NOT TESTED; Issue #2 OPEN.** Không thu cước hoặc merge PR/main.