# CHU KỲ 8 — LƯỢT 2/7 · XIAOMI A2-05b VIDEO PASS (16/11/2026, UTC+07)

- Sau phản hồi này: **AI_REPLY_COUNT=2/7**. Lượt **7/7** phải tạo bàn giao đầy đủ 3.1–3.10 + Phụ lục A/C. Trong cùng chat không reset.
- Người dùng gửi video MOV **51,93 giây** khoảng 21:43 16/11/2026, ghi thao tác Xiaomi Android 13 thu hồi **quyền Vị trí riêng NaviTaxiMeter**. AI đã xem các mốc 0–51 giây; trạng thái trước revoke active/owner native_safety/trusted_gps/ACK confirmed, trong quyền ứng dụng chọn **Không cho phép**, sau mở lại app stopped/fresh false/owner none/ACK false, sau cấp lại quyền không tự Start. Người dùng **bấm Start thủ công** ở cuối video, lần mới active/ACK/fresh; **cuối video còn active, nên hướng dẫn Stop nếu vẫn chạy**. **A2-05b PASS theo video, giới hạn UI**, chưa chứng minh thời điểm process kill/race/Android OS logs, APK cài chưa được đối chiếu SHA.
- Bằng chứng **chỉ văn bản sanitized** đã được thêm vào `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md` (mục 2E), runbook A2-05b được chú giải; **không upload raw video/frame/GPS/PII lên GitHub**. Các GitHub docs-only commits mới cần đối chiếu đúng HEAD/CI.
- Issue #2 **OPEN**, không yêu cầu lặp A2-05b. A2-06 Lab SQLite, approximate-only, stale Stop token, Doze/kill/reboot, battery/OEM và Android 11–16 còn NOT TESTED; Issue #3 production single GNSS owner + one durable app SQLite writer **NOT IMPLEMENTED**.
- Giữ PR #1 Draft, nhánh feature/navitaximeter-foundation, main/TTX READ-ONLY, ZERO PAID API, SQLite v3/prefs intact, không thu cước; tiếp theo ưu tiên kiểm thử an toàn có hướng dẫn cụ thể, từng ca một khi có nhu cầu và thiết bị.

---

# CHU KỲ 8 — LƯỢT 1/7 · TIẾP QUẢN TỪ CYCLE7 (16/11/2026, UTC+07)

- Cuộc trò chuyện mới đã **reset AI_REPLY_COUNT=0** lúc tiếp quản; sau phản hồi hoàn tất **AI_REPLY_COUNT=1/7**. Lượt AI thứ **7/7 trong chat mới** phải bàn giao độc lập 3.1–3.10 kèm Phụ lục A/C; không reset trong cùng chat.
- Đã đọc handoff Cycle7, AGENTS.md, navi-code-commander, navi-location-background, navi-github-actions, kiểm source `SafetyServicePage`/`LocationSafetyService`, Issue #2/#3 và PR #1.
- Đã xác minh branch HEAD trước ghi `c77a4157a691620e69eeb0f3a6e46d8bdecbb862`: Foundation PR [43846686647](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43846686647) **SUCCESS**, Zero Cost PR [43846686523](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43846686523) **SUCCESS**. Hai job Foundation PASS gồm build/test và Android 14 emulator headless DEBUG; không chứng minh Android Xiaomi/GNSS thực.
- **Tiếp tục Issue #2 đúng điểm dở:** đã tạo `docs/ISSUE_2_XIAOMI_ANDROID13_A2_05B_APP_PERMISSION_RUNBOOK_2026-11-16.md` tại docs-only commit `ba78baf87167dca263c19433a1e698bdbf8a5dc1`, có chi tiết thao tác và PASS/FAIL/NOT TESTED; comment Issue #2 ID `6914567232`. **A2-05b thu hồi quyền ứng dụng vẫn NOT TESTED**; chờ ảnh đã che PII từ Xiaomi Android 13. Không lặp lại provider OFF A2-05 đã PASS video.
- HEAD sau cập nhật state sẽ lại đổi; cần lấy HEAD/CI theo đúng SHA, không lấy CI PASS cũ gán sang HEAD mới. Không sửa source/DB/APK, không thu cước, không add Google Billing/API trả phí, PR #1 Draft, Issue #3 production single GNSS owner + durable writer NOT IMPLEMENTED.
- **Bước kế tiếp:** user chạy A2-05b trên điện thoại khi dừng xe (không khách/không lái), gửi evidence; AI phân loại ca, cập nhật evidence text + Issue #2, mở bug riêng khi có FAIL. Nếu user chưa test, tiếp tục review Issue #3 design mà không giả định production đã tồn tại.

---

# CHU KỲ 7 — BÀN GIAO BẮT BUỘC 7/7 (16/11/2026) · XIAOMI A2-05 VIDEO PASS

- **AI_REPLY_COUNT=7/7 sau phản hồi này**, đã hoàn tất hồ sơ mới **độc lập**: `docs/HANDOFF_2026-11-16_CYCLE7_7-7.md` (mục 3.1–3.10, Phụ lục A quy tắc 9 nguyên văn, Phụ lục B tình trạng điện thoại, Phụ lục C quy tắc 10 nguyên văn), tạo tại commit `3c8c66f3addf87c64344877732816b9aa9e611cb`. Khi chuyển chat mới reset 0; vẫn cùng chat lượt tiếp theo 8 và bàn giao lại ở 14, không reset giữa chu kỳ.
- Chủ dự án gửi **MOV 56.54 giây** trên **Xiaomi Redmi Note 12 Pro Android 13** ở 16:55–16:56 ngày 16/11 (firmware chưa xác nhận). Đã xem, **A2-05 nhánh tắt công tắc Vị trí hệ thống PASS video**: native GPS active/trusted/ACK; user tắt Vị trí → app `stopped`, `GPS mới: Không`, `owner none`, `ACK false`; bật Vị trí trở lại app vẫn stopped trong cửa sổ quan sát; user khởi động dịch vụ **thủ công** mới, `acquiring` với service ACK nhưng chưa có fresh GNSS, cuối video service lại stopped. KHÔNG post raw video/frames/tọa độ lên GitHub.
- **Bằng chứng văn bản đã lược PII:** `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md`, cập nhật commit `6dccc485d0138b176c8ba1150eede6e680e046f7`, kèm issue #2 comment. A2-01 phone UI PASS; A2-02 GPS_BUSY & owner handoff PASS UI; A2-03 Stop UI/notification PASS; A2-04 Home/lock **PASS có điều kiện** vì ảnh trước/sau không tự chứng minh thời lượng khóa màn; A2-05 **system location/provider OFF PASS video**; **A2-05 thu hồi runtime app permission / approximate-only NOT TESTED, A2-06 Lab NOT TESTED**. Doze/kill/reboot/stale Stop/Android OEM matrix NOT TESTED. **Issue #2 vẫn OPEN**.
- Repo chỉ ghi `feature/navitaximeter-foundation`; PR #1 OPEN/DRAFT/không merge, Issue #3 OPEN **TripLocationService production + one app SQLite durable writer NOT IMPLEMENTED**. Không thu cước, không Google Billing/paid APIs, không sửa/migrate app v3/prefs, không force push, main/TTX read-only.
- Latest verified **code SHA** `db4dcab34432c3a1c5a31903e30b0d0ff9b31def` Foundation PR `43826864218` SUCCESS và Zero Cost `43826864300` SUCCESS (GPS_BUSY visible + import fix). Docs SHA `68c0c915482bddd797db4786898261e9e89088cf` Foundation `43830682170` SUCCESS và Zero Cost `43830682148` SUCCESS. **Handoff docs/state commits sau đó đổi HEAD: PHẢI kiểm CI theo exact new HEAD, không suy diễn PASS hiện thời.**
- **Bước tiếp theo trên chat mới:** đọc full handoff và AGENTS/skill rules; xác minh HEAD/CI; không lặp lại ca A2-05 tắt Vị trí đã PASS; nếu chủ dự án còn tiếp tục thử, hướng dẫn riêng **A2-05b thu hồi quyền Vị trí của ứng dụng** (khác việc tắt Quick Settings), lưu privacy-safe evidence. Song song review Issue #3 design, không coi DEBUG probe là real production writer. Không bắt người dùng dùng PC/ADB.

---

# CHU KỲ 7 — LƯỢT 6/7 · XIAOMI A2-04 HOME/LOCK UI EVIDENCE (16/11/2026)

