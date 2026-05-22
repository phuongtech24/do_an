# TÀI LIỆU ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS)
**Tiêu chuẩn:** IEEE 830-1998
**Tên dự án:** Re-Connect Platform (Nền tảng Hỗ trợ Tâm lý chuẩn CBT tích hợp Trí tuệ Nhân tạo)

---

## 1. GIỚI THIỆU (INTRODUCTION)

### 1.1 Mục đích (Purpose)
Tài liệu Đặc tả Yêu cầu Phần mềm (Software Requirements Specification - SRS) này cung cấp cái nhìn toàn diện về nền tảng Re-Connect. Tài liệu miêu tả chính xác hành vi của hệ thống, bao gồm các tính năng chức năng (Functional Requirements) được chia làm 11 Module, quy trình rẽ nhánh điều trị và các yêu cầu phi chức năng (Non-Functional Requirements) để làm cơ sở cho quá trình lập trình và nghiệm thu đồ án/sản phẩm.

### 1.2 Phạm vi dự án (Project Scope)
Re-Connect là một hệ thống phần mềm vận hành theo mô hình B2B2C (Business-to-Business-to-Consumer), cung cấp giải pháp Trị liệu Nhận thức Hành vi số hóa (dCBT).
- **Thành phần phần mềm:** Bao gồm 01 ứng dụng di động (Mobile App) cho Bệnh nhân, 01 Cổng thông tin Web (Web CMS) cho Bác sĩ Tâm lý và Admin, cùng với 01 Hệ thống Backend Spring Boot làm xương sống.
- **Tính năng cốt lõi:** Trò chơi hóa lộ trình trị liệu (Gamification), phân tích ngôn ngữ tự nhiên bằng Google Gemini AI để cảnh báo rủi ro tự động, và luồng rẽ nhánh linh hoạt giữa Tự trị liệu (Bệnh nhân) và Có can thiệp chuyên sâu (Bác sĩ cấp Nhiệm vụ).

### 1.3 Thuật ngữ & Chữ viết tắt (Definitions, Acronyms, and Abbreviations)
- **CBT (Cognitive Behavioral Therapy):** Liệu pháp Nhận thức Hành vi.
- **Gamification:** Việc áp dụng các cơ chế trò chơi vào bối cảnh phi trò chơi (y tế) để tạo động lực.
- **Time-Gating:** Cơ chế khóa thời gian, ép người dùng thực hiện nhiệm vụ theo đúng chu kỳ (VD: 24h).
- **LLM / Gemini API:** Mô hình Ngôn ngữ lớn của Google, sử dụng làm động cơ phân tích cảm xúc (Sentiment Engine).

---

## 2. MÔ TẢ CHUNG OVERALL DESCRIPTION)

### 2.1 Đặc tả Đối tượng Người dùng (User Classes and Characteristics)
Toàn bộ hệ thống được phân quyền phân tách nghiêm ngặt:
1. **Patient (Bệnh nhân):** Sử dụng thiết bị di động cá nhân (Smartphone). Giao tiếp với hệ thống trong trạng thái ẨN DANH (dùng Avatar và Nickname ảo). 
2. **Therapist (Chuyên gia Tham vấn / Bác sĩ):** Sử dụng Web CMS. Theo dõi tiến độ trị liệu của bệnh nhân được phân công, giám sát cảnh báo "Cờ Đỏ" (Risk Index >= 70) và thực hiện tham vấn Telehealth khẩn cấp.
3. **Clinic Admin (Quản trị viên / Doanh nghiệp):** Sử dụng Web CMS. Quản lý việc phê duyệt tài khoản bác sĩ, khóa/mở khóa tài khoản bệnh nhân, quản trị kho dữ liệu nội dung Nhiệm vụ mẫu (Quest Templates).

### 2.2 Sơ đồ Luồng Nghiệp vụ Rẽ nhánh (Business Logic Workflow)
Mặc định mọi bệnh nhân được tiếp cận theo hướng "Tự trị liệu" (Gamification). 
- Động cơ AI chạy ngầm đằng sau phân tích nhật ký của họ mỗi ngày. 
- Nếu thuật toán `Risk Index` > Ngưỡng cho phép &rarr; Kích hoạt Cảnh báo gửi đến Bác sĩ. 
- Bác sĩ bấm "Yêu cầu Tham vấn" (Trigger Consultation) &rarr; Chặn App người dùng, chuyển sang quy trình Đặt lịch Telehealth. 
- Sau phiên khám, hệ thống đưa vào trạng thái **COOLDOWN (Thời gian chờ 3 ngày)**, ẩn đi mọi lộ trình nặng để bình ổn tâm lý.

