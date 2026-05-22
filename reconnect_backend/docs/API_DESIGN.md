# 📘 API Design Document — MindHealth Backend

> **Base URL:** `http://localhost:8081`
> **Authentication:** JWT Bearer Token (trừ các route công khai)
> **Response Format:** Tất cả API đều trả về cấu trúc `ApiResponse<T>` thống nhất

```json
{
  "status": 200,
  "message": "Mô tả kết quả",
  "data": { ... }
}
```

---

## 🔐 Module 1: AUTH (`/api/auth`)
> Tất cả route trong module này là **công khai** (không cần token)

| Method | Endpoint | Mô tả | Body |
|--------|----------|-------|------|
| `POST` | `/api/auth/register` | Đăng ký tài khoản mới | `RegisterRequest` |
| `POST` | `/api/auth/login` | Đăng nhập, nhận JWT Token | `LoginRequest` |
| `POST` | `/api/auth/register-anonymous` | Đăng ký khách vãng lai | `?deviceId=xxx` |

### Body mẫu

**POST `/api/auth/register`**
```json
{
  "email": "patient@gmail.com",
  "password": "123456",
  "role": "PATIENT",
  "isAnonymous": false,
  "nickname": "CaoNho123",
  "avatarIcon": "fox"
}
```

> Với `isAnonymous = true` (Patient), `nickname` và `avatarIcon` là bắt buộc. Hệ thống sử dụng để ẩn danh danh tính thật.

**POST `/api/auth/login`**
```json
{
  "email": "patient@gmail.com",
  "password": "123456"
}
```
**Response:**
```json
{
  "status": 200,
  "message": "Đăng nhập thành công!",
  "data": {
    "user": { "id": "...", "email": "...", "role": "PATIENT" },
    "token": "eyJhbGci..."
  }
}
```

---

## 👤 Module 2: USER (`/api/users`)
> 🔒 Yêu cầu JWT Token

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `GET` | `/api/users` | Lấy toàn bộ danh sách user | Admin |
| `GET` | `/api/users/{id}` | Lấy thông tin 1 user theo UUID | Admin, Chính user đó |
| `GET` | `/api/users/me` | Lấy thông tin user đang đăng nhập | Tất cả |

---

## 🏥 Module 3: CLINICAL (`/api/clinical`)
> 🔒 Yêu cầu JWT Token

### Hồ sơ Bệnh nhân (Patient Profile)

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `GET` | `/api/clinical/patients` | Lấy danh sách bệnh nhân | THERAPIST, ADMIN |
| `GET` | `/api/clinical/patients/{userId}` | Lấy hồ sơ 1 bệnh nhân | THERAPIST, chính PATIENT đó |
| `PUT` | `/api/clinical/patients/{userId}` | Cập nhật hồ sơ bệnh nhân | Chính PATIENT đó |
| `POST` | `/api/clinical/patients/{userId}/assign/{therapistId}` | Gán bệnh nhân cho bác sĩ | ADMIN |

**Body PUT `/api/clinical/patients/{userId}`**
```json
{
  "nickname": "BN-Ẩn danh",
  "cognitiveMap": "{ ... JSON sơ đồ nhận thức ... }"
}
```

### Hồ sơ Bác sĩ (Therapist Profile)

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `GET` | `/api/clinical/therapists` | Lấy danh sách bác sĩ | Tất cả |
| `GET` | `/api/clinical/therapists/{userId}` | Lấy hồ sơ 1 bác sĩ | Tất cả |
| `PUT` | `/api/clinical/therapists/{userId}` | Cập nhật hồ sơ bác sĩ | Chính THERAPIST đó |

**Body PUT `/api/clinical/therapists/{userId}`**
```json
{
  "fullName": "Nguyễn Văn A",
  "bio": "Chuyên gia tâm lý lâm sàng...",
  "specialization": "Trầm cảm, Lo âu",
  "meetingLink": "https://meet.google.com/xxx"
}
```

---

## 📊 Module 4: ASSESSMENT (`/api/assessment`)
> 🔒 Yêu cầu JWT Token | Chỉ PATIENT mới được nộp bài test

### PHQ-9 Test

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `POST` | `/api/assessment/phq9` | Nộp kết quả bài test PHQ-9 | PATIENT |
| `GET` | `/api/assessment/phq9/history` | Lịch sử test của bệnh nhân đang login | PATIENT |
| `GET` | `/api/assessment/phq9/patient/{userId}` | Lịch sử test của 1 bệnh nhân cụ thể | THERAPIST |

**Body POST `/api/assessment/phq9`**
```json
{
  "answers": [2, 1, 0, 3, 1, 2, 0, 1, 1],
  "totalScore": 11,
  "q2Score": 3,
  "q9Score": 1,
  "submissionType": "BASELINE"
}
```
> `submissionType`: `BASELINE` (lần đầu), `PERIODIC` (14 ngày/lần), `TRIGGERED` (bác sĩ yêu cầu).  
> `q9Score` (câu 9 – ý định tự hại) và `q2Score` (câu 2 – tuyệt vọng) **phải được lưu riêng** để phục vụ Override Rule của thuật toán Risk Index.

