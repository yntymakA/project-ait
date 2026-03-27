import requests
import sys

# Get this from Firebase Console -> Project Settings -> General -> Web API Key
FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"

def get_token(email, password):
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True
    }
    
    print(f"Logging in as {email}...")
    r = requests.post(url, json=payload)
    
    if r.status_code == 200:
        data = r.json()
        print("\n✅ SUCCESS! Here is your Firebase ID Token:\n")
        print(data["idToken"])
        print("\n🔑 Use this as the Bearer token in Swagger UI (/docs)")
    else:
        print("\n❌ Error logging in:", r.text)
        print("\nMake sure you have enabled Email/Password Auth in Firebase Console and inserted your WEB_API_KEY.")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python get_firebase_token.py <email> <password>")
        sys.exit(1)
        
    get_token(sys.argv[1], sys.argv[2])
