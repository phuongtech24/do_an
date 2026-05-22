# ĐẶC TẢ KỸ THUẬT CÁC MODULE (MODULE SPECIFICATION)

Tài liệu này quy định logic nghiệp vụ chi tiết cho từng module trong hệ thống Re-Connect.

---

## 1. Module: `auth` (Xác thực & Định danh)
**Trạng thái:** ✅ **Hoàn thành**

*   **Thành phần chính (Entities):**
    *   `User`: id, username (email), password_hash, role, is_active, is_anonymous.
*   **Logic nghiệp vụ:**
    *   Mã hóa mật khẩu BCrypt & Cấp phát JWT Token.
    *   Hỗ trợ đăng ký ẩn danh: yêu cầu `nickname` và `avatarIcon` khi `isAnonymous=true`.
    *   Tự động tạo `PatientProfile` ngay khi User (PATIENT) đăng ký thành công.

---

## 2. Module: `clinical` (Hồ sơ Lâm sàng)
**Mục đích:** Quản lý lộ trình 3 giai đoạn và trạng thái tốt nghiệp.

*   **Thành phần chính (Entities):**
    *   `PatientProfile`: nickname, avatar_icon, goals_json, current_risk_score, tapering_stage.
    *   `TherapistProfile`: full_name, specialty, approval_status.
*   **Logic nghiệp vụ:**
    *   **Tốt nghiệp (Phase 2 -> Phase 3):** Điều kiện là 2 lần làm PHQ-9 định kỳ liên tiếp đạt kết quả < 5 điểm (tối thiểu 4 tuần). Chuyển `tapering_stage` sang `WEEKLY`.
    *   Quản lý quan hệ giám sát 1-N (therapist → patients).

---

## 3. Module: `assessment` (Đánh giá & Rủi ro)
**Mục đích:** Số hóa bài test PHQ-9 và Mood Check-in.

*   **Thành phần chính (Entities):**
    *   `Phq9Submission`: total_score, q9_score, q2_score, submission_type, unlocked_at.
    *   `UserMood`: mood_score (0-100), daily_agenda (Agenda Setting), recorded_at.
    *   **`DailyRiskLog`**: Lưu lịch sử điểm Risk Index hàng ngày.
*   **Logic nghiệp vụ:**
    *   **Cooldown:** Khóa bài test định kỳ trong 14 ngày.
    *   **Daily Agenda:** Ép bệnh nhân chọn 1 vấn đề duy nhất khi check-in tâm trạng.
    *   **Risk Index Calculation:** Chạy hàng đêm dựa trên công thức `(0.4 × PHQ9) + (0.4 × AI) + (0.2 × Mood)`.
    *   **Override Rule:** Nếu PHQ9 Câu 9 > 0 -> Risk Index = 100 ngay lập tức.

---

## 4. Module: `journal` (Nhật ký & AI)
**Mục đích:** Phân tích suy nghĩ tự động bằng NLP.

*   **Thành phần chính (Entities):**
    *   `Journal`: content_encrypted, journal_type (THOUGHT_RECORD | CREDIT_LIST), ai_risk_score, severity_level.
*   **Logic nghiệp vụ:**
    *   **AI Scan (Gemini):** Phân loại rủi ro dựa trên Niềm tin cốt lõi (Bất lực, Vô giá trị, Không thể yêu thương).
    *   **Rẽ nhánh:** Tâm trạng < 45% giao Thought Record; >= 45% giao Credit List.

---

## 5. Module: `roadmap` (Nhiệm vụ trị liệu)
**Mục đích:** Giao bài tập hàng ngày (1-2 task, 5-15 phút).

*   **Thành phần chính (Entities):**
    *   `QuestTemplate`: title, content, type (COGNITIVE | BEHAVIORAL).
    *   `PatientQuest`: status, mastery_score, pleasure_score.
*   **Logic Phân bổ (Chu kỳ 14 ngày):**
    *   **Chu kỳ:** 14 ngày tính từ `last_phq9_date`. AI sẽ giao bài tập sao cho tổng kết chu kỳ đạt đúng tỷ lệ y khoa.
    *   **PHQ-9 > 15 (Nặng):** Tỷ lệ tổng chu kỳ là **80% Hành vi (Behavioral)** và **20% Nhận thức (Cognitive)**.
    *   **PHQ-9 < 15 (Nhẹ/Vừa):** Tỷ lệ là **50% Hành vi + 50% Nhận thức**.
    *   **Giới hạn ngày:** Tối đa 2 nhiệm vụ/ngày, tổng thời gian < 20 phút.

---

## 6. Module: `booster` (Củng cố & Kết nối)
**Mục đích:** Đặt lịch hẹn và các phiên củng cố đặc biệt.

*   **Thành phần chính (Entities):**
    *   `Appointment`: time, status, meeting_link.
*   **Logic nghiệp vụ:**
    *   Mở khóa **Booster Sessions** tại các mốc: 3 tháng, 6 tháng và 12 tháng sau tốt nghiệp.
    *   Kích hoạt phiên củng cố đột xuất (Ad-hoc) khi Risk Index >= 70.

---

## 7. Module: `ai` (Trợ lý Trị liệu)
**Mục đích:** Quản lý cấu trúc Prompt và hội thoại.
*   Dẫn dắt bệnh nhân thực hiện 6 câu hỏi Socratic để phản biện suy nghĩ tiêu cực.

---

## 11. Module: `cron-jobs` (Lập lịch hệ thống)
**Mục đích:** Tự động hóa các tính năng ngầm.

*   **Risk Scoring Job:** Tính điểm rủi ro tổng hợp cho toàn hệ thống.
*   **Quest Assignment Job:** Tự động chọn nhiệm vụ hàng đêm dựa trên tỷ lệ 80/20 hoặc 50/50 của chu kỳ 14 ngày hiện tại.
*   **Tapering Schedule Job:** Giãn cách tần suất nhắc nhở (Tuần -> Tháng -> Quý).
*   **Cleanup Job:** Xóa các dữ liệu nhạy cảm cũ để đảm bảo bảo mật.

---
*Tài liệu này được đồng bộ với DATABASE_DESIGN.md và PROGRESS_CHECKLIST.md.*
