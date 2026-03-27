"""
E2E test for User endpoints (Part 2).
Run: python3 -m scripts.test_user_public
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
    print("=" * 55)
    print("User Endpoints – E2E Test")
    print("=" * 55)

    # ── 1. Auth ────────────────────────────────────────────
    print("\n1. Logging in as seller...")
    token = firebase_login("seller_vip@market.com", "seller123")
    assert token, "❌ Auth failed"
    h = {"Authorization": f"Bearer {token}"}
    print("   ✅ Authenticated")

    # ── 2. Get current user to find user_id ────────────────
    print("\n2. Fetching /users/me to get user_id...")
    r = requests.get(f"{BASE}/users/me", headers=h)
    assert r.status_code == 200, f"❌ {r.text}"
    me = r.json()
    user_id = me["id"]
    print(f"   ✅ User #{user_id}: {me['full_name']} ({me['email']})")

    # ── 3. Public profile ──────────────────────────────────
    print(f"\n3. Fetching PUBLIC profile: GET /users/public/{user_id} (no auth)...")
    r = requests.get(f"{BASE}/users/public/{user_id}")  # No auth header!
    assert r.status_code == 200, f"❌ {r.text}"
    profile = r.json()
    print(f"   ✅ Public profile:")
    print(f"      Name: {profile['full_name']}")
    print(f"      City: {profile.get('city', 'N/A')}")
    print(f"      Member since: {profile['member_since']}")
    print(f"      Active listings: {profile['active_listing_count']}")
    print(f"      Avatar: {profile.get('profile_image_url', 'None')}")

    # Verify no sensitive data
    assert "email" not in profile, "❌ Email should NOT be in public profile!"
    assert "phone" not in profile, "❌ Phone should NOT be in public profile!"
    assert "firebase_uid" not in profile, "❌ firebase_uid should NOT be in public profile!"
    print("   ✅ No sensitive data exposed (email, phone, firebase_uid)")

    # ── 4. Seller's listings ───────────────────────────────
    print(f"\n4. Fetching seller listings: GET /users/public/{user_id}/listings (no auth)...")
    r = requests.get(f"{BASE}/users/public/{user_id}/listings")
    assert r.status_code == 200, f"❌ {r.text}"
    data = r.json()
    print(f"   ✅ {data['total']} listings found (limit={data['limit']}, offset={data['offset']})")
    for item in data.get("items", [])[:3]:
        print(f"      • [{item.get('id', '?')}] {item.get('title', 'N/A')}")

    # ── 5. 404 for non-existent user ───────────────────────
    print("\n5. Testing 404 for non-existent user...")
    r = requests.get(f"{BASE}/users/public/999999")
    assert r.status_code == 404, f"❌ Expected 404, got {r.status_code}"
    print("   ✅ Correctly returns 404")

    # ── 6. Avatar upload endpoint exists ───────────────────
    print("\n6. Verifying avatar upload endpoint exists...")
    # Won't actually upload (Firebase Storage not configured in dev), 
    # but endpoint should respond properly
    r = requests.post(f"{BASE}/users/me/avatar", headers=h)
    # Should get 422 (no file provided) — not 404 or 405
    assert r.status_code == 422, f"❌ Expected 422 (no file), got {r.status_code}: {r.text}"
    print("   ✅ POST /users/me/avatar endpoint is registered (422 = no file provided)")

    print("\n" + "=" * 55)
    print("🎉 All User Endpoint tests passed!")
    print("=" * 55)


if __name__ == "__main__":
    run()