- Sau lượt này **AI_REPLY_COUNT=6/7**. **LƯỢT AI TIẾP THEO LÀ 7/7: PHẢI lập BẢN BÀN GIAO đầy đủ 3.1–3.10 + PHỤ LỤC A quy tắc test điện thoại và cập nhật state; KHÔNG ưu tiên thêm feature trước bàn giao.**
- Chủ dự án gửi 3 ảnh từ Xiaomi Redmi Note 12 Pro, Android 13, trước/sau quy trình A2-04 đã hướng dẫn: 15:17 `native_safety` active, GPS fresh, trusted_gps, ACK confirmed, accepted 1, fix age 2942ms; 15:19 vẫn active/ACK valid, accepted 33, fix age 3559ms; sau Stop 15:19 stopped, owner none, ACK false, lịch sử accepted 36.
- **A2-04 PASS về trạng thái UI trước/sau**, có **điều kiện** người dùng đã bấm Home và khóa màn ≥60 giây theo hướng dẫn. Ảnh không tự chứng minh thao tác/duration hoặc dịch vụ liên tục tại mọi thời điểm khóa. Không chứng minh Doze/kill/reboot, trích xuất/cự ly GNSS độc lập, production.
- Bằng chứng chỉ văn bản bỏ PII ở `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md`, commit `8d2a1d9b92e799076895020ee0f35b5741a86c05`, comment Issue #2. Ảnh riêng tư không upload GitHub.
- Issue #2 hiện: A2-01 Start/ACK physical UI PASS; A2-02 GPS_BUSY/sau release Preview PASS; A2-03 Stop UI + notification PASS; A2-04 PASS theo ảnh trước/sau và điều kiện Home/lock 60 giây; **A2-05 revoke/provider NOT TESTED**, **A2-06 Lab NOT TESTED**, các ca rộng khác chưa test. Issue #2 vẫn OPEN.
- Mốc code SHA `db4dcab34432c3a1c5a31903e30b0d0ff9b31def` Foundation PR run `43826864218` SUCCESS, Zero Cost PR `43826864300` SUCCESS; DEBUG artifact ID `14206464796`. Code fix giữ thông báo GPS_BUSY đã chạy CI. HEAD docs trước lượt này `0176d2fee137fe8556c53e43017ff96b59cca9fc` ZeroCost `43829413107` SUCCESS, Foundation `43829413019` IN PROGRESS lúc đối chiếu; HEAD mới do docs commits cần verify CI theo exact SHA, không nhận PASS cũ thay cho HEAD docs.
- Bước tới sau **bàn giao lượt 7**: kiểm A2-05 trên Xiaomi, hướng dẫn các nút thật, chụp trạng thái before/after khi tắt Vị trí/thu hồi quyền, kỳ vọng fresh false/ACK invalid hoặc service stop, manual Stop/Start khi restore. Không chạm SQLite/thu cước. Đánh giá rủi ro OEM + pin, mở issue riêng nếu thất bại.
- Quy tắc cứng giữ nguyên: chỉ branch `feature/navitaximeter-foundation`, PR #1 OPEN/DRAFT, main/TTX READ-ONLY, không merge/force-push, không xóa/migrate app DB v3 hoặc confirmed tariff prefs, không Paid API/Cloud Billing, không thu cước khách. Issue #3 production single GNSS owner + one durable SQLite writer **NOT IMPLEMENTED**.

---

# CHU KỲ 7 — LƯỢT 5/7 · A2-02 XIAOMI GPS_BUSY PASS (16/11/2026)

- Sau lượt phản hồi này: **AI_REPLY_COUNT=5/7**, bàn giao đầy đủ mục 3.1–3.10 + Phụ lục A bắt buộc ở lượt **7/7**; không reset khi chưa đổi chat.
- User gửi 3 ảnh mới từ Xiaomi Redmi Note 12 Pro, Android 13, khoảng 15:07–15:09. Ảnh đầu `GPS thử` hiển thị chính xác `GPS_BUSY: GPS đang được dùng bởi chế độ khác. Dừng GPS nền thử trước khi bật GPS thử.` khi native đang chiếm owner; lần sau trang `GPS nền` báo `Dịch vụ: Đã dừng`, `GPS mới: Không`, `Chủ GPS: none`, `ACK/heartbeat: Chưa xác nhận` (counter 15 lịch sử); ảnh cuối `GPS thử` báo `GPS đang cập nhật · chỉ xem thử`, accuracy 10.3 m, speed 0.0 km/h; GPS tọa độ chi tiết đã được loại khỏi bản ghi public.
- **PHYSICAL UI PASS:** A2-01 Start/ACK, A2-02 owner exclusivity/GPS_BUSY và sequential reacquire, A2-03 dừng bằng UI và notification. **NOT TESTED:** A2-04 Home/lock, A2-05 quyền vị trí/provider, A2-06 optional Lab; không suy diễn accuracy GNSS độc lập hay invariant dưới race/Doze.
- Bằng chứng đã ghi ở `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md` cập nhật commit `8dad4cdfaf3f94bcc9f4b25f3ee79c96401d8b79` và comment issue #2. Chỉ ghi thông tin kỹ thuật không định danh; không upload screenshot có tọa độ lên GitHub.
- Lượt 4 đã sửa compile failure của `PlatformException` trong `lib/src/ui/gps_preview_page.dart`: commit `db4dcab34432c3a1c5a31903e30b0d0ff9b31def` thêm import `package:flutter/services.dart`. **CI ĐÚNG SHA code PASS:** Foundation PR run `43826864218` SUCCESS gồm Flutter analyze/test và DEBUG APK + Android14 emulator; Zero Cost PR run `43826864300` SUCCESS. Artifact DEBUG ở run `43826864218` ID `14206464796`. Chưa xác minh hash APK cài trên Xiaomi; thông báo GPS_BUSY trên ảnh phù hợp với mã đã sửa. Không dùng CI thay cho physical.
- **Bước tiếp theo:** hướng dẫn A2-04 khóa màn 60 giây: giữ GPS nền active trước Home/lock, chụp trạng thái và notification, mở khóa đọc lại, chụp, dừng từ app; đánh dấu PASS/FAIL/NOT TESTED theo actual ACK+owner; sau đó A2-05 thu hồi quyền/provider. Chỉ khi lỗi thực mới sửa source.
- Dự án tiếp tục giới hạn: PR #1 OPEN/DRAFT, chỉ ghi `feature/navitaximeter-foundation`; Issue #2 OPEN; Issue #3 **one production GNSS owner + durable SQLite writer NOT IMPLEMENTED**; không merge main, không đụng TTX, không chỉnh production SQLite v3, không auto migration, không thu cước, không paid APIs. HEAD đã đổi bởi docs commit, đối chiếu CI đúng SHA nếu cần.

---

# CHU KỲ 7 — LƯỢT 3/7 · XIAOMI A2-02 UI MASKING FIX & A2-03 NOTIFICATION (16/11/2026)

- Bộ đếm của cuộc trò chuyện hiện tại: **AI_REPLY_COUNT=3/7** sau câu trả lời này. Lượt 7/7 bắt buộc bàn giao độc lập mục 3.1–3.10 + Phụ lục A.
- Chủ dự án gửi thêm **7 ảnh** lúc 14:30–14:32 trên Xiaomi Redmi Note 12 Pro, Android 13. Bằng chứng riêng tư không tải public. Nội dung quan sát đã lược riêng tư tại `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md`, bổ sung commit `0155b4705f10b98cc90ab0a355948d1b35a1a32a` và comment Issue #2.
- **A2-01 repeated physical UI PASS:** `native_safety` active, fresh `trusted_gps`, ACK confirmed, acceptedCount 8→23; **A2-03 notification Stop PASS** bằng màn thông báo `DỪNG GPS AN TOÀN` 14:31 và màn stopped/owner none/ACK false 14:32.
- **A2-02 INCONCLUSIVE**: GPS thử hiển thị `Đã dừng xem GPS` hoặc `Chưa bật theo dõi`, không hiện `GPS_BUSY`; GPS nền vẫn active sau đó. Đọc mã `GpsPreviewPage._start` phát hiện catch `_state = '$e'` trước `await _stop()`, khiến cleanup ghi đè lý do bị từ chối. Native `MainActivity.kt` trả GPS_BUSY khi claim owner thất bại. Chưa suy diễn blocker proof.
- **Code fix** `8864154eba60afdf8ee4a36795298d4aa2dceb28` tại `lib/src/ui/gps_preview_page.dart`: preserve GPS_BUSY (và ưu tiên báo lỗi cleanup) sau khi kết thúc cleanup. **Test commit** `ca93b99f0443a84773833d161b951317400c7676`, thêm `test/gps_preview_start_failure_test.dart` 3 ca: async cleanup, non-busy error, cleanup failure. Không đổi engine fare, native GPS owner, SQLite v3, prefs, APIs hay main.
- Zero Cost Source Gate trên docs SHA `0155b470...`: PR run `43825414058` **SUCCESS**; Foundation PR `43825414130` **IN PROGRESS** lúc ghi, chưa tuyên bố CI PASS. Sau commit state này, HEAD/CI lại thay đổi: phải đối chiếu chính xác SHA.
- **Bước tiếp theo:** chờ kết quả GitHub Actions trên đúng code/test SHA hoặc docs-only HEAD mới; chỉ sau Foundation SUCCESS, tải artifact DEBUG đúng run, kiểm ZIP SHA+APK SHA, đưa APK mới cho chủ dự án. Yêu cầu retest A2-02 nhìn rõ `GPS_BUSY`, chụp GPS Preview và GPS nền; tiếp A2-04 Home/lock và A2-05 revoke. Issue #2 OPEN; Issue #3 production GNSS owner + one real durable writer NOT IMPLEMENTED; PR #1 DRAFT; không thu cước.
- Tiếp tục chỉ ghi nhánh `feature/navitaximeter-foundation`, không merge main/TTX, không force push, không bật paid API, không tự migrate DB, không thử tính cước khách.

---

# CHU KỲ 7 — LƯỢT 2/7 · KẾT QUẢ XIAOMI ANDROID 13 THẬT (16/11/2026)

