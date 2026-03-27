# 🏪 Marketplace Platform — Backend Documentation

> **Full-Stack Marketplace Platform** | FastAPI · MySQL · JWT · Docker

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Database Models](#database-models)
- [API Endpoints](#api-endpoints)
- [Authentication](#authentication)
- [Pagination](#pagination)
- [Error Handling](#error-handling)
- [Environment Variables](#environment-variables)
- [Setup Instructions](#setup-instructions)
- [Docker Instructions](#docker-instructions)

---

## Project Overview

A production-grade marketplace platform where users can register, list items for sale or rent, communicate via messaging, purchase promotions to boost visibility, and manage their accounts. Administrators have a dedicated panel for moderation, analytics, and platform control.

**Domain:** Real Estate Marketplace (sale & rental)

**Key capabilities:**
- User registration, authentication, and role-based access control
- Listing CRUD with multi-image support and moderation workflow
- Full messaging system with file attachments
- Favorites, notifications, and reporting
- Payments and promotion/boosting system
- Admin panel with dashboards, user management, and audit logs
- Multi-language support (EN / RU)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Python 3.11+ |
| Framework | FastAPI |
| Validation | Pydantic v2 |
| ORM | SQLAlchemy 2.x |
| Database | MySQL 8.x |
| Migrations | Alembic |
| Auth | Firebase Auth + JWT verification |
| File Storage | Local (dev) / Firebase Cloud Storage (prod) |

| Containerization | Docker + Docker Compose |
| API Docs | Swagger UI (`/docs`) · ReDoc (`/redoc`) |

---

## Architecture

The backend follows a **layered architecture** with strict separation of concerns:

```
app/
├── main.py                  # FastAPI app factory, middleware, router registration
├── core/
│   ├── config.py            # Settings (loaded from .env via pydantic-settings)
│   ├── dependencies.py      # Shared FastAPI dependencies (get_db, get_current_user)
│   ├── firebase.py          # Firebase Admin SDK initialization and verification
│   ├── security.py          # Rate limiting, CORS helpers, file validation
│   └── exceptions.py        # Custom exception classes, global error handlers
├── db/
│   ├── base.py              # Base declarative model
│   └── session.py           # SQLAlchemy engine + SessionLocal
├── models/                  # SQLAlchemy ORM models (DB tables)
│   ├── user.py
│   ├── listing.py
│   ├── category.py
│   ├── conversation.py
│   ├── message.py
│   ├── favorite.py
│   ├── notification.py
│   ├── report.py
│   ├── payment.py
│   ├── promotion.py
│   ├── promotion_package.py
│   ├── audit_log.py
│   └── enums.py
├── schemas/                 # Pydantic v2 request/response schemas
│   ├── base.py
│   ├── user.py
│   ├── listing.py
│   ├── category.py
│   ├── conversation.py
│   ├── message.py
│   ├── favorite.py
│   ├── notification.py
│   ├── report.py
│   ├── payment.py
│   └── promotion.py
├── repositories/            # Raw DB queries (data access layer)
│   ├── user_repo.py
│   ├── listing_repo.py
│   ├── category_repo.py
│   ├── conversation_repo.py
│   ├── message_repo.py
│   ├── favorite_repo.py
│   ├── notification_repo.py
│   ├── report_repo.py
│   ├── payment_repo.py
│   ├── promotion_repo.py
│   └── audit_log_repo.py
├── services/                # Business logic layer
│   ├── auth_service.py
│   ├── user_service.py
│   ├── listing_service.py
│   ├── category_service.py
│   ├── conversation_service.py
│   ├── favorite_service.py
│   ├── notification_service.py
│   ├── report_service.py
│   ├── payment_service.py
│   ├── promotion_service.py
│   ├── file_service.py
│   └── admin_service.py
├── routers/                 # FastAPI route handlers
│   ├── auth.py
│   ├── users.py
│   ├── listings.py
│   ├── categories.py
│   ├── conversations.py
│   ├── favorites.py
│   ├── notifications.py
│   ├── reports.py
│   ├── payments.py
│   ├── promotions.py
│   └── admin/
│       ├── dashboard.py
│       ├── users.py
│       ├── listings.py
│       ├── reports.py
│       ├── payments.py
│       ├── promotions.py
│       ├── categories.py
│       └── audit_logs.py
└── utils/                   # Pure helper functions
    ├── pagination.py
    ├── file_validators.py
    └── i18n.py
```

### Layer Responsibilities

| Layer | Responsibility |
|---|---|
| **Routers** | HTTP request/response handling, input validation via schemas, calling services |
| **Services** | Business logic, orchestration, permission checks |
| **Repositories** | Database queries only — no business logic |
| **Models** | SQLAlchemy table definitions |
| **Schemas** | Pydantic models for request bodies and response shaping |

---

## Database Models

### `users`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | Auto-increment |
| firebase_uid | VARCHAR(128) UNIQUE | Firebase User ID, nullable |
| full_name | VARCHAR(255) | Required |
| email | VARCHAR(255) UNIQUE | Required |
| phone | VARCHAR(30) UNIQUE | Optional |
| balance | DECIMAL(10,2) | Default 0.00 |
| role | ENUM | `guest`, `authenticated_user`, `admin` |
| status | ENUM | `active`, `blocked`, `deleted` |
| profile_image_url | TEXT | |
| bio | TEXT | |
| city | VARCHAR(100) | |
| preferred_language | VARCHAR(10) | `en`, `ru` |
| last_seen_at | DATETIME | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

### `categories`
| Column | Type | Notes |
|---|---|---|
| id | INT PK | |
| name | VARCHAR(100) | |
| slug | VARCHAR(100) UNIQUE | |
| parent_id | INT FK | Self-referential (subcategories) |
| is_active | BOOL | |
| display_order | INT | |

### `listings`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| owner_id | BIGINT FK → users | |
| category_id | INT FK → categories | |
| title | VARCHAR(255) | |
| description | TEXT | |
| price | DECIMAL(12,2) | |
| currency | VARCHAR(10) | |
| city | VARCHAR(100) | |
| status | ENUM | `draft`, `pending_review`, `approved`, `rejected`, `archived`, `sold` |
| moderation_status | ENUM | `pending`, `approved`, `rejected` |
| promotion_status | ENUM | `none`, `active`, `expired` |
| view_count | INT | |
| is_negotiable | BOOL | |
| deleted_at | DATETIME | Soft delete |
| published_at | DATETIME | |
| expires_at | DATETIME | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

### `listing_images`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| listing_id | BIGINT FK | |
| file_url | TEXT | |
| is_primary | BOOL | |
| order_index | INT | |
| created_at | DATETIME | |

### `conversations`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| listing_id | BIGINT FK | Context listing |
| participant_a_id | BIGINT FK → users | |
| participant_b_id | BIGINT FK → users | |
| last_message_at | DATETIME | |
| created_at | DATETIME | |

### `messages`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| conversation_id | BIGINT FK | |
| sender_id | BIGINT FK → users | |
| message_type | ENUM | `text`, `attachment` |
| text_body | TEXT | |
| is_read | BOOL | |
| sent_at | DATETIME | |
| deleted_at | DATETIME | Soft delete |

### `message_attachments`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| message_id | BIGINT FK | |
| file_name | VARCHAR(255) | Sanitized |
| original_name | VARCHAR(255) | |
| mime_type | VARCHAR(100) | |
| file_size | INT | Bytes |
| file_url | TEXT | |
| created_at | DATETIME | |

### `favorites`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| user_id | BIGINT FK | |
| listing_id | BIGINT FK | |
| created_at | DATETIME | UNIQUE(user_id, listing_id) |

### `notifications`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| user_id | BIGINT FK | |
| type | ENUM | `listing_approved`, `new_message`, `payment_success`, etc. |
| is_read | BOOL | |
| payload | JSON | Optional context |
| created_at | DATETIME | |

### `reports`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| reporter_user_id | BIGINT FK | |
| target_type | ENUM | `listing`, `user`, `message` |
| target_id | BIGINT | |
| reason_code | VARCHAR(50) | `spam`, `scam`, `duplicate`, etc. |
| reason_text | TEXT | |
| status | ENUM | `pending`, `resolved`, `dismissed` |
| reviewed_by_admin_id | BIGINT FK | Nullable |
| resolution_note | TEXT | |
| created_at | DATETIME | |
| reviewed_at | DATETIME | |

### `transactions`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| user_id | BIGINT FK | |
| type | ENUM | `top_up`, `spend` |
| amount | DECIMAL(12,2) | |
| description | VARCHAR(255) | |
| created_at | DATETIME | |

### `promotions`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| listing_id | BIGINT FK | |
| user_id | BIGINT FK | |
| package_id | INT FK | Nullable |
| promotion_type | ENUM | `featured`, `boosted`, `top_feed` |
| target_city | VARCHAR(100) | |
| target_category_id | INT FK | |
| starts_at | DATETIME | |
| ends_at | DATETIME | |
| status | ENUM | `pending`, `active`, `expired`, `cancelled` |
| purchased_price | DECIMAL(12,2) | |
| created_at | DATETIME | |

### `promotion_packages`
| Column | Type | Notes |
|---|---|---|
| id | INT PK | Auto-increment |
| name | VARCHAR(100) | |
| promotion_type | ENUM | `featured`, `boosted`, `top_feed` |
| duration_days | INT | |
| price | DECIMAL(12,2) | |
| is_active | BOOL | |

### `admin_audit_logs`
| Column | Type | Notes |
|---|---|---|
| id | BIGINT PK | |
| admin_id | BIGINT FK → users | |
| action | VARCHAR(100) | e.g. `suspend_user`, `approve_listing` |
| target_type | VARCHAR(50) | |
| target_id | BIGINT | |
| note | TEXT | |
| created_at | DATETIME | |

---

## API Endpoints

> Full interactive documentation is available at `/docs` (Swagger UI) and `/redoc`.
> All authenticated endpoints require `Authorization: Bearer <access_token>` header.

---

### Registration & Login

**Authentication is handled client-side via Firebase Auth.** 
The client obtains a Firebase ID token and passes it to the backend as a Bearer token. 

#### `POST /users/sync` 🔐
Syncs a newly authenticated Firebase user with the MySQL database. Call this after a user signs up on the client.

**Request:** Empty body. Token contains Firebase UID, email, etc.
**Response `200`:**
```json
{
  "id": 1,
  "firebase_uid": "ABC123XYZ",
  "email": "aibek@example.com",
  "full_name": "Aibek Dzhaksybekov",
  "status": "active",
  "role": "user",
  "created_at": "2026-03-27T00:00:00Z"
}
```

---

### Users — `/users`

#### `GET /users/me` 🔐
Get the current authenticated user's profile.

**Response `200`:**
```json
{
  "id": 1,
  "email": "aibek@example.com",
  "full_name": "Aibek Dzhaksybekov",
  "phone": "+996700123456",
  "profile_image_url": "https://cdn.example.com/images/1.jpg",
  "bio": "Real estate agent in Bishkek",
  "city": "Bishkek",
  "preferred_language": "ru",
  "role": "user",
  "status": "active",
  "created_at": "2026-03-27T00:00:00Z"
}
```

---

#### `PATCH /users/me` 🔐
Update current user's profile.

**Request:**
```json
{
  "full_name": "Aibek D.",
  "bio": "Updated bio",
  "city": "Osh",
  "preferred_language": "en"
}
```
**Response `200`:** Updated user object (same shape as `GET /users/me`)

---

#### `POST /users/me/avatar` 🔐
Upload profile image. Multipart form upload.

**Request:** `Content-Type: multipart/form-data`, field: `file`
**Response `200`:** `{ "profile_image_url": "https://cdn.example.com/..." }`

---

#### `GET /public/users/{user_id}`
Public owner profile page (no auth required).

**Response `200`:**
```json
{
  "id": 42,
  "full_name": "Marat Alykulov",
  "profile_image_url": "https://...",
  "city": "Bishkek",
  "member_since": "2025-01-15T00:00:00Z",
  "active_listing_count": 8
}
```

---

#### `GET /public/users/{user_id}/listings`
All public active listings by a specific owner. Paginated.

**Query params:** `limit`, `offset`, `sort` (`newest`, `price_asc`, `price_desc`)

**Response `200`:**
```json
{
  "items": [ /* listing objects */ ],
  "total": 8,
  "limit": 20,
  "offset": 0
}
```

---

### Listings — `/listings`

#### `GET /listings`
Browse/search listings. No auth required.

**Query params:**
| Param | Type | Description |
|---|---|---|
| `q` | string | Keyword search (title, description) |
| `category_id` | int | Filter by category |
| `city` | string | Filter by city |
| `min_price` | float | Minimum price |
| `max_price` | float | Maximum price |
| `sort` | string | `newest`, `oldest`, `price_asc`, `price_desc` |
| `limit` | int | Page size (default: 20, max: 100) |
| `offset` | int | Offset (default: 0) |

**Response `200`:**
```json
{
  "items": [
    {
      "id": 101,
      "title": "2-bedroom apartment in Bishkek",
      "price": 75000.00,
      "currency": "USD",
      "city": "Bishkek",
      "status": "approved",
      "primary_image_url": "https://...",
      "owner": { "id": 1, "full_name": "Aibek D." },
      "created_at": "2026-03-27T00:00:00Z"
    }
  ],
  "total": 342,
  "limit": 20,
  "offset": 0
}
```

---

#### `POST /listings` 🔐
Create a new listing.

**Request:**
```json
{
  "title": "3-bedroom house for sale",
  "description": "Spacious house in a quiet district...",
  "price": 120000.00,
  "currency": "USD",
  "city": "Bishkek",
  "category_id": 5,
  "is_negotiable": true
}
```

**Response `201`:**
```json
{
  "id": 102,
  "title": "3-bedroom house for sale",
  "status": "pending_review",
  "owner_id": 1,
  "created_at": "2026-03-27T00:00:00Z"
}
```

---

#### `GET /listings/{id}`
Get listing detail. No auth required.

**Response `200`:** Full listing object with images, owner card, promotion status.

---

#### `PATCH /listings/{id}` 🔐
Update own listing. Owner or admin only.

**Request:** Any subset of listing fields.
**Response `200`:** Updated listing object.

---

#### `DELETE /listings/{id}` 🔐
Soft-delete own listing.

**Response `204`:** No content.

---

#### `POST /listing-media/{listing_id}` 🔐
Upload images for a listing. Multipart, up to 10 images.

**Request:** `Content-Type: multipart/form-data`, field: `files[]`
**Response `201`:**
```json
{
  "uploaded": [
    { "id": 1, "file_url": "https://...", "is_primary": true }
  ]
}
```

---

### Favorites — `/favorites`

#### `POST /favorites/{listing_id}` 🔐
Add to favorites.

**Response `201`:** `{ "message": "Added to favorites." }`
**Response `409`:** `{ "detail": "Already in favorites." }`

---

#### `DELETE /favorites/{listing_id}` 🔐
Remove from favorites.

**Response `204`:** No content.

---

#### `GET /favorites` 🔐
List user's saved listings. Paginated.

**Response `200`:**
```json
{
  "items": [ /* listing objects */ ],
  "total": 5,
  "limit": 20,
  "offset": 0
}
```

---

### Conversations & Messages — `/conversations`, `/messages`

#### `POST /conversations` 🔐
Start or reopen a conversation about a listing.

**Request:**
```json
{
  "listing_id": 101,
  "recipient_id": 42
}
```

**Response `201`:**
```json
{
  "id": 7,
  "listing_id": 101,
  "participant_a_id": 1,
  "participant_b_id": 42,
  "created_at": "2026-03-27T00:00:00Z"
}
```

---

#### `GET /conversations` 🔐
List all conversations for current user. Paginated.

**Response `200`:**
```json
{
  "items": [
    {
      "id": 7,
      "listing": { "id": 101, "title": "2-bedroom apartment" },
      "other_participant": { "id": 42, "full_name": "Marat A." },
      "last_message": { "text_body": "Is it still available?", "sent_at": "..." },
      "unread_count": 2
    }
  ],
  "total": 3,
  "limit": 20,
  "offset": 0
}
```

---

#### `GET /conversations/{id}/messages` 🔐
Get messages in a conversation. Participants only.

**Response `200`:**
```json
{
  "items": [
    {
      "id": 55,
      "sender_id": 1,
      "message_type": "text",
      "text_body": "Is it still available?",
      "is_read": true,
      "sent_at": "2026-03-27T00:00:00Z",
      "attachments": []
    }
  ],
  "total": 12,
  "limit": 50,
  "offset": 0
}
```

---

#### `POST /conversations/{id}/messages` 🔐
Send a message (text and/or attachment).

**Request:** `multipart/form-data`

| Field | Type | Notes |
|---|---|---|
| `text_body` | string | Optional if attachment provided |
| `files[]` | file | Optional, max 5 files |

**Response `201`:**
```json
{
  "id": 56,
  "conversation_id": 7,
  "sender_id": 1,
  "message_type": "attachment",
  "text_body": null,
  "attachments": [
    {
      "id": 3,
      "original_name": "floor_plan.pdf",
      "mime_type": "application/pdf",
      "file_size": 204800,
      "file_url": "https://..."
    }
  ],
  "sent_at": "2026-03-27T00:00:00Z"
}
```

---

### Notifications — `/notifications`

#### `GET /notifications` 🔐
List notifications for current user.

**Response `200`:**
```json
{
  "items": [
    {
      "id": 9,
      "type": "listing_approved",
      "is_read": false,
      "payload": { "listing_id": 102, "title": "3-bedroom house for sale" },
      "created_at": "2026-03-27T00:00:00Z"
    }
  ],
  "unread_count": 1,
  "total": 10
}
```

---

#### `PATCH /notifications/{id}/read` 🔐
Mark notification as read.

**Response `200`:** `{ "id": 9, "is_read": true }`

---

### Reports — `/reports`

#### `POST /reports` 🔐
Submit a report.

**Request:**
```json
{
  "target_type": "listing",
  "target_id": 101,
  "reason_code": "scam",
  "reason_text": "The price looks fraudulent."
}
```

**Response `201`:** `{ "id": 4, "status": "open" }`

---

### Payments — `/payments`

#### `POST /payments/initiate` 🔐
Initiate a payment for a promotion.

**Request:**
```json
{
  "promotion_package_id": 3,
  "listing_id": 102
}
```

**Response `201`:**
```json
{
  "payment_id": 88,
  "amount": 15.00,
  "currency": "USD",
  "status": "pending",
  "payment_url": "https://provider.example.com/pay/abc123"
}
```

---

#### `GET /payments` 🔐
User's transaction history. Paginated.

**Response `200`:** `{ "items": [ /* payment objects */ ], "total": 5 }`

---

### Promotions — `/promotions`

#### `POST /promotions` 🔐
Purchase a promotion (called after successful payment).

**Request:**
```json
{
  "listing_id": 102,
  "promotion_type": "boosted",
  "target_city": "Bishkek",
  "target_category_id": 5,
  "duration_days": 7,
  "payment_id": 88
}
```

**Response `201`:**
```json
{
  "id": 11,
  "listing_id": 102,
  "promotion_type": "boosted",
  "status": "active",
  "starts_at": "2026-03-27T00:00:00Z",
  "ends_at": "2026-04-03T00:00:00Z"
}
```

---

### Categories — `/categories`

#### `GET /categories`
**Response `200`:**
```json
[
  {
    "id": 1,
    "name": "Real Estate",
    "slug": "real-estate",
    "subcategories": [
      { "id": 5, "name": "Apartments" },
      { "id": 6, "name": "Houses" }
    ]
  }
]
```

---

### Admin — `/admin/*` 🔐 *(admin role required)*

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/dashboard` | Platform stats & KPIs |
| `GET` | `/admin/users` | Search/list all users |
| `GET` | `/admin/users/{id}` | User detail with listings, payments |
| `PATCH` | `/admin/users/{id}/suspend` | Suspend user |
| `PATCH` | `/admin/users/{id}/unsuspend` | Unsuspend user |
| `GET` | `/admin/listings` | All listings with filters |
| `PATCH` | `/admin/listings/{id}/approve` | Approve a listing |
| `PATCH` | `/admin/listings/{id}/reject` | Reject a listing with note |
| `GET` | `/admin/reports` | Reports queue |
| `PATCH` | `/admin/reports/{id}/resolve` | Resolve or dismiss a report |
| `GET` | `/admin/payments` | All payment records |
| `GET` | `/admin/promotions` | All promotions |
| `GET` | `/admin/audit-logs` | Admin action audit trail |
| `POST` | `/admin/categories` | Create category |
| `PATCH` | `/admin/categories/{id}` | Update category |

---

## Authentication

The API uses **Firebase Authentication**.

### Flow

```
1. Client authenticates via Firebase SDK (Email/Password, Google, Apple)
2. Client receives a Firebase ID Token (JWT)
3. Client calls `POST /users/sync` to ensure the user exists in MySQL
4. All protected requests pass `Authorization: Bearer <firebase_id_token>`
5. Backend verifies the token using the `firebase-admin` Python SDK
```

### Security Details

- No passwords are stored in the MySQL database (Firebase handles credentials).
- Firebase ID tokens expire after 1 hour (client SDK handles automatic refresh).
- The backend matches `firebase_uid` from the token to the `users` table.
- Blocked/suspended users receive `403 Forbidden` on every authenticated request.
- Role checks are enforced server-side via dependency injection:

```python
# Example dependency
from app.core.dependencies import get_current_user

def require_admin(current_user: User = Depends(get_current_user)):
    if current_user.role not in ("admin", "superadmin"):
        raise HTTPException(status_code=403, detail="Admin access required.")
    return current_user
```

---

## Pagination

All list endpoints support **limit/offset** pagination.

### Request Parameters

| Param | Default | Max | Description |
|---|---|---|---|
| `limit` | `20` | `100` | Number of items per page |
| `offset` | `0` | — | Number of items to skip |

### Response Envelope

Every paginated response includes:

```json
{
  "items": [ /* array of objects */ ],
  "total": 342,
  "limit": 20,
  "offset": 40
}
```

Clients can compute page info:
- `total_pages = ceil(total / limit)`
- `has_next = offset + limit < total`
- `current_page = floor(offset / limit) + 1`

---

## Error Handling

All errors follow a consistent JSON structure:

```json
{
  "detail": "Human-readable error message."
}
```

For validation errors (422), FastAPI returns field-level details:

```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error.email"
    }
  ]
}
```

### HTTP Status Codes

| Code | Meaning | Example |
|---|---|---|
| `200` | OK | Successful GET / PATCH |
| `201` | Created | Resource created |
| `204` | No Content | DELETE or logout |
| `400` | Bad Request | Invalid input |
| `401` | Unauthorized | Missing or invalid token |
| `403` | Forbidden | Insufficient role / suspended user |
| `404` | Not Found | Resource doesn't exist |
| `409` | Conflict | Duplicate (e.g., email already registered, already in favorites) |
| `413` | Payload Too Large | File exceeds size limit |
| `422` | Unprocessable Entity | Pydantic validation failure |
| `500` | Internal Server Error | Unexpected server error |

### Common Business Errors

| Scenario | Status | Detail |
|---|---|---|
| Wrong credentials | `401` | `"Invalid email or password."` |
| Expired token | `401` | `"Token has expired."` |
| Editing another user's listing | `403` | `"You do not own this listing."` |
| User is suspended | `403` | `"Your account has been suspended."` |
| Promoting unapproved listing | `400` | `"Listing must be approved before promotion."` |
| Duplicate favorite | `409` | `"Already in favorites."` |
| Unsupported file type | `415` | `"File type not allowed: .exe"` |

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values.

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



# Email (for password reset notifications)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=no-reply@example.com
SMTP_PASSWORD=smtp-password
```

---

## Setup Instructions

### Prerequisites

- Python 3.11+
- MySQL 8.x running locally or via Docker
- `pip` or `poetry`

### 1. Clone and install dependencies

```bash
git clone https://github.com/your-org/marketplace-backend.git
cd marketplace-backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Firebase Setup

1. Create a Firebase project and enable Authentication.
2. Generate a new private key from **Project Settings > Service Accounts**.
3. Save the JSON file as `firebase-admin.json` in the root directory.

### 3. Configure environment

```bash
cp .env.example .env
# Edit .env with your database credentials and Firebase config
```

### 4. Run database migrations

```bash
alembic upgrade head
```

### 5. (Optional) Seed demo data

```bash
python scripts/seed.py
```

This creates:
- Sample categories, listings, and promotions
- Demo Firebase users must be created manually in the Firebase Console

### 6. Run the development server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**API available at:** http://localhost:8000  
**Swagger UI:** http://localhost:8000/docs  
**ReDoc:** http://localhost:8000/redoc  

---

## Docker Instructions

### Development (Docker Compose)

```bash
# Build and start all services (API + MySQL)
docker compose up --build

# Run in background
docker compose up -d --build

# Apply migrations inside the container
docker compose exec api alembic upgrade head

# View logs
docker compose logs -f api
```

### `docker-compose.yml` Overview

```yaml
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

### `Dockerfile` Overview

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Stopping and Cleaning Up

```bash
# Stop services
docker compose down

# Stop and remove volumes (wipes DB data)
docker compose down -v
```

---

## Demo Accounts

For development/testing, create these users in the **Firebase Console** (Authentication > Users):

| Role | Email |
|---|---|
| Admin | `admin@example.com` |
| User | `demo@example.com` |

> Passwords are managed by Firebase — set them in the Firebase Console. The seed script (`scripts/seed.py`) syncs these users into the local MySQL database with the appropriate roles.

---

## Known Limitations

- Payment gateway is **mocked** — no real money is processed in development
- Push/email notifications are stubbed and log to stdout
- File storage uses local disk in development (Firebase Cloud Storage in production)
- No WebSocket support — messages are polled via REST

---

