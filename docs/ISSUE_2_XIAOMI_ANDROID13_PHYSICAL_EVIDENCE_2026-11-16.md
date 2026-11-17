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

## 2C. A2-04: màn hình trước/sau Home/khóa máy (15:17–15:19)

**Người dùng gửi ba ảnh chụp thiết bị trong cuộc trò chuyện riêng ngày 16/11/2026, sau hướng dẫn thử A2-04 Home → khóa màn 60 giây → mở khóa → đọc lại → Stop.** Không upload ảnh hoặc dữ liệu riêng tư lên GitHub. **Ảnh không thể tự chứng minh thao tác Home/khóa máy kéo dài bao lâu**; điều kiện thao tác dựa vào việc người dùng thực hiện quy trình đã yêu cầu.

- **Trước (15:17):** `Dịch vụ: Đang chạy`, `GPS mới: Có`, `Trạng thái: trusted_gps`, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`, `Số mẫu GPS chấp nhận: 1`, `Tuổi mẫu GPS: 2942 ms`.
- **Sau (15:19):** `Dịch vụ: Đang chạy`, `GPS mới: Có`, `Trạng thái: trusted_gps`, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`, `Số mẫu GPS chấp nhận: 33`, `Tuổi mẫu GPS: 3559 ms`.
- **Kết thúc (15:19):** `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Trạng thái: stopped`, `Chủ GPS: none`, `ACK/heartbeat: Chưa xác nhận`, số mẫu tích lũy 36. Đây là counter trước đó; không còn ACK khi dừng.

**A2-04: PASS theo bằng chứng UI trước/sau, với điều kiện người dùng đã Home/khóa màn ít nhất 60 giây như hướng dẫn.** Bằng chứng xác nhận app báo session/ACK hợp lệ khi trở lại và giải phóng owner sau stop; **không chứng minh liên tục ở mỗi thời điểm màn khóa**, không chứng minh vượt Doze lâu, process kill, OEM aggressive battery, hoặc GNSS/cự ly chuẩn thương mại.

**Chưa kiểm thử:** A2-05 thu hồi quyền/tắt vị trí; A2-06 optional Lab; rapid Stop, stale notification, kill/reboot/Doze, calibrate quãng đường. Issue #2 vẫn OPEN; không mở thu cước thật.

## 2D. A2-05: video tắt rồi bật Vị trí Android (16:55–16:56, ngày 16/11/2026)

**Bằng chứng:** video MOV khoảng **56,54 giây** do chủ dự án gửi trong chat, đã xem diễn tiến hình ảnh. **Không đưa video, frame hay vị trí vào GitHub**; chỉ ghi trạng thái chẩn đoán cần thiết. Thiết bị do chủ dự án khai báo là Xiaomi Redmi Note 12 Pro/Android 13. Video không chứng minh SHA binary thực sự đã cài.

| Mốc tương đối | Quan sát từ video |
| --- | --- |
| 0 giây | Dịch vụ chưa chạy: `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Chủ GPS: none`, `ACK: Chưa xác nhận`. |
| Khoảng 9 giây | Sau bật dịch vụ thủ công, `Dịch vụ: Đang chạy`, `GPS mới: Có`, `Trạng thái: trusted_gps`, `Chủ GPS: native_safety`, `ACK: Đã xác nhận`, acceptedCount 2, tuổi fix 1615ms. |
| Khoảng 14–17 giây | Người dùng mở Quick Settings Xiaomi và **tắt công tắc Vị trí**, Android hiện `Truy cập vị trí đã tắt`. |
| Khoảng 28 giây | Quay về GPS nền: `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Trạng thái: stopped`, `Chủ GPS: none`, `ACK: Chưa xác nhận`, acceptedCount lịch sử 3. |
| Khoảng 39 giây | Android hiện `Truy cập vị trí đã bật`. |
| Khoảng 46–48 giây | Khi Vị trí đã được bật lại, dịch vụ **vẫn dừng**, `owner none`, ACK chưa xác nhận, không tự phục hồi phiên cũ trong cửa sổ quan sát ngắn. |
| Khoảng 49–50 giây | Có **hành động khởi động mới thủ công**, hộp thoại `Bật dịch vụ GPS an toàn?` và nút `Bật dịch vụ thử`; sau xác nhận, service `Đang chạy`, `native_safety`, ACK đã xác nhận nhưng **`GPS mới: Không`, `Trạng thái: acquiring`, acceptedCount 0**. ACK service không được hiểu là GNSS tin cậy. |
| Khoảng 55 giây | Dịch vụ trở lại `Đã dừng`, `GPS mới: Không`, `Trạng thái: stopped`, owner none và ACK chưa xác nhận; acceptedCount 1 là lịch sử của phiên mới. |

