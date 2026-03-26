from fastapi import FastAPI, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.dependencies import get_db
from app.routers import users

app = FastAPI(
    title="Marketplace API",
    description="Backend for Marketplace Platform",
    version="1.0.0"
)

app.include_router(users.router)

@app.get("/")
def read_root():
    return {
        "status": "ok",
        "message": "Marketplace API is running",
        "environment": settings.APP_ENV
    }

@app.get("/health")
def health_check(db: Session = Depends(get_db)):
    try:
        # Check DB connection
        db.execute(text("SELECT 1"))
        return {
            "status": "healthy",
            "database": "online"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "offline",
            "detail": str(e)
        }
