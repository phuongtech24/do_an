# BÁO CÁO: LỘ TRÌNH CBT CỦA BỆNH NHÂN TRÊN ỨNG DỤNG RE-CONNECT
**Cơ sở khoa học:** Phác đồ Trị liệu Nhận thức Hành vi (Cognitive Behavioral Therapy Protocol) chuẩn 12-16 tuần của Hiệp hội Tâm lý học Hoa Kỳ (APA).  
**Phiên bản:** 2.0 – Cập nhật theo kịch bản 3 giai đoạn chuẩn DTx.

Để bệnh nhân không cảm thấy bị ngợp, Phác đồ CBT y khoa được ứng dụng Re-Connect "dịch" sang **Bản đồ Trò chơi (Gamification Roadmap)** chia thành **3 Giai đoạn chính + 1 Giai đoạn chuyển tiếp** dựa trên nguyên tắc điều trị thực tế:

---

## Giai đoạn 1: KHỞI ĐẦU – ONBOARDING (Tuần 1)
👉 **Tiêu chí Y khoa:** Sàng lọc bệnh lý & Psychoeducation (Giáo dục Tâm lý nền tảng).

### Mục tiêu
Thiết lập "đường cơ sở" (Baseline) tâm lý và trang bị cho bệnh nhân khung nhận thức để hiểu mình đang làm gì và tại sao.

### Các bước Onboarding
- **Node 0 (Đăng ký ẩn danh):** Chọn Avatar động vật/cỏ cây + Nickname ngẫu nhiên.
- **Node 1 (Baseline PHQ-9):** Bắt buộc làm bài PHQ-9. Hệ thống lưu điểm Baseline và gán Lộ trình Mặc định.
- **Node 2 (Goal Setting):** Chọn **3–5 mục tiêu cá nhân** (Cải thiện giấc ngủ / Tự tin giao tiếp / Kiểm soát lo âu...). AI sẽ tham chiếu danh sách này khi dẫn dắt nhật ký.
- **Node 3 (Psychoeducation):** Xem qua chuỗi thẻ thông tin về Mô hình Nhận thức: **Tình huống → Suy nghĩ → Cảm xúc → Hành vi**. Phải swipe hết trước khi mở khóa Giai đoạn 2.

---

## Giai đoạn 2: VÒNG LẶP TRỊ LIỆU – DAILY LOOP (Tuần 2 – cho đến khi Tốt nghiệp)
👉 **Tiêu chí Y khoa:** Behavioral Activation + Cognitive Restructuring qua AI-guided Journaling.

### Vòng lặp hàng ngày (reset lúc 06:00 sáng)

**Bước 1 – Mood Check-in:** Bệnh nhân chấm điểm tâm trạng (0–100%). Dữ liệu này nuôi Biến số 3 trong thuật toán Risk Index.

**Bước 2 – Rẽ nhánh AI:**
- Mood >= 50% → AI mời viết **Danh sách Ghi nhận (Credit List)**: liệt kê điều tốt diễn ra hôm nay.
- Mood < 50% → AI mời viết **Nhật ký Suy nghĩ (Thought Record)**: kích hoạt quy trình khám phá dẫn dắt.

**Bước 3 – AI Khám phá Dẫn dắt (Thought Record):** AI nhận diện Lỗi tư duy, đặt câu hỏi Socratic, hướng dẫn bệnh nhân tự viết "Phản ứng Thích nghi".

**Bước 4 – Roadmap Task (Graded Task Assignment):** Hệ thống giao tối đa 1–2 nhiệm vụ/ngày (Time-Gating). Không thể mở trước 06:00 sáng hôm sau.

**Bước 5 – Đánh giá Task:** Chấm điểm **Mastery (Thành tựu) 0–10** và **Pleasure (Niềm vui) 0–10** sau hoàn thành.

### Các Trạm Nhiệm vụ thực tế trên Roadmap

**Chặng A – Ổn định Hành vi (Tuần 1–2):**
- `Node A1`: Mở rèm cửa và đón ánh sáng mặt trời trong 5 phút. *(Minh chứng: Chụp ảnh cửa sổ)*
- `Node A2`: Uống đủ 1 ly nước ấm ngay khi thức dậy.
- `Node A3`: Tự dọn dẹp quanh giường ngủ/bàn làm việc.
- `Node A4`: Đi bộ 15 phút bên ngoài.