---

## 3. YÊU CẦU ĐẶC TẢ CHỨC NĂNG (SYSTEM FEATURES / FUNCTIONAL REQUIREMENTS)

### PHẦN I: GIAO DIỆN END-USER (MOBILE APP CHO BỆNH NHÂN)

**3.1 Module 1: Xác thực & Khởi tạo (Auth & Onboarding)**
- **FR 1.1 - Đăng kí Ẩn danh:** Bệnh nhân chỉ sử dụng Nickname và Avatar ngẫu nhiên (Động/thực vật) để mã hóa danh tính.
- **FR 1.2 - Sàng lọc Baseline:** Hệ thống bắt buộc thực hiện bài trắc nghiệm PHQ-9 tiêu chuẩn trước khi truy cập bất kỳ tính năng nào. Hệ thống lưu điểm với `submission_type = 'BASELINE'`. Riêng `q9_score` và `q2_score` phải được lưu riêng (không chỉ lưu `total_score`) để phục vụ Override Rule của thuật toán Risk Index.
- **FR 1.3 - Goal Setting:** Sau PHQ-9, bệnh nhân bắt buộc chọn **3–5 mục tiêu cá nhân** từ danh sách gợi ý. Dữ liệu lưu vào `patient_profiles.goals_json`. AI tham chiếu danh sách này khi dẫn dắt Nhật ký.
- **FR 1.4 - Psychoeducation Cards:** Hệ thống hiển thị chuỗi thẻ thông tin về Mô hình Nhận thức (Tình huống → Suy nghĩ → Cảm xúc → Hành vi). Bệnh nhân phải swipe hết thẻ (xác nhận đã đọc) trước khi mở khóa Daily Loop.

**3.2 Module 2: Mood Check-in & Nhật ký AI (Daily Loop)**
- **FR 2.0 - Mood Check-in Hàng ngày:** Mỗi ngày, trước khi vào bất kỳ tính năng nào, bệnh nhân được nhắc **chấm điểm tâm trạng (0–100%)**. Dữ liệu lưu vào bảng `user_moods`. Điểm này là Biến số 3 trong công thức Risk Index.
- **FR 2.1 - Rẽ nhánh Mood:** Nếu `mood_score >= 50%` → AI mời viết **Credit List** (Danh sách ghi nhận). Nếu `mood_score < 50%` → AI mời viết **Thought Record** (Nhật ký suy nghĩ) và kích hoạt Guided Discovery.
- **FR 2.2 - Giao diện Nhắn tin (Multimodal):** Hỗ trợ nhập liệu bằng văn bản và thu âm giọng nói (Speech-to-Text).
- **FR 2.3 - AI Khám phá Dẫn dắt (Guided Discovery):** Trong luồng Thought Record, AI nhận diện Lỗi tư duy (Cognitive Distortions), đặt câu hỏi Socratic, và hướng dẫn bệnh nhân tự viết "Phản ứng Thích nghi". AI không đưa lời khuyên trực tiếp.
- **FR 2.4 - Động cơ Phân tích NLP (AI Risk Scoring):** Sau mỗi journal, hệ thống gọi Gemini API để phân loại ngôn ngữ thành 3 mức: 100 (từ khóa tự sát), 70 (Core Belief tiêu cực), 0 (tiêu cực thông thường). Lưu vào `journals.ai_risk_score`. Xem chi tiết tại `THUAT_TOAN_RISK_INDEX.md`.