- **AI_REPLY_COUNT = 2/7** sau lượt này. Lượt 7/7 bắt buộc bàn giao đầy đủ 3.1–3.10 + Phụ lục A. Không reset trong cùng chat.
- Chủ dự án gửi **7 ảnh chụp màn hình** từ Redmi Note 12 Pro/Android 13 (model/OS do người dùng xác nhận). Phân tích và lưu **chỉ bản ghi văn bản đã lược dữ liệu riêng tư** vào `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md` tại code-doc commit `214e202855d9076e5dda0fe8e9c59f66a151c9cf`, đồng thời chú giải Issue #2. Không upload ảnh/raw GPS lên GitHub.
- **Physical UI PASS theo ảnh A2-01**: Start native active, owner `native_safety`, ACK true, `GPS mới: Có`, `trusted_gps`, acceptedCount 7→9, tuổi fix 2842/2835ms (13:58). **Physical UI PASS phần A2-03 Stop từ app**: stopped, fresh false, owner none, ACK false (14:00). **A2-03 Stop notification, A2-02, A2-04, A2-05, A2-06 vẫn NOT TESTED**. GNSS trust ở đây là tự công bố bằng phần mềm, không phải độc lập đo km/antennas/OEM longevity.
- Ảnh settings: `Chỉ cho phép khi dùng ứng dụng`, `Sử dụng vị trí chính xác` bật, thông báo bật, pin ứng dụng `Tiết kiệm pin (kiến nghị)`; chưa có MIUI build. Bản APK đã xác minh hash từ ZIP gốc, không đo hash cài trên điện thoại.
- CI trên previous HEAD docs `7c413a9281a3c2c00eee3fc4580d074a43f035e5`: Foundation PR `43817918741` **SUCCESS**, Zero Cost PR `43817918803` **SUCCESS**. Các docs commits mới cần kiểm lại CI theo HEAD nếu muốn nhận thành công cho HEAD mới.
- Không thay đổi product code, DB, APK, schema, paid APIs; PR #1 vẫn DRAFT, Issue #2 OPEN, Issue #3 production NOT IMPLEMENTED. Chỉ ghi `feature/navitaximeter-foundation`.
- **Bước tiếp theo**: hướng dẫn người dùng A2-02 native/Preview GPS_BUSY trước, cần chụp lỗi Preview và quay lại trạng thái native; nhận ảnh, so sánh, ghi PASS/FAIL/NOT TESTED. Sau đó A2-03 notification Stop, A2-04 Home/lock, A2-05 revoke. Dừng khi lỗi hoặc thấy hai owner hoạt động; không test khi đang chở khách.

---

# CHU KỲ 7 — LƯỢT 1/7 · TIẾP QUẢN 16/11/2026 (XIAOMI ANDROID 13)

