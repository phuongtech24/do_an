# TỔNG HỢP TOÀN BỘ NGHIỆP VỤ VÀ KỊCH BẢN ỨNG DỤNG MINDHEALTH (CHUẨN CBT)

Tài liệu này số hóa các nguyên lý của Liệu pháp Nhận thức Hành vi (CBT) thành kịch bản hệ thống.

---

## PHẦN 1: QUẢN LÝ DỮ LIỆU & GIÁM SÁT RỦI RO (SAFETY PROTOCOL)

### 1. Cơ chế Ẩn danh (Display Anonymity)
*   **Backend:** Lưu trữ Email/SĐT thật (Mã hóa) để bảo mật và cứu hộ.
*   **Frontend/CMS:** Hiển thị Nickname/Avatar ảo cho Tình nguyện viên/Bác sĩ xem hàng ngày.
*   **Phá vỡ ẩn danh (Override):** Chỉ Super Admin được quyền giải mã SĐT thật khi hệ thống bật "Cờ đỏ" báo động tự sát để gọi điện cứu hộ.

### 2. Công thức tính Điểm rủi ro ngầm (Risk Index: 0 - 100 điểm)
`Risk Index = (0.4 × PHQ9) + (0.4 × AI_NLP) + (0.2 × Mood_Trend)`

*   **PHQ-9 (40%):** Quét Câu 9 (>0) hoặc Câu 2 (=3). Nếu Câu 9 > 0 → **Max 100 điểm**.
*   **AI NLP (40%):** Quét Niềm tin cốt lõi (Bất lực, Không được yêu thương, Vô giá trị). Từ khóa tự sát → **Max 100 điểm**.
*   **Mood Trend (20%):** Trung bình 3 ngày liên tiếp < 20% → **Max 100 điểm**.

⚠️ **Luật ghi đè (Override):** Chỉ cần AI thấy từ khóa tự sát HOẶC Câu 9 > 0 → Risk Index = 100 ngay lập tức.
🚀 **Trigger:** Risk Index ≥ 70 → Bật Cờ Đỏ CMS + Kích hoạt PHQ-9 TRIGGERED + Luồng Cứu trợ khẩn cấp.

---

## PHẦN 2: LỘ TRÌNH 3 GIAI ĐOẠN TRỊ LIỆU (USER JOURNEY)

### GIAI ĐOẠN 1: KHỞI ĐẦU & THIẾT LẬP (ONBOARDING)
*   **Baseline:** Làm test PHQ-9 đầu vào (`submission_type = BASELINE`).
*   **Goal Setting:** Chọn 3-5 mục tiêu hành vi (giấc ngủ, lo âu...).
*   **Psychoeducation:** AI hướng dẫn Mô hình Nhận thức (Tình huống → Suy nghĩ → Cảm xúc → Hành vi).

### GIAI ĐOẠN 2: VÒNG LẶP TRỊ LIỆU HÀNG NGÀY (DAILY LOOP)
*   **Bước 1 - Mood Check-in:** Chấm điểm tâm trạng (0-100%).
*   **Bước 2 - AI Rẽ nhánh:**
    *   Tệ (< 45%): Viết Nhật ký suy nghĩ (Thought Record) + Câu hỏi Socratic.
    *   Tốt (≥ 45%): Viết Danh sách ghi nhận (Credit List).
*   **Bước 3 - Agenda Setting:** Chọn 1 vấn đề duy nhất/ngày.
*   **Bước 4 - Homework Roadmap (Chu kỳ 14 ngày):**
    *   Giới hạn: 1-2 task/ngày, 5-15 phút/task.
    *   PHQ-9 ≥ 15 (Nặng): 80% Hành vi (Dễ) + 20% Nhận thức thụ động.
    *   PHQ-9 < 15 (Nhẹ/Vừa): 50% Hành vi + 50% Nhận thức chủ động.
*   **Bước 5 - Đánh giá định kỳ:** 14 ngày/lần mở khóa PHQ-9 (`submission_type = PERIODIC`).
*   **Tốt nghiệp:** 2 lần liên tiếp PHQ-9 < 5 điểm.

### GIAI ĐOẠN 3: KẾT THÚC & PHÒNG NGỪA TÁI PHÁT (TERMINATION)
*   **Progress Graph:** So sánh PERIODIC với BASELINE để tăng self-efficacy.
*   **Tapering Off (Giãn cách):** 1 lần/tuần → 1 lần/tháng → 1 lần/quý.
*   **Booster Sessions:** Lịch cố định tại tháng thứ 3, 6, 12.
*   **Ad-hoc Monitoring:** AI giám sát ngầm 24/7, kích hoạt phiên khẩn cấp nếu Risk Index ≥ 70.
