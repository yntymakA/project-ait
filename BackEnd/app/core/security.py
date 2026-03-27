from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.core.dependencies import get_db
from app.core.firebase import verify_token
# We will import user repo here soon to get the actual user from DB.
# For now we'll do the token decoding.

security = HTTPBearer()

def get_current_firebase_uid(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """
    Extracts Bearer token, verifies it with Firebase, and returns the token payload.
     "uid": "abc123",
    "email": "user@gmail.com",
    "email_verified": True
}
    """
    token = credentials.credentials
    try:
        decoded_token = verify_token(token)
        return decoded_token
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Coult not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
