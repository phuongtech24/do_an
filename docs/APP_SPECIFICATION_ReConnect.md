# TÀI LIỆU ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS) CHÍNH THỨC
**Dự án:** Re-Connect Platform (Nền tảng Trị liệu Nhận thức Hành vi tích hợp AI)
**Mô hình vận hành:** B2B2C SaaS

---

## 1. GIỚI THIỆU CHUNG
Re-Connect là một hệ sinh thái chăm sóc sức khỏe tâm thần kết hợp giữa Trí tuệ Nhân tạo (Google Gemini) và sự giám sát của Chuyên gia Tâm lý thật. Mọi tính năng trong hệ thống đều tuân thủ nguyên tắc y khoa của Liệu pháp Nhận thức Hành vi (CBT).

**Phân quyền (User Roles):**
1. **Clinic Admin (Doanh nghiệp):** Quản lý toàn bộ hệ thống, tạo tài khoản Bác sĩ, quản lý thư viện CBT chuẩn.
2. **Therapist (Bác sĩ/Chuyên gia):** Giám sát bệnh nhân, tùy chỉnh phác đồ CBT, xử lý cảnh báo khủng hoảng.
3. **Patient (Bệnh nhân):** Sử dụng Mobile App ẩn danh, thực hành CBT qua Gamification và Nhật ký AI.

---

## 2. YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)

### PHẦN I: HỆ THỐNG BỆNH NHÂN (END-USER / MOBILE APP)

**Module 1: Xác thực & Khởi tạo Hồ sơ (Onboarding)**
- Đăng nhập/Đăng ký an toàn qua JWT.
- **Tạo định danh ẩn danh:** Người dùng buộc phải chọn Avatar ảo (Động vật/Cỏ cây) và Nickname ngẫu nhiên để bảo mật danh tính. Không ai kể cả bác sĩ biết danh tính thật trừ khi bệnh nhân cho phép.
- **Đánh giá Tâm lý Đầu vào:** Làm bài Trắc nghiệm chuẩn y khoa PHQ-9 (bắt buộc trước khi dùng bất kỳ tính năng nào). Lưu riêng `q9_score` và `q2_score` để phục vụ Override Rule của Risk Index.
- **Goal Setting:** Sau PHQ-9, bệnh nhân chọn **3–5 mục tiêu cá nhân** (Cải thiện giấc ngủ / Tự tin giao tiếp / Kiểm soát lo âu...). Lưu vào `patient_profiles.goals_json`.
- **Psychoeducation Cards:** Chuỗi thẻ về Mô hình Nhận thức (Tình huống → Suy nghĩ → Cảm xúc → Hành vi). Bệnh nhân phải xác nhận đọc hết trước khi vào Daily Loop.

**Module 2: Mood Check-in & Nhật ký AI (Daily Loop)**
- **Mood Check-in Hàng ngày:** Bệnh nhân chấm điểm tâm trạng **0–100%** mỗi ngày. Lưu vào bảng `user_moods`. Là Biến số 3 (trọng số 20%) trong công thức Risk Index.
- **Rẽ nhánh AI:** Mood >= 45% → AI mời viết **Credit List**. Mood < 45% → AI mời viết **Thought Record** và kích hoạt Guided Discovery (Vấn đáp Socrates, nhận diện Lỗi tư duy, viết Phản ứng Thích nghi).
- **Khung Chat 1-1:** Tương tác với Google Gemini AI (Hỗ trợ nhập Voice, Text).
- **AI NLP Risk Scoring:** Sau mỗi journal, Gemini phân loại ngôn ngữ thành 3 mức: 100 (tự sát), 70 (Core Belief tiêu cực), 0 (tiêu cực thường). Lưu vào `journals.ai_risk_score`.
- **Biểu đồ Tâm lý:** Line chart `journals.risk_index` + Mood Trend từ `user_moods` (7 ngày/30 ngày).

