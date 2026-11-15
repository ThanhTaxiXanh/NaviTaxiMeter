# QUY TẮC CỨNG — BÀN GIAO DỰ ÁN SAU MỖI 7 LƯỢT TRẢ LỜI AI  
**Mức độ ưu tiên:** BẮT BUỘC — HARD RULE  
**Dự án áp dụng:** NaviTaxiMeter  
**Mục tiêu:** Đảm bảo không mất ngữ cảnh, mã nguồn, quyết định kỹ thuật, tiến độ và các công việc đang triển khai khi chuyển sang cuộc trò chuyện mới.  

  
⸻  

  
## 1. QUY TẮC ĐẾM BẮT BUỘC  
1. Bắt đầu mỗi cuộc trò chuyện mới với bộ đếm AI_REPLY_COUNT = 0.  
2. Mỗi lần AI hoàn tất một lượt trả lời cho người dùng, bộ đếm tăng đúng 1. Không tính tin nhắn của người dùng, kết quả công cụ hoặc các phần thuộc cùng một lượt trả lời thành nhiều lượt riêng.  
3. Tại các lượt trả lời **1, 2, 3, 4, 5, 6**, AI tiếp tục xử lý công việc bình thường.  
4. Tại **lượt trả lời thứ 7**, AI **BẮT BUỘC PHẢI TẠO BẢN BÀN GIAO DỰ ÁN ĐẦY ĐỦ**, ngay cả khi người dùng không yêu cầu.  
5. Nếu cuộc trò chuyện tiếp tục, quy tắc lặp lại tại các lượt **14, 21, 28, 35, 42…**  
6. Khi bắt đầu cuộc trò chuyện mới, bộ đếm được đặt lại về 0.  
7. AI không được tự ý bỏ qua quy tắc chỉ vì nhận thấy cuộc trò chuyện còn ngắn hoặc vẫn còn đủ ngữ cảnh.  
8. Quy tắc được áp dụng trong phạm vi chỉ dẫn mà AI thực sự nhận được và không được ghi đè các chỉ dẫn có mức ưu tiên cao hơn.  
**Công thức kiểm tra**  
```
AI_REPLY_COUNT + 1
```
Nếu kết quả chia hết cho 7:  
* Dừng việc khởi động các nhiệm vụ mới.  
* Tổng hợp toàn bộ thông tin dự án có thể truy cập.  
* Tạo BẢN BÀN GIAO DỰ ÁN.  
* Ghi nhãn: **BÀN GIAO BẮT BUỘC — LƯỢT 7/7**.  
* Cung cấp nội dung để người dùng sao chép sang cuộc trò chuyện mới.  
Nếu không chia hết cho 7:  
* Tiếp tục thực hiện yêu cầu hiện tại.  
* Duy trì thông tin phục vụ bàn giao.  
Sau mỗi lượt trả lời hoàn tất:  
```
AI_REPLY_COUNT = AI_REPLY_COUNT + 1
```

  
⸻  

  
## 2. CƠ CHẾ THEO DÕI BỘ ĐẾM  
AI phải theo dõi số lượt trả lời trong từng cuộc trò chuyện.  
Cuối các lượt trả lời thông thường, hiển thị:  
**Trạng thái bàn giao: [n/7]**  
Trong đó:  
* 1/7: Đã hoàn thành lượt thứ nhất.  
* 2/7: Đã hoàn thành lượt thứ hai.  
* 3/7: Đã hoàn thành lượt thứ ba.  
* 4/7: Đã hoàn thành lượt thứ tư.  
* 5/7: Đã hoàn thành lượt thứ năm.  
* 6/7: Đã hoàn thành lượt thứ sáu.  
* 7/7: Bắt buộc tạo bản bàn giao.  
Nếu môi trường AI có quyền ghi tệp, lưu trạng thái vào:  
```
docs/AI_HANDOFF_STATE.md
```
Tệp trạng thái cần ghi:  
* Số lượt trả lời đã hoàn tất.  
* Chu kỳ bàn giao hiện tại.  
* Thời điểm bàn giao gần nhất.  
* Công việc đang triển khai.  
* Điểm cần tiếp tục.  
**QUY ĐỊNH AN TOÀN:**  
Nếu AI không thể xác minh chính xác số lượt đã trả lời do thiếu lịch sử hoặc mất ngữ cảnh, AI không được tự bịa số lượt.  
Trong trường hợp này, AI phải chủ động tạo bản bàn giao sớm và ghi rõ:  
**Trạng thái đếm: KHÔNG XÁC MINH ĐƯỢC.**  

  
⸻  

  
## 3. NỘI DUNG BẢN BÀN GIAO BẮT BUỘC  
Đến lượt thứ 7, AI phải tạo bản bàn giao theo cấu trúc sau.  
**BẢN BÀN GIAO DỰ ÁN — NAVITAXIMETER**  
**Loại:** BÀN GIAO BẮT BUỘC — LƯỢT 7/7  
**Thời điểm:** [Ngày, giờ]  
**Trạng thái:** [Đang triển khai / Đang xử lý lỗi / Hoàn thành giai đoạn]  
**3.1. Tổng quan dự án**  
Phải trình bày:  
* Tên dự án.  
* Mục tiêu sản phẩm.  
* Đối tượng sử dụng.  
* Phạm vi phát triển.  
* Nền tảng triển khai.  
* Những nguyên tắc bắt buộc.  
**3.2. Yêu cầu cứng không được thay đổi**  
Ghi lại đầy đủ các yêu cầu mà người dùng đã xác nhận.  
Bao gồm:  
* Công nghệ và ngôn ngữ lập trình.  
* Kiến trúc hệ thống đã chốt.  
* Yêu cầu về giao diện.  
* Yêu cầu về hiệu năng.  
* Yêu cầu về dữ liệu.  
* Yêu cầu về bảo mật.  
* Yêu cầu về bản đồ và chủ quyền lãnh thổ Việt Nam.  
**Không được tự ý loại bỏ hoặc thay đổi yêu cầu cứng.**  
**3.3. Kiến trúc hệ thống**  
Phải ghi rõ:  
* Kiến trúc tổng thể.  
* Các module đang sử dụng.  
* Framework và SDK.  
* API và dịch vụ bên ngoài.  
* Công nghệ bản đồ.  
* Cơ chế online/offline.  
* Cấu trúc lưu trữ dữ liệu.  
* Quan hệ giữa các thành phần.  
Nếu có sơ đồ kiến trúc hoặc tài liệu thiết kế, phải ghi lại đường dẫn.  
**3.4. Công việc đã hoàn thành**  
Liệt kê chính xác:  
* Chức năng đã xây dựng.  
* Module đã hoàn thành.  
* Mã nguồn đã tạo.  
* Tệp đã sửa.  
* Cấu hình đã thiết lập.  
* Kết quả kiểm thử.  
* Những lỗi đã khắc phục.  
Phải phân biệt giữa:  
**ĐÃ HOÀN THÀNH VÀ KIỂM CHỨNG**  
và  
**ĐÃ VIẾT NHƯNG CHƯA KIỂM THỬ**  
Không được tự nhận hoàn thành nếu chưa có căn cứ.  
**3.5. Công việc đang triển khai**  
Phải ghi rõ:  
* Công việc hiện tại.  
* Tiến độ thực tế.  
* Phần đã thực hiện.  
* Phần chưa thực hiện.  
* Thao tác gần nhất.  
* Tệp đang chỉnh sửa.  
* Bước tiếp theo chính xác.  
**Đặc biệt quan trọng:** AI ở cuộc trò chuyện mới phải biết tiếp tục từ đâu, không phải làm lại từ đầu.  
**3.6. Lỗi và vấn đề chưa giải quyết**  
Ghi lại:  
* Lỗi đang tồn tại.  
* Thông báo lỗi.  
* Nguyên nhân đã xác định.  
* Nguyên nhân nghi ngờ.  
* Giải pháp đã thử.  
* Kết quả thử nghiệm.  
* Hướng xử lý tiếp theo.  
Không được giấu lỗi hoặc tự nhận lỗi đã được khắc phục.  
**3.7. Mã nguồn và tệp quan trọng**  
Phải liệt kê:  
* Thư mục dự án.  
* Tệp cấu hình.  
* Tệp mã nguồn chính.  
* Tệp dữ liệu.  
* Tệp bản đồ.  
* Tệp kiểm thử.  
* Tệp tài liệu.  
* Lệnh build và chạy ứng dụng.  
Nếu có mã nguồn quan trọng mà AI mới không thể truy cập, phải nêu rõ cần cung cấp lại.  
Không được bịa tên tệp hoặc đường dẫn.  
**3.8. Quyết định kỹ thuật đã thống nhất**  
Phải lưu giữ:  
* Các lựa chọn công nghệ.  
* Giải pháp đã được chấp thuận.  
* Những phương án đã loại bỏ.  
* Lý do đưa ra quyết định.  
* Những giới hạn đã thống nhất.  
AI mới không được tự ý thay đổi kiến trúc chỉ vì có phương án khác.  
**3.9. Kế hoạch tiếp tục**  
Phải đưa ra danh sách công việc theo thứ tự ưu tiên.  
Mỗi công việc cần có:  
* Mục tiêu.  
* Thành phần liên quan.  
* Các bước thực hiện.  
* Kết quả mong đợi.  
* Tiêu chí kiểm thử.  
Ưu tiên hoàn thành phần đang dang dở trước khi mở rộng chức năng.  
**3.10. Chỉ thị bắt buộc cho AI ở cuộc trò chuyện mới**  
AI tiếp nhận phải tuân thủ:  
1. Đọc toàn bộ bản bàn giao.  
2. Giữ nguyên yêu cầu cứng.  
3. Giữ nguyên kiến trúc đã thống nhất, trừ khi người dùng yêu cầu thay đổi.  
4. Không tự ý thiết kế lại dự án.  
5. Không yêu cầu người dùng nhắc lại những thông tin đã có trong bản bàn giao.  
6. Kiểm tra trạng thái mã nguồn thực tế khi có thể.  
7. Phân biệt dữ liệu đã xác minh và thông tin chưa kiểm chứng.  
8. Tiếp tục công việc từ đúng điểm đang dở.  
9. Đặt lại bộ đếm AI_REPLY_COUNT = 0.  
10. Tiếp tục thực hiện quy tắc bàn giao sau mỗi 7 lượt trả lời.  

  
⸻  

  
## 4. QUY ĐỊNH CẤM KHI BÀN GIAO  
AI tuyệt đối không được:  
* Chỉ tạo bản tóm tắt sơ sài.  
* Bỏ qua các quyết định kỹ thuật quan trọng.  
* Bỏ qua những lỗi chưa được xử lý.  
* Quên công việc đang thực hiện.  
* Tự ý thay đổi kiến trúc.  
* Bịa ra mã nguồn, đường dẫn hoặc kết quả kiểm thử.  
* Tuyên bố công việc hoàn thành khi chưa xác minh.  
* Đưa mật khẩu, access token, khóa API hoặc bí mật vào bản bàn giao.  
* Giả định cuộc trò chuyện mới tự động truy cập được toàn bộ tệp và lịch sử cũ.  
* Kết thúc bản bàn giao mà không xác định bước tiếp theo.  

  
⸻  

  
## 5. YÊU CẦU RIÊNG CHO NAVITAXIMETER  
Bản bàn giao phải bảo toàn những yêu cầu dự án đã được xác nhận.  
**5.1. Nền tảng**  
* Phát triển Android trước.  
* Sử dụng Flutter/Kotlin theo kiến trúc đã thống nhất.  
* Chỉ mở rộng sang iOS sau khi phiên bản Android đạt trạng thái ổn định.  
**5.2. Hệ thống bản đồ**  
* Bản đồ Việt Nam online/offline.  
* Hiển thị bản đồ 2D/3D.  
* Hiển thị công trình, tòa nhà 3D.  
* Hệ thống đường và làn đường.  
* Mũi tên hướng di chuyển.  
* Biển báo giao thông.  
* Giới hạn tốc độ.  
* Tìm kiếm địa chỉ và POI.  
* Tính toán và hiển thị tuyến đường.  
* Các dữ liệu GIS và Mapillary đã được tích hợp hoặc đang triển khai.  
Phải phân biệt rõ chức năng đã hoàn thành và chức năng mới nằm trong kế hoạch.  
**5.3. Yêu cầu về chủ quyền Việt Nam**  
Bảo toàn nguyên văn các yêu cầu hiển thị do người dùng xác nhận:  
* Bản đồ phải thể hiện chủ quyền lãnh thổ và biển đảo của Việt Nam.  
* Phải thể hiện Hoàng Sa và Trường Sa thuộc Việt Nam.  
* Phải sử dụng tên gọi **Biển Đông**.  
* Không hiển thị tên hoặc ranh giới do quốc gia khác tuyên bố là lãnh thổ của họ trái với yêu cầu hiển thị đã chốt.  
* Nếu phát hiện dữ liệu, nhãn hoặc ranh giới không phù hợp, phải sửa style hoặc pipeline tile và chạy kiểm thử chủ quyền.  
Phải ghi rõ trạng thái kiểm thử thực tế, không tuyên bố đã kiểm chứng khi chưa thực hiện.  
**5.4. Tính liên tục của mã nguồn**  
Mỗi bản bàn giao phải bảo toàn:  
* Những module đã hoàn thành.  
* Module đang phát triển.  
* Các API đã tích hợp.  
* Đường dẫn dữ liệu.  
* Cấu hình bản đồ.  
* Quyết định kiến trúc.  
* Lỗi đang tồn tại.  
* Các bước triển khai tiếp theo.  

  
⸻  

  
## 6. TIÊU CHÍ HOÀN THÀNH BÀN GIAO  
Một bản bàn giao chỉ đạt yêu cầu khi người dùng có thể sao chép toàn bộ nội dung sang cuộc trò chuyện mới và AI tiếp nhận biết rõ:  
1. Dự án đang xây dựng cái gì.  
2. Những yêu cầu nào tuyệt đối không được tự ý thay đổi.  
3. Công nghệ và kiến trúc hiện tại.  
4. Những việc đã hoàn thành.  
5. Những việc đang triển khai.  
6. Những lỗi chưa khắc phục.  
7. Những tệp và dữ liệu cần sử dụng.  
8. Những quyết định kỹ thuật phải giữ nguyên.  
9. Công việc tiếp theo cần thực hiện.  
10. Quy tắc tiếp tục bàn giao ở lượt thứ 7.  

  
⸻  

  
## 7. CÂU LỆNH KHỞI ĐỘNG CUỘC TRÒ CHUYỆN MỚI  
Khi người dùng đưa bản bàn giao vào cuộc trò chuyện mới, AI phải thực hiện theo chỉ thị:  
**“Hãy tiếp quản dự án NaviTaxiMeter dựa trên toàn bộ BẢN BÀN GIAO DỰ ÁN được cung cấp.**  
**Không bỏ sót bất kỳ yêu cầu cứng nào. Không tự ý thay đổi kiến trúc đã được thống nhất. Không làm lại những phần đã hoàn thành nếu không có lý do kỹ thuật được xác minh.**  
**Hãy xác định chính xác công việc còn dang dở và tiếp tục triển khai từ điểm đó.**  
**Đồng thời khởi tạo lại bộ đếm AI_REPLY_COUNT = 0 và tiếp tục áp dụng quy tắc bắt buộc: Sau mỗi 6 lượt trả lời thông thường, lượt thứ 7 phải tạo BẢN BÀN GIAO DỰ ÁN mới.”**  

  
⸻  

  
## 8. CHỈ THỊ CUỐI CÙNG — HARD RULE  
**SAU MỖI 6 LƯỢT AI TRẢ LỜI THÔNG THƯỜNG, LƯỢT THỨ 7 BẮT BUỘC PHẢI TẠO BẢN BÀN GIAO DỰ ÁN ĐẦY ĐỦ.**  
**KHÔNG CẦN NGƯỜI DÙNG NHẮC.**  
**KHÔNG ĐƯỢC CỐ Ý BỎ QUA.**  
**KHÔNG ĐƯỢC TÓM TẮT SƠ SÀI.**  
**KHÔNG ĐƯỢC LÀM MẤT TIẾN ĐỘ DỰ ÁN.**  
**QUY TẮC ĐƯỢC LẶP LẠI SAU MỖI 7 LƯỢT TRẢ LỜI TRONG CÙNG CUỘC TRÒ CHUYỆN.**  
**MỤC TIÊU CAO NHẤT: ĐẢM BẢO DỰ ÁN NAVITAXIMETER ĐƯỢC PHÁT TRIỂN LIÊN TỤC, NHẤT QUÁN VÀ CÓ THỂ BÀN GIAO GIỮA CÁC CUỘC TRÒ CHUYỆN MÀ KHÔNG BỊ MẤT THÔNG TIN QUAN TRỌNG.**  