- Trò chuyện mới reset AI_REPLY_COUNT=0; sau lượt trả lời hiện tại **AI_REPLY_COUNT=1/7**, lượt **7/7** phải viết bản bàn giao đầy đủ mục 3.1–3.10 và Phụ lục A.
- Đã đọc `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md` + Phụ lục A/C, `AGENTS.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, skills code-commander/location-background/safe-change/red-green/github-actions; đối chiếu mã nguồn UI và Issue #2/#3.
- Repo `ThanhTaxiXanh/NaviTaxiMeter`, nhánh duy nhất `feature/navitaximeter-foundation`, PR #1 **OPEN/DRAFT**, Issue #2 **OPEN/PHYSICAL NOT TESTED**, Issue #3 **OPEN/production GNSS owner+writer NOT IMPLEMENTED**. Không sửa main/TTX, không thu cước, không paid API, không migration SQLite v3, không force push.
- Chủ dự án xác nhận thiết bị có thể thử: **Xiaomi Redmi Note 12 Pro, Android 13**; phiên bản MIUI/HyperOS chưa xác minh. **Chưa có kết quả GPS vật lý**, tất cả A2-01…A2-06 NOT TESTED.
- Đã xác minh CI trên HEAD docs-only `f7172087315aa78e2f9f1c1fc9e2f5a1a3da88ab`: Foundation PR 43815099013 **SUCCESS**, Zero Cost PR 43815099105 **SUCCESS**. Sau đó có docs-only commit mới nên phải kiểm lại CI đúng HEAD.
- Đã tải artifact 14200424290 từ code commit `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24` (Foundation PR 43811708123 SUCCESS): ZIP SHA-256 `363824f62aa6d02ed50c380a38f452a9fb182b8b2d42af123a529bc0fb623cd5`; APK SHA-256 `7ec6a8bbd39252cc27663566f6c280110ab23fb235a54fae71b6d73962dc540e`; một `app-debug.apk` 165929486 bytes. APK DEBUG đã được trích xuất/gửi cho chủ dự án trong chat, **không phải build production**.
- Thêm runbook đúng thiết bị `docs/ISSUE_2_XIAOMI_REDMI_NOTE_12_PRO_ANDROID13_RUNBOOK_2026-11-16.md` tại commit `98933437ec20a0ad55931ee8a9e3aeee608eab86`; sử dụng đúng nút UI đã xác minh, bảo vệ PII, hướng dẫn A2-01…A2-05, A2-06 tùy chọn.
- **Bước tiếp theo chính xác**: kiểm GitHub CI SHA sau docs commit; đề nghị người dùng chạy A2-01 trên Xiaomi, gửi ảnh chụp đã che tọa độ và trạng thái owner/ACK; không tự ghi PASS khi chưa nhận bằng chứng. Mọi FAIL phải xử lý root cause. P1 Issue #3 production writer/FGS chờ physical evidence, chưa hiện thực. Giữ quy tắc 7 lượt.

---

# CHU KỲ 5 — BÀN GIAO BẮT BUỘC 7/7, 16/11/2026

- AI_REPLY_COUNT = 7/7 trong chat này; chat mới reset 0, tiếp tục bàn giao sau mỗi 7 lượt.
- Bản độc lập: `docs/HANDOFF_2026-11-16_CYCLE5_7-7.md` gồm mục 3.1–3.10, Phụ lục A/B về điện thoại và Phụ lục C quy tắc 10.
- HEAD trước bàn giao `ed1ad5e4bf1fbfdbdb74beab253ef3c1d1b9ebda`, Foundation PR 43800182673 IN PROGRESS, Zero Cost PR 43800182842 SUCCESS. Foundation trước đó FAIL vì `originalLease` chưa đúng scope, sửa ở `ed1ad5e` chờ CI.
- PR #1 Draft, Issue #3 OPEN, Issue #2 OPEN/NOT TESTED physical; main/TTX read-only. DEBUG writer lease test != production GNSS/SQLite.
- Mọi task code: đọc `AGENTS.md` → latest handoff → `.agents/skills/navi-code-commander/SKILL.md` → chỉ skills liên quan. Zero Paid API, data privacy, exact-SHA tests, không thu cước.
- Việc kế: verify CI SHA mới, sửa lỗi thật nếu còn; tiếp tục Issue #3 service lifecycle và single owner/writer, không auto migration; điện thoại chỉ khi đủ điều kiện Phụ lục A.

---

# CHU KỲ MỚI — LƯỢT 1/7 (16/11/2026) · ISSUE #3 P1 DEBUG IPC

- Chat mới khởi tạo `AI_REPLY_COUNT=0`; sau lượt trả lời này `AI_REPLY_COUNT=1`, tiếp tục bàn giao **đầy đủ** ở lượt 7/7 theo 3.1–3.10 và Phụ lục A. Đã đọc toàn bộ bản bàn giao ngày 16/11/2026 và quy tắc cứng.
- HEAD trước viết mã: `b72984af3d1887183b4f880d4aa871360ab0fa65`, sau mốc code `55c1c62` chỉ có docs. CI đúng HEAD trước viết: Foundation `43775491594` SUCCESS, Zero Cost `43775491561` SUCCESS. PR #1 Draft/open, issue #2/#3 open, `main` ở `539ff788`.
- Lượt này: thêm `lib/src/lab/debug_checkpoint_transport.dart`, nối **Kotlin native debug-bound service → Dart headless MethodChannel → sqflite transaction → reopen/readback → ACK typed**; thêm instrumented Android 14 test để bắt concurrency/replay/stale fence/PAUSED/rebind. `tool/verify_android_probe_results.py` bắt buộc nhận đủ **2** test executed. Tài liệu: `docs/ISSUE_3_P1_ANDROID_DEBUG_TYPED_IPC.md`.
- **Quan trọng:** đây là DB `navitaximeter_DEBUG_IPC_DBG_*.db` và service DEBUG-only; **không** có GNSS production owner, fare, route, DB khách, FGS thật, chưa có Android vật lý hoặc post-COMMIT ACK production. `navitaximeter_v1.db` giữ schema v3, không migrate. CI cho commit mã mới phải kiểm chứng đúng SHA sau push, không tự nhận PASS.
- Tiếp theo: xác minh Foundation/Zero Cost và Android emulator XML run đúng SHA mới; sửa nếu fail, rồi thiết kế và kiểm chứng `TripLocationService` GNSS owner thật + một worker production writer với durable generation fence; không vội làm UI/map.
- Chỉ ghi nhánh `feature/navitaximeter-foundation`, không merge main, không sửa TTX, không Google Billing/paid APIs, không thu cước khách. Issue #2 Android vật lý **NOT TESTED**, chưa mời test vì thiếu APK+nút+kịch bản đủ điều kiện Phụ lục A.

---

# TIẾP QUẢN CHAT HIỆN TẠI: BÀN GIAO BẮT BUỘC 7/7, NGÀY 16/11/2026

- **Đã hoàn thành lượt bàn giao thứ 7/7 trong chat hiện tại.** `AI_REPLY_COUNT=7`. Nếu tiếp tục cùng chat: 8/7 về chu kỳ và bàn giao ở 14/21...; **chat mới reset 0**, bàn giao ở lượt 7 tiếp theo.
- **TÀI LIỆU ĐẦY ĐỦ BẮT BUỘC ĐỌC:** `docs/HANDOFF_2026-11-16_CYCLE4_7-7.md` gồm 3.1–3.10 và **Phụ lục A chép nguyên văn quy tắc kiểm thử điện thoại**, Phụ lục B trạng thái không đủ điều kiện phone test. Quy tắc nguồn: `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`. Liên kết: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/blob/feature/navitaximeter-foundation/docs/HANDOFF_2026-11-16_CYCLE4_7-7.md .
- **SHA CODE/CI được đối chiếu tại lượt 7 trước khi commit docs:** `55c1c62f9b8b938df34f312a350b7474a4dd073d`. Foundation https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43758959240 **FULL SUCCESS** (build-test + Android14 emulator HEADLESS DEBUG ONLY, NOT physical GPS). ZeroCost Source Gate https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43758959319 **SUCCESS**, không phải audit chi phí 30 ngày.
- Bản bàn giao độc lập được tạo ở commit `28b6009524aac75504aa8292e1aac8a4b7c2aeb6`. **HEAD sẽ đổi sau khi cập nhật STATE này, cần đọc CI theo latest SHA; không gán PASS của code SHA cho docs SHA trước khi hoàn tất.**
- PR #1 **OPEN/DRAFT**, Issue #2 **OPEN / NOT TESTED PHYSICAL**, Issue #3 **OPEN / no one native GNSS owner + one production SQLite writer or true post-COMMIT ACK**. `main` `539ff788b62be69135e5b3ad2c554dca005249a5`; TTX reference feature SHA `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d`. Không sửa/merge main/TTX.
- CHÍNH XÁC công việc đã làm trong chat mới 1–6: unified test-only staged fare/route/fence/ACK and historical chain, coordinator COW và atomic initial v3 trip, Dart-only typed-wire readback ACK tests trên SQLite clone. CI baseline ở SHA code `55c1c62` FULL SUCCESS. **KHÔNG native Kotlin→Dart actual trip IPC/worker, không real FGS GNSS proof, không physical device.**
- **Bước đầu chat mới:** đọc handoff full, kiểm HEAD/PR/issues/CI live; ưu tiên Issue #3 test-only/native debug actual Kotlin→Dart transport/service-owned single writer + backup v3 clone fence; **không mở feature/thu cước khách**. Phone testing chỉ khi có APK artifact + SHA/checksum + nút từng bước và Phụ lục A; hiện CHƯA THỂ TEST.
- Giữ Android-first Flutter/Kotlin, Zero Paid API, v3 app DB và confirmed prefs, 7 mockups user attachments, map sovereignty display requirements, no Google Billing/paid APIs/Google paid Maps, no signed release, no actual passengers.
- Quy tắc bắt buộc: bài test PASS không đồng nghĩa production readiness; nêu rõ PENDING/NOT TESTED; không gửi GPS/PII/keystore/token.

---

# TIẾP QUẢN CHAT HIỆN TẠI - LƯỢT 6/7 (16/11/2026 ICT)

- Sau lượt trả lời này: **AI_REPLY_COUNT = 6/7**. LƯỢT AI TIẾP THEO = 7/7: PHẢI lập bản bàn giao mới đầy đủ 3.1–3.10 + phụ lục quy trình kiểm thử điện thoại, độc lập, đọc/kiểm lại repo/PR/issues/CI đúng SHA, không bắt đầu feature mới trước bàn giao.
- Nhánh được phép duy nhất `feature/navitaximeter-foundation`, PR #1 OPEN/DRAFT, issue #2 Android vật lý OPEN/NOT TESTED, issue #3 one GNSS owner/SQLite writer OPEN. `main` và TTX reference READ-ONLY; không merge.
- Baseline lượt 5: code HEAD `4175d86239efba4b5d55092376770d886d27ee8a`. Zero Cost Source Gate [43754959918](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43754959918) **SUCCESS**; Foundation Flutter Android [43754959417](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43754959417) **FULL SUCCESS** cả build-test (flutter analyze/test, debug APK, Kotlin JVM) và Android 14 emulator debug-only headless SQLite probe. Không phải GNSS physical hay production cước.
- Lượt 6: tạo `test/support/issue3_service_ack_wire_bridge.dart`, `test/issue3_service_ack_wire_bridge_test.dart`, `docs/ISSUE_3_SERVICE_ACK_WIRE_BRIDGE_TEST_ONLY.md`. Serial native-like wire `IpcProposal.toWire/fromWire` → Dart `IpcCheckpointGate` → unified sqflite clone writer COMMIT → đọc lại durable fence, ACK, route, historical record và header → chỉ sau đó trả `trip.ack.v1`. Test 8 in-order concurrent, 8 identical replay, stale generation, conflicting payload, forged ACK ID, delayed delivery, post-COMMIT lost callback → PAUSED/reopen, malformed input. **Chỉ Dart test**, CHƯA phải native Kotlin MethodChannel/TripLocationService thật.
- Commits P3 lượt này: `0d391b441a1b9c9a90a634fc86987b6e221f9359`, `473867f2b5d02287dd71cf6302d01942d940e03f`, `fc79162a9654fac2ef39227c8ff167f231b525d0`, `4f07f94ccc729a9d5099dada2c91d47b1b68c896`. **CI HEAD CUỐI CÙNG phải xác minh; không nhận PASS cho bài mới trước khi Flutter test hoàn tất.**
- Chưa có single native GNSS owner, service-owned FlutterEngine, production durable ACK/ledger, v3→v4 migrate, backup prefs + SQLite thực, physical Android 11–16/OEM, map/UI/VietQR sản phẩm đủ 7 màn, release. Vẫn KHÔNG ĐƯỢC THU CƯỚC KHÁCH.
- Bước tiếp theo: xác minh full Foundation/ZeroCost CI đúng SHA HEAD; nếu FAIL sửa, cập nhật trạng thái. **Lượt 7** phải bàn giao đầy đủ theo quy tắc cứng và phụ lục điện thoại, không được bỏ qua. Quy tắc dùng APK SHA/run, từng nút, PASS/FAIL/NOT TESTED, chứng cứ riêng tư đã che và cách gửi AI, không giả định người dùng có PC/ADB. Không yêu cầu test điện thoại nếu chưa có APK/button đúng.
- Zero Paid API, không Google Billing/paid APIs, không merge main, không sửa TTX, không signed release, không auto migration app DB, không GPS mock làm dữ liệu tính cước thật.

---

# TIẾP QUẢN 16/11/2026 - CHAT MỚI, LƯỢT 3/7

- AI_REPLY_COUNT = 3 sau lượt này, lượt 7/7 phải tạo bản bàn giao độc lập đầy đủ mục 3.1–3.10 và Phụ lục A; chat mới reset 0.
- Nhánh duy nhất được ghi: `feature/navitaximeter-foundation`; PR #1 OPEN/DRAFT/unmerged, issue #3 OPEN, issue #2 OPEN/NOT TESTED PHYSICAL. Không merge main, không sửa TTX tham chiếu.
- Baseline code commit `23f9b3f2e69e91fe87e5f924dc0a78beb6853768`: ZeroCost run `43747250593` SUCCESS; Foundation `build-test` run `43747250565` SUCCESS (`flutter analyze/test`, debug APK). Android 14 emulator-probe phải đọc riêng conclusion, không nhận là physical GPS.
- Lượt 3 đã viết bộ lịch sử ACK trên DB clone CHỈ THỬ: `test/support/issue3_historical_ack_chain.dart`, chỉnh `test/support/issue3_unified_checkpoint_writer.dart` và `test/issue3_unified_checkpoint_test.dart`. Một transaction chứa synthetic route + staged fare/header + fence + ACK + history; kiểm tra chuỗi của toàn bộ điểm khi recovery; 8 ca sửa checkpoint cũ, lỗi INSERT history, khôi phục PAUSED. Các code commits: `90cbdfef`, `d985cc9b`, `74faf0fb`. Docs `docs/ISSUE_3_HISTORICAL_ACK_CHAIN_TEST_ONLY.md` ghi giới hạn và review coordinator.
- Zero Cost Gate code SHA `74faf0fbbfc759e216ffc21c1cdc816b815e35ea` run `43748400019` SUCCESS. Foundation run `43748400050` chưa có kết luận ở lúc ghi trạng thái; commit docs có thể khiến run code bị CANCELLED, phải kiểm CI trên HEAD cuối cùng. **Chưa được đánh dấu new chain tests PASS** nếu không có `flutter test` của đúng SHA.
- Giới hạn bắt buộc: hash không khoá trong cùng file DB không chống người sửa toàn bộ DB; history helper và bảng bổ sung chỉ dùng CLONE. Chưa có production GNSS FGS owner hoặc SQLite writer/ACK, không migration app DB v3, không Android thật, không được thu cước.
- Review runtime: `MeteredTripCoordinator.accept/_suspend/resume/finish` vẫn mutate engine trước SQLite COMMIT; `begin` tạo reservation và initial route trong hai transaction. Tiếp theo xác minh full CI/fix tests, sau đó thiết kế staging coordinator theo fault/recovery test gate, rồi native IPC debug instrumented emulator, issue #2 physical.
- Quy tắc thử Android thật mục 9 không đổi: chỉ yêu cầu khi có APK/run/SHA và hướng dẫn từng nút, PASS/FAIL/NOT TESTED, bằng chứng được che thông tin riêng và cách gửi AI. Không đòi người dùng PC/ADB.
- Không Google Billing/API trả phí, không signed release, không thương mại, không tạo GPS/route/QR giả làm dữ liệu thật.

---

# TIẾP QUẢN SAU BÀN GIAO 16/11/2026 - LƯỢT 2/7 (CHAT MỚI)

- Trong chat tiếp quản hiện tại: AI_REPLY_COUNT=2 sau lượt này; lượt thứ 7 tạo BẢN BÀN GIAO ĐẦY ĐỦ 3.1-3.10 + Phụ lục A, không tự đếm tiếp từ chat cũ.
- Branch được phép: feature/navitaximeter-foundation. PR #1 vẫn Draft/unmerged; main/TTX reference không chỉnh; issue #2 OPEN/NOT TESTED physical, issue #3 OPEN.
- Lượt 1: test/support/issue3_unified_checkpoint_writer.dart và test/issue3_unified_checkpoint_test.dart tạo one test-only sqflite transaction chứa real Dart staged fare/route/fence/ACK, không có GNSS thật, Android IPC hoặc production DB. Code SHA c5b8678d694c250e91b50651e15e9df185f4ccea: Foundation run 43741664068 SUCCESS (flutter analyze/test + Android14 headless DEBUG SQLite probe), Zero Cost run 43741664065 SUCCESS.
- Lượt 2: nhận CI pass SHA c5b; bổ sung recovery-check digest của last sample + last header/fare + ACK ID, xác minh frozen tariff, chống tamper route/fence/ledger/money và 7 ca thử tương ứng; commits 4b2a4c6, 373b38c2. Tài liệu docs/ISSUE_3_UNIFIED_TEST_ONLY_CHECKPOINT_PROOF.md được tạo. **CI của HEAD cuối cùng sau docs phải kiểm tra riêng trước khi công nhận PASS**.
- Giới hạn: chưa chứng minh historical hash chain toàn bộ các hàng, recovery chỉ đối chiếu checkpoint cuối cùng bằng digest + header; chưa có Android native live GNSS owner, one production SQLite writer, real post-COMMIT ACK và physical device. Vẫn chưa thu cước khách hoặc phát hành.
- Bước kế tiếp: xác minh latest HEAD Foundation/Zero Cost, sửa Flutter test nếu FAIL; sau đó tăng tính toàn vẹn full-history/ACK and review coordinator mutation trước COMMIT; vẫn chỉ TEST ONLY. Quy tắc mục 9 bắt buộc hướng dẫn điện thoại chi tiết + cách gửi bằng chứng khi yêu cầu test; hiện chưa yêu cầu test.
- Cấm merge main, sửa TTX, paid API/Billing, auto-migrate DB thật, signed release hoặc thương mại.

---

# BÀN GIAO BẮT BUỘC — LƯỢT 7/7, CHU KỲ TIẾP QUẢN MỚI (16/11/2026)

- **AI_REPLY_COUNT = 7** sau lượt bàn giao này. Trong chat đang mở lần bàn giao sau ở 14/7; chat mới đặt count = 0. Handoff full **3.1–3.10** + nguyên văn quy tắc điện thoại mục 9 tại `docs/HANDOFF_2026-11-16_CYCLE3_7-7.md`.
- Code HEAD **trước commit tài liệu**: `edee0b7e2651f96983b0e3624243fd3e557d637e` trên **feature/navitaximeter-foundation**. Foundation Flutter Android run [43738096495](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43738096495) **FULL SUCCESS** (build-test, flutter analyze/test, Android 14 **headless debug SQLite probe**); Zero Cost run [43738096483](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43738096483) **SUCCESS**. CI trên SHA **docs-only** mới sau commit bàn giao phải kiểm tra riêng, không gán kết quả code cũ.
- PR #1 OPEN/DRAFT/unmerged; main SHA `539ff788b62be69135e5b3ad2c554dca005249a5`, TTX reference branch SHA `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d` READ-ONLY; issue #3 OPEN, issue #2 OPEN/NOT TESTED PHYSICAL.
- Chu kỳ 1–6 đã làm: typed IPC 11 tests; v3 Python clone/prefs backup/v4 dry-run 10; Flutter FFI v4 ACK clone 14; IPC->sqflite test bridge 7; `TaximeterEngine.forkForCheckpoint` + test-only staging trên TripRepository v3 10; fare grace/flat/tier/rounding thêm 15 tests. SHA cuối `edee0b7e` CI xanh toàn bộ. **Các proof vẫn tách biệt**, chưa có một production trip writer/GNSS owner/ACK integrated.
- **Điểm tiếp tục issue #3:** thử **unified test-only** typed IPC + staged immutable Dart fare candidate + sqflite transaction (route/header/fence/ACK) trên MỘT disposable DB clone; test replay/generation/rollback/lost ACK/PAUSED; sau đó mới review `MeteredTripCoordinator.accept/resume/_suspend/finish` để không mutate trước COMMIT. Không auto-migrate app DB v3, không thu cước thật.
- Hard rule §9: Nếu cần thử trên điện thoại, hướng dẫn rõ APK/SHA, ca test, từng bước/nút, PASS/FAIL/NOT TESTED, ảnh/video/log cần chụp che riêng tư và cách gửi AI. Chưa có physical Android PASS và chưa yêu cầu người dùng test ở lượt này.
- Không merge main, không sửa TTX, không Google Billing/paid APIs, không GPS/route/fare thật, không signed release.

---

# CHU KỲ MỚI — LƯỢT 6/7 (15/11/2026) · ISSUE #3 P4B

- AI_REPLY_COUNT = 6 sau lượt này. **LƯỢT AI KẾ TIẾP = 7/7: BẮT BUỘC lập bản bàn giao đầy đủ, độc lập, theo mục 3.1–3.10, có link SHA/CI/hard rules.**
- HEAD trước thay đổi: `3c1111e5985b9563f33b2ca44d80b7552d8880d6`; PR #1 OPEN/DRAFT, chưa merge; issue #2/#3 OPEN. Ghi duy nhất `feature/navitaximeter-foundation`; không sửa main/TTX.
- CI SHA `3c1111e5`: [ZeroCost 43733816387](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43733816387) SUCCESS; [Foundation 43733816398](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43733816398) SUCCESS (build-test + emulator-probe); flutter test SUCCESS bao gồm 10 staged tests. Emulator là headless debug SQLite probe, KHÔNG GNSS thật.
- Mới lượt 6: `test/issue3_fare_fork_pricing_regression_test.dart` (10 tests fork waiting grace/flat/tier/rounding/PAUSED), `test/issue3_staged_tariff_parity_test.dart` (5 real sqflite v3 disposable DB fare parity tests), và chỉnh **test-only** helper `TestOnlyFareStage.begin({TariffConfig tariff,double? fixedFare})`. `docs/ISSUE_3_P4B_FARE_PARITY_REGRESSION.md` nêu giới hạn. Tổng +15 test **đã viết, chờ CI SHA mới**.
- `TaximeterEngine.forkForCheckpoint()` từ lượt 5 vẫn không được gọi ở production `MeteredTripCoordinator`; live coordinator vẫn mutate trước COMMIT. P3 typed IPC + clone ACK và P4 fare v3 actual repo vẫn tách biệt; chưa có single service-owned native GNSS/worker hoặc production durable ledger, không migrate v4.
- Hard rule cập nhật đầy đủ `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, mục 9 hướng dẫn kiểm thử điện thoại PASS/FAIL và gửi bằng chứng; **chưa yêu cầu user thử điện thoại**. Issue #2 Android physical chưa được chứng minh.
- Bước kế tiếp: verify CI đúng SHA cuối lượt 6, nếu fail sửa; tiếp theo phối hợp transactional immutable fare + IPC+ACK trong worker thử nghiệm, guard production no billing; thiết kế/test issue #2 Android thực trước release. Giữ 0 USD paid API, không Google Billing, không merge main, không sửa TTX, không thu cước hành khách.

