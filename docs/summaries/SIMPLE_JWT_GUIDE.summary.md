# Summary: SIMPLE_JWT_GUIDE (JWT Auth)

Tóm tắt nhanh để giảm token. Bản đầy đủ: `reconnect_backend/docs/SIMPLE_JWT_GUIDE.md`.

## Phạm vi
- Dành cho backend Spring Boot dùng **JWT** (login/register + bảo vệ API) theo kiến trúc cơ bản: Entity/Repo/Service/Controller + Security filter chain.

## Input/Output chính
- `POST /auth/register` (hoặc tương đương): tạo user
- `POST /auth/login`: trả `token` (JWT)
- Các API khác: nhận `Authorization: Bearer <token>`

## Thành phần kỹ thuật
- JWT util: tạo token, verify, extract claims (username/userId, expiry)
- `UserDetailsService` + `UserDetails`
- `JwtFilter`: đọc header, validate token, set SecurityContext
- `SecurityConfig`: cho phép public endpoints (auth), chặn phần còn lại
- `application.yml`: secret, expiration, config liên quan

## Khi nào cần mở bản đầy đủ
- Khi implement/fix filter chain, token claims, hoặc gặp lỗi 401/403 do cấu hình Spring Security.

