from sqlalchemy.orm import Session
from app.repositories import category_repo
from app.schemas.category import CategoryTreeResponse, CategoryBase, CategoryResponse
from app.models.sql_models.user import User
from fastapi import HTTPException

def get_categories_tree(db: Session) -> list[CategoryTreeResponse]:
    """
    Recursively fetch categories and build a nested tree sequence.
    """
    def build_tree(parent_id: int | None) -> list[CategoryTreeResponse]:
        categories = category_repo.get_active_categories(db, parent_id)
        result = []
        for cat in categories:
            node = CategoryTreeResponse.model_validate(cat)
            node.children = build_tree(cat.id)
            result.append(node)
        return result
    
    return build_tree(None)

def create_category(db: Session, user: User, data: CategoryBase) -> CategoryResponse:
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can create categories")
        
    if category_repo.get_category_by_slug(db, data.slug):
        raise HTTPException(status_code=400, detail="Category with this slug already exists")
        
    if data.parent_id is not None:
        if not category_repo.get_category_by_id(db, data.parent_id):
            raise HTTPException(status_code=404, detail="Parent category not found")
            
    cat = category_repo.create_category(db, data.model_dump())
    return CategoryResponse.model_validate(cat)