---

# TIẾP TỤC ISSUE #3 — CHU KỲ MỚI, LƯỢT 5/7 (15/11/2026)

- AI_REPLY_COUNT = 5 sau lượt này; đến lượt 7 BẮT BUỘC bàn giao đầy đủ các mục 3.1–3.10. Hard Rule §9 hướng dẫn kiểm thử điện thoại đầy đủ vẫn lưu tại `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`; **chưa** yêu cầu user thử điện thoại.
- HEAD trước việc mới `0e6e0cc4b064096d914a15bf63978f86567c7748`; PR #1 OPEN/DRAFT chưa merge, chỉ nhánh `feature/navitaximeter-foundation`; main và TTX không sửa. Issue #2/3 OPEN.
- CI `0e6e0cc4`: Foundation run 43732807141 bước `flutter test` SUCCESS, `build-test` SUCCESS, `emulator-probe` còn chạy khi xác minh; ZeroCost 43732807126 SUCCESS. Không gọi full workflow PASS trước khi hoàn thành.
- Mới: thêm API additive `TaximeterEngine.forkForCheckpoint()` sao chép toàn bộ private runtime state (đặc biệt GPS anchor + waiting/tick), chưa gọi trong production UI; `test/support/issue3_staged_fare_checkpoint.dart` thực hiện candidate-before-COMMIT trên DB V3 tạm riêng + frozen snapshot; `test/issue3_staged_fare_checkpoint_test.dart` có 10 bài mới gồm rollback trigger route và REPLACE header, deferred transaction/publish, 8 concurrent queued, restart PAUSED, no backfill. Chỉ test fake tariff/coords, không có passenger.
- **CI SHA mới chưa được xác minh**; cần kiểm tra Flutter analyze/test đúng SHA và sửa nếu FAIL. Kết quả kiểm thử cũ không thể dùng thay mới.
- Kết nối IPC P3C trước đó và staged fare P4 là **hai proof tách biệt**, chưa có real unified service-owned writer/ACK transaction. Source coordinator `MeteredTripCoordinator.accept` vẫn live mutate before commit, cũng cần refactor `resume`, `_suspend`, `finish` sau khi có test an toàn. Không chỉnh production DB schema.
- Bước tiếp: verify new CI, thêm regression waiting grace/tiered fare/flat fare; sau đó mới đánh giá copy-on-write coordinator + Android test-only instrumentation, issue #2 physical GNSS. Không lặp lại Python/FFI proofs đã thành công.
- Cấm merge main, sửa TTX, Billing/paid APIs, thu cước thật, signed release hay tự migrate v3→v4.

---

# TIẾP TỤC ISSUE #3 — CHU KỲ MỚI, LƯỢT 4/7 (15/11/2026)

- AI_REPLY_COUNT = 4 sau lượt này; bàn giao bắt buộc đầy đủ ở lượt 7/7. Quy tắc §9 hướng dẫn kiểm thử điện thoại có trong `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`; **chưa** yêu cầu chủ dự án thử điện thoại.
- HEAD trước thay đổi `f59a6eee46238774afc34d034451c33856a9c0f9`; PR #1 OPEN/DRAFT, chưa merge `main`; issue #2/#3 OPEN. Chỉ ghi nhánh `feature/navitaximeter-foundation`, TTX read-only.
- CI của `f59a6eee`: `flutter analyze` và `flutter test` SUCCESS trên Foundation 43732189163, Zero Cost 43732189187 SUCCESS. Foundation build APK/emulator kết luận FULL phải kiểm tra khi hoàn thành.
- Bổ sung `test/support/issue3_ipc_sqflite_adapter.dart` và `test/issue3_ipc_sqflite_bridge_test.dart`: bridge test-only IPC gate -> disposable sqflite clone writer. Thêm 7 Dart tests ghép 8 ordered, duplicate idempotency, digest mismatch, stale generation, conflict, ACK lost after COMMIT, reopen/PAUSED; chỉ fixture zero fare, synthetic. `docs/ISSUE_3_IPC_SQFLITE_BRIDGE_PROOF.md` ghi rõ giới hạn.
- CI SHA sắp commit chưa xác minh. Không phải production IPC/GNSS/FGS, chưa real staged immutable meter candidate, không migrations app v3→v4, không Android physical test, không thu cước thật.
- Tiếp theo: xác minh `flutter test` CI đúng SHA mới; sau đó test staged immutable fare engine candidate với failure-injection, Android test-only instrumented sqflite + single ownership; issue #2 cần hướng dẫn từng ca và bằng chứng theo hard-rule §9.
- Giữ nguyên Zero Paid API, cấm Billing, cấm merge main/sửa TTX, cấm phát hành thương mại.