**ĐÁNH GIÁ A2-05 (nhánh tắt Vị trí hệ thống): PASS theo video.** Việc tắt provider làm ứng dụng ngừng service/thu hồi owner và ACK, không dùng trạng thái `trusted_gps` cũ để công bố GPS mới. Khi bật Vị trí trở lại, trong khoảng đã quan sát không tự khởi động phiên cũ. Người dùng có thể bật lại dịch vụ bằng thao tác chủ động; service ACK trong `acquiring` không bị nhầm với fix trusted.

**VẪN NOT TESTED:** thu hồi quyền Vị trí của ứng dụng trong Android Settings (khác với tắt provider hệ thống); giảm xuống approximate; tắt thông báo, process kill/force-stop, reboot, Doze dài, stale PendingIntent token, nhảy đồng hồ, Lab SQLite fault và cấu hình OEM khác. Không kết luận an toàn commercial từ video ~57 giây. **Issue #2 vẫn OPEN.**

## 2E. A2-05b: video thu hồi quyền Vị trí riêng của ứng dụng (~21:38–21:39, 16/11/2026)

**Bằng chứng mới:** video MOV khoảng **51,9269 giây** do chủ dự án tải riêng vào chat, gửi khoảng 21:43 giờ Việt Nam (Android trên video hiển thị khoảng 21:38–21:39). Đã **AI REVIEWED PHONE VIDEO** bằng xem khung hình theo mốc; không upload video, ảnh trích, tọa độ, thông báo hoặc dữ liệu cá nhân lên GitHub. Thiết bị theo khai báo trước: Xiaomi Redmi Note 12 Pro / Android 13, firmware MIUI/HyperOS **chưa xác minh**. SHA của APK **đang cài** vẫn **UNVERIFIED**.

| Mốc trong video | Bằng chứng quan sát |
| --- | --- |
| 0–3s | Ứng dụng khởi động ở tab GPS nền; trước Start báo service stopped, owner none, ACK false. |
| ~4–9s | Chủ dự án bấm **Bật GPS nền thử** → dialog **Bật dịch vụ thử**. ~7s active/owner `native_safety`/ACK true, acquiring, chưa fresh; ~9s `GPS mới: Có`, `trusted_gps`, acceptedCount 1, GPS age khoảng 464ms. Chỉ chẩn đoán, không tính cước. |
| ~12–20s | Rời app, vào **Thông tin ứng dụng → Quyền ứng dụng → Vị trí** của chính NaviTaxiMeter; trước đổi quyền đang **Chỉ cho phép khi dùng ứng dụng**, vị trí chính xác bật; sau đó chọn **Không cho phép**, thấy lựa chọn đã được chọn. **Không phải tắt Vị trí toàn hệ thống**. |
| ~22–28s | Mở lại app bằng biểu tượng, màn splash xuất hiện (~26s). ~28s tab GPS nền báo `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Trạng thái: stopped`, `Chủ GPS: none`, `ACK/heartbeat: Chưa xác nhận`, acceptedCount 0. Có dấu hiệu app được khởi chạy lại; **không thể khẳng định chắc chắn nguyên nhân/đúng thời điểm process kill** nếu không có log OS. |
| ~38–42s | Vào quyền Vị trí app, khôi phục **Chỉ cho phép khi dùng ứng dụng**, **Sử dụng vị trí chính xác** bật. |
| ~45–46s | Khi quay lại tab GPS nền, trước khi bấm Start, vẫn `Đã dừng`, fresh false, owner none, ACK false: **không quan sát thấy tự khởi động lại**. |
| ~48–51s | Chủ dự án **tự bấm** `Bật GPS nền thử` và xác nhận ở dialog. ~50s service active/owner `native_safety`/ACK true, trusted_gps/fresh true, acceptedCount 1, GPS age khoảng 232ms. Đây là **phiên do người dùng chủ động bật**, không phải tự nối lại. Video kết thúc khi service đang active; chưa có clip Stop cuối. |

