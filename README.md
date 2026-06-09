# 🧠 ReConnect MindHealth

**ReConnect MindHealth** is a mental-health therapy management SaaS platform designed to support CBT-based self-help journeys, therapist matching, AI-assisted guidance, and telehealth appointment workflows. 

The system is built as a graduation thesis project with a strong focus on secure patient data handling, clinical flow alignment, and scalable backend architecture.

---

## ✨ Key Features
* **Clinical Workflows:** LSAS-based social anxiety assessment flow, Fear Ladder, and Behavioral Experiment workflows.
* **Patient Toolkit:** Goal setting, therapist matching, daily mood check-in, and CBT thought record support.
* **Telehealth:** Appointment booking and therapist management.
* **Security & Access:** Role-based access control (Patient, Therapist, Admin) and secure authentication with JWT.
* **Performance:** Redis caching for therapist directory APIs.
* **Modern DevOps:** Dockerized development/deployment workflow and CI/CD pipelines with GitHub Actions.

## 🛠 Tech Stack

### Backend
* **Language & Framework:** Java 17, Spring Boot, Spring Security
* **Database & ORM:** MySQL, Spring Data JPA / Hibernate
* **Caching & API:** Redis, REST APIs

### Frontend
* **Mobile App:** Flutter (`reconnect_app`)
* **Web Portal:** Flutter Web (`reconnect_web`)

### DevOps & Infra
* Docker, Docker Compose
* GitHub Actions
* GHCR (GitHub Container Registry)

## 🏗 Architecture Overview
The project is organized into core modules:
* `reconnect_backend`: Spring Boot backend APIs and business logic.
* `reconnect_app`: Flutter patient application.
* `reconnect_web`: Flutter web portal for management surfaces.
* `infra`: Docker Compose and deployment-related configuration.

## 🚀 Technical Highlights
* Optimized backend performance by eliminating **N+1 query issues** using JPA `EntityGraph` and aggregated repository queries.
* Integrated **Redis caching** (`@Cacheable` / `@CacheEvict`) to reduce repeated database load.
* Ensured consistency in sensitive scheduling flows using `@Transactional` and **pessimistic locking**.
* Designed structured business flows based on LSAS-first CBT treatment logic.
* Built CI/CD pipelines for automated build, test, Docker validation, and image publishing.

## ⚙️ Getting Started

### Prerequisites
* Java 17 & Maven
* Flutter SDK
* Docker Desktop
* MySQL / Redis (or use the provided Docker Compose)

### Run Locally

**1. Infrastructure (Docker Compose)**
```bash
cd infra
docker compose up --build -d
2. Backend
cd reconnect_backend
mvn spring-boot:run
3. Web Portal
cd reconnect_web
flutter pub get
flutter run -d chrome
4. Patient App
cd reconnect_app
flutter pub get
flutter run
🔄 CI/CD
This repository includes automated pipelines:

CI Pipeline: For backend verification, Flutter analyze/test/build, and Docker validation.

CD Pipeline: For publishing backend and web Docker images to GHCR.

🎯 Project Purpose
This project was developed as a graduation thesis and a practical software engineering portfolio project, focusing on:

Backend system design & Performance optimization

Business workflow implementation

Secure API development

Modern DevOps practices

👨‍💻 Author
Nguyễn Khắc Nam Phương

Intern Software Engineer

GitHub: @phuongtech24
