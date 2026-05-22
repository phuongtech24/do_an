# BÁO CÁO THIẾT KẾ Y KHOA: TIÊU CHÍ ĐÁNH GIÁ LÂM SÀNG TỪ DỮ LIỆU APP (DÀNH CHO BÁC SĨ)
**Tài liệu:** Framework phân tích dữ liệu điều hướng Trị liệu Nhận thức Hành vi (CBT) trên hệ thống CMS
**Vai trò (Persona):** Bác sĩ Tâm lý / Chuyên gia Tham vấn (Therapists)

---

## Mở đầu
Để bác sĩ có thể trực tiếp can thiệp và áp dụng phương pháp CBT một cách chuẩn xác, hệ thống Web CMS bắt buộc phải có khả năng "chuyển dịch" (translate) dữ liệu thô từ các thao tác chơi game (Gamification) và viết nhật ký AI (AI Journaling) của bệnh nhân thành các **Chỉ số Lâm sàng trực quan**.

Dưới đây là đặc tả chi tiết 4 hệ thống biểu đồ và tiêu chí đánh giá trên Dashboard của Bác sĩ.

---

## 1. Biểu đồ Tuân thủ Hành vi (Behavioral Activation Adherence)
- **Nguồn dữ liệu:** Lấy từ bảng cơ sở dữ liệu `AssignedQuest` thu thập tiến trình hoàn thành các Trạm (Nodes) trên Bản đồ Chữa lành (Gamification Roadmap).
- **Y khoa CBT:** Đo lường kỹ thuật *Kích hoạt hành vi (Behavioral Activation)*. Việc mất động lực là triệu chứng cốt lõi của trầm cảm; do đó, mức độ tương tác với app phản ánh năng lượng sống của bệnh nhân.
- **Trực quan hóa (UI/UX CMS):** Dùng **Biểu đồ Vòng tròn (Donut Chart)** bao gồm 3 mảng màu:
  - 🟢 Màu Xanh: Trạm hoàn thành đúng hạn (Thực hiện hành vi thành công).
  - 🟡 Màu Cam: Trạm đang xử lý (ACTIVE).
  - 🔘 Màu Xám: Trạm bị khóa không thể qua hoặc Vượt quá hạn 24H (Thất bại hành vi).
- **Phân tích của Bác sĩ:** Nếu vùng Xám chiếm > 40%, bác sĩ đánh giá bệnh nhân đang bị "quá tải" nhận thức. Bác sĩ sẽ áp dụng thao tác **Phân rã hành vi (Graded Task Assignment)** bằng cách gán thêm các *Side Quests* (Nhiệm vụ viền tím) vỡ lòng cực dễ để lấy lại động lực.

## 2. Đường Biến thiên Nhận thức (Cognitive Distortion Tracker)
- **Nguồn dữ liệu:** Lấy dữ liệu phân tích cảm xúc (Sentiment Scores 0 - 100) được chấm ngầm tự động bởi AI (Call Google Gemini API) từ các đoạn chat Nhật ký.
- **Y khoa CBT:** Đo lường kỹ thuật *Tái lập nhận thức (Cognitive Restructuring)*. Nhận diện các tư duy lệch lạc (Catastrophizing, All-or-nothing thinking).
- **Trực quan hóa (UI/UX CMS):** Dùng **Biểu đồ Đường thời gian (Line Chart)** trải dài trong chu kỳ 14 ngày.
  - Vùng đáy (0 - 30): Bình thường.
  - Vùng giữa (40 - 70): Có xu hướng lo âu.
  - Đỉnh Spike Đỏ (80 - 100): Cơn hoảng loạn (Panic Attack) hoặc Trầm cảm suy sụp cực độ.
- **Phân tích của Bác sĩ:** Bác sĩ có thể **Click trực tiếp vào các Đỉnh Đỏ** trên biểu đồ. Web sẽ ngay lập tức bung cửa sổ hiển thị đúng dòng chat Nhật ký ngày hôm đó. Bác sĩ sẽ phát hiện ra "tư duy rác" (Cognitive Distortion) nào đang khống chế bệnh nhân và lên kịch bản gỡ rối trong buổi hẹn Telehealth kế tiếp.

## 3. Mức độ Phân cực Dữ liệu (Behavior vs. Emotion Divergence)
- **Y khoa CBT:** Đánh giá độ tin cậy của biểu hiện bệnh nhân (Phát hiện hội chứng Trầm cảm cười - Smiling Depression).
- **Trực quan hóa (UI/UX CMS):** Dùng **Biểu đồ Cột kép (Bar Chart)** so sánh chéo:
  - Cột 1: Điểm Cày Game/Hành vi (Chỉ số cực cao / Rất chăm chỉ làm task).
  - Cột 2: Điểm Tâm trạng Nhật ký AI (Chỉ số cực thấp / Viết toàn nội dung tiêu cực tuyệt vọng).
- **Phân tích của Bác sĩ:** Sự chệch pha dữ liệu này chứng tỏ phương pháp dCBT (Tự can thiệp qua máy) là không đủ. Bệnh nhân đang thực hiện các hành vi đối phó cơ học như một cái máy nhưng "điểm nghẽn nhận thức" vẫn chưa được giải phóng. Bác sĩ hiểu rầng cần can thiệp con người sâu hơn (Therapist-guided intervention).

## 4. Hệ thống Cảnh báo Đỏ (Crisis & Risk Alerts)
- **Nguồn dữ liệu:** Thuật toán AI bóc tách từ khóa rủi ro sinh tồn (Ví dụ: "tẩy chay", "tuyệt vọng", "nhảy xuống", "kết thúc").
- **Trực quan hóa (UI/UX CMS):**
  - Không nằm trong bảng thống kê mà hiển thị thành **Thẻ Banner Chớp Ngang (Red Alert Badge)** ngay bên cạnh tên bệnh nhân trên Roster (Danh sách tổng).
- **Phân tích của Bác sĩ:** Thiết lập Ưu tiên Số 1. Bác sĩ bỏ qua quy trình vẽ bản đồ Roadmap và kích hoạt ngay Phác đồ Xử lý khủng hoảng (Khóa mõm AI chatbot, lập tức đẩy thông báo cấp cứu vào app Bệnh nhân và gọi số điện thoại khẩn cấp người thân).