---

# TIẾP TỤC ISSUE #3 — CHU KỲ MỚI, LƯỢT 3/7 (15/11/2026)

- AI_REPLY_COUNT = 3 sau lượt này; bàn giao bắt buộc tiếp theo ở lượt 7/7. Giữ nguyên HARD RULE §9: mọi yêu cầu thử trên điện thoại phải có bước thao tác, điều kiện PASS/FAIL, mẫu bằng chứng và cách gửi; chưa yêu cầu thử điện thoại tại lượt này.
- HEAD trước khi sửa: 85de6187b0f6a166a8986c75a8f0b87559670c13, PR #1 OPEN/DRAFT/chưa merge, main 539ff788b62be69135e5b3ad2c554dca005249a5, TTX tham chiếu a40c246de6fd3799aaddedce3ed0d3b1d9dd524d. Issue #2/#3 OPEN.
- CI của SHA 85de6187: Zero Cost 43731059286 SUCCESS; Foundation 43731059227 build-test SUCCESS, emulator-probe vẫn IN PROGRESS lúc kiểm tra. Không gán FULL SUCCESS cho run chưa hoàn thành.
- Phần mới: chỉ test/support/issue3_sqflite_clone_writer.dart và test/issue3_sqflite_clone_ack_test.dart cộng docs/ISSUE_3_SQFLITE_CLONE_ACK_PROOF.md. Thử sqflite FFI transaction route + header + durable test fence + ledger, ack sau Future COMMIT, crash/lost-ACK mô phỏng, 8 concurrent và rollback; chỉ trên bản sao DB schema-v3-shaped với fixture không có cước thật.
- Chưa có CI xác minh test mới tại SHA sẽ commit; chưa thử Android SQLite app clone thực, không có production GNSS service, physical Android issue #2 vẫn NOT TESTED.
- Bước tiếp: xác minh CI đúng SHA mới, sửa lỗi nếu có; sau đó nối typed IPC gate với Dart test-only sqflite adapter, xây test staged immutable TaximeterEngine candidate, Android instrumentation trên DB debug riêng; tiếp tục physical gate issue #2 khi có quy trình/hướng dẫn rõ.
- Tuyệt đối không merge main, không sửa TTX, không bật Google Billing/paid API, không thu cước khách, không auto-migrate DB sản phẩm.

---

# TIẾP QUẢN CHU KỲ MỚI: LƯỢT 2/7 (15/11/2026)

- AI_REPLY_COUNT = 2 sau lượt này. Bản bàn giao mới đầy đủ tại 7/7. Quy tắc cứng bản đầy đủ đã commit: `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` (section 9 hướng dẫn rõ từng bước kiểm chứng điện thoại / bằng chứng / gửi AI).
- GitHub HEAD trước công việc P3: `6dc68cae6e2f4d7b91569a2e9ddaa88c6877ac8b`, PR #1 OPEN/DRAFT/unmerged, main `539ff788`; TTX read-only `a40c246d`. Issue #2/#3 OPEN.
- Lượt 1 code `bc5a9cf5`: Zero Cost PR 43729776609 SUCCESS; Foundation 43729776697 `build-test` SUCCESS nhưng `emulator-probe` CANCELLED sau push docs-only (không được gọi lỗi build hay full PASS). AVD debug proof 43725473578 trên code `85cfa50` vẫn SUCCESS.
- Lượt 2 mới: `tool/v3_clone_migration_proof.py`, `tool/test_v3_clone_migration_proof.py`, `docs/ISSUE_3_V3_CLONE_MIGRATION_PROOF.md`: 10 local CPython tests PASS cho app-v3-shaped technical SQLite fixture, tariff prefs placeholder, snapshot/hash/restore và v4 dry-run transactional rollback. **KHÔNG** SQLite app production, `sqflite` Android, v2 migration hoặc physical GNSS.
- CI trên SHA chứa thay đổi P3 phải xác minh riêng, không nhận PASS trước khi chạy. Không yêu cầu chủ dự án test điện thoại trong P3 Python.
- Bước tiếp theo: verify CI P3; viết Dart sqflite app-clone tests/staged meter candidate/post-COMMIT durable fence+ledger. Không đụng DB/prefs thật; issue #2 chỉ thử điện thoại khi có APK đúng và hướng dẫn chi tiết theo hard rule section 9.
- Không merge main, không sửa TTX, không Google Billing/paid APIs, không thu cước khách hoặc phát hành.

---

# CẬP NHẬT SAU BÀN GIAO CHU KỲ 2: CHU KỲ MỚI 1/7 (15/11/2026)

- AI_REPLY_COUNT bắt đầu 0 trong chat mới, bằng 1 sau câu trả lời tiếp quản này; bàn giao độc lập tiếp theo ở lượt 7.
- Trước thay đổi: feature HEAD 0c3a37340cd2d4eb23883ed5dcf562bcc839994a, PR #1 OPEN/DRAFT/unmerged, main 539ff788b62be69135e5b3ad2c554dca005249a5, TTX read-only a40c246de6fd3799aaddedce3ed0d3b1d9dd524d; issue #2/#3 OPEN.
- CI trên HEAD trước thay đổi: Zero Cost run 43728012965 SUCCESS; Foundation run 43728012982 IN PROGRESS tại thời điểm đọc (phải đối chiếu lại). Android emulator debug probe đã SUCCESS tại 85cfa50, run 43725473578.
- Việc mới trong commit này: pure Dart typed IPC fence + one logical serialized test-writer queue, test late callbacks, same-sequence replay, 8 concurrent requests, unknown-commit PAUSED. Có tài liệu docs/ISSUE_3_IPC_PROOF_STATUS.md. Không nối Android runtime, SQLite app, GNSS hoặc engine tiền.
- Chỉ phát test ACK khi injected writer Future trả về identity trùng, KHÔNG coi fake writer là bằng chứng SQLite COMMIT. Đã tạo mã/test; cần GitHub CI trên SHA mới để kết luận PASS.
- Bước tiếp: issue #3 P3 fixture clone v3 + confirmed prefs backup/rollback, v4 dry-run và actual sqflite transaction gate/ACK ledger; staged immutable candidate; issue #2 Android physical giữ OPEN. Không auto migration, không thương mại.
- Không merge main, không sửa TTX, không Google Billing hoặc API có phí, không thu cước khách, không signed release.

---

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


## Chu kỳ mới lượt 5/7 — Android emulator run, XML gate và callback teardown (15/11/2026)

- **AI_REPLY_COUNT = 5/7 sau lượt trả lời này.** Lượt 7/7 bắt buộc tạo bản bàn giao độc lập theo mục 3.1–3.10 từ `QUY TẮC CỨNG`; lượt 6 tiếp tục nhiệm vụ hiện tại. Không tự reset bộ đếm giữa cùng cuộc trò chuyện.
- **Đầu lượt:** branch feature HEAD `e116b97cee65deea2353cb9050bacaa4d4c87dbf`; PR #1 OPEN DRAFT/unmerged; issue #2 và #3 OPEN, main `539ff788b62be69135e5b3ad2c554dca005249a5`, TTX reference `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d` không đổi.
- **Kết quả CI chính xác HEAD cũ:** Foundation Flutter Android PR run [43724015757](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43724015757) có `build-test` **SUCCESS**; `emulator-probe` **FAIL** tại bước `Require executed Android test XML`: report path dùng `android/app/build/.../connected` không tồn tại trên Flutter mới, đúng là `build/app/outputs/androidTest-results/connected`. Log ghi `Starting 1 tests on test(AVD) - 14`, `Finished 1 tests` và `connectedDebugAndroidTest BUILD SUCCESSFUL` trên Android 14 emulator, nhưng gate XML thất bại. **KHÔNG tuyên bố emulator PASS** / **KHÔNG đánh dấu physical Android test**. Zero Cost Source Gate trên HEAD cũ SUCCESS. [Log job](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43724015757).
- **Lỗi đã sửa:** `.github/workflows/flutter-foundation.yml` đổi XML artifact/report sang `build/app/.../connected` tại commit `4efe8f6542731833e08b5cafed10ec010f6de14b`; verifier giữ yêu cầu XML testcase thành công, không giả PASS dựa vào Gradle compile.
- **Mã lifecycle debug-only:** `android_native/HeadlessProbeCallbackFence.kt` (được cài vào `src/debug`), `android_native/HeadlessProbeCallbackFenceTest.kt` (Kotlin JVM unit tests `src/test`), sửa `HeadlessSqliteProbeService.kt`, `tool/bootstrap_android.py`, `tool/test_bootstrap_android.py`. Fence giữ at-most-once callback, fail `SERVICE_DESTROYED` cho pending requests khi onDestroy, drop late Dart response; unit JVM tests duplicate/destroy/pending/reopen. Không tham gia production GNSS/fare/SQLite.
- **Android instrumented test mở rộng:** `HeadlessSqliteProbeInstrumentedTest.kt` test một + tám yêu cầu sqflite tuần tự trong DB `navitaximeter_HEADLESS_PROBE_ONLY.db`, unbind/destroy headless service và bind lại, rồi đọc count được commit. Không chạm `navitaximeter_v1.db`, không phải native TripLocationService hay Android production ACK.
- **Mốc code:** commits `4101e0d`, `0dc7a13`, `17bc8d2`, `2924a0c`, `6d8b603`, `58fc25441dad91acc7566ee6ef25a9666b9be5b2`, docs `f7423619a834e1859173b3f50763ac614dbe038f`. Callback gate nguồn Kotlin đã compile và chạy smoke test JVM **cục bộ**; không nhầm với Android instrumented runtime. Zero Cost Gate trên code `58fc254` PR run `43725322677` SUCCESS; Foundation run `43725322723` đang chạy khi đọc, không kết luận. Việc ghi hồ sơ docs **tạo HEAD mới và kích hoạt CI lại**, phải kiểm chứng cuối cùng theo HEAD mới.
- **Chưa làm:** triển khai single production GNSS owner/FGS, one trip DB writer, staged immutable monetary candidate, durable session/generation/seq fence + atomic route/header/ACK ledger, v3→v4 backup/migration, Android 11–16 real-device issue #2, paid API 1/50/100 users ×30days audit, driver release signoff, map/UI/VietQR/production release. Issue #2 không thể đóng bằng emulator.
- **Tiếp tục lượt 6:** đối chiếu run PR Foundation chính xác HEAD hiện tại, đọc XML report trong emulator; nếu FAIL tìm root cause, không sửa ngoài nhánh feature. Sau khi mới có emulator proof, tiến tới test tear down / late callback / fault injection test-only, thiết kế phase transition + ACK-after-COMMIT cho *app database copy* và đưa vấn đề migration/backup lên issue #3. Duy trì PR Draft, không merge main/TTX, không Billing hoặc tiền khách.


