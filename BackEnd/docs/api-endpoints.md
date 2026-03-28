# API Endpoints Reference

> **Base URL:** `http://localhost:8000/api/v1`  
> Full interactive docs: [`/docs`](http://localhost:8000/api/v1/docs) (Swagger UI) · [`/redoc`](http://localhost:8000/api/v1/redoc)  
> 🔐 = Requires `Authorization: Bearer <firebase_id_token>`
> 🌍 = Localization Supported. Send `Accept-Language` header (`en` or `ru`).

---

## Users — `/users`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/users/sync` | 🔐 | Sync a newly created Firebase user to the local DB |
| `GET` | `/users/me` | 🔐 | Get own profile |
| `PATCH` | `/users/me` | 🔐 | Update own profile |
| `POST` | `/users/me/avatar` | 🔐 | Upload profile image (multipart) |
| `GET` | `/users/public/{user_id}` | ❌ | Public owner profile |
| `GET` | `/users/public/{user_id}/listings` | ❌ | Owner's active listings (paginated) |

---

## Listings — `/listings`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/listings` | ❌ | Browse / search listings |
| `POST` | `/listings` | 🔐 | Create a new listing (includes exactly 3 multipart images `image1`, `image2`, `image3`) |
| `GET` | `/listings/{id}` | ❌ | Get listing detail |
| `PATCH` | `/listings/{id}` | 🔐 | Update own listing (text fields only) |
| `PATCH` | `/listings/{listing_id}/images/{image_id}/primary` | 🔐 | Set one of the images as primary |

### `GET /listings` Query Params

| Param | Type | Description |
|-------|------|-------------|
| `q` | string | Keyword search (title, description) |
| `category_id` | int | Filter by category |
| `city` | string | Filter by city |
| `min_price` | float | Minimum price |
| `max_price` | float | Maximum price |
| `sort` | string | `newest`, `oldest`, `price_asc`, `price_desc` |
| `limit` | int | Page size (default: 20, max: 100) |
| `offset` | int | Offset (default: 0) |

---

## Favorites — `/favorites`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/favorites/{listing_id}` | 🔐 | Add to favorites |
| `DELETE` | `/favorites/{listing_id}` | 🔐 | Remove from favorites |
| `GET` | `/favorites` | 🔐 | List saved listings (paginated) |

---

## Conversations & Messages

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/conversations` | 🔐 | Start or reopen a conversation |
| `GET` | `/conversations` | 🔐 | List user's conversations (paginated) |
| `GET` | `/conversations/{id}/messages` | 🔐 | Get messages (participants only) |
| `POST` | `/conversations/{id}/messages` | 🔐 | Send a message (text and/or files, max 5) |

---

## Notifications — `/notifications`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/notifications` | 🔐 | List user's notifications |
| `PATCH` | `/notifications/read-all` | 🔐 | Mark all notifications as read |
| `PATCH` | `/notifications/{notification_id}/read` | 🔐 | Mark a specific notification as read |
| `POST` | `/notifications/device-token` | 🔐 | Register FCM device token for push |

---

## Reports — `/reports`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/reports` | 🔐 | Submit a report (listing / user / message) |
| `GET` | `/reports/my` | 🔐 | Get your submitted reports (paginated) |

---

## Payments — `/payments`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/payments/top-up` | 🔐 | Add testing funds to user balance |
| `GET` | `/payments/history` | 🔐 | View transaction history |

---

## Promotions — `/promotions`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/promotions` | 🔐 | Purchase a promotion (deducts from user's `balance`) |

**Promotion types:** `featured`, `boosted`, `top_feed`

---

## Categories — `/categories`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/categories` | ❌ | List all categories with subcategories |

---

## Admin — `/admin/*` 🔐 *(admin role required)*

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/admin/stats` | Platform stats & KPIs |
| `GET` | `/admin/reports` | Get reports queue |
| `PATCH` | `/admin/reports/{report_id}/status` | Change report status (`resolved` or `dismissed`) |
| `PATCH` | `/admin/users/{user_id}/status` | Change user status (e.g. `suspended` or `active`) |
| `PATCH` | `/admin/listings/{listing_id}/moderation` | Approve or reject a listing by ID |
