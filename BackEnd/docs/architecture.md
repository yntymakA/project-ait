# Architecture

## Overview

A production-grade **real estate marketplace** backend built with **FastAPI**. Users can register, list properties for sale or rent, communicate via messaging, purchase promotions to boost visibility, and manage their accounts. Administrators have a dedicated panel for moderation, analytics, and platform control.

**Domain:** Real Estate Marketplace (sale & rental)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Python 3.11+ |
| Framework | FastAPI |
| Validation | Pydantic v2 |
| ORM | SQLAlchemy 2.x |
| Database | MySQL 8.x |
| Migrations | Alembic |
| Auth | JWT (access + refresh tokens) |
| File Storage | Local (dev) / Firebase Cloud Storage (prod) |

| Containerization | Docker + Docker Compose |
| API Docs | Swagger UI (`/docs`) · ReDoc (`/redoc`) |

## Directory Structure

```
app/
├── main.py                  # FastAPI app factory, middleware, router registration
├── core/
│   ├── config.py            # Settings (loaded from .env via pydantic-settings)
│   ├── security.py          # Password hashing, JWT encode/decode
│   └── dependencies.py      # Shared FastAPI dependencies (get_db, get_current_user)
├── db/
│   ├── session.py           # SQLAlchemy engine + SessionLocal
│   └── base.py              # Base declarative model
├── models/                  # SQLAlchemy ORM models (DB tables)
│   ├── user.py
│   ├── listing.py
│   ├── category.py
│   ├── message.py
│   ├── notification.py
│   ├── payment.py
│   ├── promotion.py
│   ├── promotion_package.py
│   └── ...
├── schemas/                 # Pydantic request/response schemas
│   ├── user.py
│   ├── listing.py
│   └── ...
├── repositories/            # Raw DB queries (data access layer)
│   ├── user_repo.py
│   ├── listing_repo.py
│   └── ...
├── services/                # Business logic layer (organized by domain folders)
│   ├── auth/
│   ├── listing/
│   ├── payment/
│   └── ...
├── routers/                 # FastAPI route handlers
│   ├── auth.py
│   ├── users.py
│   ├── listings.py
│   ├── messages.py
│   ├── payments.py
│   ├── promotions.py
│   ├── admin/
│   │   ├── users.py
│   │   ├── listings.py
│   │   └── reports.py
│   └── ...
└── migrations/              # Alembic migration scripts
```

## Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Routers** | HTTP request/response handling, input validation via schemas, calling services |
| **Services** | Business logic, orchestration, permission checks |
| **Repositories** | Database queries only — no business logic |
| **Models** | SQLAlchemy table definitions |
| **Schemas** | Pydantic models for request bodies and response shaping |

## Data Flow

```
Client (Browser / Mobile)
        │  HTTP
        ▼
FastAPI App (main.py)
  ├── CORS Middleware
  ├── JWT Auth Middleware
  └── Routers (routers/)
        │  validated request
        ▼
    Services (services/)
        │  business logic
        ▼
  Repositories (repositories/)
        │  SQL queries
        ▼
    MySQL 8.x (db/)
```

## Key Patterns

### 1. Router → Service → Repository

```
routers/listings.py  →  services/listing/listing_service.py  →  repositories/listing_repo.py
```

### 2. Request / Response with Pydantic

```python
class CreateListingRequest(BaseModel):
    title: str
    price: float
    category_id: int

class ListingResponse(BaseModel):
    id: int
    title: str
    status: str
    created_at: datetime
```

### 3. Auth Dependency

```python
from app.core.dependencies import get_current_user, require_admin

@router.get("/me")
async def get_profile(user = Depends(get_current_user)):
    ...

@router.get("/admin/users", dependencies=[Depends(require_admin)])
async def list_users():
    ...
```

### 4. Database Session

```python
from app.core.dependencies import get_db
from sqlalchemy.orm import Session

@router.get("/listings")
async def list_listings(db: Session = Depends(get_db)):
    ...
```

## Roles

| Role | Access Level |
|------|-------------|
| `guest` | Unauthenticated guest/read-only access |
| `authenticated_user` | Browse, list, message, favorite, report |
| `admin` | Full admin panel + user management |
