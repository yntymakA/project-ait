"""
Integration test: Trigger a REAL top-up and verify that
a payment_success notification is created AUTOMATICALLY.
Run: python3 -m scripts.test_notification_integration
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
    token = r.json().get("idToken")
    if token:
        requests.post(f"{BASE}/users/sync", headers={"Authorization": f"Bearer {token}"})
    return token


def run():
    print("=" * 60)
    print("Integration Test: Notifications triggered by REAL actions")
    print("=" * 60)

    # ── Auth ────────────────────────────────────────────────
    print("\n1. Logging in...")
    token = firebase_login("seller_vip@market.com", "seller123")
    assert token, "❌ Auth failed"
    h = {"Authorization": f"Bearer {token}"}
    print("   ✅ Authenticated")

    # ── Clear old notifications count ──────────────────────
    r = requests.get(f"{BASE}/notifications", headers=h)
    before_total = r.json()["total"]
    print(f"\n2. Current notifications: {before_total}")

    # ── Trigger: Top-up $5 ─────────────────────────────────
    print("\n3. Triggering: POST /payments/top-up ($5.00)...")
    r = requests.post(f"{BASE}/payments/top-up", headers=h, json={"amount": 5.0})
    assert r.status_code == 201, f"❌ Top-up failed: {r.text}"
    print(f"   ✅ Top-up successful: Transaction #{r.json()['id']}")

    # ── Check: notification was AUTO-created ───────────────
    print("\n4. Checking notifications AFTER top-up...")
    r = requests.get(f"{BASE}/notifications", headers=h)
    assert r.status_code == 200
    after = r.json()
    after_total = after["total"]
    print(f"   Total notifications: {before_total} → {after_total}")

    # Find the new payment_success notification
    new_notifs = [n for n in after["items"] if n["type"] == "payment_success" and not n["is_read"]]
    assert len(new_notifs) > 0, "❌ No payment_success notification was created!"
    latest = new_notifs[0]
    print(f"   ✅ AUTO-CREATED notification found:")
    print(f"      ID: {latest['id']}")
    print(f"      Type: {latest['type']}")
    print(f"      Payload: {latest['payload']}")
    print(f"      Created: {latest['created_at']}")

    print("\n" + "=" * 60)
    print("🎉 Notifications are triggered AUTOMATICALLY by real actions!")
    print("=" * 60)


if __name__ == "__main__":
    run()
