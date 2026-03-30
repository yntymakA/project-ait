import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.enums import RoleEnum, UserStatusEnum
from app.models.sql_models.user import User


DEFAULT_ADMIN_EMAIL = "tashmat@gmail.com"
DEFAULT_ADMIN_NAME = "Bootstrap Admin"


def ensure_admin(email: str) -> None:
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()

        if user is None:
            user = User(
                email=email,
                full_name=DEFAULT_ADMIN_NAME,
                firebase_uid=None,
                role=RoleEnum.admin,
                status=UserStatusEnum.active,
            )
            db.add(user)
            db.commit()
            print(f"Created bootstrap admin user: {email}")
            return

        changed = False
        if user.role != RoleEnum.admin:
            user.role = RoleEnum.admin
            changed = True
        if user.status != UserStatusEnum.active:
            user.status = UserStatusEnum.active
            changed = True

        if changed:
            db.commit()
            print(f"Updated bootstrap admin user: {email}")
        else:
            print(f"Bootstrap admin already ready: {email}")
    finally:
        db.close()


if __name__ == "__main__":
    email = os.getenv("BOOTSTRAP_ADMIN_EMAIL", DEFAULT_ADMIN_EMAIL).strip()
    if not email:
        print("BOOTSTRAP_ADMIN_EMAIL is empty, skipping admin bootstrap.")
        raise SystemExit(0)

    ensure_admin(email)
