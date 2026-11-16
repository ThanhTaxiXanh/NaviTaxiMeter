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

## 2A. Bổ sung bằng chứng vòng hai: A2-02 và A2-03 notification (14:30–14:32)

**7 ảnh bổ sung người dùng gửi trong chat riêng, không tải ảnh gốc lên GitHub.** Đây vẫn là Xiaomi Redmi Note 12 Pro/Android 13 do người dùng cung cấp; không có log hệ điều hành hoặc mã hash APK đã cài.

- **A2-01 lặp lại, PASS trạng thái phần mềm/ACK:** khoảng 14:30 `Dịch vụ: Đang chạy`, `GPS mới: Có`, `Chủ GPS: native_safety`, `Trạng thái: trusted_gps`, `ACK/heartbeat: Đã xác nhận`, acceptedCount **8**, tuổi fix **3729 ms**; 14:31 acceptedCount **23**, tuổi fix **3510 ms**. Không thấy thu cước.
- **A2-02 tranh chấp GPS preview, CHƯA ĐỦ BẰNG CHỨNG / INCONCLUSIVE:** ảnh ở tab `GPS thử` hiện `Đã dừng xem GPS` và ảnh khác `Chưa bật theo dõi`, không có thông báo `GPS_BUSY` hiển thị. Trở lại tab GPS nền thấy `native_safety` vẫn active và ACK true. Không thấy hai owner hoạt động cùng lúc, nhưng màn hình **không xác minh được lý do Preview dừng**. Đối chiếu source Flutter `lib/src/ui/gps_preview_page.dart` tại trước sửa: catch bắt lỗi `LocationOwnerLease.acquire` rồi đặt `_state = '$e'`, nhưng `await _stop()` sau đó ghi đè `_state='Đã dừng xem GPS'`. Native `android_native/MainActivity.kt` thực sự trả `GPS_BUSY` nếu `LocationOwnerRegistry.claim(owner)` từ chối. Do **điểm mù UI có thật**, KHÔNG ghi A2-02 PASS chỉ dựa ảnh.
- **A2-03 notification STOP, PASS theo diễn tiến UI:** ảnh 14:31 cho thấy thông báo foreground `NaviTaxiMeter · Theo dõi an toàn` với nút `DỪNG GPS AN TOÀN`; ảnh 14:32 không còn thông báo Navi và tab GPS nền hiện `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Chủ GPS: none`, `Trạng thái: stopped`, `ACK/heartbeat: Chưa xác nhận`, acceptedCount tích lũy **34**. Kết luận **PASS về hành vi UI được quan sát**, không phải log chứng minh token chống notification cũ hay Android process lifecycle.
- **A2-04 Home/khóa màn**, **A2-05 revoke**, **A2-06 Lab** vẫn NOT TESTED.

**Sửa lỗi điểm mù từ chính bằng chứng Xiaomi:** commit `8864154eba60afdf8ee4a36795298d4aa2dceb28` sửa thứ tự thông báo lỗi sau cleanup, commit `ca93b99f0443a84773833d161b951317400c7676` thêm 3 test phân biệt GPS_BUSY, cleanup chờ và lỗi cleanup. **Chưa suy diễn CI PASS** cho code mới nếu GitHub Actions chưa hoàn tất; cần lấy **APK DEBUG mới từ run thành công đúng SHA**, xác minh ZIP/APK SHA rồi yêu cầu retest A2-02 để nhìn rõ `GPS_BUSY`. Không dùng ảnh từ APK cũ để chứng minh UI mới.

## 2B. Bổ sung vòng ba: A2-02 đã đối chiếu PASS, giải phóng và mở Preview tuần tự (15:07–15:09)

**Người dùng gửi 3 ảnh chụp điện thoại trong chat riêng.** Một ảnh chứa tọa độ chi tiết; **KHÔNG đăng lại ảnh, tọa độ, địa chỉ hoặc định vị lên GitHub**. Thông tin bên dưới chỉ giữ trạng thái kỹ thuật không định danh.

