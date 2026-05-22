# Deploy bang Docker (Local / May khac)

Muc tieu: chay nhanh `MySQL + Backend + Web CMS` chi voi Docker Desktop (khong can cai Java/Maven/Flutter tren may deploy).

## 1) Cach khuyen nghi: Docker Compose (Full stack)

Yeu cau:
- Docker Desktop + Docker Compose (Windows/macOS/Linux)

Chay:

```powershell
cd d:\DOAN\infra
docker compose up -d --build
```

URLs:
- Backend API: `http://localhost:8081`
- Web CMS: `http://localhost:3000`
- MySQL: `localhost:3306` (user/pass trong `infra/docker-compose.yml`)

Dung:

```powershell
cd d:\DOAN\infra
docker compose down
```

## 2) Cau hinh can biet

- Backend doc env tu `reconnect_backend/src/main/resources/application.yml`:
  - DB: `DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD`
  - JWT: `JWT_SECRET`
  - AI: `AI_ENABLED`, `GEMINI_API_KEY` (neu bat AI)
- Backend luu file uploads trong container:
  - `/app/uploads`
  - `/app/proofs`
  - Docker Compose da gan volume de giu du lieu khi restart.

## 3) Test nhanh sau deploy

Postman:
- Import env: `infra/postman/ReConnectMindHealth_Local.postman_environment.json`
- Base URL: `http://localhost:8081`
- Chay collection:
  - `infra/postman/ReConnectMindHealth_AdminApprovalLogin.postman_collection.json`
  - hoac `infra/postman/ReConnectMindHealth_Full.postman_collection.json`

Web CMS:
- Mo `http://localhost:3000`
- Dang nhap admin/therapist theo env Postman local.

## 3.1) Neu login bao "Khong tim thay email"

Truong hop nay thuong do DB da co tu truoc nhung chua seed tai khoan demo.

- Cach nhanh nhat (Docker local):

```powershell
cd d:\DOAN\infra
docker compose down -v
docker compose up -d --build
```

Luu y: `down -v` se xoa volume MySQL (mat du lieu cu).

## 4) Plan B: Deploy ONLINE bang Docker (VPS)

Muc tieu: co 1 server tren internet (VPS) chay `docker compose up -d` va ban/giang vien co the truy cap bang IP/domain.

### 4.1) Yeu cau
- 1 VPS Ubuntu (khuyen nghi 2GB RAM+), co public IP
- Da cai `docker` va `docker compose`
- Mo firewall ports: `22` (SSH), `80` (web), `8080` (API neu can), `3306` (KHONG mo public neu khong can)

### 4.2) Copy source len VPS
Tren VPS:

```bash
git clone <your-repo-url>
cd DOAN/infra
```

Neu ban khong dung git, co the zip repo va upload len VPS roi giai nen.

### 4.3) Chay compose

```bash
docker compose up -d --build
```

Sau khi len:
- Web CMS: `http://<VPS_IP>:3000`
- Backend API: `http://<VPS_IP>:8080`

### 4.4) (Khuyen nghi) Dung domain + HTTPS
De “dep” khi demo, ban co the dat reverse proxy (Caddy/Nginx) tren VPS de:
- map domain -> web (port 3000)
- map domain/api -> backend (port 8080)
- tu dong cap HTTPS

Neu ban muon, minh se tao san `infra/docker-compose.vps.yml` + Caddyfile/Nginx config theo domain cua ban.
