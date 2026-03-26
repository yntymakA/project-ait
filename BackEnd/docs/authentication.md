# Authentication

The API uses **Firebase Authentication**.

## Flow

```
1. Client authenticates via Firebase SDK (Email/Password, Google, Apple)
2. Client receives a Firebase ID Token (JWT)
3. Client calls `POST /users/sync` to ensure the user exists in MySQL
4. Protected requests pass `Authorization: Bearer <firebase_id_token>`
5. Backend verifies the token using the `firebase-admin` Python SDK
```

## Endpoints

### `POST /users/sync` 🔐

Syncs a newly authenticated Firebase user with the MySQL database. Call this after a user signs up on the client.

**Request:** Empty body. Token contains Firebase UID, email, etc.
**Response `200`:**
```json
{
  "id": 1,
  "firebase_uid": "ABC123XYZ",
  "email": "john@example.com",
  "full_name": "John Smith",
  "status": "active",
  "role": "user",
  "created_at": "2026-03-27T00:00:00Z"
}
```

---

## Security Details

- **No passwords are stored** in the MySQL database (Firebase handles credentials).
- Firebase ID tokens expire after 1 hour (client SDK handles automatic refresh).
- The backend matches `firebase_uid` from the token to the `users` table.
- Blocked/suspended users receive `403 Forbidden` on every authenticated request.

## Validating Tokens

The backend uses `firebase-admin` to verify incoming tokens:

```python
from firebase_admin import auth

def verify_token(token: str):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token["uid"]
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## Role-Based Access

```python
# core/dependencies.py

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    firebase_uid = verify_token(token)
    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()
    if not user or user.status == "blocked":
        raise HTTPException(status_code=403, detail="Access denied.")
    return user

def require_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in ("admin", "superadmin"):
        raise HTTPException(status_code=403, detail="Admin access required.")
    return current_user
```

| Role | Can access |
|------|-----------|
| `user` | Own profile, listings, messages, favorites |
| `moderator` | + Listing moderation |
| `admin` | + Full admin panel |
| `superadmin` | + Platform configuration |
