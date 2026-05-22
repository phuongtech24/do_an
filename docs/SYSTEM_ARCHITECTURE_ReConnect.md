# TỔNG HỢP NGHIỆP VỤ CỐT LÕI (CORE BUSINESS LOGIC) & PHÂN RÃ MODULE

## PHẦN 1: TỔNG HỢP NGHIỆP VỤ CỐT LÕI

### 1. Mô hình vận hành (B2B2C SaaS)
- **Clinic Admin (Doanh nghiệp):** Mua bản quyền phần mềm, tạo tài khoản cho Bác sĩ, nạp danh sách Bệnh nhân và phân bổ bệnh nhân cho từng bác sĩ. Quản lý Thư viện Nhiệm vụ (Quest Library).
- **Therapist (Bác sĩ):** Quản lý hồ sơ bệnh nhân được giao. Chịu trách nhiệm y khoa cao nhất (ra quyết định rẽ nhánh điều trị, tùy chỉnh phác đồ).
- **Patient (Bệnh nhân):** Sử dụng App ẩn danh để tự trị liệu thông qua Gamification và Nhật ký AI.

### 2. Trò chơi hóa chuẩn CBT (CBT-based Gamification)
Mọi nhiệm vụ (Quest) không được random mà phải thuộc 4 nhóm liệu pháp:
1. **BEHAVIORAL (Kích hoạt hành vi):** Các hoạt động thể chất phá vỡ sự trì trệ (Đi dạo, dọn phòng, chụp ảnh bữa sáng).
2. **COGNITIVE (Nhận thức):** Bài tập nhận diện suy nghĩ sai lệch (Viết nhật ký, trả lời câu hỏi phản biện của AI).
3. **EMOTIONAL (Cảm xúc):** Bài tập thư giãn, chánh niệm (Hít thở, viết 3 điều biết ơn).
4. **SOCIAL (Xã hội):** Bài tập tương tác phá vỡ sự cô lập (Nhắn tin cho bạn, ra quán cafe).

### 3. Vai trò của AI & Hệ thống Đánh giá Rủi ro (Risk Scoring System)
- **Nguyên tắc tối thượng:** AI KHÔNG chẩn đoán bệnh. AI chỉ đóng vai trò "Cảnh báo rủi ro" (Risk Flagging).
- **Thuật toán chấm điểm (Risk Index):** Chạy ngầm mỗi ngày, tổng hợp từ:
  - Tần suất từ khóa tiêu cực (Negative words).
  - Độ lười biếng/Bỏ nhiệm vụ (Inactivity).
  - Xu hướng bài test PHQ-9.
- **Hành động:** Nếu Risk Index > Ngưỡng, AI sinh ra một "Báo cáo Cảnh báo" gửi cho Bác sĩ, gợi ý bác sĩ xem xét rẽ nhánh điều trị.

### 4. Luồng Rẽ nhánh Điều trị & Cooldown (Branching & Cooldown Logic)
- **Mặc định:** Bệnh nhân ở nhánh Tự trị liệu (Gamification).
- **Rẽ nhánh:** Bác sĩ nhận cảnh báo từ AI -> Bác sĩ phân tích -> Bấm nút "Yêu cầu Tham vấn". App của bệnh nhân sẽ khóa các quest khó và yêu cầu đặt lịch gọi Video/Gặp mặt.
- **Giai đoạn Cooldown (Post-Consultation):** Ngay sau khi kết thúc buổi tham vấn, hệ thống tự động chuyển sang trạng thái COOLDOWN (3-5 ngày). Các nhiệm vụ nặng (BEHAVIORAL, SOCIAL) bị ẩn đi, chỉ đẩy lên các nhiệm vụ nhẹ nhàng (EMOTIONAL, COGNITIVE) để bệnh nhân bình ổn tâm lý.
- **Trở lại (Game Master):** Sau Cooldown, bác sĩ điều chỉnh lại độ khó/tần suất nhiệm vụ phù hợp hơn và bệnh nhân tiếp tục hành trình Gamification.

---

## PHẦN 2: PHÂN RÃ MODULE LẬP TRÌNH (Dành cho AI Coder)

### Module 1: Core System & Auth (Hệ thống Lõi & Xác thực)
- Thực trạng: Đã dựng base Entity và MySQL.
- Bổ sung: JWT, Cấu hình Role (ADMIN, THERAPIST, PATIENT), Redis Cache (Caching Quest Template).

### Module 2: Patient App (Ứng dụng Bệnh nhân)
- Thực trạng: Roadmap (Gamification), Camera Proof, Telehealth Calendar UI đã dựng xong cơ bản và gọi API mẫu.
- Bổ sung: Tích hợp Google Gemini (Vision) để validate ảnh chụp minh chứng. Hoàn thiện luồng AI Journaling Chat.

### Module 3: Therapist Web CMS (Cổng Bác sĩ / Trợ lý AI)
- Dashboard: Danh sách bệnh nhân, biểu đồ Risk Index / Sentiment Line Chart.
- Alert Mailbox: Hòm thư cảnh báo khẩn.
- Game Master Panel: Sửa/Thêm Quest, đổi loại Quest, nút "Trigger Consultation".

### Module 4: Admin Web CMS (Cổng Doanh nghiệp)
- User Management: CRUD Bác sĩ/Bệnh nhân. Mappping relationship.
- Quest Library CMS: Quản lý Quest Template 4 nhóm (BEHAVIORAL, COGNITIVE, EMOTIONAL, SOCIAL).

### Module 5: Background Jobs & Cron (Xử lý ngầm)
- Logic `Risk Scoring Job`: Chạy Schedule lúc định kỳ (12h đêm) để quét DB tính Risk Index. Lưu bản ghi Alert.
- Logic `State Machine Job`: Đếm lùi trạng thái COOLDOWN (1-3 ngày) để tự động swap về GAMIFICATION_NORMAL.