**ĐÁNH GIÁ: A2-05b runtime app location permission revoke = PASS theo video, giới hạn trong trạng thái UI quan sát được.** Sau khi quyền `Không cho phép` được chọn, video ghi nhận trạng thái dừng, không GPS fresh và không ACK/owner cũ khi mở lại. Sau khi được cấp quyền, trước hành động thủ công không tự Start. Bằng chứng không chứng minh tức thời mọi microsecond khi Android đóng tiến trình, không chứng minh notification/OS-level location FGS state độc lập hoặc race/stale token, không thay thế Android 11–16 OEM matrix. Việc video kết thúc khi service active cần nhắc chủ dự án **Dừng GPS nền thử** nếu còn chạy; không bắt lặp A2-05b.

**Sau video:** A2-01/02/03 PASS UI; A2-04 Home/lock PASS có điều kiện; A2-05a provider OFF PASS video; **A2-05b app permission revoked PASS video**; A2-06 Lab SQLite NOT TESTED; approximate-only permission, stale notification, process kill/reboot/Doze, pin OEM dài, Android 11–16, fare calibration **NOT TESTED**. Issue #2 vẫn OPEN, Issue #3 production single owner + durable app SQLite writer vẫn NOT IMPLEMENTED. Chỉ thử khi xe dừng, không tính cước khách.

## 2F. A2-05c: video chuyển precise ON → approximate-only (~22:32–22:33, 16/11/2026)

**Nguồn bằng chứng riêng:** video MOV thời lượng **56,4494 giây**, user gửi trong chat khoảng **22:58 giờ Việt Nam ngày 16/11/2026**. Đã AI REVIEWED trực tiếp bằng các khung hình từ video, không upload file MOV/ảnh trích/GPS tọa độ/thông báo/PII lên GitHub. Máy theo khai báo trước **Xiaomi Redmi Note 12 Pro, Android 13**, firmware MIUI/HyperOS và SHA-256 binary APK thực cài **UNVERIFIED**. Màn hình trong video khoảng **22:32–22:33**.

