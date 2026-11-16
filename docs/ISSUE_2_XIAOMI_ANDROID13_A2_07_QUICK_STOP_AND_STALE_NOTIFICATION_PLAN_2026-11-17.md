# Issue #2 — Xiaomi Android 13: A2-07 Quick Stop, giới hạn stale-notification

**Ngày:** 17/11/2026 (UTC+07). **Trạng thái:** PREPARED / **NOT TESTED**. Hướng dẫn từng nút dành cho chủ dự án. Tài liệu được tạo sau khi người dùng nhắc AI phải cung cấp quy trình kiểm thử điện thoại trước khi yêu cầu test, tuân thủ quy tắc 9 `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`.

## Bằng chứng kỹ thuật và giới hạn cần nói rõ

- Repository `ThanhTaxiXanh/NaviTaxiMeter`, nhánh DUY NHẤT được ghi `feature/navitaximeter-foundation`, PR #1 Draft, không merge `main`. HEAD trước soạn `620923f97a4dfd9b0fdbe7fcefb76a63a074a9aa`; code GNSS/Flutter last changed in `db4dcab34432c3a1c5a31903e30b0d0ff9b31def`. Đã kiểm tra `lib/src/ui/safety_service_page.dart`, `android_native/MainActivity.kt`, `LocationSafetyService.kt`, `LocationOwnerRegistry.kt`.
- **Bản chạy:** Android DEBUG đang cài trên Xiaomi Redmi Note 12 Pro Android 13, **SHA binary APK đang cài CHƯA XÁC MINH**; nếu UI khác, dừng. Bản DEBUG có artifact nguồn đã được xác minh từ Foundation PR `43846686647`, artifact `14216620325`, ZIP digest trên GitHub `sha256:a400d9d0182e6e1215d609b8b08b270cc3e2002bcc00ca8cbeb3c0668ea80713`; hash ZIP **không** chứng minh APK đang cài. Không yêu cầu gỡ/cài lại.
- **Không thể thực hiện hai điều bằng giao diện hiện tại:** (1) Flutter đặt `_busy=true` lúc Start và `Dừng GPS nền thử` có `onPressed: _busy ? null : _stop`, vì vậy người dùng **không thể bấm Stop trước ACK** bằng nút hiện tại; chỉ test **Stop nhanh sau khi UI cho bấm**. (2) Native notification Stop chứa lease token trong intent URI khác biệt theo phiên; khi phiên mới hoạt động, thông báo mới thay thế cái cũ. Người dùng **không có nút phục hồi/gửi lại PendingIntent phiên cũ**; test stale notification thực sự cần **test harness/instrumentation riêng** và **NOT TESTED** trên điện thoại qua UI, không đánh tráo với Stop thông báo phiên hiện tại. A2-03 Stop qua notification bình thường **đã PASS UI**, không cần lặp chỉ để gọi là stale-token.
- Đây là GPS health DEBUG-only, không gửi coordinates sang Flutter, không ghi SQLite cước. Không dùng khách thật, không lái xe, không xóa/migrate DB v3, không thay tariff, paid APIs/Google Billing.

## Chuẩn bị

1. Đỗ xe an toàn, không có khách. Android **Vị trí** toàn hệ thống ON, quyền `NaviTaxiMeter → Vị trí → Chỉ cho phép khi dùng ứng dụng`, **Sử dụng vị trí chính xác ON** (video A2-05c cuối để OFF), thông báo ON. Không đổi thiết lập pin OEM trong ca test.
2. Mở app, đảm bảo thấy 5 tab `Trạng thái | Bảng giá | GPS thử | Phòng thử | GPS nền`; vào **GPS nền**, có nhãn `CHỈ CHẨN ĐOÁN · KHÔNG TÍNH CƯỚC`. Nếu thiếu, **NOT TESTED** và gửi ảnh màn có nút thực tế.
3. Nếu GPS nền còn chạy: `Dừng GPS nền thử → Đọc lại trạng thái`. Trước test cần `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Chủ GPS: none`, `ACK/heartbeat: Chưa xác nhận`.
4. Bật Xiaomi **Ghi màn hình**, quay liên tục, che thông báo riêng tư/địa chỉ nếu có.

## A2-07A — Stop nhanh sau ACK bằng các nút đang tồn tại