**Module 3: Trò chơi hóa CBT & Lộ trình (CBT Gamification - Lõi Hệ thống)**
- **Bản đồ Hành trình (Roadmap):** 4 Chặng chuẩn CBT (Ổn định Hành vi → Nhận diện Cảm xúc → Tái lập Nhận thức → Tốt nghiệp).
- **Phân loại Nhiệm vụ (Quest):** Bắt buộc thuộc 4 nhóm (BEHAVIORAL, COGNITIVE, EMOTIONAL, SOCIAL). Graded Task Assignment: Cognitive < 5 phút/ngày, Behavioral/Social 10–15 phút, 3–4 ngày/tuần.
- **Time-Gating (Khóa thời gian):** Tối đa 1–2 Task/ngày. Phải chờ đến 06:00 sáng mai mới mở khóa trạm kế tiếp.
- **Mastery & Pleasure Rating:** Sau mỗi task, bệnh nhân chấm **Mastery (Thành tựu) 0–10** và **Pleasure (Niềm vui) 0–10**. Lưu vào `patient_quests`. Bác sĩ dùng để theo dõi Anhedonia.
- **Proof Submission & AI Vision:** Ép mở Camera chụp trực tiếp, chặn chọn thư viện ảnh cũ. AI xác nhận ảnh tự động.
- **Hệ thống Phần thưởng:** Lottie nổ pháo hoa, Streak, Badge. Không thưởng hiện vật/tiền.
- **Side Quests (Nhiệm vụ viền tím):** Do bác sĩ chèn vào bản đồ để ép bệnh nhân vượt qua nỗi sợ cá nhân.
- **Tốt nghiệp:** PHQ-9 < 5 trong **2 chu kỳ liên tiếp** (14 ngày/chu kỳ) → Popup "Quy gán Sự tiến bộ" + Pháo hoa chứng chỉ → Kích hoạt Giai đoạn 3 Tapering.

**Module 4: Đặt lịch Tham vấn (Telehealth Booking)**
- **Danh bạ & Lịch rảnh (Availability):** Liệt kê Bác sĩ có rating, học hàm và các slot trống time-slot để đặt. Nút đặt lịch chạy logic Transaction Locking (Khóa chống trùng lịch).
- **Tùy chọn Quyền Riêng Tư (Toggle):** Cho chọn "Khám ẩn danh" (Bác sĩ chỉ thấy Cáo Nhỏ) hoặc "Khám công khai" (Share tên/SĐT thật).

**Module 5: Cài đặt & Hậu Tốt nghiệp (Settings & Maintenance Mode)**
- Thiết lập ngôn ngữ (Đa ngữ), Quản lý bật/tắt Push Notification tránh áp lực.
- **Tính năng Tốt Nghiệp:** Khi qua hết chặng cuối, hệ thống ép làm lại PHQ-9.
  - Điểm an toàn: Kích hoạt pháo hoa chứng chỉ, hạ App xuống chế độ Bảo trì (Tắt lộ trình, chỉ giữ AI Chat và nhắc nhở hàng tháng).
  - Điểm nguy hiểm: Khởi động rẽ nhánh "Booster Course" (Khóa huấn luyện bổ sung 3 tuần).

---

### PHẦN II: HỆ THỐNG CHUYÊN GIA (THERAPIST / WEB CMS)

**Module 6: Hồ sơ Y khoa (Therapist Onboarding)**
- Form Upload chứng chỉ hành nghề, kinh nghiệm làm việc để Admin xét duyệt (State: PENDING -> APPROVED).

