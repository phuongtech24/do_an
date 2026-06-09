ReConnect MindHealth
ReConnect MindHealth is a mental-health therapy management SaaS platform designed to support CBT-based self-help journeys, therapist matching, AI-assisted guidance, and telehealth appointment workflows.
The system is built as a graduation thesis project with a strong focus on secure patient data handling, clinical flow alignment, and scalable backend architecture.

Key Features
LSAS-based social anxiety assessment flow
Goal setting and therapist matching
Fear Ladder and Behavioral Experiment workflows
Daily mood check-in and CBT thought record support
Telehealth appointment booking and therapist management
Role-based access for patient, therapist, and admin
Secure authentication with JWT
Redis caching for therapist directory APIs
Dockerized development and deployment workflow
CI/CD pipelines with GitHub Actions
Tech Stack
Backend
Java 17
Spring Boot
Spring Security
Spring Data JPA / Hibernate
MySQL
Redis
REST APIs
Frontend
Flutter (reconnect_app)
Flutter Web (reconnect_web)
DevOps / Infra
Docker
Docker Compose
GitHub Actions
GHCR (GitHub Container Registry)
Architecture Overview
The project is organized into three main parts:

reconnect_backend: Spring Boot backend APIs and business logic
reconnect_app: Flutter patient application
reconnect_web: Flutter web portal for management surfaces
infra: Docker Compose and deployment-related configuration
Highlights
Eliminated N+1 query issues using JPA EntityGraph and aggregated repository queries
Integrated Redis caching with @Cacheable / @CacheEvict
Applied @Transactional and pessimistic locking for sensitive scheduling flows
Designed structured business flows based on LSAS-first CBT treatment logic
Built CI/CD pipelines for automated build, test, Docker validation, and image publishing
Getting Started
Prerequisites
Java 17
Maven
Flutter SDK
Docker Desktop
MySQL / Redis (or Docker Compose)
Run with Docker Compose
cd infra
docker compose up --build -d
Backend
cd reconnect_backend
mvn spring-boot:run
Web
cd reconnect_web
flutter pub get
flutter run -d chrome
Patient App
cd reconnect_app
flutter pub get
flutter run
CI/CD
This repository includes:

CI pipeline for backend verification, Flutter analyze/test/build, and Docker validation
CD pipeline for publishing backend and web Docker images to GHCR
Project Purpose
This project was developed as a graduation thesis and practical software engineering portfolio project, focusing on:

backend system design
business workflow implementation
performance optimization
secure API development
modern DevOps practices
Author
Nguyen Khac Nam Phuong
Intern Software Engineer
GitHub: phuongtech24
