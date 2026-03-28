import requests
from pprint import pprint

BASE_URL = "http://localhost:8000/listings"

examples = [
    {"desc": "First 5 listings", "params": {"limit": 5}},
    {"desc": "Search for 'apartment'", "params": {"q": "apartment", "limit": 3}},
    {"desc": "Category ID 2", "params": {"category_id": 2, "limit": 3}},
    {"desc": "City = Moscow", "params": {"city": "Moscow", "limit": 3}},
    {"desc": "Price 1000-5000", "params": {"min_price": 1000, "max_price": 5000, "limit": 3}},
    {"desc": "Sort by price ascending", "params": {"sort": "price_asc", "limit": 3}},
    {"desc": "Second page (offset 5)", "params": {"limit": 5, "offset": 5}},
]

def fetch_listings(params):
    resp = requests.get(BASE_URL, params=params)
    try:
        data = resp.json()
    except Exception:
        data = None
    return resp.status_code, data

def main():
    for ex in examples:
        print(f"\n--- {ex['desc']} ---")
        try:
            status, data = fetch_listings(ex["params"])
        except Exception as e:
            print(f"Request failed: {e}")
            continue
        print(f"Status: {status}")
        if data is None:
            print("  Error: No data returned.")
            continue
        items = data.get('items', [])
        print(f"Items returned: {len(items)}")
        if items:
            for idx, item in enumerate(items, 1):
                pprint(item)
        else:
            print("  No items found.")

if __name__ == "__main__":
    main()