| Mốc video | Quan sát đã xác minh bằng hình ảnh |
| --- | --- |
| 0–2 s | Tab **GPS nền** trước Start: stopped, `GPS mới: Không`, owner none, ACK false; chủ dự án bấm `Bật GPS nền thử` → dialog `Bật dịch vụ GPS an toàn?` → `Bật dịch vụ thử`. |
| Khoảng 3–6 s | Native service **Đang chạy**, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`, nhưng `GPS mới: Không`, `Trạng thái: acquiring`, acceptedCount 0. **CHƯA quan sát `trusted_gps` / fresh GNSS trước lúc đổi quyền.** |
| Khoảng 13–20 s | Android `Thông tin ứng dụng → Quyền ứng dụng → Vị trí`: giữ `Chỉ cho phép khi dùng ứng dụng`; công tắc `Sử dụng vị trí chính xác` từ **ON** sang **OFF**; toàn hệ thống không có thao tác tắt Vị trí trong đoạn này. Đây là approximate-only, không phải `Không cho phép`. |
| Khoảng 22–27 s | Khi mở lại NaviTaxiMeter bằng icon có màn splash rồi tab GPS nền báo **Đã dừng**, `GPS mới: Không`, `Trạng thái: stopped`, owner none, ACK false. Đây là trạng thái sau mở lại, **không có bằng chứng trạng thái liên tục của service trong quá trình hệ điều hành áp quyền**. |
| Khoảng 28–33 s | Trở lại trang `Quyền Vị trí` và bật lại `Sử dụng vị trí chính xác` → ON; quyền dùng ứng dụng vẫn được chọn. |
| Khoảng 34–42 s | Trở lại ứng dụng, trước khi bấm Start: vẫn **stopped / fresh false / owner none / ACK false**. Không thấy tự khởi động dịch vụ từ phiên cũ. |
| Khoảng 43–56 s | Chủ dự án **chủ động bấm Start** và xác nhận dialog, native service mới hoạt động; trong khung hình cuối `acquiring`, `GPS mới: Không`, owner native_safety, ACK true, acceptedCount 0. **Không có `trusted_gps` rõ trong phần cuối**, video kết thúc khi service còn active nên cần dừng nếu vẫn chạy. |

**ĐÁNH GIÁ A2-05c: PARTIAL PASS (PASS các quan sát fail-closed sau downgrade/không tự hồi), CHƯA XÁC MINH ĐỦ toàn ca.** Video xác nhận precise OFF trong quyền app; sau mở lại không có GPS fresh/ACK của phiên cũ, khôi phục precise không tự Start. Nhưng điều kiện đầu của runbook yêu cầu **service active + GPS mới Có + trusted_gps trước downgrade** không đạt vì trước đổi đang `acquiring`. Do đó chưa chứng minh thiết bị xử lý **chuyển trực tiếp từ trusted_gps sang untrusted_gps** khi chỉ còn coarse permission hoặc xử lý stale fix nếu process vẫn sống. Android có vẻ mở lại tiến trình (splash) nhưng không có log OS để khẳng định chính xác cơ chế terminate/restart. Không suy diễn lỗi, cũng không nhận FULL PASS.

**Ma trận sau video:** A2-01/A2-02/A2-03 PASS UI; A2-04 Home/lock PASS có điều kiện; A2-05a provider OFF PASS video; A2-05b revoke app permission hoàn toàn PASS video (giới hạn UI); **A2-05c partial PASS / chưa đủ xác minh transition; A2-06 Lab/SQLite NOT TESTED**. Stale notification, process kill/Doze/reboot, nhiều Android 11–16, quãng đường tính cước production và session SQLite writer chưa có chứng cứ. Issue #2 giữ **OPEN**, Issue #3 production one GNSS owner + one durable app SQLite writer **NOT IMPLEMENTED**.

**Bước tiếp nếu muốn xác minh A2-05c đầy đủ:** không bắt lặp các ca đã PASS. Riêng A2-05c chỉ kiểm thêm khi `GPS mới: Có` và `trusted_gps` đã hiện trước khi tắt precise; nếu không có fresh trước thì dừng và ghi NOT VERIFIED, tránh kéo dài thử ngoài an toàn. Phải chụp quyền precise OFF và trạng thái trong app; nếu Android đóng tiến trình thì chỉ báo PASS phần fail-closed sau reopen, không nhận thử runtime continuous transition. Không thử khi lái/chở khách, ảnh/video chat đã che PII.

## 2G. A2-05c bổ sung: video trusted_gps trước khi chuyển sang approximate-only (17/11/2026)

**Bằng chứng riêng trong chat:** video ghi màn hình dài **54,6025 giây**, do chủ dự án gửi khoảng **06:46 giờ Việt Nam ngày 17/11/2026** (đồng hồ trong video **06:44–06:45**). AI trực tiếp đọc các khung 0–53s của video; **không** upload raw video, ảnh cắt màn hình, GPS/tọa độ, thông báo cá nhân, tên file nguồn hoặc định danh lên GitHub. Thiết bị theo khai báo trước: Xiaomi Redmi Note 12 Pro / Android 13; firmware MIUI/HyperOS và SHA binary APK cài **UNVERIFIED**.

| Mốc video | Quan sát thực tế |
| --- | --- |
| 0–3s | Tab `GPS nền`: trước Start `stopped`, owner `none`, ACK false; người dùng chủ động bật GPS nền thử. Tại ~3s service `Đang chạy`, owner `native_safety`, ACK true nhưng đang `acquiring` (chưa fresh). |
| ~6–9s | **Điều kiện còn thiếu ở video cũ nay đã có:** `GPS mới: Có`, `Trạng thái: trusted_gps`, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`, `Số mẫu GPS chấp nhận: 1`, tuổi mẫu ~2473ms tại ~9s. Đó là trạng thái phần mềm công bố, **không phải đo GNSS độc lập**. |
| ~11–13s | Mở `Quyền Vị trí` riêng của `navitaximeter`, vẫn chọn `Chỉ cho phép khi dùng ứng dụng`; `Sử dụng vị trí chính xác` ON tại ~11s, gạt **OFF khoảng 12s** và thấy công tắc OFF trong trang quyền. Không bấm `Không cho phép`, không thấy tắt Vị trí toàn hệ thống. |
| ~14–21s | Có màn trắng/splash khi ứng dụng mở lại. Tại ~21s tab GPS nền: `Dịch vụ: Đã dừng`, `GPS mới: Không`, `state: stopped`, owner `none`, ACK false, acceptedCount 0. Điều này chứng minh **trạng thái sau reopen**, không chứng minh sự kiện/giây process bị Android kill nếu thiếu OS log. |
| ~24–30s | Khi **vẫn còn approximate-only**, người dùng bấm `Bật GPS nền thử` → dialog `Bật dịch vụ thử` và bật mới thủ công. Service chạy `native_safety`, `ACK: Đã xác nhận`, nhưng `GPS mới: Không`, `Trạng thái: acquiring`, acceptedCount 0. ACK chỉ là **dịch vụ sống**, không phải trusted GNSS. |
| ~39–42s | Trang `Quyền Vị trí` một lần nữa xác nhận `Chỉ cho phép khi dùng ứng dụng` và **Sử dụng vị trí chính xác: OFF**. |
| ~48–51s | Trở lại GPS nền, service **vẫn Đang chạy**, owner `native_safety` và ACK true, **nhưng `GPS mới: Không`**, `acquiring`, acceptedCount 0, dù precise OFF. Đây là chứng cứ thực tế về phân biệt ACK và GNSS trust ở coarse-only trong phạm vi video. |
| ~53s | Tab GPS nền hiển thị `Dịch vụ: Đã dừng`, owner none, ACK false và fresh false. **Không quan sát thấy bước khôi phục precise ON** trong video này. |

