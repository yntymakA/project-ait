import requests

API_BASE_URL = "http://localhost:8000"
FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"

def get_token(email, password):
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": email, "password": password, "returnSecureToken": True})
    if r.status_code == 200:
        return r.json()["idToken"]
    return None

def test_encoding():
    token = get_token("tashmat@gmail.com", "352251")
    if not token:
        print("❌ Failed to get token")
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Try to find a conversation
    r = requests.get(f"{API_BASE_URL}/conversations", headers=headers)
    if r.status_code != 200 or not r.json()["items"]:
        print("❌ No conversations found. Run test_messaging.py first.")
        return
    
    conv_id = r.json()["items"][0]["id"]
    
    # Send Russian text
    russian_text = "Привет, это тест кодировки! ёъ"
    print(f"Sending: {russian_text}")
    
    r = requests.post(
        f"{API_BASE_URL}/conversations/{conv_id}/messages",
        headers=headers,
        json={"text_body": russian_text}
    )
    
    if r.status_code == 201:
        msg_id = r.json()["id"]
        print(f"✅ Message sent! ID: {msg_id}")
        
        # Read it back
        r = requests.get(f"{API_BASE_URL}/conversations/{conv_id}/messages", headers=headers)
        messages = r.json()["items"]
        for m in messages:
            if m["id"] == msg_id:
                print(f"Received from DB: {m['text_body']}")
                if m["text_body"] == russian_text:
                    print("✨ Encoding is correct!")
                else:
                    print(f"❌ ENCODING ISSUE DETECTED! Received: {m['text_body']}")
    else:
        print(f"❌ Failed to send message: {r.text}")

if __name__ == "__main__":
    test_encoding()
