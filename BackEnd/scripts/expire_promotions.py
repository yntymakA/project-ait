"""
Cron expiry script – call this via a scheduled job (e.g. `crontab`, `systemd timer`, or Cloud Scheduler).

Usage (from project root inside Docker or locally):
    docker exec marketplace_api python -m scripts.expire_promotions

Or add to crontab:
    0 * * * * docker exec marketplace_api python -m scripts.expire_promotions >> /var/log/promo_expiry.log 2>&1
"""
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.repositories import promotion_repo


def main():
    db = SessionLocal()
    try:
        expired_count = promotion_repo.expire_old_promotions(db)
        print(f"✅ Expired {expired_count} promotion(s).")
    finally:
        db.close()


if __name__ == "__main__":
    main()