1. Tab **GPS nền** → **Bật GPS nền thử** → hộp thoại `Bật dịch vụ GPS an toàn?` → **Bật dịch vụ thử**.
2. Quan sát `Dịch vụ: Đang chạy`, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`. Chỉ tiếp tục nếu nút `Dừng GPS nền thử` **đã bấm được**. Không cần `trusted_gps` hay cước. Không cố chạm Stop khi nó đang mờ: không chứng minh pre-ACK. Nếu không có ACK, ghi NOT TESTED và không ép thử.
3. **Ngay khi nút bấm được**, chạm **Dừng GPS nền thử đúng một lần**, không nhấp liên tục. Bấm **Đọc lại trạng thái** sau khoảng 1–3 giây và 5 giây.
4. Mong đợi `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Chủ GPS: none`, `ACK/heartbeat: Chưa xác nhận`. Nếu còn owner khác hoặc ACK cũ dai dẳng sau lần refresh thứ hai, ghi hiện tượng và dừng, không kết luận do UI đơn lẻ.
5. Tab **GPS thử** → **Bắt đầu xem GPS**. Nếu `GPS_BUSY` xuất hiện ngay sau teardown, đợi 3–5 giây rồi thử lại **một lần**. Khi Preview chạy, bấm **Dừng GPS thử**. Nếu Preview không thể start/owner không thả, ghi ảnh và FAIL hoặc NOT VERIFIED tùy biểu hiện.
6. Tab **GPS nền** → **Đọc lại trạng thái**; chắc chắn service không tự Start. Kết thúc quay video.

**PASS cho phần quan sát UI:** service stop; owner none và ACK false; Preview có thể nhận quyền sau khi native nhả; không thấy hai GPS đồng thời trong phạm vi video, không tự chạy lại/cước. **FAIL:** service cũ còn báo ACK/owner sau teardown, crash, hai chế độ GPS đồng thời, hoặc tự tính cước; dừng và gửi video. **NOT TESTED:** thiếu ACK, không tìm thấy nút hoặc thiếu evidence sau stop. Đây **không** kiểm được Stop pre-ACK, stale token hoặc thời điểm chính xác của native onDestroy.

## A2-07B — Thông báo Stop *phiên cũ*: CHƯA THỂ TEST BẰNG UI

Không yêu cầu chủ dự án tìm, giữ, sao chép hay bấm một nút `DỪNG GPS AN TOÀN` cũ sau Start phiên mới: Android thông thường chỉ trình bày notification hiện hành, không tạo luồng gửi lại token cũ. Một thông báo có chữ Stop giống nhau **không chứng minh đó là token phiên cũ**. **Không biến A2-03 Stop notification bình thường đã PASS thành test stale-token.**

**Muốn kiểm thật:** cần lập kế hoạch source/test-only instrumented harness giữ được `PendingIntent` hoặc gửi lại stale `ACTION_STOP` với lease cũ vào sandbox DEBUG sau Start phiên mới; phải có quyền kiểm soát token mà không làm lộ dữ liệu người dùng. Test sẽ yêu cầu chứng minh: `old_lease STOP` không dừng `new_lease`, không mở song song GPS, và stale callback không phát ACK. Phần này **DESIGN ONLY / NOT IMPLEMENTED / NOT TESTED**, phải code review, CI, chỉ sau đó mới chạy Android thật. Không yêu cầu PC/ADB với người dùng ở bước hiện tại.

## Bằng chứng cần gửi cho AI

**Một video** liên tục A2-07A từ trước Start đến sau Preview Stop và trở lại GPS nền. Hoặc **4 ảnh**: (1) trước Start, (2) active/ACK true, (3) sau Stop owner none/ACK false, (4) Preview chạy sau khi native nhả, kèm trạng thái cuối. Ghi `A2-07A | PASS / FAIL / NOT TESTED theo quan sát | thời điểm VN | trạng thái sau 5 giây | GPS_BUSY nếu có | máy Android 13 | APK installed SHA: UNVERIFIED`. Che tọa độ, địa chỉ, hành trình khách, IMEI/serial, tài khoản, token, API key và thông báo cá nhân. Gửi trong chat; **không đăng bằng chứng riêng tư lên GitHub**.

Nếu FAIL mới tạo issue lỗi riêng với reproduction; Issue #2 còn OPEN. Không tăng phạm vi thử sang Lab/SQLite hoặc tiền cước.
