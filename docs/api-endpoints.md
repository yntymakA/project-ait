# API Endpoints Reference

> **Base URL:** `http://localhost:8000`  
> Full interactive docs: [`/docs`](http://localhost:8000/docs) (Swagger UI) · [`/redoc`](http://localhost:8000/redoc)  
> 🔐 = Requires `Authorization: Bearer <firebase_id_token>`

---

## Users — `/users`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/users/sync` | 🔐 | Sync a newly created Firebase user to the local DB |
| `GET` | `/users/me` | 🔐 | Get own profile |
| `PATCH` | `/users/me` | 🔐 | Update own profile |
| `POST` | `/users/me/balance/top-up` | 🔐 | Top up virtual balance (for academic demo) |
| `POST` | `/users/me/avatar` | 🔐 | Upload profile image (multipart) |
| `GET` | `/public/users/{user_id}` | ❌ | Public owner profile |
| `GET` | `/public/users/{user_id}/listings` | ❌ | Owner's active listings (paginated) |

---

## Listings — `/listings`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/listings` | ❌ | Browse / search listings |
| `POST` | `/listings` | 🔐 | Create a new listing |
| `GET` | `/listings/{id}` | ❌ | Get listing detail |
| `PATCH` | `/listings/{id}` | 🔐 | Update own listing |
| `DELETE` | `/listings/{id}` | 🔐 | Soft-delete own listing |
| `POST` | `/listing-media/{listing_id}` | 🔐 | Upload images (multipart, up to 10) |

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
| `PATCH` | `/notifications/{id}/read` | 🔐 | Mark notification as read |

---

## Reports — `/reports`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/reports` | 🔐 | Submit a report (listing / user / message) |

---

## Transactions (History)

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/transactions` | 🔐 | User's balance history (top-ups, spends) |

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
| `GET` | `/admin/dashboard` | Platform stats & KPIs |
| `GET` | `/admin/users` | Search / list all users |
| `GET` | `/admin/users/{id}` | User detail with listings, payments |
| `PATCH` | `/admin/users/{id}/suspend` | Suspend a user |
| `PATCH` | `/admin/users/{id}/unsuspend` | Unsuspend a user |
| `GET` | `/admin/listings` | All listings with filters |
| `PATCH` | `/admin/listings/{id}/approve` | Approve a listing |
| `PATCH` | `/admin/listings/{id}/reject` | Reject a listing with note |
| `GET` | `/admin/reports` | Reports queue |
| `PATCH` | `/admin/reports/{id}/resolve` | Resolve or dismiss a report |
| `GET` | `/admin/transactions` | All platform transactions |
| `GET` | `/admin/promotions` | All promotions |
| `GET` | `/admin/audit-logs` | Admin action audit trail |
| `POST` | `/admin/categories` | Create category |
| `PATCH` | `/admin/categories/{id}` | Update category |
