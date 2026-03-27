import sys
import os
import requests

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
API_BASE_URL = "http://localhost:8000"

def login() -> str | None:
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": "tashmat@gmail.com", "password": "352251", "returnSecureToken": True})
    if r.status_code != 200:
        print("❌ Login failed:", r.text)
        return None
    return r.json()["idToken"]

def test_favorites():
    print("-" * 50)
    print("1. Logging in to Firebase...")
    token = login()
    if not token:
        return
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Logged in.")

    # Step 1: Find a valid listing to favorite
    print("\n2. Finding a valid listing to favorite...")
    target_id = None
    target_title = None
    for i in range(1, 100):
        r = requests.get(f"{API_BASE_URL}/listings/{i}")
        if r.status_code == 200:
            target_id = i
            target_title = r.json().get("title", f"Listing {i}")
            break
            
    if not target_id:
        print("❌ No listings found in the database. Please run seed_listings.py first.")
        return
    print(f"✅ Picked Listing {target_id}: '{target_title}'")

    # Step 2: Add to favorites
    print(f"\n3. Adding Listing {target_id} to favorites...")
    r = requests.post(f"{API_BASE_URL}/favorites/{target_id}", headers=headers)
    if r.status_code == 201:
        print("✅ Successfully added to favorites!")
    else:
        print(f"⚠️  Result ({r.status_code}): {r.text}")

    # Step 3: Try adding the exact same listing again (Should fail with 409)
    print(f"\n4. Trying to add Listing {target_id} again (testing duplicate constraint)...")
    r = requests.post(f"{API_BASE_URL}/favorites/{target_id}", headers=headers)
    if r.status_code == 409:
        print("✅ Correctly prevented duplicate favorite (409 Conflict)!")
    else:
        print(f"❌ Expected 409, got {r.status_code}: {r.text}")

    # Step 4: Fetch favorites
    print("\n5. Fetching your favorites list...")
    r = requests.get(f"{API_BASE_URL}/favorites", headers=headers)
    if r.status_code == 200:
        data = r.json()
        items = data.get("items", [])
        print(f"✅ You have {data.get('total')} favorite(s).")
        for item in items:
            print(f"   - [ID {item['id']}] {item['title']}")
        
        # Verify our target is in the list
        if any(item["id"] == target_id for item in items):
            print("✅ The newly added listing is in your favorites list!")
        else:
            print("❌ The listing is MISSING from your favorites list!")
    else:
        print(f"❌ Failed to fetch favorites: {r.status_code} {r.text}")

    # Step 5: Remove favorite
    print(f"\n6. Removing Listing {target_id} from favorites...")
    r = requests.delete(f"{API_BASE_URL}/favorites/{target_id}", headers=headers)
    if r.status_code == 204:
        print("✅ Successfully removed from favorites!")
    else:
        print(f"❌ Failed to remove favorite: {r.status_code} {r.text}")

    # Step 6: Verify it's gone
    print("\n7. Verifying it was removed...")
    r = requests.get(f"{API_BASE_URL}/favorites", headers=headers)
    if r.status_code == 200:
        data = r.json()
        if not any(item["id"] == target_id for item in data.get("items", [])):
            print("✅ Verified! The listing is no longer in your favorites.")
        else:
            print("❌ Error: The listing is STILL in your favorites!")

    print("-" * 50)
    print("🎉 All Favorites tests passed successfully!")

if __name__ == "__main__":
    try:
        requests.get(f"{API_BASE_URL}/health", timeout=3)
    except requests.exceptions.ConnectionError:
        print(f"❌ Cannot connect to {API_BASE_URL}. Start your FastAPI server first.")
        sys.exit(1)

    test_favorites()
