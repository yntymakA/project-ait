# Marketplace Backend — Gemini Guide

## Project Overview
FastAPI real estate marketplace backend. Python 3.11+, SQLAlchemy 2.x, MySQL 8.x, Firebase Auth, Docker.

## Documentation
- **Architecture:** [docs/architecture.md](docs/architecture.md)
- **API Endpoints:** [docs/api-endpoints.md](docs/api-endpoints.md)
- **Data Models:** [docs/data-models.md](docs/data-models.md)
- **Authentication:** [docs/authentication.md](docs/authentication.md)
- **Error Handling & Pagination:** [docs/error-handling-pagination.md](docs/error-handling-pagination.md)
- **Setup & Docker:** [docs/setup-docker.md](docs/setup-docker.md)

---

## Coding Standards

- Use **Python 3.11+**
- Use **SQLAlchemy 2.x** (sync ORM via `Session`, not async)
- Format code like **Black** formatter
- Follow **REST** principles for route design
- Use **Pydantic v2** for all request/response schemas — every route needs typed models
- Use **OOP** principles; prefer class-based services
- Environment config via `core/config.py` (pydantic-settings, loaded from `.env`)

---

## Key Patterns

### Router
```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user

router = APIRouter(prefix="/items", tags=["Items"])

@router.get("/{item_id}", response_model=ItemResponse)
def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item
```

### Database Query
```python
from sqlalchemy.orm import Session
from app.models.listing import Listing

def get_approved_listings(db: Session, limit: int, offset: int):
    return (
        db.query(Listing)
        .filter(Listing.status == "approved", Listing.deleted_at.is_(None))
        .offset(offset)
        .limit(limit)
        .all()
    )
```

### Auth — Protect a Route (Firebase JWT)
```python
from app.core.dependencies import get_current_user, require_admin

@router.get("/me")
def get_profile(user = Depends(get_current_user)):
    return user

@router.get("/admin/data", dependencies=[Depends(require_admin)])
def admin_data():
    ...
```

### Environment Config
```python
from app.core.config import settings

db_url  = settings.DATABASE_URL
firebase_project_id = settings.FIREBASE_PROJECT_ID
env     = settings.APP_ENV   # "development" | "production"
```

### Pagination
```python
@router.get("/listings")
def list_listings(limit: int = Query(20, le=100), offset: int = 0, db: Session = Depends(get_db)):
    total = db.query(Listing).count()
    items = db.query(Listing).offset(offset).limit(limit).all()
    return {"items": items, "total": total, "limit": limit, "offset": offset}
```

---

## User Roles
```python
# role values: "user", "moderator", "admin", "superadmin"
# status values: "active", "blocked", "pending_verification", "deleted"
```

## Listing Statuses
```python
# "draft" → "pending_review" → "approved" | "rejected"
# also: "archived", "sold"
```

---

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `routers/` | FastAPI route handlers |
| `services/` | Business logic |
| `repositories/` | Raw DB queries (no business logic) |
| `models/` | SQLAlchemy ORM table definitions |
| `schemas/` | Pydantic request/response models |
| `core/dependencies.py` | `get_db`, `get_current_user`, `require_admin` |
| `core/config.py` | App settings via pydantic-settings |
| `core/firebase.py` | Firebase Admin SDK verification |
| `db/session.py` | SQLAlchemy engine + SessionLocal |
| `migrations/` | Alembic migration scripts |

---

## Checklist — Before Adding New Code

- [ ] Check `routers/` for an existing endpoint
- [ ] Check `services/` for existing business logic
- [ ] Check `repositories/` for existing DB queries
- [ ] Check `models/` for existing ORM models
- [ ] Check `schemas/` for existing Pydantic models
- [ ] Add Alembic migration if you changed a model:
  ```bash
  alembic revision --autogenerate -m "description"
  alembic upgrade head
  ```
