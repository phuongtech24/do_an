# MindHealth Mobile - Module Structure (Flutter)

## Muc tieu

- To chuc frontend theo module de mapping truc tiep UC01-UC10.
- Uu tien luong benh nhan tren mobile app.
- Giu backend doc lap de noi Spring Boot + MySQL sau.

## Cau truc thu muc de xay dung tiep

```txt
lib/
  app/
    app.dart
    router/
      app_router.dart
    theme/
      mindhealth_theme.dart
  shared/
    widgets/
      feature_card.dart
      mindhealth_scaffold.dart
  features/
    auth/presentation/pages/
    assessment/presentation/pages/
    home/presentation/pages/
    journal_ai/presentation/pages/
    roadmap/presentation/pages/
    telehealth/presentation/pages/
    settings/presentation/pages/
```

## Mapping UC -> Module mobile

- UC01 -> `features/auth`
- UC04 -> `features/assessment`
- UC05 -> `features/journal_ai`
- UC06 -> `features/roadmap`
- UC10 -> `features/telehealth`
- FR1.4, FR1.5 -> `features/settings`

## Phan du kien cho CMS (reconnect_web)

- UC02, UC03 -> Admin CMS
- UC07, UC08, UC09 -> Therapist CMS
- Mobile app se khong xu ly giao dien quan tri vai tro Admin/Therapist.

## Ke hoach noi backend

- Them `core/network` voi `Dio` hoac `http` + interceptor JWT.
- Tao `data/repositories` cho moi module.
- Dung `application-local.yml` cho CORS localhost va endpoint `/api/v1`.
