from sqlalchemy.orm import Session
from app.models.sql_models.category import Category

def get_active_categories(db: Session, parent_id: int | None = None) -> list[Category]:
    query = db.query(Category).filter(Category.is_active == True)
    if parent_id is not None:
        query = query.filter(Category.parent_id == parent_id)
    else:
        query = query.filter(Category.parent_id == None)
    return query.order_by(Category.display_order).all()

def get_category_by_id(db: Session, category_id: int) -> Category | None:
    return db.query(Category).filter(Category.id == category_id, Category.is_active == True).first()