**ĐÁNH GIÁ A2-05c (cập nhật sau video thứ hai): PASS THEO VIDEO đối với hai hành vi an toàn có thể quan sát**: (1) phiên đã có `trusted_gps` trước downgrade, sau đổi precise OFF và reopen không còn công bố trusted/ACK cũ; (2) khởi động mới bằng quyền gần đúng có thể được ACK nhưng **không được coi là trusted_gps/fresh**. Điều kiện pre-trusted trước đổi, vốn thiếu trong video 16/11, **nay đã được đáp ứng**. Không cần bắt người dùng lặp lại hai hành vi đã PASS trên máy.

**Giới hạn chưa được kiểm chứng:** không chứng minh in-process permission transition liên tục khi Android không restart, exact teardown ở từng thời điểm, OEM khác/Android 11–16, anti-spoofing, cự ly/cước, process-kill nguyên nhân hoặc APK SHA installed. Bước **khôi phục vị trí chính xác** theo runbook không xuất hiện trong video này; nếu cần dùng GPS chính xác ở lần sau, chủ dự án phải kiểm tra bật lại trong Settings. **Không tuyên bố A2-05c đạt mọi nhánh stress hoặc Issue #2 CLOSED.**

**Trạng thái tổng:** A2-01/A2-02/A2-03 PASS theo ảnh; A2-04 PASS có điều kiện; A2-05a provider OFF PASS video; A2-05b revoke hoàn toàn PASS video; **A2-05c core observed safety PASS video (giới hạn)**; A2-06 SQLite Lab, stale notification, Doze/kill/reboot, OEM/Android 11–16 **NOT TESTED**. Issue #2 OPEN; Issue #3 TripLocationService production và one durable SQLite writer NOT IMPLEMENTED. Không dùng app để thu cước khách.

