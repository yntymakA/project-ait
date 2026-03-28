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

def add_favorite(token: str, listing_id: int):
    headers = {"Authorization": f"Bearer {token}"}
    r = requests.post(f"{API_BASE_URL}/favorites/{listing_id}", headers=headers)
    print(f"POST /favorites/{listing_id} -> Status {r.status_code}")
    try:
        print(r.json())
    except:
        print(r.text)

def get_favorites(token: str):
    headers = {"Authorization": f"Bearer {token}"}
    r = requests.get(f"{API_BASE_URL}/favorites", headers=headers)
    print(f"GET /favorites -> Status {r.status_code}")
    try:
        print(r.json())
    except:
        print(r.text)

if __name__ == "__main__":
    token = login()
    if token:
        print("✅ Login successful")
        # We know listing 30 and 31 exist from our previous db inspection.
        # Feel free to change this ID to test others.
        target_listing_id = 30
        print(f"Attempting to favorite listing ID {target_listing_id} ...")
        add_favorite(token, target_listing_id)
        
        print("\nFetching favorites list...")
        get_favorites(token)
