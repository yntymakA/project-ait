from collections.abc import Generator
from sqlalchemy.orm import Session
from app.db.session import SessionLocal

def get_db() -> Generator[Session, None, None]:
    """
    FastAPI dependency that provides a SQLAlchemy session for a request and closes it when done.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
