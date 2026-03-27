# Data Models Reference

All SQLAlchemy ORM models and the key Pydantic schemas used in the marketplace platform.

---

## Database: MySQL 8.x

All tables use `BIGINT` primary keys (auto-increment) and `DATETIME` timestamps.

---

## SQL Models (`models/`)

### `users`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | Auto-increment |
| `firebase_uid` | VARCHAR(128) UNIQUE | Firebase User ID, nullable |
| `full_name` | VARCHAR(255) | Required |
| `email` | VARCHAR(255) UNIQUE | Required |
| `phone` | VARCHAR(30) UNIQUE | Optional |
| `balance` | DECIMAL(10,2) | Default: 0.00 (Для симуляции пополнений) |
| `role` | ENUM | `guest`, `authenticated_user`, `admin` |
| `status` | ENUM | `active`, `blocked`, `deleted` |
| `profile_image_url` | TEXT | |
| `bio` | TEXT | |
| `city` | VARCHAR(100) | |
| `preferred_language` | VARCHAR(10) | `en`, `ru`|
| `last_seen_at` | DATETIME | |
| `created_at` | DATETIME | |
| `updated_at` | DATETIME | |

---

### `categories`

| Column | Type | Notes |
|--------|------|-------|
| `id` | INT PK | |
| `name` | VARCHAR(100) | |
| `slug` | VARCHAR(100) UNIQUE | |
| `parent_id` | INT FK | Self-referential (subcategories) |
| `is_active` | BOOL | |
| `display_order` | INT | |

---

### `listings`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `owner_id` | BIGINT FK → users | |
| `category_id` | INT FK → categories | |
| `title` | VARCHAR(255) | |
| `description` | TEXT | |
| `price` | DECIMAL(12,2) | |
| `currency` | VARCHAR(10) | |
| `city` | VARCHAR(100) | |
| `status` | ENUM | `draft`, `pending_review`, `approved`, `rejected`, `archived`, `sold` |
| `moderation_status` | ENUM | `pending`, `approved`, `rejected` |
| `promotion_status` | ENUM | `none`, `active`, `expired` |
| `view_count` | INT | |
| `is_negotiable` | BOOL | |
| `deleted_at` | DATETIME | Soft delete |
| `published_at` | DATETIME | |
| `expires_at` | DATETIME | |
| `created_at` | DATETIME | |
| `updated_at` | DATETIME | |

---

### `listing_images`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `listing_id` | BIGINT FK | |
| `file_url` | TEXT | |
| `is_primary` | BOOL | |
| `order_index` | INT | |
| `created_at` | DATETIME | |

---

### `conversations`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `listing_id` | BIGINT FK | Context listing |
| `participant_a_id` | BIGINT FK → users | |
| `participant_b_id` | BIGINT FK → users | |
| `last_message_at` | DATETIME | |
| `created_at` | DATETIME | |

---

### `messages`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `conversation_id` | BIGINT FK | |
| `sender_id` | BIGINT FK → users | |
| `message_type` | ENUM | `text`, `attachment` |
| `text_body` | TEXT | |
| `is_read` | BOOL | |
| `sent_at` | DATETIME | |
| `deleted_at` | DATETIME | Soft delete |

---

### `message_attachments`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `message_id` | BIGINT FK | |
| `file_name` | VARCHAR(255) | Sanitized |
| `original_name` | VARCHAR(255) | |
| `mime_type` | VARCHAR(100) | |
| `file_size` | INT | Bytes |
| `file_url` | TEXT | |
| `created_at` | DATETIME | |

---

### `favorites`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `user_id` | BIGINT FK | |
| `listing_id` | BIGINT FK | |
| `created_at` | DATETIME | `UNIQUE(user_id, listing_id)` |

---

### `notifications`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `user_id` | BIGINT FK | |
| `type` | ENUM | `listing_approved`, `new_message`, `payment_success`, etc. |
| `is_read` | BOOL | |
| `payload` | JSON | Optional context |
| `created_at` | DATETIME | |

---

### `reports`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `reporter_user_id` | BIGINT FK | |
| `target_type` | ENUM | `listing`, `user`, `message` |
| `target_id` | BIGINT | |
| `reason_code` | VARCHAR(50) | `spam`, `scam`, `duplicate`, etc. |
| `reason_text` | TEXT | |
| `status` | ENUM | `pending`, `resolved`, `dismissed` |
| `reviewed_by_admin_id` | BIGINT FK | Nullable |
| `resolution_note` | TEXT | |
| `created_at` | DATETIME | |
| `reviewed_at` | DATETIME | |

---

### `transactions` (История пополнений и списаний)

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `user_id` | BIGINT FK | |
| `type` | ENUM | `top_up` (пополнение), `spend` (покупка продвижения) |
| `amount` | DECIMAL(12,2) | |
| `description` | VARCHAR(255) | Например: "Пополнение баланса" или "Продвижение объявления #10" |
| `created_at` | DATETIME | |

---

### `promotions`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `listing_id` | BIGINT FK | |
| `user_id` | BIGINT FK | |
| `package_id` | INT FK | Nullable |
| `promotion_type` | ENUM | `featured`, `boosted`, `top_feed` |
| `target_city` | VARCHAR(100) | |
| `target_category_id` | INT FK | |
| `starts_at` | DATETIME | |
| `ends_at` | DATETIME | |
| `status` | ENUM | `pending`, `active`, `expired`, `cancelled` |
| `purchased_price` | DECIMAL(12,2) | |
| `created_at` | DATETIME | |

---

### `promotion_packages`

| Column | Type | Notes |
|--------|------|-------|
| `id` | INT PK | Auto-increment |
| `name` | VARCHAR(100) | |
| `promotion_type` | ENUM | `featured`, `boosted`, `top_feed` |
| `duration_days` | INT | |
| `price` | DECIMAL(12,2) | |
| `is_active` | BOOL | |

---

### `admin_audit_logs`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT PK | |
| `admin_id` | BIGINT FK → users | |
| `action` | VARCHAR(100) | e.g. `suspend_user`, `approve_listing` |
| `target_type` | VARCHAR(50) | |
| `target_id` | BIGINT | |
| `note` | TEXT | |
| `created_at` | DATETIME | |

---

## Pydantic Schemas (`schemas/`)

### Pattern

Each domain has a schema file with request and response models:

```python
# schemas/listing.py

class CreateListingRequest(BaseModel):
    title: str
    description: str
    price: float
    currency: str = "USD"
    city: str
    category_id: int
    is_negotiable: bool = False

class ListingResponse(BaseModel):
    id: int
    title: str
    price: float
    status: str
    owner: UserCardResponse
    created_at: datetime

    class Config:
        from_attributes = True
```

### Pagination Envelope

All list responses share this shape:

```python
class PaginatedResponse(BaseModel):
    items: list
    total: int
    limit: int
    offset: int
```

---

## User Roles

| Role | Value | Permissions |
|------|-------|-------------|
| `guest` | base | Unauthenticated guest/read-only access |
| `authenticated_user` | default | Browse, list, message, favorite, report |
| `admin` | admin | Full admin panel + user management |

## User Statuses

| Status | Meaning |
|--------|---------|
| `active` | Normal access |
| `blocked` | Cannot authenticate |
| `deleted` | Soft-deleted account |

## Listing Statuses

| Status | Meaning |
|--------|---------|
| `draft` | Just created, not submitted |
| `pending_review` | Submitted, waiting for moderation |
| `approved` | Visible to public |
| `rejected` | Rejected by admin with note |
| `archived` | Hidden by owner |
| `sold` | Marked as sold |
