# Tóm tắt Dự án: ReConnect MindHealth (Brief)

## 1. ReConnect là gì?
ReConnect là một nền tảng B2B2C SaaS chuyên cung cấp giải pháp chăm sóc sức khỏe tâm thần (đặc biệt là trầm cảm và lo âu) dựa trên Liệu pháp Nhận thức Hành vi (CBT - Cognitive Behavioral Therapy). 

Điểm khác biệt cốt lõi của ReConnect là sự kết hợp giữa **Trí tuệ nhân tạo (Google Gemini AI)** để tương tác hàng ngày và sự giám sát an toàn từ **Chuyên gia Tâm lý thật (Therapist)**.

## 2. Đối tượng Người dùng (User Roles)
1. **Patient (Bệnh nhân):** Sử dụng Mobile App. Tương tác với AI, chơi game trị liệu (Gamification) và theo dõi tâm trạng dưới chế độ hoàn toàn ẩn danh.
2. **Therapist (Bác sĩ/Chuyên gia Tâm lý):** Sử dụng Web CMS. Quản lý danh sách bệnh nhân, theo dõi rủi ro tự sát/trầm cảm qua các chỉ số do AI phân tích, và can thiệp bằng cách giao nhiệm vụ (Quest) hoặc gọi Video (Telehealth).
3. **Clinic Admin (Quản trị Phòng khám):** Sử dụng Web CMS. Quản lý tài khoản chuyên gia và thư viện nhiệm vụ CBT chuẩn y khoa.

## 3. Các Luồng Giá trị Chính (Core Value Flows)
- **Daily Loop (Vòng lặp hàng ngày):** Bệnh nhân check-in cảm xúc -> Nếu tiêu cực: AI hướng dẫn viết nhật ký (Thought Record) -> AI phân tích câu chữ và đánh giá rủi ro (Risk Score).
- **Gamification Roadmap (Lộ trình Game hóa):** Bệnh nhân thực hiện các nhiệm vụ CBT ngoài đời thực (Ví dụ: Ra ngoài đi dạo, chụp ảnh ly cafe) -> AI Vision xác thực ảnh -> Bệnh nhân nhận phần thưởng ảo (Pháo hoa, huy hiệu).
- **Emergency Intervention (Can thiệp khẩn cấp):** Khi AI phát hiện chỉ số rủi ro của bệnh nhân tăng cao (ví dụ: nhắc đến tự sát), hệ thống báo động đỏ (Red Flag) cho Bác sĩ. Bác sĩ lập tức đóng băng game và kích hoạt gọi Video khẩn cấp.

## 4. Công nghệ cốt lõi
- **Frontend (Patient):** Flutter Mobile App (Provider, Dio).
- **Frontend (Therapist/Admin):** React.js Web CMS.
- **Backend:** Spring Boot (Java), Hibernate/JPA, MySQL. Tự động hóa qua Spring Scheduler.
- **AI Integration:** Google Gemini NLP (Xử lý ngôn ngữ) và Gemini Vision (Xử lý ảnh).
