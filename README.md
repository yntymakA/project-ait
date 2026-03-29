# Project AIT

## Docker run

Из корня проекта:

```bash
cp .env.example .env
docker compose up --build
```

Поднимутся:

- `db` MySQL на `localhost:3307`
- `api` FastAPI на `http://localhost:8000`
- `web` на `http://localhost:5173`

Что уже настроено:

- backend ждёт готовности MySQL;
- Alembic автоматически делает `upgrade head`;
- web собирается в production внутри Docker.

Полезные ссылки:

- API health: `http://localhost:8000/health`
- API docs: `http://localhost:8000/docs`
- Web: `http://localhost:5173`

Если нужен полный сброс базы:

```bash
docker compose down -v
docker compose up --build
```

## Env files

Файлы окружения, которые реально используются:

- [`.env.example`](/Users/main/Desktop/project%20ait/.env.example) — основной env для `docker compose` из корня проекта.
- [`BackEnd/.env.example`](/Users/main/Desktop/project%20ait/BackEnd/.env.example) — env для локального запуска backend без Docker.
- [`Web/.env.example`](/Users/main/Desktop/project%20ait/Web/.env.example) — env для локального запуска web без Docker.

Для проверки через Docker учителю достаточно:

```bash
cp .env.example .env
docker compose up --build
```

## Mobile run

Mobile не запускается через Docker. Он использует тот же backend на `8000`.

Запуск:

```bash
docker compose up --build
cd Mobile
flutter pub get
```

Android по USB:

```bash
adb reverse tcp:8000 tcp:8000
flutter run
```

Android Emulator:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000
```

По умолчанию mobile использует `http://127.0.0.1:8000`.
Отдельного `.env` для mobile нет: если нужен другой адрес backend, он передаётся через `--dart-define=API_URL=...`.

## Firebase note

Если файла `BackEnd/firebase-admin.json` нет, базовый запуск контейнеров всё равно работает. Он нужен только для Firebase Admin функций вроде server-side storage/messaging.
