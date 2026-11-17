# Issue #2 | Bắt đầu kiểm thử GPS trên điện thoại Android thật (DEBUG) | 16/11/2026

**Trạng thái:** PREPARED / CHƯA THỰC HIỆN TEST VẬT LÝ. Mọi ô PASS phải do thiết bị Android thật và bằng chứng người dùng cung cấp, không dựa emulator.

## 0. APK đã xác minh để thử

- Repository: `ThanhTaxiXanh/NaviTaxiMeter`, branch `feature/navitaximeter-foundation`, PR #1 OPEN/DRAFT.
- **Đúng commit đã build APK:** `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24`.
- **Foundation PR run:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43811708123 , **SUCCESS** build-test + Android 14 emulator (emulator KHÔNG thay điện thoại).
- **GitHub artifact:** `navitaximeter-native-gps-safety-DEBUG-only`, ID `14200424290`, ZIP chứa duy nhất `app-debug.apk`. Trong GitHub Actions run, tìm phần **Artifacts** và tải ZIP của artifact này khi đã đăng nhập GitHub; giải nén APK.
- **ZIP SHA-256 kiểm trực tiếp:** `363824f62aa6d02ed50c380a38f452a9fb182b8b2d42af123a529bc0fb623cd5`; đây là SHA của gói ZIP, KHÔNG phải APK.
- **APK SHA-256 sau giải nén, kiểm trực tiếp:** `7ec6a8bbd39252cc27663566f6c280110ab23fb235a54fae71b6d73962dc540e`; kích thước `165929486` bytes. File nguồn là `app-debug.apk`.
- Loại APK: Flutter **DEBUG**, **không phải RELEASE**, không dùng thu cước, không kiểm thử với hành khách, không thay bản đang giữ dữ liệu quan trọng.
- Thử trên **máy Android phụ** được phép cài APK. **iPhone không cài APK Android.** Không có máy Android thì đánh dấu NOT TESTED, không tuyên bố lỗi sản phẩm.
- Không dùng ADB. Nếu thiết bị đang dùng NaviTaxiMeter với dữ liệu thật hoặc cần giữ bản cũ: **dừng**, không gỡ/cài đè hoặc xóa data.
- Khi tải qua GitHub, đừng dùng APK từ link lạ. Nếu Android hỏi cho phép cài từ ứng dụng mở tệp, chỉ bật tạm thời khi nguồn tin cậy và tự tắt lại sau khi cài. Nếu hệ điều hành từ chối: ghi lại hiện tượng, không bỏ qua lớp bảo mật.

## 1. Điều kiện trước khi thử

1. Cài bản APK đúng SHA ở trên, mở ứng dụng; xác nhận tên NaviTaxiMeter và thanh dưới có năm tab **Trạng thái · Bảng giá · GPS thử · Phòng thử · GPS nền**. Nếu khác: **DỪNG / NOT TESTED** và gửi ảnh đã che riêng tư; không đoán vị trí nút.
2. Vào **Cài đặt > Giới thiệu điện thoại** ghi model máy + Android version (không cần serial/IMEI). Ghi ngày, giờ, hãng và mức pin; chỉ dùng môi trường an toàn, không lái xe trong lúc thao tác.
3. Bật Vị trí của Android. Cấp quyền Vị trí cho NaviTaxiMeter và **vị trí chính xác** nếu được Android hỏi; ghi lại quyền hiện có. Thử cả khi thông báo được phép, nhưng nếu không có quyền thông báo phải ghi rõ. Không thay đổi tối ưu hóa pin trước ca đầu tiên.
4. Không bật một ứng dụng GPS/location thử nghiệm khác. Không mở giao diện thu cước hoặc tạo chuyến với hành khách. Chụp ảnh phải che tọa độ/địa chỉ, tên khách, thông báo cá nhân.

## 2. Các ca đầu tiên, đúng nhãn nút trong mã hiện tại

### A2-01 | Start/ACK GPS nền Android (tại chỗ, không chạy xe)

