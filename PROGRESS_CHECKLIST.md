# 📊 BẢNG THEO DÕI TIẾN ĐỘ DỰ ÁN RE-CONNECT (DTx Platform)

File này dùng để quản lý trạng thái các task và module. Cập nhật dấu `[x]` khi hoàn thành.

---

## 🏗️ TỔNG QUAN HỆ THỐNG
- **Dự án:** Re-Connect (Sản phẩm Y tế số chuẩn lâm sàng)
- **Trạng thái:** 🟢 MVP hoàn thành (Phase 1 → Phase 5)

---

## ✅ MODULE 1: AUTH & ONBOARDING (100%)
- [x] Entity User & PatientProfile.
- [x] Logic Đăng ký/Đăng nhập JWT.
- [x] Hỗ trợ đăng ký ẩn danh (Nickname/Avatar).
- [x] Tự động khởi tạo PatientProfile + real_phone (Encrypted).

## ⚪ MODULE 2: CLINICAL (20%)
*Mục đích: Hồ sơ lâm sàng & Tốt nghiệp.*
- [x] Entity `PatientProfile` (Đã có `is_red_flag_active`).
- [x] Logic chuyển giai đoạn (Graduation) khi 2 lần PHQ-9 PERIODIC liên tiếp < 5.
- [x] API cập nhật mục tiêu trị liệu (`goals_json`).

## 🟢 MODULE 3: ASSESSMENT (100%)
*Mục đích: Đo lường sức khỏe tâm lý và rủi ro.*
- [x] Thực thể `UserMood` (Đã bổ sung `daily_agenda`).
- [x] Thực thể `Phq9Submission` (Đã chuẩn hóa snake_case).
- [x] Tạo Enums: `Phq9Type`, `SeverityLevel`, `JournalType`.
- [x] Tạo Repositories: `Phq9Repository`, `UserMoodRepository`, `Phq9QuestionRepository`.
- [x] Viết `AssessmentService` xử lý logic:
    - [x] Tính điểm PHQ-9 & Phân loại Severity.
    - [x] Kiểm tra Cooldown 14 ngày dựa trên ngày làm gần nhất.
- [x] Viết API Controllers cho Module 3.

## 🟡 MODULE 4: JOURNAL (60%)
*Mục đích: Nhật ký & Phân tích suy nghĩ tự động (CBT).*
- [x] Entity `Journal` (Có `journal_type` để rẽ nhánh AI).
- [x] API lưu nhật ký + lấy danh sách + xem chi tiết (AES encrypt/decrypt ở Backend).
- [x] Tích hợp Gemini API để phân tích NLP (Core Beliefs) + Cognitive Distortions (AI hỗ trợ).
- [x] Logic tính `ai_risk_score` (0/70/100) + trigger Red Flag theo BRD (hybrid rule-based trước, gọi AI khi nghi ngờ).

## 🟡 MODULE 5: ROADMAP (50%)
*Mục đích: Giao bài tập hàng ngày (Nhận thức & Hành vi).*
- [x] Thực thể `QuestTemplate` và `PatientQuest`.
- [x] Logic chọn & phân bổ Daily Quests theo PHQ-9 (ưu tiên BEHAVIORAL khi nặng) + cân bằng category.
- [x] API lấy danh sách Quest hàng ngày của Patient (tối đa 2 quest/ngày + time-gating 06:00).
- [x] API hoàn thành quest + lưu Mastery/Pleasure (0-10).

## 🟢 MODULE 6: BOOSTER (100%)
*Mục đích: Đặt lịch hẹn & Phiên củng cố sau tốt nghiệp.*
- [x] Thực thể `Appointment`.
- [x] API slots/book/my-appointments cho patient.
- [x] Logic tạo Booster Sessions (Tapering + Booster 3/6/12 tháng) qua Cron + endpoint manual trigger.

## ⚪ MODULE 7: AI ASSISTANT (0%)
*Mục đích: Trợ lý trị liệu hội thoại.*
- [ ] Quản lý cấu trúc Prompt & Lịch sử trò chuyện.
- [ ] Logic dẫn dắt 6 câu hỏi Socratic hỗ trợ phản biện suy nghĩ tiêu cực.

## 🟡 MODULE 11: CRON JOBS (60%)
- [x] Job tính Risk Index hàng đêm `(0.4 × PHQ9) + (0.4 × AI) + (0.2 × Mood)`.
- [ ] Job lưu lịch sử vào `DailyRiskLog`.
- [x] Job quản lý Tapering + Booster scheduling (tạo lịch hẹn định kỳ sau tốt nghiệp).
- [ ] Job dọn dẹp dữ liệu nhạy cảm cũ.

---

## 📱 MOBILE APP: FLUTTER (Tiến độ: 55%)
- [x] Khởi tạo Project & Cấu trúc thư mục (Core/Features/Shared).
- [x] Thiết lập hệ thống Router (`GoRouter`).
- [x] **Module 1: Auth & Onboarding UI/Logic**
    - [x] Giao diện Đăng nhập (với chế độ Ẩn danh nhanh).
    - [x] Giao diện Đăng ký (chuẩn UX, không dư thừa).
    - [x] Tích hợp `AuthRepository` & `AuthProvider` gọi API.
    - [x] Đồng bộ trạng thái Ẩn danh & Nickname sang màn hình Setup Profile.
    - [ ] Lưu trữ Token an toàn (Flutter Secure Storage) và Tự động đăng nhập.
- [x] **Module 3: Assessment UI/Logic (100% API-Connected)**
    - [x] Widget làm bài test PHQ-9 động lấy câu hỏi & đáp án từ API.
    - [x] Tự động tính điểm, phát hiện nguy cơ tự hại lâm sàng (Cờ đỏ).
    - [x] Tự động khóa nút làm bài test nếu đang trong 14 ngày cooldown.
    - [x] Giao diện Daily Mood Check-in kết nối thẳng API lưu trữ database thực thụ.
- [ ] **Module 5: Roadmap UI**
    - [x] Giao diện Daily Quests (Nhiệm vụ hàng ngày) + Quest detail + submit Mastery/Pleasure + proof verify (Gemini Vision).
- [ ] **Module 7: AI Chat UI**
    - [ ] Màn hình Chatbot hội thoại (Socratic CBT Chat).

---

## 📅 ƯU TIÊN TIẾP THEO (PRIORITY)
1. (Optional) Tích hợp `flutter_secure_storage` để lưu giữ phiên đăng nhập (Token) + auto login.
2. (Optional) Nối “Quản lý lịch hẹn” cho Therapist CMS bằng API thật (hiện màn appointment của therapist là mock).
3. (Optional) Thêm `DailyRiskLog` để lưu lịch sử Risk theo ngày (phục vụ analytics sâu hơn).

---
*Cập nhật lần cuối: 15/05/2026*
