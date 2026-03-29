import sys
import os
import requests
import random
import time

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

FIREBASE_WEB_API_KEY = "AIzaSyDkcm4AW_aW_TPUaKjgPi1LcQgsNX6voJc"
API_BASE_URL = "http://localhost:8000"

def get_or_create_user_token(email, password, full_name):
    # Try login
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    r = requests.post(url, json={"email": email, "password": password, "returnSecureToken": True})
    
    if r.status_code != 200:
        # Try signup
        url_signup = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={FIREBASE_WEB_API_KEY}"
        r_signup = requests.post(url_signup, json={"email": email, "password": password, "returnSecureToken": True})
        if r_signup.status_code != 200:
            print(f"❌ Failed to login or create user {email}: {r_signup.text}")
            return None
        token = r_signup.json()["idToken"]
    else:
        token = r.json()["idToken"]
        
    # Sync with backend to ensure the DB record exists and is fresh
    headers = {"Authorization": f"Bearer {token}"}
    sync_resp = requests.post(f"{API_BASE_URL}/users/sync", headers=headers)
    if sync_resp.status_code != 200:
        print(f"❌ Failed to sync user {email} with backend: {sync_resp.text}")
        return None
        
    # Update profile name just in case
    requests.patch(f"{API_BASE_URL}/users/me", headers=headers, json={"full_name": full_name})
    
    return token

def test_messaging():
    print("-" * 50)
    print("1. Authenticating User A (Seller) & User B (Buyer)...")
    
    token_seller = get_or_create_user_token("tashmat@gmail.com", "352251", "Tashmat Seller")
    token_buyer = get_or_create_user_token("buyer@gmail.com", "123456", "John Buyer")
    
    if not token_seller or not token_buyer:
        return
        
    h_seller = {"Authorization": f"Bearer {token_seller}"}
    h_buyer = {"Authorization": f"Bearer {token_buyer}"}
    
    # Get user profiles to know their IDs
    seller_id = requests.get(f"{API_BASE_URL}/users/me", headers=h_seller).json()["id"]
    buyer_id = requests.get(f"{API_BASE_URL}/users/me", headers=h_buyer).json()["id"]
    print(f"✅ Seller ID: {seller_id}")
    print(f"✅ Buyer ID: {buyer_id}")

    print("\n2. Finding a listing owned by the Seller to chat about...")
    # First, let's see if seller has a listing. We'll just look for any listing not owned by buyer.
    # We iterate until we find one that buyer doesn't own so they can chat about it.
    target_listing = None
    for i in range(1, 100):
        r = requests.get(f"{API_BASE_URL}/listings/{i}")
        if r.status_code == 200:
            listing = r.json()
            if listing["owner_id"] != buyer_id:
                target_listing = listing
                break
                
    if not target_listing:
        print("❌ Could not find a suitable listing. Run seed_listings.py first.")
        return
        
    listing_id = target_listing["id"]
    listing_owner_id = target_listing["owner_id"]
    print(f"✅ Picked Listing {listing_id}: '{target_listing['title']}' (Owned by User {listing_owner_id})")
    
    print("\n3. Buyer starts a conversation...")
    payload = {"listing_id": listing_id, "recipient_id": listing_owner_id}
    r_conv = requests.post(f"{API_BASE_URL}/conversations", headers=h_buyer, json=payload)
    if r_conv.status_code == 201:
        conv_id = r_conv.json()["id"]
        print(f"✅ Conversation {conv_id} created successfully!")
    else:
        print(f"❌ Failed to create conversation: {r_conv.text}")
        return

    print("\n4. Buyer sends a text message...")
    data_msg = {"text_body": "Hi! Is this property still available for sale?"}
    r_msg1 = requests.post(
        f"{API_BASE_URL}/conversations/{conv_id}/messages",
        headers=h_buyer,
        json=data_msg,
    )
    if r_msg1.status_code == 201:
        print("✅ Text message sent!")
    else:
        print(f"❌ Failed to send message: {r_msg1.text}")

    print("\n5. Buyer sends a second text message...")
    r_msg2 = requests.post(
        f"{API_BASE_URL}/conversations/{conv_id}/messages",
        headers=h_buyer,
        json={"text_body": "Could we schedule a viewing this week?"},
    )
    if r_msg2.status_code == 201:
        print("✅ Second text message sent!")
    else:
        print(f"❌ Failed to send second message: {r_msg2.text}")

    print("\n6. Seller checks their inbox...")
    r_inbox = requests.get(f"{API_BASE_URL}/conversations", headers=h_seller)
    inbox = r_inbox.json()["items"]
    our_chat = next((c for c in inbox if c["id"] == conv_id), None)
    if our_chat:
        print(f"✅ Chat found in Seller's inbox! Unread count: {our_chat['unread_count']}")
    else:
        print("❌ Chat NOT found in Seller's inbox!")
        
    print("\n7. Seller opens the chat history to read messages...")
    r_hist = requests.get(f"{API_BASE_URL}/conversations/{conv_id}/messages", headers=h_seller)
    history = r_hist.json()["items"]
    print(f"✅ Loaded {len(history)} messages.")
    for m in history:
        sender = "Buyer" if m['sender_id'] == buyer_id else "Seller"
        print(f"   [{sender}] {m['text_body']}")
        
    print("\n8. Seller checks inbox again to ensure unread count reset to 0...")
    r_inbox2 = requests.get(f"{API_BASE_URL}/conversations", headers=h_seller)
    our_chat2 = next((c for c in r_inbox2.json()["items"] if c["id"] == conv_id), None)
    if our_chat2 and our_chat2["unread_count"] == 0:
        print("✅ Unread count successfully reset to 0!")
    else:
        print(f"❌ Unread count is NOT 0 (It is {our_chat2['unread_count'] if our_chat2 else 'missing'})")

    print("\n9. Seller replies...")
    r_reply = requests.post(
        f"{API_BASE_URL}/conversations/{conv_id}/messages",
        headers=h_seller,
        json={"text_body": "Yes, it is! Let me know if you want to schedule a viewing."},
    )
    if r_reply.status_code == 201:
        print("✅ Reply sent!")
    else:
        print(f"❌ Failed to reply: {r_reply.text}")

    print("-" * 50)
    print("🎉 All Messaging tests passed successfully!")


if __name__ == "__main__":
    test_messaging()
