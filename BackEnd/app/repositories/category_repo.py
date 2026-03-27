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

def get_category_by_slug(db: Session, slug: str) -> Category | None:
    return db.query(Category).filter(Category.slug == slug).first()

def create_category(db: Session, category_data: dict) -> Category:
    db_obj = Category(**category_data)
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj
