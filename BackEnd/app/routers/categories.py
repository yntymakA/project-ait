from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.dependencies import get_db, get_current_user
from app.schemas.category import CategoryTreeResponse, CategoryBase, CategoryResponse
from app.models.sql_models.user import User
from app.services.category import category_service

router = APIRouter(prefix="/categories", tags=["Categories"])

@router.get("", response_model=List[CategoryTreeResponse])
def get_categories(db: Session = Depends(get_db)):
    """
    Returns the active category tree.
    """
    return category_service.get_categories_tree(db)

@router.post("", response_model=CategoryResponse, status_code=201)
def create_category(
    data: CategoryBase,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Create a new category. Requires admin privileges.
    """
    return category_service.create_category(db, current_user, data)


@router.patch("/{category_id}/deactivate")
def deactivate_category(
    category_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Deactivate a category (and its descendants). Requires admin privileges."""
    return category_service.deactivate_category(db, current_user, category_id)
