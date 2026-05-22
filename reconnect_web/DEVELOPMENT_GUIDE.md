# Web CMS Development Guide

## Muc tieu

Flutter web CMS nay danh cho `THERAPIST` va `ADMIN`.

## Cau truc nen dung

```text
lib/
|- core/
|  |- config/
|  |- constants/
|  |- network/
|  |- router/
|  |- theme/
|- shared/
|  |- models/
|  |- services/
|  |- widgets/
|- features/
|  |- auth/
|  |- admin_dashboard/
|  |- doctor_approval/
|  |- patient_monitoring/
|  |- quest_library/
|  |- schedule_management/
|  |- telehealth_requests/
```

## Mapping theo role

- `ADMIN`
  - dashboard tong quan
  - duyet bac si
  - quan ly thu vien quest
- `THERAPIST`
  - dashboard patient
  - canh bao rui ro
  - lich lam viec
  - giao quest
  - xu ly lich hen

## Nguyen tac

- Navigation theo role sau login
- Tuyet doi khong render raw journal text
- Chart va tong hop risk la du lieu da rut gon tu backend
- Tach widget bang dieu khien, bang du lieu, chart, modal thanh widget rieng

## Chay local

```powershell
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```