## Chu kỳ mới lượt 6/7 — Android 14 emulator PASS cho headless SQLite DEBUG (2026-11-15)

- **AI_REPLY_COUNT sau lượt này = 6/7**. **LƯỢT TRẢ LỜI TIẾP THEO (7/7) BẮT BUỘC TẠO BẢN BÀN GIAO 3.1–3.10 ĐỘC LẬP, ĐẦY ĐỦ** theo `QUY TẮC CỨNG — BÀN GIAO DỰ ÁN SAU MỖI 7 LƯỢT TRẢ LỜI AI`, đủ để copy sang chat mới. Không bắt đầu nhiệm vụ khác trong lượt 7/7. Trong chat mới AI_REPLY_COUNT = 0, không reset trong chat này.
- **Trạng thái đầu lượt:** feature HEAD `85cfa50e79f77787e61e10e86a4652d004e7aae3`, main `539ff788b62be69135e5b3ad2c554dca005249a5`, TTX reference `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d`, PR #1 OPEN/DRAFT/unmerged, issue #2 và #3 OPEN.
- **CI MỚI ĐÃ KIỂM TRA và hoàn tất sau khi bắt đầu lượt:** Foundation Flutter Android PR run [43725473578](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43725473578) trên chính code HEAD `85cfa50e79f77787e61e10e86a4652d004e7aae3` **SUCCESS toàn bộ cả hai jobs**. Job `build-test` SUCCESS: Python safety, 12 Python isolated SQLite tests, Kotlin JVM (gồm callback fence), assembleDebugAndroidTest, Flutter analyze/test, Debug APK, compiled manifest, upload debug artifact. Job `Android 14 emulator headless SQLite execution` SUCCESS: Android API34 AVD chạy thật `:app:connectedDebugAndroidTest`, bước `Require executed Android test XML` SUCCESS.
- **Log thực chứng emulator job `132847796746`:** `Starting 1 tests on test(AVD) - 14`; `Finished 1 tests on test(AVD) - 14`; `BUILD SUCCESSFUL in 3m 31s`; `PASS: headless FlutterEngine/sqflite instrumentation actually executed once on an Android emulator (NOT a physical device)`; `WARNING: NO production SQLite writer, GNSS or passenger-fare proof`. Android instrumented test đã chạy **1+8 serialized DB probe requests**, unbind/destroy và rebind headless engine, đọc lại counter bền qua reopen từ **`navitaximeter_HEADLESS_PROBE_ONLY.db`**.
- **Giới hạn nghiêm:** **CHỈ PASS Android 14 emulator debug headless SQLite probe**. Không có Android physical device result, issue #2 **OPEN/NOT TESTED**, chưa chứng minh GNSS thực/FGS một owner, kill/Doze/OEM, Android 11–16, post-COMMIT ACK trên DB app, durability power-loss/fsync, fare/calibration, maps, release. Kotlin `TripCheckpointProtocol` vẫn fake writer, Python proof chạy DB `DISPOSABLE_TEST_ONLY.db`; app SQLite `navitaximeter_v1.db` schema 3 và writer trong Lab vẫn độc lập, chưa có v4 persistent session/generation/seq/fence/ACK ledger, tariff snapshot migration/backup.
- **Đã làm thêm lượt này:** Cập nhật issue #3 milestone [comment](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3#issuecomment-6896375542); issue #2 [comment](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2#issuecomment-6896349852) về protocol test thật, đồng thời ghi rõ emulator không thể thay physical; **không sửa mã** trong lượt 6. Zero Cost Source Gate PR run `43725473618` **SUCCESS** trên HEAD trước khi cập nhật docs. Việc ghi docs trạng thái này làm HEAD feature đổi, cần kiểm tra CI đúng HEAD mới và không tự nâng kết quả từ `85cfa50`.
- **Điểm tiếp tục sau bàn giao 7/7:** kiểm tra latest feature HEAD/CI/PR/issues, đọc các tài liệu `docs/HANDOFF_2026-11-15_CYCLE_7-7.md`, `docs/AI_HANDOFF_STATE.md`, `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`, `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, `docs/SQLITE_ACK_TRANSACTION_PROOF.md`. Tiếp theo issue #3: thiết kế typed IPC session/generation/sequence và writer Dart duy nhất với staged immutable meter candidate, thử schema v4 trên **app DB clone** (không migration production), post-COMMIT ACK/fault injection/replay; sau đó issue #2 device matrix (Android 11–16 physical, GNSS/FGS/Doze/OEM), fare parity and independent approval. **Không tự ý bật production route/fare.**
- **Giữ bất biến:** không merge main, không sửa TTX gốc, không Google Billing/API trả phí, không thu cước khách, không ký phát hành. PR #1 Draft đến khi owner xác nhận.


## Chu kỳ mới lượt 7/7 — BÀN GIAO BẮT BUỘC CHU KỲ 2 (15/11/2026)

- **AI_REPLY_COUNT = 7/7 sau khi hoàn tất câu trả lời này.** Tại **cuộc trò chuyện mới** reset `AI_REPLY_COUNT = 0`; nếu tiếp tục **trong cùng chat**, lượt tiếp theo là **8**, bàn giao lại ở 14/21/28... theo quy tắc cứng. **Lần bàn giao gần nhất:** 15/11/2026, sau tin nhắn người dùng lúc 21:54:32 (UTC+07:00).
- **BẢN ĐỘC LẬP 3.1–3.10 MỚI:** [`docs/HANDOFF_2026-11-15_CYCLE2_7-7.md`](HANDOFF_2026-11-15_CYCLE2_7-7.md), commit tạo file `2fe0a1b7fd7577fd8e98eeccf532d02652c0c7e1`. Đây là bản bàn giao chu kỳ tiếp quản thứ hai, đọc thay vì chỉ dựa phần lịch sử cũ.
- **Mốc kiểm chứng đầu lượt:** feature HEAD `a8a09433ead50014b61301e0b8aafeca35f2eb74` (chỉ thêm docs so với code HEAD `85cfa50e79f77787e61e10e86a4652d004e7aae3`), Foundation CI mới `43726611613` lúc kiểm tra đầu lượt còn IN PROGRESS, Zero Cost run `43726611616` SUCCESS. Bản bàn giao ghi rõ trạng thái và phải kiểm tra lại CI sau commit docs.
- **BẰNG CHỨNG KHÔNG THỂ ĐÁNH TRÁO:** code HEAD `85cfa50e79f77787e61e10e86a4652d004e7aae3` có Foundation Flutter Android PR run [43725473578](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43725473578) **SUCCESS cả `build-test` lẫn Android 14 emulator-probe với executed XML verifier SUCCESS**. Đây là **headless FlutterEngine + sqflite DEBUG probe-only**, không phải GNSS physical/production fare/ACK. Zero Cost PR run `43725473618` SUCCESS chỉ quét nguồn.
- **Đang làm/chưa làm:** issue #3 **OPEN**: một native `TripLocationService` GNSS/FGS và một Dart service-owned SQLite writer cho app DB **CHƯA TRIỂN KHAI**; chưa có staged fare candidate, v4 migration, durable session/generation/ACK ledger hoặc post-COMMIT Android trip ACK. Issue #2 **OPEN/NOT TESTED PHYSICAL**, cần Android 11–16/OEM/Doze/FGS và redacted evidence. Không thử chuyến khách.
- **Điểm tiếp tục chính xác cho AI mới:** đọc toàn bản handoff mới; xác minh HEAD, PR #1 Draft, issue #2/#3, Foundation/Zero Cost đúng SHA; xem `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, `docs/SQLITE_ACK_TRANSACTION_PROOF.md`, `lib/src/data/trip_repository.dart`, `lib/src/core/metered_trip_coordinator.dart`; tiếp tục issue #3 bằng **typed IPC + one-writer contract, staged candidate, DB v3 clone→v4 proof, ACK after COMMIT/fault-injection**, rồi issue #2 physical. **Không làm lại emulator probe đã PASS nếu không có lỗi mới.**
- **Bất biến:** Chỉ ghi nhánh `feature/navitaximeter-foundation`; PR #1 OPEN/DRAFT/unmerged, main `539ff788b62be69135e5b3ad2c554dca005249a5` và TTX reference `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d` không sửa; KHÔNG Google Billing/API trả phí, KHÔNG thu cước khách, KHÔNG ký/ra release. CI APK debug only, không có zero-cost cloud billing audit thực.