**3.3 Module 3: Công cụ Trò chơi hóa Trị liệu (CBT Gamification)**
- **FR 3.1 - Lộ trình Nhiệm vụ (Roadmap UI):** Hiển thị màn hình lộ trình dạng cây phân mảnh. Nhiệm vụ thuộc 4 nhóm: BEHAVIORAL, COGNITIVE, EMOTIONAL, SOCIAL. Áp dụng nguyên tắc **Graded Task Assignment**: bài Nhận thức mỗi ngày (< 5 phút), bài Hành vi/Xã hội 3–4 ngày/tuần (10–15 phút).
- **FR 3.2 - Khóa kỷ luật (Time-Gating):** Tối đa **1–2 nhiệm vụ/ngày**. Ép đếm ngược sang ngày hôm sau (06:00 AM) để chống hoàn thành ồ ạt, rèn thói quen hành vi.
- **FR 3.3 - Nộp Minh chứng chống gian lận:** Mở Camera trực tiếp xác thực (AI Vision đối chiếu với mô tả của Quest). 
- **FR 3.4 - Đánh giá sau Hoàn thành (Mastery & Pleasure):** Sau mỗi nhiệm vụ, bệnh nhân chấm điểm **Mastery (Thành tựu) 0–10** và **Pleasure (Niềm vui) 0–10**. Lưu vào `patient_quests.mastery_score` và `patient_quests.pleasure_score`. Bác sĩ dùng dữ liệu này để đánh giá Anhedonia.
- **FR 3.5 - Luồng Tốt nghiệp Khóa học:** PHQ-9 < 5 trong **2 chu kỳ liên tiếp** (cách nhau 14 ngày) → Popup "Quy gán Sự tiến bộ" + Pháo hoa chứng chỉ → Kích hoạt Giai đoạn 3. Nếu PHQ-9 > 10: Kích hoạt Booster Course 4 tuần.

**3.4 Module 4: Đặt lịch Tham vấn (Telehealth Booking)**
- **FR 4.1 - Cổng Đặt lịch:** Danh bạ bác sĩ với Rating. Lịch rảnh đồng bộ chống Trùng lặp (Concurrency control).
- **FR 4.2 - Khóa Riêng tư:** Gạt nút cho phép bác sĩ thấy tên thực (Consent) hoặc giữ kín (Anonymous Booking).

**3.5 Module 5: Cài đặt (Settings)**
- **FR 5.1:** Quản lý avatar, thay đổi ngôn ngữ (I18N), tùy chỉnh bật/tắt Push Notifications để tránh dội bom thông báo.

---

### PHẦN II: GIAO DIỆN CHUYÊN GIA TÂM LÝ (WEB CMS CỦA BÁC SĨ)

**3.6 Module 6: Hồ sơ Bác sĩ (Therapist Onboarding)**
- **FR 6.1 - Duyệt cấp phép:** Upload file chứng chỉ điện tử. Chặn tính năng nhận phác đồ khi trạng thái tài khoản đang là `PENDING`. 

**3.7 Module 7: Bảng điều khiển Quản lý Bệnh nhân (Patient Dashboard)**
- **FR 7.1 - Danh sách Roster:** Hiển thị List bệnh nhân (ẩn danh). Bệnh nhân có Risk Index >= 70 tự động được đẩy lên đầu danh sách với Cờ Đỏ (🚨).
- **FR 7.2 - Cảnh báo đỏ cứu sinh (Emergency Alerts):** Banner cấp thiết và nhấp nháy kích hoạt **ngay lập tức** khi Risk Index của bệnh nhân **>= 70** (không cần chờ nhiều ngày). Bác sĩ thấy nút "Gửi yêu cầu Can thiệp". Sau can thiệp, bác sĩ bấm "Đã xử lý" để đóng alert.
- **FR 7.3 - Đọc biểu đồ y khoa:** Xem biểu đồ Sentiment (Line Chart 14 ngày từ `journals.risk_index`), Mood Trend (từ `user_moods`), Mastery/Pleasure Trend (từ `patient_quests`). Tuyệt đối chặn hiển thị nội dung text Nhật ký (Bảo mật PHI) trừ trường hợp Emergency Alert có kích hoạt.

**3.8 Module 8: Can thiệp Trị liệu Game Master (CBT Intervention)**
- **FR 8.1 - Giao phác đồ cá nhân:** Kéo thả chèn ép Nhiệm vụ riêng lẻ (Side Quest) hoặc Cụm nhiệm vụ (Booster Package) vào tài khoản từng bệnh nhân.
- **FR 8.2 - Xử lý Rẽ nhánh:** Ấn nút "Trigger Consultation" &rarr; Buộc app của User phía đầu cầu khóa Game, đẩy luồng đi tham vấn video.

