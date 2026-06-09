name: CI

on:
  push:
  pull_request:

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  backend:
    name: Backend - Maven Verify
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: reconnect_backend
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
          cache: maven

      - name: Verify backend
        run: mvn -B -ntp verify

  reconnect-web:
    name: Web - Flutter Analyze/Test/Build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: reconnect_web
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze web app
        run: flutter analyze

      - name: Run web tests
        run: flutter test

      - name: Build web app
        run: flutter build web --release --dart-define=API_BASE_URL=/api

  reconnect-app:
    name: Patient App - Flutter Analyze/Test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: reconnect_app
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze patient app
        run: flutter analyze

      - name: Run patient app tests
        run: flutter test

  docker:
    name: Docker Build Validation
    runs-on: ubuntu-latest
    needs:
      - backend
      - reconnect-web
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Validate docker compose
        run: docker compose -f infra/docker-compose.yml config

      - name: Build backend image
        uses: docker/build-push-action@v6
        with:
          context: ./reconnect_backend
          file: ./reconnect_backend/Dockerfile
          push: false
          tags: reconnect-backend:ci

      - name: Build web image
        uses: docker/build-push-action@v6
        with:
          context: ./reconnect_web
          file: ./reconnect_web/Dockerfile
          push: false
          tags: reconnect-web:ci
