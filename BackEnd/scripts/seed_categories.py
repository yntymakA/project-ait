import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.sql_models.category import Category

def seed():
    db = SessionLocal()
    try:
        print("Starting category seeding...")
        # Create parent categories
        parents = [
            {"name": "Residential Sales", "slug": "residential-sales", "display_order": 1},
            {"name": "Residential Rent", "slug": "residential-rent", "display_order": 2},
            {"name": "Commercial", "slug": "commercial", "display_order": 3},
            {"name": "Land", "slug": "land", "display_order": 4},
        ]
        
        parent_objs = []
        for p in parents:
            cat = db.query(Category).filter(Category.slug == p["slug"]).first()
            if not cat:
                cat = Category(**p)
                db.add(cat)
                print(f"Added parent: {p['name']}")
            parent_objs.append(cat)
        
        db.commit()
        
        for cat in parent_objs:
            db.refresh(cat)
            
        # Create subcategories
        subs = [
            {"name": "Apartments", "slug": "apartments-sale", "parent_id": parent_objs[0].id, "display_order": 1},
            {"name": "Houses", "slug": "houses-sale", "parent_id": parent_objs[0].id, "display_order": 2},
            {"name": "Villas", "slug": "villas-sale", "parent_id": parent_objs[0].id, "display_order": 3},
            
            {"name": "Apartments", "slug": "apartments-rent", "parent_id": parent_objs[1].id, "display_order": 1},
            {"name": "Rooms", "slug": "rooms-rent", "parent_id": parent_objs[1].id, "display_order": 2},
            
            {"name": "Offices", "slug": "offices", "parent_id": parent_objs[2].id, "display_order": 1},
            {"name": "Retail Space", "slug": "retail", "parent_id": parent_objs[2].id, "display_order": 2},
            
            {"name": "Agricultural", "slug": "land-agricultural", "parent_id": parent_objs[3].id, "display_order": 1},
            {"name": "Construction", "slug": "land-construction", "parent_id": parent_objs[3].id, "display_order": 2},
        ]
        
        for s in subs:
            if not db.query(Category).filter(Category.slug == s["slug"]).first():
                db.add(Category(**s))
                print(f"Added subcategory: {s['name']}")
                
        db.commit()
        print("✅ Successfully seeded all real estate categories!")
        
    except Exception as e:
        print("❌ Error seeding categories:", str(e))
    finally:
        db.close()

if __name__ == "__main__":
    seed()
