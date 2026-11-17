# Issue #2 — Xiaomi Android 13: A2-05c chuyển từ vị trí CHÍNH XÁC sang GẦN ĐÚNG

**Ngày:** 16/11/2026; **cập nhật chứng cứ:** 17/11/2026, UTC+07. **Trạng thái A2-05c: PASS THEO VIDEO đối với hành vi an toàn đã quan sát (giới hạn Android reopen/coarse-only)**. Video bổ sung dài 54,60 giây lúc 06:44–06:45 **đã ghi trusted_gps + GPS mới Có trước khi tắt precise ON→OFF**, sau reopen stopped/owner none/ACK false. Khi chủ dự án Start thủ công với precise vẫn OFF, service ACK true nhưng fresh false/acquiring/acceptedCount 0 (xác nhận lại quyền precise OFF lúc ~42s); cuối video service stopped. **Không thấy thao tác khôi phục precise ON**, chưa kiểm nhánh dịch vụ sống liên tục không restart hoặc OEM khác. Video 16/11 trước đó chỉ partial PASS vì chưa có trusted fix ban đầu; video 17/11 đã bổ sung điều kiện này. Xem mục **2F–2G** trong hồ sơ evidence. **Không yêu cầu lặp ca đã PASS**; Issue #2 vẫn OPEN.

## 1. Mục tiêu, môi trường, và cơ sở mã nguồn

**Mục tiêu:** khi người dùng còn cấp quyền Vị trí gần đúng nhưng tắt **Sử dụng vị trí chính xác** cho NaviTaxiMeter, ứng dụng KHÔNG được tiếp tục công bố **GPS mới: Có / trusted_gps** từ mẫu GNSS cũ hoặc nguồn NETWORK_PROVIDER. ACK/heartbeat (nếu còn) chỉ xác nhận Android service còn sống, **không** có nghĩa GPS chính xác để tính cước. Phân biệt với quy trình A2-05b đã thử hoàn toàn `Không cho phép`.

- **Máy:** Xiaomi Redmi Note 12 Pro / Android 13 theo chủ dự án; MIUI/HyperOS build chưa xác minh. **Không cần PC, ADB hoặc cài lại ứng dụng.**
- **Nhánh kiểm chứng:** `feature/navitaximeter-foundation`; HEAD tại lúc soạn `01faacf994d37cca85880565df936f438cbc140a` (các commit tài liệu sau đó có thể làm HEAD đổi). **Mã sản phẩm tham chiếu:** `db4dcab34432c3a1c5a31903e30b0d0ff9b31def` (khắc phục import Flutter, không can thiệp native permission).
- **GitHub Actions HEAD trước soạn:** Zero Cost PR [43889882523](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43889882523) **SUCCESS**; Foundation PR [43889882563](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43889882563) **IN PROGRESS tại thời điểm đối chiếu**. Không nhận PASS chưa có hoặc dùng CI thay video Xiaomi.
- **APK Debug tham chiếu đã có artifact:** Foundation run [43846686647](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43846686647) SUCCESS trên code chưa thay đổi, artifact `navitaximeter-native-gps-safety-DEBUG-only` ID **14216620325**; ZIP GitHub digest `sha256:a400d9d0182e6e1215d609b8b08b270cc3e2002bcc00ca8cbeb3c0668ea80713`. **Chưa biết SHA-256 APK giải nén / binary đang cài trên Xiaomi.** Không yêu cầu cài lại nếu app hiện tại mở đúng màn và nút. Nếu chỉ có APK từ nguồn lạ hoặc tính năng khác màn dự kiến thì **NOT TESTED**.
- **Cơ sở code được đọc:** `android_native/LocationSafetyService.kt`: có quyền fine thì chọn GPS_PROVIDER; nếu coarse-only thì có thể dùng NETWORK_PROVIDER. `GnssFixTrustGate.kt` từ chối GNSS trust khi thiếu fine permission hoặc provider không phải GNSS; `GnssHealthPublication` chỉ báo `fresh` với state `trusted_gps`. Việc Android restart app khi đổi precision phụ thuộc OS/OEM, không suy đoán là service tiếp tục chạy.

## 2. Điều kiện an toàn

- Dừng xe, không hành khách, **không thử khi đang lái**, không sử dụng app để tính cước hoặc xuất biên nhận; không thao tác ở `Phòng thử` và không tạo tariff demo.
- **Vị trí** toàn hệ thống luôn ON trong ca này; chỉ đổi tùy chọn chính xác của **NaviTaxiMeter**. Giữ nguyên thông báo và cài đặt pin để so sánh; không gỡ/cài lại, không xóa dữ liệu `navitaximeter_v1.db` hoặc prefs.
- Trước test, mở Android **Cài đặt → Ứng dụng → Quản lý ứng dụng** (nếu có) → **NaviTaxiMeter → Quyền ứng dụng → Vị trí**. Kiểm đang **Chỉ cho phép khi dùng ứng dụng** và **Sử dụng vị trí chính xác** đang ON. Nếu Xiaomi đổi tên menu, dùng tìm kiếm Cài đặt với `NaviTaxiMeter`, không tự đoán mục khác. Ghi phiên bản MIUI/HyperOS nếu có nhưng KHÔNG chụp IMEI/serial.
- Mở NaviTaxiMeter, kiểm 5 tab **Trạng thái / Bảng giá / GPS thử / Phòng thử / GPS nền**, nhãn **CHỈ CHẨN ĐOÁN · KHÔNG TÍNH CƯỚC** ở `GPS nền`. Không khớp: dừng, ghi **NOT TESTED**.

