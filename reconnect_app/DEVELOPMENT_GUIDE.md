# Mobile App Development Guide

## Muc tieu

Flutter app nay danh cho `PATIENT`.

## Cau truc nen dung

```text
lib/
|- core/
|  |- config/
|  |- constants/
|  |- network/
|  |- router/
|  |- storage/
|  |- theme/
|- shared/
|  |- models/
|  |- services/
|  |- widgets/
|- features/
|  |- auth/
|  |- assessment/
|  |- journal_ai/
|  |- roadmap/
|  |- telehealth/
|  |- settings/
```

## Nguyen tac

- Moi feature tach `data`, `domain`, `presentation`
- Route dat trong `core/router`
- API client dat trong `core/network`
- Widget dung chung dat trong `shared/widgets`
- Model response co the dat o `shared/models` neu dung nhieu feature

## Thu tu code khuyen nghi

1. auth
2. assessment
3. journal_ai
4. roadmap
5. telehealth
6. settings

## Chay local

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Neu chay tren Windows/Web thi doi `API_BASE_URL` thanh `http://localhost:8080`.

## Asset

- `assets/images`
- `assets/icons`
- `assets/animations`
- `assets/audio`

Them vao `pubspec.yaml` khi ban bat dau dung that.
