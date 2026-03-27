import sys
import os
import requests
import random

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
API_BASE_URL = "http://localhost:8000"

MOCK_LISTINGS = [
    {
        "title": "Cozy 1-Bedroom in Downtown",
        "description": "Perfect for singles or couples. Close to all amenities and metro stations.",
        "price": "65000.00",
        "currency": "USD",
        "city": "Bishkek",
        "is_negotiable": "false",
    },
    {
        "title": "Spacious Family Villa",
        "description": "4 bedrooms, a huge garden, and a private pool. Ideal for a large family.",
        "price": "320000.00",
        "currency": "USD",
        "city": "Osh",
        "is_negotiable": "true",
    },
    {
        "title": "Modern Office Space",
        "description": "Open-plan office space with meeting rooms and a kitchen. 200 sq.m.",
        "price": "2500.00",
        "currency": "USD",
        "city": "Bishkek",
        "is_negotiable": "true",
    },
    {
        "title": "Agricultural Land 5 Hectares",
        "description": "Fertile land perfect for farming or agricultural business. Has water access.",
        "price": "45000.00",
        "currency": "USD",
        "city": "Karakol",
        "is_negotiable": "true",
    },
    {
        "title": "Studio near University",
        "description": "Great investment opportunity. High rental demand from students year-round.",
        "price": "35000.00",
        "currency": "USD",
        "city": "Bishkek",
        "is_negotiable": "false",
    },
]


def login() -> str | None:
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": "tashmat@gmail.com", "password": "352251", "returnSecureToken": True})
    if r.status_code != 200:
        print("❌ Login failed:", r.text)
        return None
    return r.json()["idToken"]


def get_leaf_categories() -> list:
    resp = requests.get(f"{API_BASE_URL}/categories")
    if resp.status_code != 200 or not resp.json():
        print("❌ Could not fetch categories. Seed them first.")
        return []
    categories = resp.json()
    leaves = []
    for c in categories:
        if c.get("children"):
            leaves.extend(c["children"])
        else:
            leaves.append(c)
    return leaves


def download_image(seed: int, tmp_path: str) -> bool:
    """Download a unique photo from picsum.photos."""
    try:
        data = requests.get(f"https://picsum.photos/seed/{seed}/800/600", timeout=10).content
        with open(tmp_path, "wb") as f:
            f.write(data)
        return True
    except Exception as e:
        print(f"   ⚠️  Could not download image (seed={seed}): {e}")
        return False


def seed_listings():
    print("-" * 50)
    print("1. Logging in to Firebase...")
    token = login()
    if not token:
        return
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Logged in.")

    print("2. Fetching categories...")
    leaves = get_leaf_categories()
    if not leaves:
        return
    print(f"✅ Found {len(leaves)} leaf categories.")

    print(f"3. Seeding {len(MOCK_LISTINGS)} listings (3 photos each)...")
    print("-" * 50)

    for i, listing_data in enumerate(MOCK_LISTINGS):
        cat = random.choice(leaves)
        form_data = {**listing_data, "category_id": str(cat["id"])}

        # Download 3 unique images from picsum
        seeds = random.sample(range(1, 100_000), 3)
        tmp_paths = [f"/tmp/seed_photo_{i}_{j}.jpg" for j in range(3)]
        ok = all(download_image(s, p) for s, p in zip(seeds, tmp_paths))
        if not ok:
            print(f"   ⚠️  Skipping '{listing_data['title']}' — image download failed.")
            continue

        try:
            files = [
                ("image1", (f"photo_{i}_1.jpg", open(tmp_paths[0], "rb"), "image/jpeg")),
                ("image2", (f"photo_{i}_2.jpg", open(tmp_paths[1], "rb"), "image/jpeg")),
                ("image3", (f"photo_{i}_3.jpg", open(tmp_paths[2], "rb"), "image/jpeg")),
            ]
            resp = requests.post(
                f"{API_BASE_URL}/listings",
                headers=headers,
                data=form_data,
                files=files,
            )

            if resp.status_code == 201:
                listing = resp.json()
                print(f"[{i+1}/{len(MOCK_LISTINGS)}] ✅ '{listing_data['title']}' → ID {listing['id']} | cat: {cat['name']} | 📸 3 photos")
            else:
                print(f"[{i+1}/{len(MOCK_LISTINGS)}] ❌ Failed ({resp.status_code}): {resp.text}")
        finally:
            for p in tmp_paths:
                if os.path.exists(p):
                    os.remove(p)


if __name__ == "__main__":
    try:
        requests.get(f"{API_BASE_URL}/health", timeout=3)
    except requests.exceptions.ConnectionError:
        print(f"❌ Cannot connect to {API_BASE_URL}. Start your FastAPI server first.")
        sys.exit(1)

    seed_listings()
