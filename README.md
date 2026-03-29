# Project AIT - Full Stack Marketplace Application

Полнофункциональное мобильное и веб-приложение для маркетплейса с бэкэндом на Python (FastAPI).

## 📁 Структура проекта

```
project/
├── BackEnd/          # Python FastAPI Backend
├── Mobile/           # Flutter Mobile Application
├── Web/              # React/Vite Web Application
└── docs/             # Документация
```

## 🚀 Быстрый старт

### Backend (Python/FastAPI)

```bash
cd BackEnd
python -m venv venv
source venv/bin/activate  # или venv\Scripts\activate на Windows
pip install -r requirements.txt
python -m app.main
```

Backend доступен: `http://localhost:8000`
API документация: `http://localhost:8000/docs`

### Mobile (Flutter)

```bash
cd Mobile
flutter pub get
flutter run
```

### Web (Vite + React + TypeScript)

```bash
cd Web
npm install
npm run dev
```

Web доступен: `http://localhost:5173`

## 📋 Требования

- **Backend**: Python 3.9+, PostgreSQL
- **Mobile**: Flutter 3.0+, iOS/Android SDK
- **Web**: Node.js 18+, npm/yarn

## 🔧 Технологический стек

### Backend
- FastAPI
- SQLAlchemy
- Alembic
- PostgreSQL
- Firebase Admin SDK

### Mobile
- Flutter
- Firebase
- GetX/Provider для управления состоянием

### Web
- React 18+
- TypeScript
- Vite
- TailwindCSS

## 📚 Документация

- [Backend API Endpoints](BackEnd/docs/api-endpoints.md)
- [Architecture](BackEnd/docs/architecture.md)
- [Authentication](BackEnd/docs/authentication.md)
- [Mobile Setup Guide](Mobile/README.md)

## 👥 Автор

Yntymak Almazbekuulu

## 📝 Лицензия

MIT