## 3. Các thao tác chính xác (A2-05c)

1. Vào tab **GPS nền** → bấm **Bật GPS nền thử** → hộp thoại `Bật dịch vụ GPS an toàn?` → **Bật dịch vụ thử**. Chờ 5–15 giây nơi thoáng (nếu có), bấm **Đọc lại trạng thái**. **Chỉ tiếp tục** nếu nhìn thấy `Dịch vụ: Đang chạy`, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận` và `GPS mới: Có` / `Trạng thái: trusted_gps`. Nếu không có fresh trusted trước thử, ghi **NOT TESTED** và dừng: không thể xác minh chuyển từ trusted sang untrusted.
2. **Ảnh TRƯỚC:** chụp (đã che phần nhạy cảm) các dòng `Dịch vụ`, `GPS mới`, `Trạng thái`, `Chủ GPS`, `ACK/heartbeat`. Không ghi tọa độ hoặc khách.
3. Bấm **Home** → Android **Cài đặt → Ứng dụng → (Quản lý ứng dụng nếu có) → NaviTaxiMeter → Quyền ứng dụng → Vị trí**. Giữ `Chỉ cho phép khi dùng ứng dụng`; **TẮT công tắc `Sử dụng vị trí chính xác`** (nếu Android có câu xác nhận, đọc và xác nhận chỉ đổi sang **Gần đúng**). **KHÔNG bấm `Không cho phép`, KHÔNG tắt Vị trí toàn hệ thống.** Chụp **Ảnh QUYỀN** của màn hình precise OFF.
4. Chờ **5–15 giây**. Mở lại NaviTaxiMeter bằng biểu tượng nếu Android đóng ứng dụng, hoặc quay lại nếu còn chạy → tab **GPS nền** → **Đọc lại trạng thái**. Chờ 3–5 giây rồi bấm **Đọc lại trạng thái** lần nữa. **Ảnh SAU** gồm `Dịch vụ`, `GPS mới`, `Trạng thái`, `Chủ GPS`, `ACK/heartbeat`. Ghi rõ **Android có hiện splash/app khởi chạy lại không**. **Không bấm Start** ở bước này.
5. **Khôi phục:** Android Cài đặt → NaviTaxiMeter → Quyền ứng dụng → Vị trí → bật `Sử dụng vị trí chính xác` (để `Chỉ cho phép khi dùng ứng dụng`). Quay lại **GPS nền** → **Đọc lại trạng thái**, chụp **Ảnh KHÔI PHỤC trước Start** để phát hiện nếu tự Start. Sau đó **Dừng GPS nền thử** nếu service vẫn đang chạy. Nếu cần Start một phiên mới, phải do người dùng chủ động thực hiện; không bắt buộc trong ca này.

## 4. Đối chiếu PASS / FAIL / NOT TESTED

- **PASS theo bằng chứng UI/video:** sau khi **precise OFF**, `GPS mới: Không` và **không còn** `Trạng thái: trusted_gps` với `GPS mới: Có`; app có thể `stopped`/owner `none`/ACK false do Android restart, **hoặc** service còn active và ACK true **nhưng fresh false** (ACK thuần heartbeat **không** chứng minh GNSS tin cậy). Sau khi bật precise lại, phiên cũ không tự tính cước hoặc tự khôi phục một chuyến.
- **FAIL và dừng thử:** precise OFF đã xác nhận nhưng `GPS mới: Có` **đồng thời** `trusted_gps` vẫn được công bố sau refresh; hoặc app tạo cước/biên nhận; hoặc app tự mở một phiên cước sau thay đổi quyền. Không kéo dài test hay đổi cài đặt thêm nếu thấy FAIL; lưu ảnh và thời điểm.
- **NOT TESTED/CHƯA XÁC MINH:** không thấy công tắc precise, không có trusted_gps ban đầu, không mở lại được app, thông tin quyền sau đổi không rõ, chỉ có ảnh trước mà thiếu ảnh sau, hoặc thiếu dấu hiệu quyền còn `Chỉ cho phép khi dùng ứng dụng`. Việc Android restart process hoặc hết ACK **không tự chứng minh** mọi chuyển đổi trong khoảng 5–15 giây.
- **Chưa kiểm:** chạy với coarse-only từ đầu, sensor spoofing, stale Stop token, kill/reboot/Doze, Android 11–16, pin OEM dài, quãng đường/cước, một SQLite writer production.

## 5. Cách gửi bằng chứng về chat

Gửi **3–4 ảnh đã che**: 1) GPS nền trước, 2) quyền app chính xác OFF nhưng `Chỉ cho phép khi dùng ứng dụng` vẫn ON, 3) GPS nền sau đổi, 4) GPS nền sau khôi phục chính xác (trước Start mới). Nếu tiện, 1 video ngắn thay ảnh cũng được nhưng **không cần**. Ghi `A2-05c | PASS / FAIL / NOT TESTED (tự báo) | Android có đóng/mở lại app không | thời điểm | các dòng GPS mới/Trạng thái/ACK sau thay đổi | firmware nếu biết`.

Che tọa độ, địa chỉ, hành trình/khách, số điện thoại, IMEI, serial, thông báo riêng tư, tài khoản ngân hàng, token/key/keystore. **Chỉ gửi riêng trong chat; không upload raw screenshots/video lên GitHub.** AI sẽ phân loại **AI REVIEWED PHONE EVIDENCE** riêng với CI sau khi xem. Issue #2 vẫn OPEN; không phát hành hoặc thu tiền.