**Chặng B – Nhận diện Cảm xúc (Tuần 3–5):**
👉 *Tiêu chí Y khoa: Emotion Monitoring & Identification of Automatic Negative Thoughts (ANTs).*
- `Node B1`: Viết 3 điều biết ơn ngày hôm nay vào "Nhật ký AI".
- `Node B2`: Chat với AI về một nỗi buồn vu vơ. *(AI bắt đầu thu thập Sentiment Score)*
- `Node B3`: Bài tập Thở hộp (Box Breathing) 4-4-4-4 trong 3 phút.
- `Node B4`: Quiz nhận diện "Suy nghĩ Trắng-Đen" (All-or-nothing thinking).

**Chặng C – Tái lập Nhận thức (Tuần 6–10):**
👉 *Tiêu chí Y khoa: Cognitive Restructuring – Áp dụng mô hình ABC của Albert Ellis.*
- `Node C1`: Mảnh ghép ABC – Phân mổ một luồng suy nghĩ cay đắng ra 3 phần (Sự việc → Suy nghĩ → Hậu quả cảm xúc) cùng AI hướng dẫn.
- `Node C2`: Viết bức thư tha thứ cho bản thân (Self-compassion journal).
- `Node C3 [Side Quest 🟣]`: Nhắn tin hẹn uống nước đá với 1 người bạn. *(Minh chứng: Chụp ảnh ly nước ngoài quán)*
- `Node C4`: Đọc lại biểu đồ 14 ngày cùng bác sĩ trên Telehealth.

---

## Giai đoạn 2.5: ĐÁNH GIÁ THUYÊN GIẢM (Cron Job tự động)
👉 **Tiêu chí Y khoa:** Remission Assessment theo tiêu chuẩn APA (PHQ-9 < 5 trong 2 chu kỳ liên tiếp).

### Cơ chế Cooldown PHQ-9
- Bài test PHQ-9 định kỳ chỉ được mở khóa **14 ngày/lần**.
- Cron Job theo dõi ngày làm bài gần nhất, tự cập nhật `unlocked_at`.

### Điều kiện Tốt nghiệp
```
PHQ-9 < 5 điểm TRONG 2 CHU KỲ LIÊN TIẾP (tối thiểu 4 tuần)
```
→ Kích hoạt Popup **"Quy gán Sự tiến bộ"**: Chúc mừng bệnh nhân, nhấn mạnh đây là công sức của chính họ.  
→ Mở khóa Giai đoạn 3.

### Trường hợp Chưa đạt
- PHQ-9 >= 10 sau khi hoàn thành toàn bộ Roadmap → Kích hoạt **Booster Course** (khóa bổ trợ 4 tuần, bác sĩ nhận thông báo).
- PHQ-9 từ 5–9 → Tiếp tục Daily Loop, chờ chu kỳ tiếp theo.

---

## Giai đoạn 3: KẾT THÚC & PHÒNG NGỪA TÁI PHÁT
👉 **Tiêu chí Y khoa:** Relapse Prevention + Autonomy Building (Xây dựng Tự chủ – bệnh nhân là bác sĩ của chính mình).

### Lịch trình Giãn cách (Tapering Schedule)

| Thời gian từ Tốt nghiệp | Tần suất nhắc nhở | Bệnh nhân làm gì |
|---|---|---|
| Tháng 1 | 1 lần/tuần | Review nhật ký, làm 1 task nhẹ |
| Tháng 2 – Tháng 6 | 1 lần/tháng | Mood Check-in + 1 task ngắn |
| Sau 6 tháng | 1 lần/quý | Mood Check-in nhẹ |

### Fixed Booster Sessions (Cron Job bắt buộc)

| Mốc thời gian | Hành động |
|---|---|
| **Tháng thứ 3** | PHQ-9 + Ôn tập với AI |
| **Tháng thứ 6** | PHQ-9 + Đặt lịch Bác sĩ nếu score tăng |
| **Tháng thứ 12** | PHQ-9 + Đặt lịch Bác sĩ nếu score tăng |

Nếu điểm PHQ-9 tại Booster Session >= 10 → Hệ thống tự động kích hoạt lại Giai đoạn 2.

---

**Tóm tắt:** Trò chơi đánh quỷ phá trạm (Roadmap) trên điện thoại trông giống hệt như một bài ứng dụng **Liệu pháp CBT kinh điển**, chỉ khác là Bệnh nhân làm nó trên app một cách vui vẻ thay vì trả lời tài liệu khô khan trên giấy A4 trong phòng khám!
