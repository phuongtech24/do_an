# UI Test Runbook (Step-by-step)

Muc tieu: ban co 1 checklist "bam nut gi, ky vong gi" de tu test nhanh tren giao dien truoc khi demo/bao ve.

## 0) Chuan bi (Local)

### Backend + MySQL
- Backend API: `http://localhost:8081`
- Web CMS: `http://localhost:3000` (neu chay docker) hoac port tu dong (neu `flutter run`)

Tai khoan demo (seed):
- Admin: `admin@mindhealth.com` / `admin123`
- Therapist: `therapist1@mindhealth.com` / `therapist123`
- Patient: `patient1@mindhealth.com` / `patient123`

Neu login bao "Khong tim thay email", hay kiem tra DB co du lieu chua. Backend se tu auto-seed khi DB con rong.

## 1) Web CMS - Admin flows (BRD)

1. Mo Web CMS.
2. Dang nhap bang Admin.
   - Expected: vao duoc man hinh Admin (menu: Ho so Benh nhan / Kho CBT / Quan ly Bac si).

### 1.1) Quan ly Bac si/Chuyen gia (Approval)
1. Vao man "Quan ly Bac si".
2. Bam "CAP TAI KHOAN" -> nhap FullName/Email/Password.
   - Expected: tao thanh cong, trang thai `PENDING`.
3. Bam Approve/Activate (set `ACTIVE`).
   - Expected: therapist chuyen sang `ACTIVE` va dang nhap duoc.

### 1.2) Kho Noi dung CBT (Quest Templates)
1. Vao man "Kho Noi dung CBT".
   - Expected: load danh sach quest templates.
2. Thu tao 1 template moi (title/description/category).
   - Expected: tao thanh cong, hien tren list.

### 1.3) Quan ly ho so benh nhan
1. Vao man "Ho so Benh nhan".
   - Expected: thay danh sach benh nhan + risk/redFlag + therapist.
2. Thu toggle Active (khoa/mo tai khoan).
   - Expected: user bi khoa thi khong login duoc, mo lai thi login duoc.
3. Thu "Gan BS" -> chon 1 therapist ACTIVE -> Luu.
   - Expected: benh nhan duoc gan therapist; therapist thay benh nhan trong dashboard.

## 2) Web CMS - Therapist flow (Patient Monitoring + Red Flag)

1. Dang nhap bang Therapist (ACTIVE).
   - Expected: vao duoc dashboard therapist.
2. Mo man "Patient Monitoring" / "Patients".
   - Expected: hien danh sach patient.
3. Bat filter "Red flag only" (neu co).
   - Expected: danh sach chi con patient co red flag.

## 3) Flutter App - Patient flow (Daily Loop)

Luu y base URL:
- Android emulator: `API_BASE_URL=http://10.0.2.2:8081/api`
- Windows/iOS simulator: `API_BASE_URL=http://localhost:8081/api`

### 3.1) Mood check-in + re nhanh (nguong 45%)
1. Vao man Mood check-in.
2. Keo mood < 45%.
   - Expected: re nhanh sang Thought Record.
3. Thu lai voi mood >= 45%.
   - Expected: re nhanh sang Credit List.

## 4) Roadmap / Quest (Gamification)
1. Mo Roadmap.
   - Expected: co time-gating (1-2 quest/ngay, mo sau 06:00).

## 5) Postman sanity check (neu UI gap loi)

- env: `infra/postman/ReConnectMindHealth_Local.postman_environment.json`
- collection: `infra/postman/ReConnectMindHealth_AdminApprovalLogin.postman_collection.json`

Expected:
- Login admin -> set `jwtAdmin`
- Create therapist -> set `therapistId`
- Login therapist -> set `jwtTherapist`

