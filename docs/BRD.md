# TÀI LIỆU YÊU CẦU NGHIỆP VỤ (BUSINESS REQUIREMENT DOCUMENT - BRD)

Dưới đây là tài liệu đặc tả nghiệp vụ (BRD) hoàn chỉnh, số hóa các nguyên lý của Liệu pháp Nhận thức Hành vi (CBT) thành kịch bản hệ thống với các con số chính xác.

---

## PHẦN 1: QUẢN LÝ DỮ LIỆU & GIÁM SÁT RỦI RO (SAFETY PROTOCOL)

### 1. Cơ chế Ẩn danh (Display Anonymity)
*   **Backend:** Bắt buộc lưu trữ SĐT/Email thật để bảo mật và phục vụ giao thức can thiệp khẩn cấp.
*   **Frontend/CMS:** Hiển thị ẩn danh (Tên giả, Avatar mặc định, mã định danh VD: Bệnh nhân #1024) đối với Tình nguyện viên/Bác sĩ theo dõi hàng ngày để giảm rào cản tâm lý và nỗi sợ bị phán xét.
*   **Phá vỡ ẩn danh (Override):** Chỉ khi Hệ thống bật "Cờ đỏ" báo động tự sát, Bác sĩ Trưởng (Super Admin) mới được quyền giải mã xem SĐT thật để gọi điện cứu hộ.

### 2. Công thức tính Điểm rủi ro ngầm (Risk Index: 0 - 100 điểm)
Hệ thống tính điểm hàng ngày dựa trên 3 biến số:
*   **40% từ PHQ-9:** Quét Câu 9 (Ý định tự hại) và Câu 2 (Tuyệt vọng). Nếu Câu 9 có điểm > 0 → **Max 100 điểm**.
*   **40% từ AI NLP quét Nhật ký:** Quét 3 nhóm Niềm tin cốt lõi (Bất lực, Không thể yêu thương, Vô giá trị). Mức 70 điểm nếu có cụm từ bế tắc cùng cực; Mức 100 điểm nếu có từ khóa tự sát/cái chết.
*   **20% từ Xu hướng Tâm trạng (Mood Trend):** Nếu trung bình chấm điểm tâm trạng 3 ngày liên tiếp < 20% → **Max 100 điểm**.

⚠️ **Luật ghi đè khẩn cấp (Override Rule):** Nếu AI quét thấy từ khóa tự sát HOẶC Câu 9 PHQ-9 > 0 → Lập tức gán `Risk Index = 100 điểm`.

🚀 **Trigger (Cò súng):** Khi `Risk Index ≥ 70`, hệ thống lập tức bật Cờ đỏ trên CMS của bác sĩ và kích hoạt bài test PHQ-9 đột xuất (TRIGGERED) cùng luồng Cứu trợ Telehealth trên app bệnh nhân.

---

## PHẦN 2: LỘ TRÌNH 3 GIAI ĐOẠN TRỊ LIỆU (USER JOURNEY)

### GIAI ĐOẠN 1: KHỞI ĐẦU & THIẾT LẬP (ONBOARDING)
*   **Thời điểm:** Duy nhất ngày đầu tiên cài App.
*   **Đánh giá Baseline (Đường cơ sở):** Bệnh nhân làm bài test PHQ-9 đầu vào (Lưu Database: `submission_type = BASELINE`).
*   **Thiết lập mục tiêu (Goal Setting):** Chọn 3 đến 5 mục tiêu hành vi cụ thể (VD: Cải thiện giấc ngủ, Bớt lo âu khi đi thi).
*   **Giáo dục tâm lý (Psychoeducation):** AI hướng dẫn ngắn (< 5 phút) về Mô hình Nhận thức: Tình huống → Suy nghĩ → Cảm xúc → Hành vi.

### GIAI ĐOẠN 2: VÒNG LẶP TRỊ LIỆU HÀNG NGÀY (DAILY LOOP)
*   **Thời điểm:** Kéo dài tối thiểu 4 tuần. Mỗi ngày chỉ tốn 5-15 phút.
*   **Bước 1 - Mood Check-in:** Chấm điểm tâm trạng (0-100%) ngay khi mở app.
*   **Bước 2 - AI Rẽ nhánh:**
    *   **Tâm trạng Tệ (< 45%):** AI rủ viết Nhật ký suy nghĩ (Thought Record). AI nhận diện Lỗi tư duy và dùng 1-2 câu hỏi Socratic để bệnh nhân tự phản biện.
    *   **Tâm trạng Tốt (≥ 45%):** AI rủ viết Danh sách ghi nhận (Credit List) để tự khen ngợi tiến bộ.
*   **Bước 3 - Chọn vấn đề (Agenda Setting):** Bệnh nhân chỉ chọn 1 vấn đề duy nhất cần giải quyết trong ngày để tránh quá tải.
*   **Bước 4 - Phân bổ Bài tập (Homework Roadmap):**
    *   *Giới hạn:* Hệ thống tự động giao tối đa 1 - 2 task/ngày, mỗi task 5 - 15 phút.
    *   *Thuật toán phân bổ theo điểm PHQ-9 (áp dụng cho chu kỳ 14 ngày):*
        *   **Nếu PHQ-9 ≥ 15 (Trầm cảm nặng):** Hệ thống tự bốc **80% bài tập Hành vi** (dọn dẹp, đi dạo 10p để kích hoạt năng lượng), **20% bài tập Nhận thức thụ động** (chỉ cần đọc Thẻ đối phó).
        *   **Nếu PHQ-9 < 15 (Trầm cảm vừa/nhẹ):** Hệ thống tự bốc **50% Hành vi** (giao tiếp xã hội), **50% Nhận thức chủ động** (Tự viết Nhật ký suy nghĩ, tìm bằng chứng).
*   **Bước 5 - Khóa thời gian & Đánh giá định kỳ:** Cứ đúng 14 ngày/lần, app mở khóa bài test PHQ-9 (Lưu Database: `submission_type = PERIODIC`).
*   **Điều kiện Tốt nghiệp (Chuyển sang Giai đoạn 3):** Cần 2 lần đánh giá định kỳ LIÊN TIẾP đạt điểm PHQ-9 < 5 (Mức MINIMAL). Lộ trình này tốn tối thiểu 4 tuần.

### GIAI ĐOẠN 3: KẾT THÚC & PHÒNG NGỪA TÁI PHÁT (TERMINATION)
*   **Thời điểm:** Bắt đầu ngay khi bệnh nhân đạt Điều kiện tốt nghiệp.
*   **Bước 1 - Quy gán sự tiến bộ:** AI hiện biểu đồ Progress Graph (So sánh PERIODIC với BASELINE) và khẳng định *"Chính nỗ lực thay đổi của bạn đã tạo ra kết quả này"* để tăng self-efficacy.
*   **Bước 2 - Lưới an toàn Thẻ đối phó:** Chèn thẻ dặn dò: *"Thụt lùi (Setbacks) là bình thường. Nếu buồn lại, hãy mở app ra viết Nhật ký"*.
*   **Bước 3 - Giãn cách tần suất bài tập (Tapering Off):**
    *   *Tháng đầu sau tốt nghiệp:* AI nhắc làm bài tập 1 lần/tuần.
    *   *Tháng 2 đến Tháng 6:* AI nhắc 1 lần/tháng.
    *   *Sau 6 tháng:* AI nhắc 1 lần/quý.
*   **Bước 4 - Phiên củng cố (Booster Sessions):**
    *   *Lịch cố định:* App tự động nhắc đặt lịch phiên củng cố vào đúng 3 mốc: 3 tháng, 6 tháng, và 12 tháng sau tốt nghiệp.
    *   *Giám sát ngầm (Ad-hoc):* Nếu bệnh nhân vào app viết linh tinh và AI quét thấy Điểm rủi ro (Risk Index) ≥ 70, CMS báo Cờ đỏ, bắt buộc yêu cầu đặt Phiên củng cố khẩn cấp.

---

## PHẦN 3: CẤU TRÚC DATABASE BẢNG ĐÁNH GIÁ (PHQ-9 SUBMISSION)

Bảng `phq9_submissions` cần có 2 trường dữ liệu quan trọng để phục vụ biểu đồ và luồng cảnh báo:

### 1. `submission_type` (Hoàn cảnh nộp bài)
*   `BASELINE`: Test lần đầu tiên ở Ngày 1 (Mốc số 0).
*   `PERIODIC`: Test định kỳ theo chu kỳ 14 ngày/lần. Dùng để vẽ biểu đồ và xét điều kiện tốt nghiệp.
*   `TRIGGERED`: Test đột xuất do AI kích hoạt ép buộc khi `Risk Index ≥ 70`.

### 2. `severity_level` (Mức độ nghiêm trọng y khoa)
*   `MINIMAL` (0-4 điểm): Bình thường → Điều kiện cần để Tốt nghiệp (Hiển thị UI Xanh).
*   `MILD` (5-9 điểm): Nhẹ → Giao 50% Hành vi / 50% Nhận thức.
*   `MODERATE` (10-14 điểm): Trung bình → Giao 50% Hành vi / 50% Nhận thức (Hiển thị UI Vàng).
*   `MODERATELY_SEVERE` (15-19 điểm): Trung bình nặng → Giao 80% Hành vi / 20% Nhận thức (Hiển thị UI Cam).
*   `SEVERE` (20-27 điểm): Nặng → Cảnh báo đỏ cho Bác sĩ (Hiển thị UI Đỏ).

---

## PHẦN 4: NGHIỆP VỤ HỆ THỐNG ADMIN

### 1. Nghiệp vụ Đăng nhập (Xác thực)
*   **Tài khoản cứng:** Sử dụng tài khoản cấu hình sẵn (VD: `admin` / `admin`).
*   **Bỏ qua các luồng phụ:** Không làm chức năng Đăng ký (Register) hay Quên mật khẩu cho Admin. Đăng nhập thành công sẽ đi thẳng vào màn hình Dashboard.

### 2. Nghiệp vụ Quản lý Bệnh nhân (Patient Management)
*   **Xem danh sách:** Truy xuất và hiển thị toàn bộ người dùng có phân quyền là Bệnh nhân (`role = PATIENT`).
*   **Khóa/Mở khóa tài khoản (Block/Unblock):** Admin có quyền thay đổi trạng thái hoạt động (`is_active = true/false`). Dùng cho kịch bản bệnh nhân vi phạm chính sách cộng đồng hoặc yêu cầu vô hiệu hóa tài khoản.

### 3. Nghiệp vụ Quản lý Bác sĩ/Tình nguyện viên (Therapist Management - Quan trọng nhất)
*   **Xem danh sách đăng ký:** Hiển thị danh sách các chuyên gia/bác sĩ tạo tài khoản trên hệ thống (`role = THERAPIST`).
*   **Kiểm duyệt hồ sơ (Approval Process):**
    *   Trạng thái mặc định khi bác sĩ mới đăng ký là chờ duyệt (`approval_status = PENDING`).
    *   **Duyệt (Approve):** Admin đổi trạng thái sang `ACTIVE` → Bác sĩ chính thức được phép đăng nhập, quản lý lịch hẹn và theo dõi Cờ Đỏ của bệnh nhân.
    *   **Từ chối (Reject):** Admin đổi trạng thái sang `REJECTED` → Không cấp quyền truy cập.

---

## 💡 LƯU Ý LÂM SÀNG CỐT LÕI

### 1. Điểm Mood Check-in CÓ LÀM THAY ĐỔI Roadmap bài tập không?
Câu trả lời là **KHÔNG**. Sự tách biệt hoàn toàn giữa hai chỉ số này đảm bảo tính khoa học:
*   **Roadmap Bài tập (Kế hoạch 14 ngày):** Tỷ lệ phân bổ bài tập (80% Hành vi/20% Nhận thức hay 50/50) chỉ bị thay đổi bởi điểm số **PHQ-9**, và nó được "chốt cứng" cho một chu kỳ 14 ngày. Cho dù trong ngày hôm đó bệnh nhân có chấm điểm Mood lên xuống 10 lần, số lượng và loại bài tập (Task) được giao trong Roadmap ngày hôm đó vẫn giữ nguyên để đảm bảo tính kỷ luật và không làm người bệnh quá tải.
*   **Điểm Mood Check-in (Tâm trạng hàng ngày):** Điểm này chỉ dùng để phục vụ 2 việc:
    1.  Cộng dồn để tính Điểm Rủi ro (`Risk Index`) trung bình 3 ngày.
    2.  Quyết định gợi ý tức thời của AI (AI Suggestion) ngay tại thời điểm đó (Dưới 45% thì AI rủ viết Nhật ký suy nghĩ thầm kín, trên 45% thì AI rủ viết Danh sách ghi nhận).

### 2. Tại sao Luồng Cập Nhật Tâm Trạng Chủ Động (Tâm trạng tệ đi) bắt buộc phải có?
Về mặt cơ sở khoa học của Liệu pháp Nhận thức Hành vi (CBT), đây chính là linh hồn của toàn bộ ứng dụng. Bệnh nhân phải được rèn luyện kỹ năng tự hỏi: *"Điều gì vừa xẹt qua đầu mình?"* ngay tại khoảnh khắc họ nhận thấy tâm trạng của mình đang thay đổi hoặc tồi tệ đi.
*   Nếu bỏ luồng này, app sẽ chỉ là một cái app "đo lường tâm trạng" thụ động đơn thuần (sáng dậy hỏi hôm nay thế nào rồi thôi).
*   Giả sử 2 giờ chiều bệnh nhân gặp biến cố, tâm trạng chạm đáy và nguy cơ tự hại tăng cao. Nếu không có nút cập nhật tâm trạng chủ động để kích hoạt ngay lúc đó, AI sẽ không biết để kịp thời rủ viết Nhật ký suy nghĩ (Thought Record) và hỏi Socratic để phản biện xoa dịu cảm xúc bế tắc.
