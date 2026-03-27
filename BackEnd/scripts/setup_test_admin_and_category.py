import sys
import os
import requests

# Add BackEnd path for database imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.sql_models.user import User

# Extracted from get_firebase_token.py
FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
API_BASE_URL = "http://localhost:8000"

def main():
    email = "tashmat@gmail.com"
    password = "352251"
    
    print("-" * 50)
    print(f"1. Logging in to Firebase as {email}...")
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": email, "password": password, "returnSecureToken": True})
    
    if r.status_code != 200:
        print("❌ Error logging in to Firebase:", r.text)
        return
        
    token = r.json()["idToken"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Logged in successfully. JWT Token acquired.")
    
    print("-" * 50)
    print("2. Syncing user to local database (/users/sync)...")
    sync_resp = requests.post(f"{API_BASE_URL}/users/sync", headers=headers)
    if sync_resp.status_code not in [200, 201]:
        print("❌ Error syncing user:", sync_resp.text)
        return
    print("✅ User synced to local DB.")
        
    print("-" * 50)
    print("3. Promoting user to 'admin' in the database...")
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if user:
            user.role = "admin"
            db.commit()
            print(f"✅ User {email} successfully promoted to ADMIN!")
        else:
            print("❌ User not found in DB after sync.")
            return
    finally:
        db.close()
        
    print("-" * 50)
    print("4. Testing Category Creation API (/categories)...")
    category_data = {
        "name": "Luxury Apartments",
        "slug": "luxury-apartments-test",
        "parent_id": None,
        "display_order": 1
    }
    
    cat_resp = requests.post(f"{API_BASE_URL}/categories", json=category_data, headers=headers)
    
    if cat_resp.status_code == 201:
        print("✅ SUCCESS! Category created securely via API:")
        print(cat_resp.json())
    else:
        print("❌ Error creating category:", cat_resp.text)

if __name__ == "__main__":
    # Ensure the user has the FastAPI server running!
    try:
        requests.get(f"{API_BASE_URL}/health")
    except requests.exceptions.ConnectionError:
        print(f"❌ ERROR: Could not connect to {API_BASE_URL}. Make sure your FastAPI server is running!")
        sys.exit(1)
        
    main()
