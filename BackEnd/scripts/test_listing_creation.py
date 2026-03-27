import sys
import os
import requests

# Add BackEnd path for any needed imports (though this script uses pure REST)
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
API_BASE_URL = "http://localhost:8000"

def test_listing_creation():
    email = "tashmat@gmail.com"
    password = "352251"
    
    print("-" * 50)
    print(f"1. Logging into Firebase as {email}...")
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": email, "password": password, "returnSecureToken": True})
    if r.status_code != 200:
        print("❌ Login failed:", r.text)
        return
    
    token = r.json()["idToken"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Logged in! Inheriting admin privileges.")
    
    print("-" * 50)
    print("2. Fetching categories to get a valid category_id...")
    cat_resp = requests.get(f"{API_BASE_URL}/categories")
    if cat_resp.status_code != 200:
        print("❌ Failed to fetch categories:", cat_resp.text)
        return
        
    categories = cat_resp.json()
    if not categories:
        print("❌ No categories found in the database. Please seed categories first!")
        return
        
    # Get the ID of the first subcategory we find
    category_id = None
    for c in categories:
        if c.get("children"):
            category_id = c["children"][0]["id"]
            break
            
    if not category_id:
        category_id = categories[0]["id"]
        
    print(f"✅ Found Category ID: {category_id}")
    
    print("-" * 50)
    print("3. Creating a new test listing...")
    listing_data = {
        "title": "Beautiful 3-Room Apartment in the Center",
        "description": "A wonderful apartment in the city center with a great view and modern renovation.",
        "price": 125000.0,
        "currency": "USD",
        "city": "Bishkek",
        "category_id": category_id,
        "is_negotiable": True
    }
    
    list_resp = requests.post(f"{API_BASE_URL}/listings", json=listing_data, headers=headers)
    if list_resp.status_code != 201:
        print("❌ Failed to create listing:", list_resp.text)
        return
        
    listing = list_resp.json()
    listing_id = listing["id"]
    print(f"✅ SUCCESS! Listing created! ID: {listing_id}")
    
    print("-" * 50)
    print("4. Testing Listing Image Upload...")
    
    # Create a tiny dummy image file (1x1 pixel JPEG structure or just purely random bytes)
    # The simplest way is to just write some string, but Firebase uses Mime types, so we pass image/jpeg
    dummy_image_path = "/tmp/dummy_image.jpg"
    with open(dummy_image_path, "wb") as f:
        f.write(b"\xFF\xD8\xFFfake jpeg data for firebase testing")
        
    try:
        with open(dummy_image_path, "rb") as f:
            files = {"file": ("dummy_image.jpg", f, "image/jpeg")}
            img_resp = requests.post(f"{API_BASE_URL}/listings/{listing_id}/images", headers=headers, files=files)
            
        if img_resp.status_code == 201:
            print("✅ SUCCESS! Image uploaded and attached to the listing!")
            print(img_resp.json())
        else:
            print(f"❌ Failed to upload image (Status {img_resp.status_code}):", img_resp.text)
    finally:
        if os.path.exists(dummy_image_path):
            os.remove(dummy_image_path)

if __name__ == "__main__":
    try:
        requests.get(f"{API_BASE_URL}/health")
    except requests.exceptions.ConnectionError:
        print(f"❌ ERROR: Could not connect to {API_BASE_URL}. Make sure your FastAPI server is running!")
        sys.exit(1)
        
    test_listing_creation()
