import sys
import os
import requests
import random
import time

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
API_BASE_URL = "http://localhost:8000"

def seed_listings():
    email = "tashmat@gmail.com"
    password = "352251"
    
    print("-" * 50)
    print("1. Logging into Firebase to get credentials...")
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": email, "password": password, "returnSecureToken": True})
    if r.status_code != 200:
        print("❌ Login failed:", r.text)
        return
    token = r.json()["idToken"]
    headers = {"Authorization": f"Bearer {token}"}
    
    print("2. Fetching categories from your database...")
    cat_resp = requests.get(f"{API_BASE_URL}/categories")
    categories = cat_resp.json()
    if not categories:
        print("❌ No categories found! Please seed categories first.")
        return
        
    leaf_categories = []
    for c in categories:
        if c.get("children"):
            leaf_categories.extend(c["children"])
        else:
            leaf_categories.append(c)
            
    mock_listings = [
        {
            "title": "Cozy 1-Bedroom in Downtown",
            "description": "Perfect for singles or couples. Close to all amenities and metro stations.",
            "price": 65000.0,
            "currency": "USD",
            "city": "Bishkek",
            "is_negotiable": False
        },
        {
            "title": "Spacious Family Villa",
            "description": "4 bedrooms, a huge garden, and a private pool. Ideal for a large family.",
            "price": 320000.0,
            "currency": "USD",
            "city": "Osh",
            "is_negotiable": True
        },
        {
            "title": "Modern Office Space",
            "description": "Open-plan office space with meeting rooms and a kitchen. 200 sq.m.",
            "price": 2500.0,
            "currency": "USD",
            "city": "Bishkek",
            "is_negotiable": True
        },
        {
            "title": "Agricultural Land 5 Hectares",
            "description": "Fertile land perfect for farming or agricultural business. Has water access.",
            "price": 45000.0,
            "currency": "USD",
            "city": "Karakol",
            "is_negotiable": True
        },
        {
            "title": "Studio near University",
            "description": "Great investment opportunity. High rental demand from students year-round.",
            "price": 35000.0,
            "currency": "USD",
            "city": "Bishkek",
            "is_negotiable": False
        }
    ]
    
    print(f"3. Seeding {len(mock_listings)} unique listings with different photos...")
    print("-" * 50)
    
    for i, data in enumerate(mock_listings):
        # Pick a random category
        cat = random.choice(leaf_categories)
        data["category_id"] = cat["id"]
        
        # Create Listing
        list_resp = requests.post(f"{API_BASE_URL}/listings", json=data, headers=headers)
        if list_resp.status_code != 201:
            print(f"❌ Failed to create listing '{data['title']}':", list_resp.text)
            continue
            
        listing_id = list_resp.json()["id"]
        print(f"[{i+1}/{len(mock_listings)}] ✅ Created: '{data['title']}' in '{cat['name']}' category (ID: {listing_id})")
        
        # Download a random unique image from picsum.photos so they actually look different
        # We append random numbers to the URL to bypass browser/cdn caching
        img_url = f"https://picsum.photos/seed/{random.randint(1,100000)}/800/600"
        try:
            img_data = requests.get(img_url).content
            dummy_path = f"/tmp/listing_photo_{listing_id}.jpg"
            with open(dummy_path, "wb") as f:
                f.write(img_data)
                
            # Upload Image
            with open(dummy_path, "rb") as f:
                files = {"file": (f"listing_{listing_id}.jpg", f, "image/jpeg")}
                img_resp = requests.post(f"{API_BASE_URL}/listings/{listing_id}/images", headers=headers, files=files)
                
            if img_resp.status_code == 201:
                print(f"         📸 Image successfully uploaded and attached to Firebase!")
            else:
                print(f"         ❌ Failed to upload image:", img_resp.text)
                
            os.remove(dummy_path)
            
        except Exception as e:
            print(f"         ❌ Error downloading/uploading image: {e}")

if __name__ == "__main__":
    try:
        requests.get(f"{API_BASE_URL}/health")
    except requests.exceptions.ConnectionError:
        print(f"❌ ERROR: Could not connect to {API_BASE_URL}. Make sure your FastAPI server is running!")
        sys.exit(1)
        
    seed_listings()
