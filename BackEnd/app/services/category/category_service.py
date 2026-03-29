from sqlalchemy.orm import Session
from app.repositories import category_repo
from app.schemas.category import CategoryTreeResponse, CategoryBase, CategoryResponse
from app.models.sql_models.user import User
from app.models.enums import RoleEnum
from fastapi import HTTPException

def get_categories_tree(db: Session, include_inactive: bool = False) -> list[CategoryTreeResponse]:
    """
    Recursively fetch categories and build a nested tree sequence.
    """
    def build_tree(parent_id: int | None) -> list[CategoryTreeResponse]:
        categories = category_repo.get_categories(db, parent_id, include_inactive=include_inactive)
        result = []
        for cat in categories:
            node = CategoryTreeResponse.model_validate(cat)
            node.children = build_tree(cat.id)
            result.append(node)
        return result
    
    return build_tree(None)

def create_category(db: Session, user: User, data: CategoryBase) -> CategoryResponse:
    if user.role != RoleEnum.admin:
        raise HTTPException(status_code=403, detail="Only admins can create categories")
        
    if category_repo.get_category_by_slug(db, data.slug):
        raise HTTPException(status_code=400, detail="Category with this slug already exists")
        
    if data.parent_id is not None:
        if not category_repo.get_category_by_id(db, data.parent_id):
            raise HTTPException(status_code=404, detail="Parent category not found")
            
    cat = category_repo.create_category(db, data.model_dump())
    return CategoryResponse.model_validate(cat)


def deactivate_category(db: Session, user: User, category_id: int) -> dict:
    if user.role != RoleEnum.admin:
        raise HTTPException(status_code=403, detail="Only admins can deactivate categories")

    category = category_repo.get_category_by_id(db, category_id)
    if category is None:
        raise HTTPException(status_code=404, detail="Category not found")

    affected = category_repo.deactivate_category_and_descendants(db, category_id)
    return {
        "ok": True,
        "deactivated_count": affected,
    }


def activate_category(db: Session, user: User, category_id: int) -> dict:
    if user.role != RoleEnum.admin:
        raise HTTPException(status_code=403, detail="Only admins can activate categories")

    category = category_repo.get_category_by_id_any_status(db, category_id)
    if category is None:
        raise HTTPException(status_code=404, detail="Category not found")

    affected = category_repo.activate_category_and_descendants(db, category_id)
    return {
        "ok": True,
        "activated_count": affected,
    }