- **A2-02 loại trừ chủ GPS khác: PASS theo bằng chứng màn hình Android thật.** Khoảng **15:07**, trang `Kiểm tra GPS thật` cho thấy đúng thông báo sau nút `Bắt đầu xem GPS`: `GPS_BUSY: GPS đang được dùng bởi chế độ khác. Dừng GPS nền thử trước khi bật GPS thử.`. Nút vẫn là `Bắt đầu xem GPS`, không có dòng đang thu vị trí hoặc cước.
- **Stop giải phóng quyền:** ảnh tiếp theo ở trang GPS nền thể hiện `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Trạng thái: stopped`, `Chủ GPS: none`, `ACK/heartbeat: Chưa xác nhận`, **15 mẫu GPS đã chấp nhận trước đó** (counter lịch sử; không chứng minh còn chạy). **PASS** trạng thái đã dừng được quan sát.
- **Preview sau khi giải phóng:** khoảng **15:09**, trang `Kiểm tra GPS thật` hiển thị `GPS đang cập nhật · chỉ xem thử`, nút `Dừng GPS thử`, **độ chính xác được báo 10,3 m**, **tốc độ 0,0 km/h**; **không ghi tọa độ hoặc thời gian chi tiết từ ảnh**. **PASS** Preview có thể nhận dữ liệu khi native owner đã được giải phóng.
- Kết quả này xác minh **đường chuyển quyền qua UI và thông báo từ chối GPS_BUSY trên thiết bị thật** trong kịch bản được chụp, **không chứng minh** không thể xảy ra race ở mọi thời điểm, không chứng minh GPS hardware/cự ly độc lập hoặc background long-running.
- Thông báo `GPS_BUSY` hiển thị trùng với sửa Flutter ở commit `8864154eba60afdf8ee4a36795298d4aa2dceb28`, có import bổ sung để build ở `db4dcab34432c3a1c5a31903e30b0d0ff9b31def`; **không thể đọc SHA APK thật đã cài chỉ từ ảnh**. CI đúng SHA `db4dcab...`: Foundation Flutter Android [run 43826864218](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43826864218) **SUCCESS**, Zero Cost Source Gate [run 43826864300](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43826864300) **SUCCESS**. Native GPS safety DEBUG artifact ID `14206464796` (GitHub SHA256 của ZIP `fc6f2ac2eb1b46a0efb454827a86b61fef22602cf95fbbb43de42ad75c69cc5d`), chưa đối chiếu SHA APK cài trên máy.
- **Cập nhật ma trận:** A2-01 PASS theo ảnh, **A2-02 PASS theo ảnh**, A2-03 UI Stop PASS, A2-03 notification Stop PASS. **A2-04 Home/khóa màn, A2-05 thu hồi quyền, A2-06 Lab đều NOT TESTED.** Issue #2 vẫn OPEN.

**Bước tiếp theo thực tế:** A2-04 60 giây Home/khóa màn trên Xiaomi với cấu hình tiết kiệm pin ban đầu. Thu ảnh GPS nền trước và sau, đánh giá owner, fresh, ACK và xem notification. Dừng dịch vụ bằng nút sau test. Không dùng khách thật, không chia sẻ tọa độ.

## 3. Bước tiếp theo có thể thực hiện ngay trên điện thoại

**A2-02**: khi dừng như ảnh 14:00, vào **GPS nền** → **Bật GPS nền thử** → hộp thoại **Bật dịch vụ thử** → **Đọc lại trạng thái** và xác nhận `native_safety` + `Đã xác nhận`. Trong khi native còn chạy, chuyển **GPS thử** → bấm **Bắt đầu xem GPS**, chụp thông báo lỗi/state **đã che tọa độ**. Mong đợi `GPS_BUSY`/owner bận, không mở hai stream. Quay lại **GPS nền** → **Đọc lại trạng thái**, chụp owner/ACK → **Dừng GPS nền thử**. Nếu native bị dừng khi chuyển tab thì NOT TESTED cho phần tranh chấp, không ghi PASS. Nếu song song hoặc crash thì FAIL và dừng.

Sau A2-02, kiểm **A2-03 Stop bằng notification**, **A2-04 Home/khóa màn**, **A2-05 revoke**, giữ nguyên battery preset ở lượt đầu. Ảnh/log gửi trong chat đã che PII, không đăng công khai.

## 4. Cảnh báo và giới hạn

- **Issue #2 vẫn OPEN**, mới đạt hai tiêu chí con. Chưa đạt Android 11–16/OEM matrix, real route calibration, permission revocation, Doze, force-stop, reboot và background longevity.
- **Issue #3 production GNSS owner + one durable SQLite writer** vẫn NOT IMPLEMENTED. Không mở tính cước khách, SQLite migration, ký/phát hành thương mại, Google Billing hoặc paid APIs.
- Giữ nhánh `feature/navitaximeter-foundation`, PR #1 Draft. Không viết main/TTX, không xóa SQLite v3 / prefs.
- Nguồn kịch bản: `docs/ISSUE_2_XIAOMI_REDMI_NOTE_12_PRO_ANDROID13_RUNBOOK_2026-11-16.md`; quy tắc điện thoại và bảo mật ở `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md` Phụ lục A.