## 2H. A2-07A: video Stop nhanh SAU ACK, giải phóng owner cho GPS thử (17/11/2026)

**Bằng chứng:** MP4 **29,5506 giây**, user gửi riêng trong chat khoảng **07:09 giờ Việt Nam, 17/11/2026**. Video hiển thị đồng hồ máy khoảng 07:08. AI trực tiếp xem các khung 0–29 giây, bao gồm bước Stop và Preview; **không upload video, frame, tọa độ/vĩ độ/kinh độ được hiện trong `GPS thử`, thông báo hoặc PII lên GitHub**. Máy theo khai báo trước: Xiaomi Redmi Note 12 Pro, Android 13; MIUI/HyperOS firmware và SHA APK cài **UNVERIFIED**.

| Thời gian video | Bằng chứng đã thấy |
| --- | --- |
| 0–2s | Tab `GPS nền` ban đầu `Dịch vụ: Đã dừng`, `GPS mới: Không`, owner `none`, ACK chưa xác nhận; user bấm **Bật GPS nền thử → Bật dịch vụ thử**. |
| ~3–4,6s | Dịch vụ **Đang chạy**, owner `native_safety`, `ACK/heartbeat: Đã xác nhận`, state `acquiring`, fresh false/acceptedCount 0; xác nhận START/ACK chỉ là chẩn đoán, không đòi trusted fix cho ca Quick Stop. |
| ~5–6s | User **chủ động bấm Dừng GPS nền thử** ngay sau ACK; màn thể hiện `Đã gửi lệnh dừng có xác nhận token`. Service chuyển `stopped`, owner `none`, ACK chưa xác nhận và `GPS mới: Không`. |
| ~8–14s | Vẫn trên tab GPS nền, bấm **Đọc lại trạng thái**; các lần đọc tiếp vẫn `stopped / fresh false / owner none / ACK false`. Không thấy old ACK bật lại. |
| ~15–16s | Sang tab **GPS thử**, ban đầu `Chưa bật theo dõi`, user bấm **Bắt đầu xem GPS**. |
| ~17–21s | Preview `Đang tìm vị trí chính xác` rồi `GPS đang cập nhật - chỉ xem thử`, có mẫu GPS thực (trong video nhìn thấy tọa độ và accuracy nhưng **cố ý KHÔNG CHÉP** vào repo). Không quan sát `GPS_BUSY` cản Preview sau Stop native. Chưa chứng minh OS không có overlap FGS bằng log OS; chỉ theo app UI. |
| ~22–23s | User bấm **Dừng GPS thử**, app hiển thị `Đã dừng xem GPS`. |
| ~24–28s | Trở lại tab GPS nền và bấm **Đọc lại trạng thái**; service vẫn `stopped`, owner `none`, ACK false, fresh false. Không có tự restart trong phạm vi video. |