### Mood Check-in (Theo dõi tâm trạng hàng ngày)

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `POST` | `/api/assessment/user-moods` | Ghi nhận tâm trạng hôm nay (bắt buộc trước khi dùng app) | PATIENT |
| `GET` | `/api/assessment/user-moods/history` | Lịch sử tâm trạng 30 ngày | PATIENT |
| `GET` | `/api/assessment/user-moods/average` | Trung bình 3 ngày gần nhất (dùng cho Risk Index) | THERAPIST, SYSTEM |

**Body POST `/api/assessment/user-moods`**
```json
{
  "moodScore": 65
}
```
> `moodScore`: 0–100. Điểm này là **Biến số 3 (trọng số 20%)** trong công thức Risk Index. Nếu không check-in 3 ngày liên tiếp → hệ thống cần mặc định `avg = 0` (nguy hiểm).

---

## 📔 Module 5: JOURNAL (`/api/journal`)
> 🔒 Yêu cầu JWT Token | Chỉ PATIENT

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `POST` | `/api/journal/thought-records` | Tạo nhật ký suy nghĩ mới | PATIENT |
| `GET` | `/api/journal/thought-records` | Lấy danh sách nhật ký của tôi | PATIENT |
| `GET` | `/api/journal/thought-records/{id}` | Xem chi tiết 1 nhật ký | PATIENT |
| `POST` | `/api/journal/thought-records/{id}/analyze` | Gọi AI phân tích nhật ký | PATIENT |

**Body POST `/api/journal/thought-records`**
```json
{
  "situation": "Bị sếp phê bình trước mặt mọi người",
  "automaticThought": "Tôi vô dụng, không làm được việc gì",
  "emotion": "Xấu hổ, tức giận",
  "emotionScore": 80
}
```

---

## 🗺️ Module 6: ROADMAP (`/api/roadmap`)
> 🔒 Yêu cầu JWT Token

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `GET` | `/api/roadmap/tasks` | Lấy danh sách nhiệm vụ của tôi | PATIENT |
| `POST` | `/api/roadmap/tasks` | Tạo nhiệm vụ mới (AI hoặc thủ công) | PATIENT, THERAPIST |
| `PUT` | `/api/roadmap/tasks/{id}/complete` | Đánh dấu nhiệm vụ hoàn thành | PATIENT |
| `GET` | `/api/roadmap/tasks/patient/{userId}` | Xem roadmap của bệnh nhân | THERAPIST |

**Body PUT `/api/roadmap/tasks/{id}/complete`**
```json
{
  "masteryScore": 7,
  "pleasureScore": 6
}
```
> `masteryScore` (Thành tựu 0–10) + `pleasureScore` (Niềm vui 0–10) là bắt buộc sau khi hoàn thành. Bác sĩ dùng dữ liệu này để theo dõi Anhedonia (mất khả năng cảm nhận niềm vui).

**Body POST `/api/roadmap/tasks`**
```json
{
  "title": "Đi bộ 30 phút",
  "description": "Kích hoạt hành vi: đi bộ buổi sáng",
  "category": "BEHAVIORAL",
  "dueDate": "2026-04-30"
}
```

---

## 📅 Module 7: BOOSTER (`/api/booster`)
> 🔒 Yêu cầu JWT Token

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| `POST` | `/api/booster/appointments` | Đặt lịch hẹn Booster Session | PATIENT |
| `GET` | `/api/booster/appointments` | Xem lịch hẹn của tôi | PATIENT, THERAPIST |
| `PUT` | `/api/booster/appointments/{id}/confirm` | Xác nhận lịch hẹn + thêm link Meet | THERAPIST |
| `PUT` | `/api/booster/appointments/{id}/cancel` | Hủy lịch hẹn | PATIENT, THERAPIST |

**Body POST `/api/booster/appointments`**
```json
{
  "therapistId": "uuid-cua-bac-si",
  "requestedTime": "2026-05-01T14:00:00",
  "note": "Tôi muốn thảo luận về tiến trình tuần vừa rồi"
}
```

---

## 🤖 Module 8: AI (`/api/ai`)
> 🔒 Yêu cầu JWT Token | Tầng kỹ thuật, thường được gọi nội bộ từ Journal/Roadmap

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `POST` | `/api/ai/analyze-thought` | Phân tích lỗi tư duy từ nhật ký |
| `POST` | `/api/ai/generate-task` | AI gợi ý nhiệm vụ dựa trên ngữ cảnh |

---

## 📋 Bảng tóm tắt trạng thái triển khai

| Module | Status | Ghi chú |
|--------|--------|---------|
| Auth | ✅ Hoàn thành | Register, Login, Anonymous |
| User | ✅ Hoàn thành | GetAll, GetById, GetMe |
| Clinical | ⏳ Chưa làm | Module tiếp theo – cần PatientProfile + GoalsJson |
| Assessment | ⏳ Chưa làm | PHQ-9 (cần q9_score, q2_score, unlocked_at) + UserMoods |
| Journal | ⏳ Chưa làm | Thought Record + AI NLP Risk Scoring + ai_risk_score |
| Roadmap | ⏳ Chưa làm | PatientQuests với mastery_score + pleasure_score |
| Booster | ⏳ Chưa làm | Appointments + Tapering/Booster Cron Job |
| AI | ⏳ Chưa làm | Phụ thuộc Journal – Gemini NLP phân loại 3 mức (0/70/100) |
| CronJobs | ⏳ Chưa làm | Risk Scoring, State Machine, PHQ-9 Cooldown, Tapering |