1. Mở tab **GPS nền**, chụp màn hình trạng thái ban đầu.
2. Bấm **Bật GPS nền thử**; trong hộp hỏi **Bật dịch vụ GPS an toàn?**, bấm **Bật dịch vụ thử**.
3. Chờ phản hồi của ứng dụng, sau đó bấm **Đọc lại trạng thái**.
4. Quan sát các dòng **Dịch vụ**, **GPS mới**, **Trạng thái**, **Chủ GPS**, **ACK/heartbeat**, **Số mẫu GPS chấp nhận**. Nếu đứng ngoài trời có tín hiệu thật, có thể đợi thêm để có fix; trong nhà thiếu fix không tự coi FAIL.
5. **PASS** nếu Service báo **Đang chạy**, `Chủ GPS: native_safety`, `ACK/heartbeat: Đã xác nhận`, không hiển thị tính cước; khi đã có GNSS đạt điều kiện thì `GPS mới: Có` và `Trạng thái: trusted_gps`. Nếu chưa có fix thật, ghi PASS riêng phần Start/ACK, phần fresh GNSS **NOT TESTED**.
6. **FAIL** nếu ứng dụng crash, báo ACK đã xác nhận khi Service đã dừng, hoặc có thu cước; ghi đúng dòng trạng thái và DỪNG. Nếu không có nút trên, **NOT TESTED**, chụp màn đã che thông tin.

### A2-02 | Không cho Preview mở GPS chồng native Service

1. Khi A2-01 vẫn đang chạy và `Chủ GPS: native_safety`, chuyển sang tab **GPS thử**.
2. Bấm **Bắt đầu xem GPS**. Chú ý trạng thái lỗi trên màn; không yêu cầu tọa độ công khai.
3. **PASS** nếu Preview bị từ chối lấy GPS do owner bận (`GPS_BUSY` hoặc thông báo tương ứng), không có hai luồng location FGS chạy song song; quay lại tab **GPS nền** và bấm **Đọc lại trạng thái**.
4. **FAIL** nếu hai GPS streams đều báo đang chạy cùng lúc hoặc app crash. DỪNG, ghi mô tả và chụp hai màn đã che vị trí.
5. Nếu đổi tab tự dừng phiên hoặc không có chức năng, ghi **NOT TESTED** phần tương ứng; không coi là PASS giả.

### A2-03 | Stop từ UI và từ thông báo Android

1. Ở tab **GPS nền**, bấm **Dừng GPS nền thử**, rồi **Đọc lại trạng thái**.
2. **PASS** nếu `Dịch vụ: Đã dừng` và `ACK/heartbeat: Chưa xác nhận`, không còn owner active.
3. Bật lại bằng hai nút ở A2-01. Mở bảng thông báo Android, tìm **NaviTaxiMeter · Theo dõi an toàn** và bấm **Dừng GPS an toàn**.
4. Mở lại ứng dụng > tab **GPS nền** > **Đọc lại trạng thái**. PASS nếu Service dừng và không có ACK/heartbeat giả; FAIL nếu vẫn xác nhận owner cũ sau dừng. Nếu Android ẩn thông báo, ghi NOT TESTED cho bước notification.

### A2-04 | Home/khóa màn hình và tỉnh lại

1. Bật **GPS nền** thành công như A2-01. Ghi trạng thái ACK/owner, chụp màn đã che dữ liệu.
2. Bấm Home, khóa màn hình khoảng 30–60 giây; xem Android còn thông báo GPS nền không.
3. Mở khóa, vào NaviTaxiMeter > **GPS nền** > **Đọc lại trạng thái**.
4. **PASS** nếu Service vẫn chạy hợp lệ với ACK/lease cùng phiên, **hoặc** đã dừng/mất điều kiện và ACK không còn được xem là đang xác nhận. Tuyệt đối không tính cước/đo quãng đường bù.
5. **FAIL** nếu ACK giả khi Service chết, tự khởi chạy lại chuyến thu cước hoặc xuất hiện tiền/chuyến khách. Ghi OEM, mức tiết kiệm pin và dấu hiệu quan sát.

