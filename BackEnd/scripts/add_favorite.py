import sys
import requests

API_BASE_URL = "http://localhost:8000"
FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"

def login() -> str | None:
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": "tashmat@gmail.com", "password": "352251", "returnSecureToken": True})
    if r.status_code != 200:
        print("❌ Login failed:", r.text)
        return None
    return r.json()["idToken"]

if __name__ == "__main__":
    token = login()
    if not token:
        sys.exit(1)
    headers = {"Authorization": f"Bearer {token}"}

    listing_id = 1  # замените на нужный ID объявления
    resp = requests.post(f"{API_BASE_URL}/favorites/{listing_id}", headers=headers)
    if resp.status_code == 201:
        print("✅ Added to favorites!")
    else:
        print(f"❌ Failed ({resp.status_code}): {resp.text}")