**Module 7: Quản lý Bệnh nhân & Cảnh báo (Patient Dashboard)**
- **Danh sách Roster:** Xem danh sách đang phụ trách.
- **Dashboard Phân tích (Analytics):** Xem biểu đồ Vòng tròn (Mức độ tuân thủ Game), Biểu đồ Đường (Biến thiên nhận thức từ điểm Sentiment của lịch sử chat), nhưng *bác sĩ không được đọc lén nội dung nhật ký riêng tư* trừ khi đó là đoạn chat khơi châm Cảnh báo đỏ.
- **Cảnh báo Đỏ (Emergency Alerts):** Banner/Popup cấp cứu chạy nếu bệnh nhân có Risk Index nguy hiểm. Bác sĩ phải bấm "Đã xử lý" sau khi liên hệ can thiệp.

**Module 8: Trở thành Game Master (CBT Intervention)**
- **Quest Library:** Kéo thả các nhiệm vụ mẫu từ kho DB.
- **Assign Booster/Side Quests:** Kê đơn gán 1 nhiệm vụ (nhắm trúng phóc vấn đề) vào thẳng bản đồ của bệnh nhân cụ thể.
- **Trigger Consultation (Xử lý khủng hoảng):** Nhấn nút "Yêu cầu Tham vấn". Tính năng này lập tức đóng băng chức năng Trò chơi của app bệnh nhân và ép họ chuyển sang trạng thái gọi Video.

**Module 9: Quản lý Lịch biểu (Schedule Management)**
- Chọn các khung giờ rảnh đưa lên App. Quản lý đồng ý/hủy/dời lịch và tự động bắn Push Notification về app người dùng.

---

### PHẦN III: QUẢN TRỊ VIÊN & XỬ LÝ NGẦM (ADMIN & BACKGROUND JOBS)

**Module 10: Quản trị Hệ thống (Admin Web CMS)**
- **User Management (CRUD):** Quản lý vòng đời tài khoản Admin/Therapist/Patient.
- **CBT Content CMS:** Nơi duy nhất admin được quyền tạo Mẫu Nhiệm Vụ (Biên soạn tên Task, gán thẻ BEHAVIORAL/SOCIAL, hình ảnh chuẩn AI Vision). Admin tạo 1 lần -> Bác sĩ xài nhiều lần.
- System Analytics Report.

**Module 11: Trigger tự động hóa (Background/Cron Jobs)**
- Hoạt động chìm bằng Spring Boot Scheduled Jobs.
- **Risk Scoring Job (00:00 Đêm):** Tính `Risk_Index = (0.4 × Score_PHQ9) + (0.4 × Score_AI) + (0.2 × Score_Mood)`. **Override Rule:** Nếu `q9_score > 0` hoặc AI phát hiện từ khóa tự sát → Risk = 100 ngay lập tức. Nếu Risk >= 70 → kích hoạt Emergency Protocol. Chi tiết tại [`THUAT_TOAN_RISK_INDEX.md`](./THUAT_TOAN_RISK_INDEX.md).
- **State Machine Job (Cooldown):** Sau Telehealth → `COOLDOWN` 3 ngày, khóa Quest nặng. Ngày thứ 4 tự về `GAMIFICATION_NORMAL`.
- **PHQ-9 Cooldown & Graduation Job:** Quản lý cooldown 14 ngày/lần test. Nếu 2 chu kỳ liên tiếp < 5 điểm → Graduation + kích hoạt Giai đoạn 3.
- **Tapering & Booster Sessions Job:** Điều chỉnh tần suất nhắc nhở theo `tapering_stage` (Tuần/Tháng/Quý). Trigger PHQ-9 Booster tại Tháng 3, 6, 12 từ ngày tốt nghiệp.

---

## 3. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL)
- **Bảo mật & Ẩn danh:** Mã hóa mật khẩu BCrypt. Dữ liệu tin nhắn API qua SSL. Đảm bảo tuân thủ tiêu chuẩn phân tách User Identity.
- **Performance:** App Flutter load màn hình Bản đồ dưới 1.5s, AI Vision xác nhận hình ảnh không quá 3 giây.
- **Scalability:** Hệ thống background task có thể handle check hàng ngàn bệnh nhân mỗi nửa đêm. Kiến trúc Microservice-ready.