**ĐÁNH GIÁ: A2-07A PASS THEO VIDEO/UI trong phạm vi Stop nhanh SAU ACK**: lease native được nhả trong UI; ACK/fresh không còn, Preview sau đó có thể lấy GPS và dừng, GPS nền không tự bật lại. Không có khoản tiền hoặc biên nhận nào được tạo/quan sát. Do video không thể xác thực Android OS location FGS ở từng mili giây, đây **không phải** chứng nhận race-free tuyệt đối, độ chính xác cước hoặc production.

**Hai cổng vẫn NOT TESTED / CHƯA THỂ THỬ BẰNG UI:**
1. **Stop trước first ACK**: Flutter `SafetyServicePage._busy` vô hiệu hóa nút Dừng cho tới khi Start/ACK flow kết thúc. Video chỉ thấy Stop SAU ACK; không biến thành PASS pending-START race.
2. **Replay notification Stop của PHIÊN CŨ**: `PendingIntent` gắn token và Android thay thông báo hiện hành; giao diện không có nút phát lại token cũ. A2-03 notification Stop thông thường trước đây PASS nhưng khác hoàn toàn stale-token test. Cần debug-only instrumented/harness có kiểm soát trước khi thử thật.

**Ma trận sau cập nhật:** A2-01/02/03 PASS UI, A2-04 PASS có điều kiện, A2-05a system provider OFF PASS video, A2-05b app permission revoked PASS theo video có giới hạn, A2-05c trusted→approximate core safety PASS video có giới hạn, **A2-07A Quick Stop after ACK PASS video**, A2-06 Lab/SQLite NOT TESTED, pre-ACK Stop và stale notification STOP NOT TESTED, Doze/kill/reboot/OEM Android 11–16 NOT TESTED. Issue #2 vẫn OPEN. Issue #3 single production TripLocationService/one durable app SQLite writer NOT IMPLEMENTED; ZERO PAID API, không thu cước khách.

## 3. Bước tiếp theo có thể thực hiện ngay trên điện thoại

**A2-02**: khi dừng như ảnh 14:00, vào **GPS nền** → **Bật GPS nền thử** → hộp thoại **Bật dịch vụ thử** → **Đọc lại trạng thái** và xác nhận `native_safety` + `Đã xác nhận`. Trong khi native còn chạy, chuyển **GPS thử** → bấm **Bắt đầu xem GPS**, chụp thông báo lỗi/state **đã che tọa độ**. Mong đợi `GPS_BUSY`/owner bận, không mở hai stream. Quay lại **GPS nền** → **Đọc lại trạng thái**, chụp owner/ACK → **Dừng GPS nền thử**. Nếu native bị dừng khi chuyển tab thì NOT TESTED cho phần tranh chấp, không ghi PASS. Nếu song song hoặc crash thì FAIL và dừng.

Sau A2-02, kiểm **A2-03 Stop bằng notification**, **A2-04 Home/khóa màn**, **A2-05 revoke**, giữ nguyên battery preset ở lượt đầu. Ảnh/log gửi trong chat đã che PII, không đăng công khai.

## 4. Cảnh báo và giới hạn

- **Issue #2 vẫn OPEN**, mới đạt hai tiêu chí con. Chưa đạt Android 11–16/OEM matrix, real route calibration, permission revocation, Doze, force-stop, reboot và background longevity.
- **Issue #3 production GNSS owner + one durable SQLite writer** vẫn NOT IMPLEMENTED. Không mở tính cước khách, SQLite migration, ký/phát hành thương mại, Google Billing hoặc paid APIs.
- Giữ nhánh `feature/navitaximeter-foundation`, PR #1 Draft. Không viết main/TTX, không xóa SQLite v3 / prefs.
- Nguồn kịch bản: `docs/ISSUE_2_XIAOMI_REDMI_NOTE_12_PRO_ANDROID13_RUNBOOK_2026-11-16.md`; quy tắc điện thoại và bảo mật ở `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md` Phụ lục A.
