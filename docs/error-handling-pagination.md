# Error Handling & Pagination

## Error Handling

All errors follow a consistent JSON structure:

```json
{ "detail": "Human-readable error message." }
```

Validation errors (422) include field-level detail:

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
|------|---------|---------|
| `200` | OK | Successful GET / PATCH |
| `201` | Created | Resource created |
| `204` | No Content | DELETE or logout |
| `400` | Bad Request | Invalid input |
| `401` | Unauthorized | Missing or invalid token |
| `403` | Forbidden | Insufficient role / suspended user |
| `404` | Not Found | Resource doesn't exist |
| `409` | Conflict | Duplicate (e.g. email already registered, already in favorites) |
| `413` | Payload Too Large | File exceeds size limit |
| `415` | Unsupported Media Type | File type not allowed |
| `422` | Unprocessable Entity | Pydantic validation failure |
| `500` | Internal Server Error | Unexpected server error |

### Common Business Errors

| Scenario | Status | Detail |
|----------|--------|--------|
| Wrong credentials | `401` | `"Invalid email or password."` |
| Expired access token | `401` | `"Token has expired."` |
| Editing another user's listing | `403` | `"You do not own this listing."` |
| User is suspended | `403` | `"Your account has been suspended."` |
| Promoting unapproved listing | `400` | `"Listing must be approved before promotion."` |
| Duplicate favorite | `409` | `"Already in favorites."` |
| Unsupported file type | `415` | `"File type not allowed: .exe"` |

---

## Pagination

All list endpoints support **limit/offset** pagination.

### Request Parameters

| Param | Default | Max | Description |
|-------|---------|-----|-------------|
| `limit` | `20` | `100` | Number of items per page |
| `offset` | `0` | — | Number of items to skip |

### Response Envelope

```json
{
  "items": [ ],
  "total": 342,
  "limit": 20,
  "offset": 40
}
```

### Computing Page Info (client-side)

```js
const totalPages = Math.ceil(total / limit)
const hasNext    = offset + limit < total
const currentPage = Math.floor(offset / limit) + 1
```

### FastAPI Example

```python
from fastapi import Query

@router.get("/listings")
def list_listings(
    limit: int = Query(default=20, le=100),
    offset: int = Query(default=0),
    db: Session = Depends(get_db),
):
    total = db.query(Listing).filter(Listing.status == "approved").count()
    items = db.query(Listing).filter(Listing.status == "approved").offset(offset).limit(limit).all()
    return {"items": items, "total": total, "limit": limit, "offset": offset}
```