**3.9 Module 9: Quản lý Lịch biểu (Schedule Management)**
- **FR 9.1:** Tạo Time-slots, tự động hóa gửi thông báo lịch làm việc về App qua luồng Push Notification.

---

### PHẦN III: HỆ THỐNG QUẢN TRỊ VIÊN VÀ BACKGROUND JOBS

**3.10 Module 10: Quản trị Hệ thống (Admin Web CMS)**
- **FR 10.1 - Quản lý Tài liệu CBT:** Admin điều phối `Quest Library CMS`. Soạn bộ nhiệm vụ (Template) gắn thẻ BEHAVIORAL, COGNITIVE, EMOTIONAL, SOCIAL.
- **FR 10.2 - Chăm sóc Nhân sự:** Duyệt tài khoản cho phép Bác sĩ hoạt động.

**3.11 Module 11: Tiến trình Tự động (Background / Cron Jobs)**
- **FR 11.1 - Risk Scoring Job (00:00 AM):** Job quét toàn bộ bệnh nhân Active. Công thức: `Risk_Index = (0.4 × Score_PHQ9) + (0.4 × Score_AI) + (0.2 × Score_Mood)`. **Override Rule (ưu tiên tuyệt đối):** Nếu `q9_score > 0` HOẶC AI phát hiện từ khóa tự sát → Risk_Index = 100 (bỏ qua công thức). Nếu Risk_Index >= 70 → kích hoạt Emergency Protocol ngay lập tức. Xem chi tiết tại `THUAT_TOAN_RISK_INDEX.md`.
- **FR 11.2 - State Machine Job (Cooldown sau Telehealth):** Nhận diện State `COOLDOWN` (sau phiên tham vấn). Đếm lùi 3 ngày, ẩn task độ khó cao. Ngày thứ 4 tự chuyển về `GAMIFICATION_NORMAL`.
- **FR 11.3 - PHQ-9 Cooldown & Graduation Job:** Quản lý cột `phq9_submissions.unlocked_at` (cooldown 14 ngày giữa các lần test). Sau mỗi lần test Periodic, so sánh 2 kết quả gần nhất: nếu cả 2 đều < 5 điểm → trigger Graduation (Popup "Quy gán Sự tiến bộ" + kích hoạt Giai đoạn 3 Tapering).
- **FR 11.4 - Tapering & Booster Sessions Job:** Dựa vào ngày tốt nghiệp và `patient_profiles.tapering_stage`, Job gửi nhắc nhở theo lịch (Tháng 1: 1 lần/tuần; Tháng 2–6: 1 lần/tháng; Sau 6 tháng: 1 lần/quý). Tự động trigger Booster Session PHQ-9 tại mốc Tháng 3, Tháng 6, Tháng 12 kể từ ngày tốt nghiệp.

---

## 4. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)

### 4.1 Tính Bảo mật và Quyền riêng tư (Security & Privacy Requirements)
- **NFR-1 (Authentication):** Giao thức xử lý JWT Bearer Token có hiệu lực và mã hóa mật khẩu cấp độ cao (BCrypt).
- **NFR-2 (PHI Compliance):** Bằng mọi giá không lưu giữ thông tin văn bản Nhật Ký không mã hóa. Không cho phép admin và bác sĩ đọc Text trừ trường hợp cấp cứu Alert có sự đồng thuận từ trước.

### 4.2 Hiệu suất (Performance Requirements)
- **NFR-3:** APIs kết xuất từ Backend (Spring Boot) không lớn hơn 300ms.
- **NFR-4 (LLM Speed):** Gọi qua cổng Google Gemini Engine phải hoàn trả lại tin nhắn AI Chat trong dung sai không quá 2,5 giây/bản ghi chữ.

### 4.3 Khả năng Mở rộng (Scalability & Maintainability)
- **NFR-5:** Thuật toán Data Database MySQL được thiết lập Relational ánh xạ cứng. Logic đếm ngược Cooldown và Job đánh giá cảm biến phải chạy tách biệt đa luồng, không ảnh hưởng đến băng thông của Người dùng Mobile khi Online lúc 00:00 đêm.
