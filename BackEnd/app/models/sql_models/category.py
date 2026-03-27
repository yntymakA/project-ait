from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base import Base

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    name = Column(String(100), nullable=False)
    slug = Column(String(100), unique=True, index=True, nullable=False)
    parent_id = Column(Integer, ForeignKey("categories.id"), nullable=True) # car -> parent_id, vehicle -> nothing 
    is_active = Column(Boolean, default=True, nullable=False)
    display_order = Column(Integer, default=0, nullable=False)# category with A is first etc

    # Self-referential relationship
    subcategories = relationship("Category", backref="parent", remote_side=[id]) 
    #sub = db.query(Category).filter_by(name="Легковые").first()print(sub.parent.name) # Выведет "Транспорт"