---

# CHU KỲ 6 — LƯỢT 1/7 · TIẾP QUẢN ISSUE #3 · 16/11/2026

- Cuộc trò chuyện mới bắt đầu từ AI_REPLY_COUNT=0; sau lượt hoàn tất này là **1/7**. Lượt 7 tiếp theo phải bàn giao độc lập với mục 3.1–3.10 và Phụ lục A.
- Đã đọc `AGENTS.md`, `docs/HANDOFF_2026-11-16_CYCLE5_7-7.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, `.agents/skills/navi-code-commander/SKILL.md`, cùng các skill trực tiếp: `navi-location-background`, `navi-safe-change`, `navi-red-green`, `navi-github-actions`. Trên tree hiện tại chỉ có AGENTS.md ở gốc.
- HEAD ban đầu đối chiếu GitHub: `331f51c9ea54e79f612df72a0e5dee0946e2f60c`; PR #1 OPEN/DRAFT/NOT MERGED, issue #2 OPEN/NOT TESTED physical, issue #3 OPEN, main read-only. Tại HEAD ban đầu Zero Cost PR 43800403906 SUCCESS; Foundation PR 43800403898 đang chạy khi kiểm tra, **không nhận PASS**.
- **Đã phát triển mã thực, DEBUG-only:** commit `0e73d2e1dc150faf354630541f6b112170763a2b` bổ sung Android instrumented test `competingWriterLeaseDeniesEngineUntilTeardownAndExplicitRebind` vào `android_native/HeadlessSqliteProbeInstrumentedTest.kt`. Test dựng lease của writer đang bị chiếm, bind Android Service, chứng minh Dart engine bị từ chối, checkpoint `DEBUG_SESSION_PAUSED`, teardown không xóa lease đối thủ, sau release/rebind mới cấp token mới và chặn writer thứ ba.
- Commit `e5b37d6b4da77f223366c252c012025a5410660f` thêm verifier XML/test Python bắt buộc thấy đủ **3** Android instrumented methods thực thi và không fail/skip, tệp `tool/verify_android_probe_results.py`, `tool/test_verify_android_probe_results.py`.
- **Exact-SHA CI của `e5b37d6b` tại lúc kiểm tra:** Zero Cost Source Gate PR 43801795329 SUCCESS, push 43801789967 SUCCESS; Foundation PR 43801795339 IN PROGRESS. Foundation push 43801790031 CANCELLED do concurrency, không phải FAIL hay PASS. Phải kiểm lại CI sau khi ghi file STATE vì HEAD tài liệu sẽ khác.
- Vẫn **CHƯA CÓ** GNSS production owner, `TripLocationService`, one durable production SQLite writer, session/generation fence + ACK trong DB v3 thật, Android physical GNSS/FGS proof, APK test issue #2 hợp lệ, calibration/chứng nhận thu cước. TEST DEBUG không cấp phép thu cước.
- Tiếp theo: lấy CI Foundation PR đúng SHA của HEAD mới; nếu FAIL đọc lỗi đầu tiên theo job logs và sửa tối thiểu; nếu PASS tiếp tục kiểm thử callback đến trễ/thời điểm teardown và thiết kế service-owned GNSS/SQLite worker production theo ADR. Không sửa `navitaximeter_v1.db` v3, `navi_confirmed_tariffs_v1`, hóa đơn, main/TTX; không migration v4, không Billing/Paid API, không thu cước.

---

# CHU KỲ 6 — LƯỢT 3/7 · ISSUE #3 DEBUG ACK/WRITER FENCE · 16/11/2026

- **AI_REPLY_COUNT = 3/7** sau lượt này. Mọi lượt tiếp theo trong cùng chat tăng một; lượt 7 bắt buộc bàn giao đầy đủ 3.1–3.10 + Phụ lục A. Mốc 1/7 đã được ghi trước, lượt 2/7 gồm fix `4dac227f22816d1a0a9bcddf5ecb9f5dea174759` và harden callback teardown `b319d77c15969fd4cae4777d7d5898ffaea318b2`.
- Xác minh code baseline `b319d77c15969fd4cae4777d7d5898ffaea318b2`: Foundation PR run 43803533022 **SUCCESS** (cả build-test và Android14 emulator DEBUG), Zero Cost PR run 43803533033 **SUCCESS**; PR #1 OPEN/DRAFT/NOT MERGED; Issues #2/#3 OPEN. Đây KHÔNG phải GNSS production hoặc Android vật lý.
- **Lượt 3 thay đổi mã:** `347f50745bb8b80f799d4031b73c5e302271f674` thêm `HeadlessProbeCallbackFence.resolveIfWriterOwned`, kiểm tra writer lease tại **thời điểm trả ACK** trong cả đường Kotlin DEBUG checkpoint và isolated write/read; nếu mất lease thì không trả success, đóng checkpoint session fail-closed. Thêm 2 JVM tests cho mất lease, ACK đến trễ và callback thuộc engine cũ. Tệp: `android_native/HeadlessProbeCallbackFence.kt`, `HeadlessProbeCallbackFenceTest.kt`, `HeadlessSqliteProbeService.kt`.
- **Lỗi thực từ CI:** `347f5074` Foundation PR 43805338505 và Zero Cost PR 43805338478 **FAIL** tại `tool/test_bootstrap_android.py:test_headless_probe_never_targets_app_database`, do assertion còn yêu cầu `callbackFence.resolve(requestId, result, null)` dù code đã đổi sang `resolveIfWriterOwned`. Không phải lỗi GPS/SQLite production. Commit `67e80be7727a701aa57cc31e20802d482376c600` cập nhật assertion kiểm hai đường ACK, lease-at-delivery, và JVM test names. Zero Cost PR run **43805468386 SUCCESS**. Foundation PR run 43805468358 **PENDING** tại lần kiểm trước khi ghi tài liệu.
- **Lưu ý:** Sau commit tài liệu STATE, HEAD và CI run SHA thay đổi; phải kiểm tra SHA mới và không chuyển PASS của SHA code sang HEAD mới. Không ghi dữ liệu chuyến xe hoặc sửa schema v3, confirmed tariff, receipts; không Google Billing/Paid API; không main/TTX/merge.
- **Điểm tiếp tục:** xác minh Foundation theo HEAD mới, xem cả `:app:testDebugUnitTest`, `:app:assembleDebugAndroidTest`, Android14 executed XML; nếu FAIL lấy lỗi đầu tiên và sửa tối thiểu. Sau đó bổ sung proof native Android callback đến sau Service teardown/engine rebind, theo sau là single GNSS owner và durable production SQLite writer thực sự. Issue #2 physical Android **NOT TESTED / CHƯA THỂ TEST** nếu chưa có APK/sha256 và kịch bản Phụ lục A; không thu cước.


---

# CHU KỲ 6 — LƯỢT 7/7 · BÀN GIAO BẮT BUỘC · 16/11/2026

- **AI_REPLY_COUNT=7/7** sau hoàn tất câu trả lời này. **Handoff độc lập:** `docs/HANDOFF_2026-11-16_CYCLE6_7-7.md`, đọc 3.1–3.10, Phụ lục A nguyên văn và Phụ lục C; chat mới reset AI_REPLY_COUNT=0. Cùng chat lần kế là 8, bàn giao tiếp ở 14.
- **Đã trả lời yêu cầu chủ dự án:** Android GPS đã có `LocationManager.requestLocationUpdates` và Geolocator; quá nhiều lượt tập trung test-only/debug; **đổi ưu tiên Issue #2 physical ngay**. Không đánh đồng CI/emulator PASS với thiết bị thật.
- GitHub source baseline SHA `fff1c65ad2edad0ef90b8fde1da987ee0f6e8a24`, Foundation PR run `43811708123` SUCCESS **cả build-test và emulator**, Zero Cost PR run `43811708180` SUCCESS. PR #1 OPEN/DRAFT/NOT MERGED, issue #2 OPEN, issue #3 OPEN. Mọi CI sau commit handoff/docs phải so đúng SHA.
- **Đã tải artifact ZIP thật từ Github run 43811708123** (ID `14200424290`, debug), kiểm ZIP SHA-256 `363824f62aa6d02ed50c380a38f452a9fb182b8b2d42af123a529bc0fb623cd5` khớp GitHub; trích APK `app-debug.apk` (165929486 bytes) và kiểm SHA-256 `7ec6a8bbd39252cc27663566f6c280110ab23fb235a54fae71b6d73962dc540e`. Đã cung cấp link APK trực tiếp trong chat hiện tại, link sandbox có thể không portable. Không có kết quả test phone.
- File thử Android: `docs/ISSUE_2_REAL_ANDROID_TEST_START_2026-11-16.md` có A2-01..A2-06, đúng nút có thật, PASS/FAIL/NOT TESTED, che GPS coords, cách upload chat, không buộc ADB/PC. **Chưa thể đánh dấu Issue #2 PASS cho tới khi người dùng có máy Android thật và cung cấp bằng chứng.**
- Issue #3 vẫn chưa có `TripLocationService` GNSS production owner và service-owned durable trip SQLite writer hoặc ACK/migration dữ liệu thật. SQLite v3, pref `navi_confirmed_tariffs_v1`, immutable receipt, Zero Paid API, branch giới hạn/PR Draft không đổi; không cước khách. Kế tiếp hỏi còn thiếu đúng 1 điều kiện: có máy Android nào, model/OS gì; thử theo quickstart, đánh giá lỗi trước khi làm thêm mock GPS.
- Handoff này được commit bằng docs-only nên HEAD mới có thể không trùng code SHA; **phải kiểm live HEAD/CI mới**. Không dùng code run để dán nhãn docs run PASS.
