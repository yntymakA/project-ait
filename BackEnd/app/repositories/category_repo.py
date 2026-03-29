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


def get_direct_children(db: Session, parent_id: int) -> list[Category]:
    return db.query(Category).filter(Category.parent_id == parent_id).all()


def deactivate_category_and_descendants(db: Session, category_id: int) -> int:
    to_process = [category_id]
    visited: set[int] = set()
    deactivated_count = 0

    while to_process:
        current_id = to_process.pop()
        if current_id in visited:
            continue
        visited.add(current_id)

        category = db.query(Category).filter(Category.id == current_id).first()
        if category is not None and category.is_active:
            category.is_active = False
            deactivated_count += 1

        children = get_direct_children(db, current_id)
        to_process.extend(child.id for child in children)

    db.commit()
    return deactivated_count
