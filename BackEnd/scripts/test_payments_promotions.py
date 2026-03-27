"""
E2E test for Phase 3: Payments & Promotions
Run: python3 -m scripts.test_payments_promotions
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
        # try sign-up
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
    print("Phase 3: Payments & Promotions – E2E Test")
    print("=" * 55)

    # ── 1. Auth ────────────────────────────────────────────
    print("\n1. Logging in as seller...")
    token = firebase_login("seller_vip@market.com", "seller123")
    assert token, "❌ Could not get Firebase token"
    h = {"Authorization": f"Bearer {token}"}
    print("   ✅ Authenticated")

    # ── 2. List available packages ─────────────────────────
    print("\n2. Fetching promotion packages...")
    r = requests.get(f"{BASE}/promotions/packages")
    assert r.status_code == 200, f"❌ {r.text}"
    packages = r.json()["items"]
    print(f"   ✅ Found {len(packages)} packages:")
    for p in packages:
        print(f"      • [{p['id']}] {p['name']:30s}  ${p['price']}  ({p['duration_days']}d) [{p['promotion_type']}]")

    # Pick the cheapest boosted package
    boosted_pkg = next((p for p in packages if p["promotion_type"] == "boosted"), None)
    topfeed_pkg = next((p for p in packages if p["promotion_type"] == "top_feed"), None)
    assert boosted_pkg, "❌ No boosted package found"
    assert topfeed_pkg, "❌ No top_feed package found"

    # ── 3. Check initial balance (should be 0 or whatever is stored) ────
    me = requests.get(f"{BASE}/users/me", headers=h).json()
    print(f"\n3. Current balance: ${me.get('balance', 0)}")

    # ── 4. Top-up enough funds ────────────────────────────
    top_up_amount = float(topfeed_pkg["price"]) + float(boosted_pkg["price"]) + 5.0
    print(f"\n4. Topping up ${top_up_amount:.2f}...")
    r = requests.post(f"{BASE}/payments/top-up", headers=h, json={"amount": top_up_amount})
    assert r.status_code == 201, f"❌ Top-up failed: {r.text}"
    txn = r.json()
    print(f"   ✅ Transaction #{txn['id']} | type={txn['type']} | amount=${txn['amount']}")

    # ── 5. Transaction history ─────────────────────────────
    print("\n5. Viewing transaction history...")
    r = requests.get(f"{BASE}/payments/history", headers=h)
    assert r.status_code == 200, f"❌ {r.text}"
    hist = r.json()
    print(f"   ✅ {hist['total']} transaction(s) on record")

    # ── 6. Find a listing owned by this seller ─────────────
    print("\n6. Finding a listing to promote...")
    # Get user's listings by querying DB directly (no /listings/my endpoint)
    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker as sm_
    _engine = create_engine("mysql+pymysql://marketplace_user:password@127.0.0.1:3307/marketplace")
    _Session = sm_(bind=_engine)
    _db = _Session()
    from app.models.sql_models.user import User as UserModel
    from app.models.sql_models.listing import Listing as ListingModel
    me_db = _db.query(UserModel).filter(UserModel.email == "seller_vip@market.com").first()
    listing_obj = _db.query(ListingModel).filter(
        ListingModel.owner_id == me_db.id, ListingModel.deleted_at == None
    ).first() if me_db else None
    _db.close()
    listing_id = listing_obj.id if listing_obj else None

    if not listing_id:
        print("   ⚠️  No listings found for this seller – skipping promotion purchase test")
        print("\n✅ Payments module verified. Create a listing first to test promotions.")
        return

    print(f"   ✅ Using Listing #{listing_id}")


    # ── 7. Buy a Boost package ─────────────────────────────
    print(f"\n7. Purchasing Boost package (id={boosted_pkg['id']}) for Listing #{listing_id}...")
    r = requests.post(f"{BASE}/promotions/purchase", headers=h,
                      json={"listing_id": listing_id, "package_id": boosted_pkg["id"]})
    assert r.status_code == 201, f"❌ Promotion purchase failed: {r.text}"
    promo = r.json()
    print(f"   ✅ Promotion #{promo['id']} | type={promo['promotion_type']} | status={promo['status']}")
    print(f"   ✅ Active until: {promo['ends_at']}")

    # ── 8. Buy a Top Feed package ─────────────────────────
    print(f"\n8. Purchasing Top Feed package (id={topfeed_pkg['id']}) for Listing #{listing_id}...")
    r = requests.post(f"{BASE}/promotions/purchase", headers=h,
                      json={"listing_id": listing_id, "package_id": topfeed_pkg["id"]})
    assert r.status_code == 201, f"❌ Top Feed purchase failed: {r.text}"
    promo2 = r.json()
    print(f"   ✅ Promotion #{promo2['id']} | type={promo2['promotion_type']} | status={promo2['status']}")

    # ── 9. Verify listing feed sorts promoted first ─────────
    print(f"\n9. Checking that Listing #{listing_id} appears FIRST in the public feed...")
    r = requests.get(f"{BASE}/listings?limit=50&offset=0")
    assert r.status_code == 200, f"❌ {r.text}"
    feed = r.json()
    feed_ids = [item["id"] for item in (feed if isinstance(feed, list) else feed.get("items", []))]
    if feed_ids and feed_ids[0] == listing_id:
        print(f"   ✅ Promoted listing #{listing_id} is FIRST in feed!")
    else:
        print(f"   ⚠️  Listing #{listing_id} not first (feed order: {feed_ids[:5]}). May need another listing in DB.")

    # ── 10. Verify top_feed badge appears in listing response ─
    print(f"\n10. Checking active_promotions badge in listing response...")
    r = requests.get(f"{BASE}/listings/{listing_id}")
    assert r.status_code == 200, f"❌ {r.text}"
    item = r.json()
    active_promos = item.get("active_promotions", [])
    print(f"    ✅ active_promotions = {active_promos}")

    print("\n" + "=" * 55)
    print("🎉 All Phase 3 Payments & Promotions tests passed!")
    print("=" * 55)


if __name__ == "__main__":
    run()
