from sqlalchemy.orm import Session
from app.repositories import category_repo
from app.schemas.category import CategoryTreeResponse

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
