from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.dependencies import get_db
from app.schemas.category import CategoryTreeResponse
from app.services.category import category_service

router = APIRouter(prefix="/categories", tags=["Categories"])

@router.get("", response_model=List[CategoryTreeResponse])
def get_categories(db: Session = Depends(get_db)):
    """
    Returns the active category tree.
    """
    return category_service.get_categories_tree(db)
