# Issue #2 — Bằng chứng kiểm thử GPS trên Xiaomi Redmi Note 12 Pro / Android 13

**Ngày kiểm thử:** 2026-11-16, trên ảnh khoảng **13:57–14:00** giờ Việt Nam UTC+7.  
**Ngày nhận ảnh trong chat:** 2026-11-16 (người dùng gửi 7 ảnh).  
**Nguồn bằng chứng:** ảnh chụp màn hình thiết bị do chủ dự án gửi **trong cuộc trò chuyện riêng**, đã đối chiếu bằng quan sát; **không đăng ảnh gốc, vị trí hoặc định danh cá nhân lên GitHub**.  
**Trạng thái:** lần đầu có bằng chứng **physical Android UI**. **Không phải** chứng thực quãng đường GNSS, chạy nền lâu, tiền cước, hay chứng minh toàn bộ Issue #2 đạt.

## 1. Thiết bị, nguồn build và cài đặt quan sát

- **Thiết bị người dùng khai báo:** Xiaomi Redmi Note 12 Pro, **Android 13**. Chưa có ảnh màn hình giới thiệu máy/OS, chưa xác minh phiên bản MIUI/HyperOS; thiết bị và Android version là **user-reported**, không phải được app tự đọc.
- Ảnh hiển thị ứng dụng `navitaximeter`, trang **GPS nền Android**, các tab `Trạng thái · Bảng giá · GPS thử · Phòng thử · GPS nền` và đúng hộp hỏi/nút của source. **Không đọc được APK SHA-256 từ ảnh**. Người dùng đang thực hiện quy trình đã gửi với bản DEBUG từ code `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24` / Actions `43811708123` / artifact `14200424290`; SHA APK **đã xác minh từ ZIP gốc**, **chưa kiểm chứng trực tiếp binary đã cài trong điện thoại**.
- Ảnh cài đặt thể hiện `Chỉ cho phép khi dùng ứng dụng`, **Sử dụng vị trí chính xác: bật**; `Hiển thị thông báo: bật`, `Thông báo nổi: bật`, `Thông báo cố định: bật`; pin ứng dụng ở **Tiết kiệm pin (kiến nghị)**, không phải `Không hạn chế` (đã chụp). Thông tin battery 100% trên ảnh. Không có bằng chứng thử trong Doze/kill/lock trước khi gắn nhãn.
- Ảnh hộp xác nhận đúng: `Bật dịch vụ GPS an toàn?` → `Bật dịch vụ thử`.

## 2. Kết quả quan sát từng ca

| Mã | Kết quả đối chiếu | Quan sát thực tế và giới hạn |
| --- | --- | --- |
| **A2-01 START/ACK** | **PASS (bằng chứng UI trên thiết bị thật)** | Ảnh khoảng 13:58: `Dịch vụ: Đang chạy`; `GPS mới: Có`; `Trạng thái: trusted_gps`; `Chủ GPS: native_safety`; `ACK/heartbeat: Đã xác nhận`; `Số mẫu GPS chấp nhận: 7` rồi `9`; `Tuổi mẫu GPS: 2842 ms` rồi `2835 ms`. Không có nội dung tính cước trên màn. Đây là **trạng thái tin cậy do phần mềm hiện hành công bố**, chưa xác minh anten/GNSS vật lý độc lập. |
| **A2-02 owner exclusivity với Preview** | **NOT TESTED** | Chưa thấy ảnh/quan sát thử tab `GPS thử` khi `native_safety` còn giữ owner. |
| **A2-03 STOP qua UI** | **PASS (bằng chứng trạng thái sau dừng)** | Ảnh khoảng 14:00: `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Trạng thái: stopped`, `Chủ GPS: none`, `ACK/heartbeat: Chưa xác nhận`. Bộ đếm `Số mẫu GPS chấp nhận: 30` là bộ đếm lịch sử, không được nhầm là service còn chạy. |
| **A2-03 STOP từ thông báo Android** | **NOT TESTED** | Quyền thông báo được bật nhưng chưa có ảnh bấm `Dừng GPS an toàn` trong notification. |
| **A2-04 Home/khóa màn 30–60 giây** | **NOT TESTED** | Chưa có bằng chứng sau thao tác Home/lock. |
| **A2-05 tắt GPS/thu hồi quyền** | **NOT TESTED** | Chưa có bằng chứng khi revoke permission/provider. |
| **A2-06 phòng thử SQLite** | **NOT TESTED** | Không yêu cầu khi thiếu điều kiện; không được xóa checkpoint hay tạo demo tariff. |

**Không có lỗi rõ ràng trong các ảnh đã đối chiếu.** Không suy diễn kết quả rộng hơn những gì ảnh cho thấy.

## 3. Bước tiếp theo có thể thực hiện ngay trên điện thoại

**A2-02**: khi dừng như ảnh 14:00, vào **GPS nền** → **Bật GPS nền thử** → hộp thoại **Bật dịch vụ thử** → **Đọc lại trạng thái** và xác nhận `native_safety` + `Đã xác nhận`. Trong khi native còn chạy, chuyển **GPS thử** → bấm **Bắt đầu xem GPS**, chụp thông báo lỗi/state **đã che tọa độ**. Mong đợi `GPS_BUSY`/owner bận, không mở hai stream. Quay lại **GPS nền** → **Đọc lại trạng thái**, chụp owner/ACK → **Dừng GPS nền thử**. Nếu native bị dừng khi chuyển tab thì NOT TESTED cho phần tranh chấp, không ghi PASS. Nếu song song hoặc crash thì FAIL và dừng.

Sau A2-02, kiểm **A2-03 Stop bằng notification**, **A2-04 Home/khóa màn**, **A2-05 revoke**, giữ nguyên battery preset ở lượt đầu. Ảnh/log gửi trong chat đã che PII, không đăng công khai.

## 4. Cảnh báo và giới hạn

- **Issue #2 vẫn OPEN**, mới đạt hai tiêu chí con. Chưa đạt Android 11–16/OEM matrix, real route calibration, permission revocation, Doze, force-stop, reboot và background longevity.
- **Issue #3 production GNSS owner + one durable SQLite writer** vẫn NOT IMPLEMENTED. Không mở tính cước khách, SQLite migration, ký/phát hành thương mại, Google Billing hoặc paid APIs.
- Giữ nhánh `feature/navitaximeter-foundation`, PR #1 Draft. Không viết main/TTX, không xóa SQLite v3 / prefs.
- Nguồn kịch bản: `docs/ISSUE_2_XIAOMI_REDMI_NOTE_12_PRO_ANDROID13_RUNBOOK_2026-11-16.md`; quy tắc điện thoại và bảo mật ở `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md` Phụ lục A.
