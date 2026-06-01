# Setup Guide

## 1. Phien ban nen dung

- Java: `17`
- Maven: `3.9+`
- Flutter SDK: nen dung ban moi tuong thich voi `Dart 3.11.x`
- Android Studio hoac VS Code
- MySQL: `8.x`
- Git
- Docker Desktop: khuyen dung de chay MySQL local nhanh hon

## 2. Cau truc repo

```text
DOAN/
|- reconnect_backend/
|- reconnect_app/
|- reconnect_web/
|- infra/
|- docs/
```

## 3. MySQL local

Ban co 2 cach:

### Cach A: Docker

```powershell
cd d:\DOAN\infra
docker compose up -d
```

Thong tin mac dinh:

- Database: `mindhealth_db`
- Username: `mindhealth_user`
- Password: `mindhealth_password`
- Port: `3306`

### (Khuyen nghi) Chay full stack bang Docker Compose

Neu muon chay nhanh ca `MySQL + Backend + Web CMS` bang Docker (de deploy tren may khac), dung:

```powershell
cd d:\DOAN\infra
docker compose up -d --build
```

Sau khi len container:

- Backend API: `http://localhost:8080`
- Web CMS: `http://localhost:3000`

### Cach B: Cai MySQL thu cong

Tao database:

```sql
CREATE DATABASE mindhealth_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Sau do sua file backend config cho dung tai khoan MySQL may ban.

## 4. Backend Spring Boot

File chinh:

- [pom.xml](/d:/DOAN/reconnect_backend/pom.xml)
- [application.yml](/d:/DOAN/reconnect_backend/src/main/resources/application.yml)
- [application-local.yml.example](/d:/DOAN/reconnect_backend/src/main/resources/application-local.yml.example)

Lenh chay:

```powershell
cd d:\DOAN\reconnect_backend
mvn spring-boot:run
```

Mac dinh:

- API port: tuy theo `server.port` (tham khao `application.yml` va profile local)
- Base URL: `http://localhost:<port>`

Khuyen nghi:

- Tao `application-local.yml` tu file example
- Dung profile `local`
- Ve sau them `Flyway` migration va `JWT secret` bang env var

## 5. Flutter App

Lenh:

```powershell
cd d:\DOAN\reconnect_app
flutter pub get
flutter run
```

Neu chay Android emulator:

```powershell
flutter run -d emulator-5554
```

Neu can goi local backend:

- Android emulator: `http://10.0.2.2:8080`
- Windows/Web/macOS: `http://localhost:8081`

## 6. Flutter Web CMS

Lenh:

```powershell
cd d:\DOAN\reconnect_web
flutter pub get
flutter run -d chrome
```

Mac dinh web dev server se tu cap port.

Neu chay bang Docker (compose), web CMS se mo san tai: `http://localhost:3000`

## 7. Bien moi truong nen co

Ban co the thong nhat quy uoc sau:

- Backend
  - `DB_HOST`
  - `DB_PORT`
  - `DB_NAME`
  - `DB_USER`
  - `DB_PASSWORD`
  - `JWT_SECRET`
  - `AI_ENABLED` (true/false)
  - `GEMINI_API_KEY`
  - `AI_RISK_CALL_AI_ONLY_WHEN_SUSPICIOUS` (true/false)
  - `AI_RISK_AI_CALL_THRESHOLD` (default 70)
  - `AI_DISTORTIONS_CALL_AI_ONLY_WHEN_SUSPICIOUS` (true/false)
  - `AI_DISTORTIONS_MAX_SUGGESTIONS` (default 3)
- Flutter App/Web
  - `API_BASE_URL`
  - `GEMINI_PROXY_URL` neu sau nay ban tach AI gateway

Vi Flutter thuong dung `--dart-define`, ban co the chay nhu sau:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

## 8. Thu muc nen tuan thu khi code

- Backend: code trong `modules/<feature>`
- App: code trong `lib/features/<feature>`
- Web: code trong `lib/features/<feature>`
- API note: ghi vao `docs/api`
- Diagram/ERD/use case: ghi vao `docs/diagrams`

## 9. Thu tu lam viec khuyen nghi

1. Setup MySQL
2. Chay backend
3. Chay app
4. Chay web
5. Bat dau code theo [IMPLEMENTATION_CHECKLIST.md](/d:/DOAN/IMPLEMENTATION_CHECKLIST.md)

## 10. Luu y

- Hien tai repo da co mot so file demo/man hinh mau. Ban co the giu lai de tham khao.
- `build/`, `.dart_tool/`, file generated khong nen sua tay.
- Neu backend sap toi them JWT, mail, push notification, AI proxy thi nen tach config vao `config/` va `security/`.

## 11. Test Accounts (Local)

Dung de test nhanh cac chuc nang onboarding (PHQ-9 Baseline, Goal Setting, Journal...):

```json
{
  "email": "patient_phq9@reconnect.com",
  "password": "123456"
}
```

## 12. Environment Variables & Security ⚠️

### Quy tac QUAN TRONG:

**NEVER commit `.env` file len Git!** Neu ban check `.env` vao repo, API keys, database passwords, encryption keys... se bi leak!

### Setup local environment:

1. **Copy `.env.example` thành `.env.local`:**
   ```powershell
   cp .env.example .env.local
   ```

2. **Sua `.env.local` voi gia tri cua ban** (khong commit file nay!):
   ```bash
   GEMINI_API_KEY=sk-xxx... (tuy situation)
   JWT_SECRET=your-strong-secret-32-chars
   ENCRYPTION_KEY=ReconnectMindH78 (16 chars dung)
   ENCRYPTION_IV=MindHealthIv1234  (16 chars dung)
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=123456
   API_BASE_URL=http://localhost:8081/api
   ```

3. **Load `.env.local` trc khi chay:**
   - **Backend (PowerShell):**
     ```powershell
     # Windows PowerShell
     foreach ($line in Get-Content .env.local) {
       if ($line -and -not $line.StartsWith("#")) {
         $parts = $line -split "=", 2
         [Environment]::SetEnvironmentVariable($parts[0], $parts[1])
       }
     }
     mvn spring-boot:run
     ```
   
   - **Hoac dung `application.properties` directly:**
     ```properties
     # src/main/resources/application-local.properties
     spring.datasource.password=${DB_PASSWORD}
     app.security.jwt-secret=${JWT_SECRET}
     encryption.key=${ENCRYPTION_KEY}
     encryption.iv=${ENCRYPTION_IV}
     ```
     Rui chay: `mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=local"`
   
   - **Flutter/Web (--dart-define):**
     ```powershell
     flutter run --dart-define=API_BASE_URL=http://localhost:8081/api
     ```

4. **Docker compose (Production):**
   ```bash
   docker run -e GEMINI_API_KEY=sk-xxx -e JWT_SECRET=xxx -e ENCRYPTION_KEY=xxx image-name
   ```

### Checklist:

- [x] `.env` trong `.gitignore` (da them san)
- [x] `.env.example` commit len Git (vay file nay se la template)
- [x] `EncryptionUtil.java` load key tu env (khong hardcoded - da fix)
- [x] `application.yml` xai `${VAR:default}` syntax (ok)
- [x] Flutter xai `String.fromEnvironment()` (ok)

### Neu accident commit key:

```bash
# Rotate the key immediately!
# 1. Regenerate GEMINI_API_KEY (vao Google Cloud Console)
# 2. Change JWT_SECRET va ENCRYPTION_KEY
# 3. Force push (if private repo) hoac revert + rewrite history
git revert <commit-hash>
git push
```

