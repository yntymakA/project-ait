# Setup & Docker

## Prerequisites

- Python 3.11+
- MySQL 8.x (local or Docker)
- `pip` or `poetry`

---

## Local Setup

### 1. Clone and install dependencies

```bash
git clone https://github.com/your-org/marketplace-backend.git
cd marketplace-backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 1.5. Firebase Setup

1. Create a Firebase project and enable Authentication.
2. Generate a new private key from **Project Settings > Service Accounts**.
3. Save the JSON file as `firebase-admin.json` in the root directory.

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env with your database credentials and secret key
```

**`.env` reference:**

```env
# Application
APP_ENV=development           # development | production
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=./firebase-admin.json

# Database
DATABASE_URL=mysql+pymysql://user:password@localhost:3306/marketplace_db

# File Storage (local dev)
UPLOAD_DIR=uploads/
MAX_FILE_SIZE_MB=10

# File Storage (Firebase / production)
# FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com



# Email (for password reset)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=no-reply@example.com
SMTP_PASSWORD=smtp-password
```

### 3. Run database migrations

```bash
alembic upgrade head
```

### 4. (Optional) Seed demo data

```bash
python scripts/seed.py
```

Creates:
- Admin user: `admin@example.com` / `Admin123!`
- Demo user: `demo@example.com` / `Demo123!`
- Sample categories, listings, and promotions

### 5. Run the development server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

| URL | Description |
|-----|-------------|
| http://localhost:8000 | API root |
| http://localhost:8000/docs | Swagger UI |
| http://localhost:8000/redoc | ReDoc |

---

## Docker (Recommended)

### Start all services

```bash
# Build and start API + MySQL
docker compose up --build

# Run in background
docker compose up -d --build

# Apply migrations inside the container
docker compose exec api alembic upgrade head

# View logs
docker compose logs -f api
```

### `docker-compose.yml`

```yaml
version: "3.9"

services:
  api:
    build: .
    ports:
      - "8000:8000"
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./uploads:/app/uploads

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: marketplace_db
      MYSQL_USER: user
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: rootpassword
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      timeout: 5s
      retries: 10



volumes:
  mysql_data:
```

### `Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Stop and clean up

```bash
docker compose down           # Stop services
docker compose down -v        # Stop + wipe DB volumes
```

---

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@example.com` | `Admin123!` |
| User | `demo@example.com` | `Demo123!` |

---

## Known Limitations

- Payments are simplified to an internal `balance` field for academic demonstration (no external payment gateways used).
- Push/email notifications are stubbed (log to stdout)
- File storage uses local disk in dev (swap to Firebase Cloud Storage for production)
- No WebSocket support — messages are polled via REST
