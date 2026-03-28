# API Endpoints Reference

Below is a concise summary of all main API endpoints, their parameters, authentication, and responses, based on your FastAPI routers and models.

---

## Categories

| Method | Path         | Auth | Parameters | Optional | Returns |
|--------|--------------|------|------------|----------|---------|
| GET    | /categories  | ❌   | None       | N/A      | List[CategoryTreeResponse] (category tree)
| POST   | /categories  | 🔐   | CategoryBase (body) | N/A | CategoryResponse (created category)

---

## Favorites

| Method | Path                | Auth | Parameters         | Optional | Returns |
|--------|---------------------|------|--------------------|----------|---------|
| POST   | /favorites/{listing_id} | 🔐 | listing_id (path)  | N/A      | Success message
| DELETE | /favorites/{listing_id} | 🔐 | listing_id (path)  | N/A      | 204 No Content
| GET    | /favorites          | 🔐   | limit, offset (query) | Yes   | Paginated favorites

---

## Listings

| Method | Path                        | Auth | Parameters | Optional | Returns |
|--------|-----------------------------|------|------------|----------|---------|
| GET    | /listings                   | ❌   | See below  | Yes      | Paginated listings
| POST   | /listings                   | 🔐   | Multipart form: title, description, price, currency, city, category_id, is_negotiable, image1, image2, image3 | N/A | ListingResponse
| GET    | /listings/{listing_id}      | ❌   | listing_id (path) | N/A | ListingResponse
| PATCH  | /listings/{listing_id}      | 🔐   | listing_id (path), ListingUpdate (body) | N/A | ListingResponse
| PATCH  | /listings/{listing_id}/images/{image_id}/primary | 🔐 | listing_id, image_id (path) | N/A | Success message

**GET /listings Query Params:**
- q, category_id, city, min_price, max_price, sort, limit, offset

---

## Payments

| Method | Path         | Auth | Parameters | Optional | Returns |
|--------|--------------|------|------------|----------|---------|
| POST   | /payments/top-up | 🔐 | TopUpRequest (body: amount, payment_method) | N/A | TransactionResponse
| GET    | /payments/history | 🔐 | limit, offset (query) | Yes | TransactionListResponse

---

## Promotions

| Method | Path                | Auth | Parameters | Optional | Returns |
|--------|---------------------|------|------------|----------|---------|
| GET    | /promotions/packages | ❌   | None       | N/A      | PromotionPackageListResponse
| POST   | /promotions/purchase | 🔐   | PurchasePromotionRequest (body) | N/A | PromotionResponse

---

## Notifications

| Method | Path                        | Auth | Parameters | Optional | Returns |
|--------|-----------------------------|------|------------|----------|---------|
| GET    | /notifications              | 🔐   | limit, offset (query) | Yes | NotificationListResponse
| PATCH  | /notifications/{notification_id}/read | 🔐 | notification_id (path) | N/A | NotificationResponse
| PATCH  | /notifications/read-all     | 🔐   | None       | N/A      | Success message
| POST   | /notifications/device-token | 🔐   | DeviceTokenRequest (body: fcm_token) | N/A | Success message

---

## Reports

| Method | Path         | Auth | Parameters | Optional | Returns |
|--------|--------------|------|------------|----------|---------|
| POST   | /reports     | 🔐   | ReportCreate (body) | N/A | ReportResponse
| GET    | /reports/my  | 🔐   | status (query), limit, offset | Yes | ReportListResponse

---

## Conversations

| Method | Path                        | Auth | Parameters | Optional | Returns |
|--------|-----------------------------|------|------------|----------|---------|
| POST   | /conversations              | 🔐   | ConversationCreate (body) | N/A | ConversationResponse
| GET    | /conversations              | 🔐   | limit, offset (query) | Yes | ConversationListResponse
| GET    | /conversations/{conversation_id}/messages | 🔐 | conversation_id (path), limit, offset (query) | Yes | MessageListResponse
| POST   | /conversations/{conversation_id}/messages | 🔐 | conversation_id (path), text_body (form), files (form) | Yes | MessageResponse

---

## Users

| Method | Path                        | Auth | Parameters | Optional | Returns |
|--------|-----------------------------|------|------------|----------|---------|
| POST   | /users/sync                 | 🔐   | None (uses Bearer Firebase ID token) | N/A | UserSyncResponse
| GET    | /users/me                   | 🔐   | None       | N/A      | UserResponse
| PATCH  | /users/me                   | 🔐   | UserUpdate (body) | N/A | UserResponse
| POST   | /users/me/avatar            | 🔐   | file (form) | N/A | profile_image_url
| GET    | /users/public/{user_id}     | ❌   | user_id (path) | N/A | PublicUserResponse
| GET    | /users/public/{user_id}/listings | ❌ | user_id (path), limit, offset (query) | Yes | Paginated listings

---

> _All endpoints marked with 🔐 require Authorization: Bearer <firebase_id_token> header._
> _Paginated responses use limit/offset. See models for detailed response schemas._