---

## 9. QUY TẮC CỨNG BỔ SUNG: HƯỚNG DẪN KIỂM THỬ/KIỂM CHỨNG TRÊN ĐIỆN THOẠI
**Ngày bổ sung:** 15/11/2026. **Mức độ ưu tiên:** BẮT BUỘC, áp dụng xuyên suốt NaviTaxiMeter và mọi chu kỳ bàn giao 7 lượt.

**Nguyên văn yêu cầu của chủ dự án:**
> Nếu muốn tôi kiểm thử hay kiểm chứng trên điện thoại thì phải hướng dẫn chi tiết, kiểm thử cái gì, kiểm chứng cái gì, làm thế nào để cho bạn biết là đã kiểm thử hay kiểm chứng thành công để đưa cho bạn xem.

**Quy tắc thực thi cho AI:**
1. Mỗi khi nhờ chủ dự án kiểm thử/kiểm chứng trên điện thoại, **bắt buộc cung cấp một quy trình thao tác cụ thể, theo từng bước**, phù hợp người dùng chủ yếu vận hành qua điện thoại, không mặc nhiên có máy tính hoặc ADB.
2. Trước khi thao tác, ghi rõ **mục tiêu đang kiểm thử**, chức năng/rủi ro cần kiểm chứng, mã commit SHA, loại bản Android APK (DEBUG/RELEASE), link GitHub Actions/artifact khi đã xác minh, điều kiện tiên quyết, Android/OEM và trạng thái quyền GPS cần quan sát. Không đặt link/artifact không tồn tại, không nhận CI PASS thay cho kiểm thử điện thoại thật.
3. Hướng dẫn **cách tải, cài và mở đúng bản APK thử nghiệm**, có cảnh báo về nguồn tải hoặc giới hạn cài đặt; hướng dẫn chính xác nút/màn/tab cần mở, thứ tự bấm, thời gian chờ hoặc dấu hiệu nhìn thấy. Nếu chưa có đúng bản APK hoặc tính năng kiểm chứng thì ghi **CHƯA THỂ TEST**, không yêu cầu bấm nút giả định.
4. Với **mỗi ca test**, trình bày: (a) đang thử điều gì; (b) từng bước thao tác; (c) **kết quả mong đợi (PASS)**; (d) dấu hiệu **FAIL** và lúc nào phải dừng; (e) cách xử lý nếu không thấy nút hoặc màn hình khác tài liệu. Không dùng chỉ dẫn mơ hồ như “thử GPS rồi báo lại”.
5. Ghi rõ **cần thu thập bằng chứng gì**, chụp ảnh màn hình/video/ghi lại biểu hiện ở đúng bước, cách tìm phiên bản Android và model thiết bị, thời gian test, quyền vị trí, tình trạng khóa màn hình, mã APK/run/SHA. Có thể dùng checklist ngắn để người dùng chỉ việc điền **PASS / FAIL / NOT TESTED** và mô tả điều quan sát thực tế.
6. Hướng dẫn **gửi bằng chứng về cho AI** ngay trong cuộc trò chuyện: đính kèm ảnh/video hoặc văn bản, kèm mã ca test, bước số, kết quả quan sát được và thông tin máy/phiên bản Android đã kiểm tra. AI phải nêu tiêu chí để đối chiếu và **chỉ công nhận PASS sau khi bằng chứng đủ rõ**; nếu chưa đủ thì đánh dấu **CHƯA XÁC MINH**, chỉ yêu cầu bổ sung phần thiếu.
7. **Quy tắc riêng về bảo mật:** ảnh/video/log phải che hoặc cắt bỏ tọa độ, địa chỉ nhà, hành trình khách, số tài khoản ngân hàng, thông báo riêng tư, mã token, API key, keystore và dữ liệu cá nhân. Không yêu cầu đăng công khai bằng chứng nhạy cảm lên GitHub; không thu phí khách, không dùng hành khách thật để thử; nếu hành vi GPS/FGS không an toàn thì dừng ngay.
8. Luôn phân biệt **“đã chạy thao tác”**, **“người dùng báo PASS”**, **“AI đã đối chiếu bằng chứng”**, **“CI PASS”** và **“Android vật lý được kiểm chứng”**. Chưa quan sát được không được suy diễn là PASS. Nếu test FAIL, ghi nguyên hiện tượng, bước tái hiện và điều kiện; không đánh dấu issue #2 hoặc #3 hoàn tất trước khi có bằng chứng đầy đủ.
9. Khi có bản bàn giao 7/7, **phải chép nguyên vẹn quy tắc bổ sung này hoặc liên kết kèm đầy đủ văn bản và nhắc bắt buộc** trong mục 3.2, 3.9 và 3.10 để AI tiếp quản áp dụng từ lượt đầu tiên. Bản quy tắc phải lưu trong repository NaviTaxiMeter trên nhánh được phép, không sửa TTX/main.

**Mẫu tối thiểu cho mỗi yêu cầu test điện thoại:** `Mã ca | Mục tiêu | APK/SHA | Chuẩn bị | Bước 1,2,3... | PASS khi | FAIL khi | Bằng chứng cần chụp | Cách gửi AI | Kết quả PASS/FAIL/NOT TESTED`.

**Quy tắc này không cấp phép triển khai production:** vẫn giữ Zero Paid API, single GNSS owner, fail-closed/PAUSED, không Billing, không thương mại và không merge main.