### A2-05 | Thu hồi quyền hoặc tắt vị trí Android

1. Khi GPS nền đang hoạt động, mở Cài đặt Android > Ứng dụng > NaviTaxiMeter > Quyền > Vị trí. Ghi quyền ban đầu và chuyển sang **Từ chối**, hoặc tắt công tắc Vị trí hệ thống.
2. Quay lại NaviTaxiMeter > GPS nền, chọn **Đọc lại trạng thái**. Quan sát sau 5–15 giây.
3. **PASS** nếu Service dừng hoặc ACK không còn được xác nhận / `GPS mới: Không`. **FAIL** nếu vẫn công bố GPS tin cậy và ACK hợp lệ dù không có quyền hoặc provider.
4. Khôi phục quyền nếu muốn thử tiếp, nhưng **không coi phục hồi tự động trong một session lỗi là PASS**. Bấm Stop và Start lại theo thao tác chủ động.
5. Nếu thông báo quyền khác vì Android 11/12/13+, ghi đúng lựa chọn thực tế, không đoán; nếu chưa thể thực hiện, ghi NOT TESTED.

### A2-06 | Phòng thử GPS/SQLite: có thể chỉ quan sát, không bắt buộc

1. Tab **Phòng thử** hiện các nút **Bật GPS thử**, **Bắt đầu lưu phiên GPS thử**, **Tiếp tục sau gián đoạn (thủ công)** và **Xóa checkpoint phiên thử** tùy trạng thái.
2. Nếu **chưa có bảng giá xác nhận thật** hoặc có dữ liệu cần bảo vệ, chỉ ghi NOT TESTED; **không tạo bảng giá demo**, không xóa checkpoint có dữ liệu chưa xác định.
3. Chỉ thử thêm khi có phiên kỹ thuật độc lập và đã hiểu xác nhận trên màn; không dùng người/chuyến khách thực. Mọi lỗi lưu SQLite, owner tranh chấp hoặc tạm dừng phải được chụp và dừng.

## 3. Bảng bằng chứng cần gửi lại cho AI

Với mỗi mã ca A2-01...A2-06, gửi ngay **trong chat**, không đăng tọa độ/thông tin riêng tư công khai trên GitHub.

| Mã ca | Kết quả | Ghi quan sát thực tế | Ảnh/video đã che |
| --- | --- | --- | --- |
| A2-01 | NOT TESTED | | |
| A2-02 | NOT TESTED | | |
| A2-03 | NOT TESTED | | |
| A2-04 | NOT TESTED | | |
| A2-05 | NOT TESTED | | |
| A2-06 | NOT TESTED | | |

Ghi kèm: **model/OEM, Android version, ngày/giờ, quyền Vị trí chính xác hay gần đúng, trạng thái thông báo/tiết kiệm pin, build SHA `fff1c65a`, workflow `43811708123`, APK SHA-256 ở mục 0**. Mỗi ảnh che vĩ độ/kinh độ, địa chỉ, số điện thoại, thông báo riêng tư và tài khoản ngân hàng. Nếu FAIL, báo số bước và dấu hiệu; AI phải đối chiếu bằng chứng mới xác nhận.

**Chưa có Android vật lý được thực hiện.** Ma trận mở rộng Issue #2 (Android 11–16/OEM, rapid Stop, stale notification, kill/Doze/reboot, SQLite fault) vẫn cần thử độc lập. Nếu APK mới xuất hiện, kiểm SHA/run khác và không mặc nhiên dùng bộ chứng cứ cũ.

## 4. Điều kiện an toàn

DEBUG APK **không dùng thu cước, phát hành hóa đơn, ký release hoặc chạy chuyến với khách**. Không yêu cầu ADB/PC. Không dùng GPS giả để chứng minh GNSS thật. Không tự động sửa DB/SharedPreferences, không merge main hoặc bật Paid APIs. Chỉ hoàn thành Issue #2 sau đủ bằng chứng vật lý và các follow-up FAIL được ghi nhận.

Quy tắc đầy đủ: `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` mục 9; CI PASS ≠ Android physical PASS.
