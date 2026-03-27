"""
E2E test for Notifications module.
Run: python3 -m scripts.test_notifications
"""
import sys, os, requests
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
BASE = "http://localhost:8000"


def firebase_login(email, password):
    r = requests.post(
        f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}",
        json={"email": email, "password": password, "returnSecureToken": True},
    )
    if r.status_code != 200:
        r = requests.post(
            f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={FIREBASE_WEB_API_KEY}",
            json={"email": email, "password": password, "returnSecureToken": True},
        )
    token = r.json().get("idToken")
    if token:
        requests.post(f"{BASE}/users/sync", headers={"Authorization": f"Bearer {token}"})
    return token


def run():
    print("=" * 55)
    print("Notifications – E2E Test")
    print("=" * 55)

    # ── 1. Auth ────────────────────────────────────────────
    print("\n1. Logging in as seller...")
    token = firebase_login("seller_vip@market.com", "seller123")
    assert token, "❌ Could not get Firebase token"
    h = {"Authorization": f"Bearer {token}"}
    print("   ✅ Authenticated")

    # ── 2. Save FCM device token ──────────────────────────
    print("\n2. Saving FCM device token...")
    r = requests.post(f"{BASE}/notifications/device-token", headers=h,
                      json={"fcm_token": "test_fcm_token_abc123"})
    assert r.status_code == 200, f"❌ {r.text}"
    print(f"   ✅ Device token saved: {r.json()}")

    # ── 3. Seed notifications via DB ──────────────────────
    print("\n3. Seeding test notifications via DB...")
    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker
    engine = create_engine("mysql+pymysql://marketplace_user:password@127.0.0.1:3307/marketplace")
    Session = sessionmaker(bind=engine)
    db = Session()

    from app.models.sql_models.user import User
    from app.models.sql_models.notification import Notification
    from app.models.enums import NotificationTypeEnum

    user = db.query(User).filter(User.email == "seller_vip@market.com").first()
    assert user, "❌ Seller not found in DB"

    # Create 3 test notifications
    for ntype, payload in [
        (NotificationTypeEnum.listing_approved, {"listing_id": 14, "title": "Premium Laptop"}),
        (NotificationTypeEnum.payment_success, {"amount": "15.00", "message": "Balance topped up"}),
        (NotificationTypeEnum.new_message, {"conversation_id": 1, "message": "Is it still available?"}),
    ]:
        n = Notification(user_id=user.id, type=ntype, payload=payload)
        db.add(n)
    db.commit()
    print("   ✅ Created 3 test notifications")
    db.close()

    # ── 4. Get notifications list ─────────────────────────
    print("\n4. Fetching notifications list...")
    r = requests.get(f"{BASE}/notifications", headers=h)
    assert r.status_code == 200, f"❌ {r.text}"
    data = r.json()
    print(f"   ✅ {data['total']} notification(s), {data['unread_count']} unread")
    for item in data["items"][:3]:
        print(f"      • [{item['id']}] {item['type']} | read={item['is_read']} | {item.get('payload', {})}")

    # ── 5. Mark one as read ───────────────────────────────
    notif_id = data["items"][0]["id"]
    print(f"\n5. Marking notification #{notif_id} as read...")
    r = requests.patch(f"{BASE}/notifications/{notif_id}/read", headers=h)
    assert r.status_code == 200, f"❌ {r.text}"
    updated = r.json()
    assert updated["is_read"] is True, "❌ is_read should be True"
    print(f"   ✅ Notification #{notif_id} marked as read")

    # ── 6. Mark all as read ───────────────────────────────
    print("\n6. Marking all notifications as read...")
    r = requests.patch(f"{BASE}/notifications/read-all", headers=h)
    assert r.status_code == 200, f"❌ {r.text}"
    result = r.json()
    print(f"   ✅ {result}")

    # ── 7. Verify unread count is 0 ───────────────────────
    print("\n7. Verifying unread count is now 0...")
    r = requests.get(f"{BASE}/notifications", headers=h)
    assert r.status_code == 200, f"❌ {r.text}"
    data = r.json()
    assert data["unread_count"] == 0, f"❌ Expected 0 unread, got {data['unread_count']}"
    print(f"   ✅ unread_count = {data['unread_count']}")

    print("\n" + "=" * 55)
    print("🎉 All Notifications tests passed!")
    print("=" * 55)


if __name__ == "__main__":
    run()
