import requests
import json

# Configuration
FIREBASE_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
BACKEND_URL = "http://127.0.0.1:8000"
EMAIL = "tashmat@gmail.com"
PASSWORD = "352251"

def get_firebase_token(email, password):
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_API_KEY}"
    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True
    }
    response = requests.post(url, json=payload)
    if response.status_code != 200:
        raise Exception(f"Firebase Auth failed: {response.text}")
    return response.json()["idToken"]

def test_endpoint(path, token, method="GET", data=None):
    url = f"{BACKEND_URL}{path}"
    headers = {"Authorization": f"Bearer {token}"}
    if method == "GET":
        response = requests.get(url, headers=headers)
    elif method == "PATCH":
        response = requests.patch(url, headers=headers, json=data)
    else:
        raise ValueError(f"Unsupported method: {method}")
    
    print(f"\n--- Testing {method} {path} ---")
    print(f"Status Code: {response.status_code}")
    try:
        print("Response Body:")
        print(json.dumps(response.json(), indent=2))
    except:
        print("Response Body (non-JSON):")
        print(response.text)
    return response.json()

def main():
    try:
        print(f"Authenticating as {EMAIL}...")
        token = get_firebase_token(EMAIL, PASSWORD)
        print("Authentication successful!")

        # Test /admin/stats
        test_endpoint("/admin/stats", token)

        # Test /admin/reports
        test_endpoint("/admin/reports?limit=5", token)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
