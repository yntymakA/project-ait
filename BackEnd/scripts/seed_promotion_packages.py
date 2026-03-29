"""
Seed standard promotion packages into the DB.
Run once after migration:
    docker exec -it marketplace_api python -m scripts.seed_promotion_packages
"""
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.sql_models.promotion_package import PromotionPackage
from app.models.enums import PromotionTypeEnum

DB_URL = "mysql+pymysql://marketplace_user:password@127.0.0.1:3307/marketplace"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)

PACKAGES = [
    dict(name="Featured Badge (7 days)", promotion_type=PromotionTypeEnum.featured, duration_days=7, price=5.00, is_active=True),
    dict(name="Featured Badge (30 days)", promotion_type=PromotionTypeEnum.featured, duration_days=30, price=15.00, is_active=True),
]

def main():
    db = Session()
    created = 0
    for pkg_data in PACKAGES:
        exists = db.query(PromotionPackage).filter_by(name=pkg_data["name"]).first()
        if not exists:
            db.add(PromotionPackage(**pkg_data))
            created += 1
    db.commit()
    print(f"✅ Seeded {created} new promotion package(s) (skipped {len(PACKAGES)-created} that already existed).")
    db.close()

if __name__ == "__main__":
    main()
