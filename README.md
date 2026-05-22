# MindHealth Monorepo

Monorepo nay gom 3 thanh phan chinh:

- `reconnect_app`: Flutter mobile app cho Patient.
- `reconnect_web`: Flutter web CMS cho Admin va Therapist.
- `reconnect_backend`: Spring Boot backend + MySQL.

Muc tieu cua repo nay la giu cau truc ro rang de ban tu code tung use case theo dung module, thay vi de code nam lon xon theo man hinh.

## Cau truc muc tieu

```text
DOAN/
|- docs/                         Tai lieu nghiep vu, API, diagram, task
|- infra/                        Docker/MySQL/Postman/local infra
|- reconnect_backend/            Spring Boot API
|- reconnect_app/                Flutter mobile app
|- reconnect_web/                Flutter web CMS
|- SETUP_GUIDE.md                Huong dan cai moi truong
|- IMPLEMENTATION_CHECKLIST.md   Lo trinh code theo 10 use case
```

## Stack chinh

- Backend: Java 17, Spring Boot 3.2.4, Spring Security, Spring Data JPA, MySQL
- Mobile App: Flutter, Dart `^3.11.0`
- Web CMS: Flutter Web, Dart `^3.11.0`
- Auth: JWT Bearer Token
- Database: MySQL 8

## Cach bat dau

1. Doc [SETUP_GUIDE.md](/d:/DOAN/SETUP_GUIDE.md)
2. Doc [IMPLEMENTATION_CHECKLIST.md](/d:/DOAN/IMPLEMENTATION_CHECKLIST.md)
3. Doc guide rieng cua tung project:
   - [backend](/d:/DOAN/reconnect_backend/DEVELOPMENT_GUIDE.md)
   - [app](/d:/DOAN/reconnect_app/DEVELOPMENT_GUIDE.md)
   - [web](/d:/DOAN/reconnect_web/DEVELOPMENT_GUIDE.md)

## Nguyen tac lam do an

- Code theo module/use case, khong code theo kieu "tat ca trong 1 file".
- Backend viet entity/repository/service/controller tach lop.
- Flutter tach `core`, `shared`, `features`.
- Moi use case phai co:
  - API/backend task
  - UI task
  - model/request/response task
  - test task toi thieu

## Thu muc moi da tao san

- `docs/tasks`, `docs/api`, `docs/diagrams`
- `infra/mysql/init`
- `reconnect_backend/src/main/java/com/reconnect/platform/modules/*`
- `reconnect_app/lib/core`, `reconnect_app/lib/shared`, `reconnect_app/lib/features/*`
- `reconnect_web/lib/core`, `reconnect_web/lib/shared`, `reconnect_web/lib/features/*`

Ban co the tu dien code vao dung module ma khong can sap xep lai repo nua.
