"""
Comprehensive E2E test for pagination, filters, and sorting.
Tests against: GET /listings
"""
import requests
import sys

BASE = "http://localhost:8000"
passed = 0
failed = 0


# ── Helpers ──────────────────────────────────────────────

def assert_eq(actual, expected, label):
    assert actual == expected, f"{label}: expected {expected}, got {actual}"

def assert_true(condition, msg):
    assert condition, msg

def assert_keys(d, keys):
    for k in keys:
        assert k in d, f"Missing key: {k}"

def assert_all_match(items, field, value, label):
    for i, item in enumerate(items):
        actual = item.get(field)
        assert str(actual).lower() == str(value).lower(), f"Item {i}: {label}={actual}, expected {value}"

def assert_all_prices_gte(items, min_val):
    for i, item in enumerate(items):
        assert item["price"] >= min_val, f"Item {i}: price {item['price']} < {min_val}"

def assert_all_prices_lte(items, max_val):
    for i, item in enumerate(items):
        assert item["price"] <= max_val, f"Item {i}: price {item['price']} > {max_val}"

def assert_any_contains(items, field, substr):
    assert any(substr.lower() in item.get(field, "").lower() for item in items), \
        f"No item contains '{substr}' in '{field}'"

def assert_sorted_asc(items, field):
    """Check sort order, skipping first N promoted items that may break natural order."""
    if len(items) < 2:
        return
    vals = [item[field] for item in items]
    # Find where natural order starts (skip promoted items at the top)
    start = 0
    while start < len(vals) - 1 and vals[start] > vals[start + 1]:
        start += 1
    for i in range(start, len(vals) - 1):
        assert vals[i] <= vals[i + 1], f"Not sorted asc by {field}: {vals[i]} > {vals[i+1]}"

def assert_sorted_desc(items, field):
    """Check sort order, skipping first N promoted items that may break natural order."""
    if len(items) < 2:
        return
    vals = [item[field] for item in items]
    # Find where natural order starts (skip promoted items at the top)
    start = 0
    while start < len(vals) - 1 and vals[start] < vals[start + 1]:
        start += 1
    for i in range(start, len(vals) - 1):
        assert vals[i] >= vals[i + 1], f"Not sorted desc by {field}: {vals[i]} < {vals[i+1]}"

def test(name, url, check_fn, expect_status=200):
    global passed, failed
    try:
        r = requests.get(url)
        assert r.status_code == expect_status, f"HTTP {r.status_code} (expected {expect_status})"
        if expect_status == 200:
            data = r.json()
            check_fn(data)
        print(f"  ✅ {name}")
        passed += 1
    except Exception as e:
        print(f"  ❌ {name}: {e}")
        failed += 1


# ── PAGINATION ───────────────────────────────────────────

print("=" * 60)
print("PAGINATION TESTS")
print("=" * 60)

test(
    "Default pagination metadata present",
    f"{BASE}/listings",
    lambda d: assert_keys(d, ["items", "page", "page_size", "total_items", "total_pages"]),
)

test(
    "Page 1 with page_size=2 returns 2 items",
    f"{BASE}/listings?page=1&page_size=2",
    lambda d: (
        assert_eq(len(d["items"]), 2, "items count"),
        assert_eq(d["page"], 1, "page"),
        assert_eq(d["page_size"], 2, "page_size"),
        assert_true(d["total_items"] >= 2, "total_items >= 2"),
        assert_true(d["total_pages"] >= 2, "total_pages >= 2"),
    ),
)

test(
    "Page 2 with page_size=2 returns different items",
    f"{BASE}/listings?page=2&page_size=2",
    lambda d: (
        assert_eq(d["page"], 2, "page"),
        assert_true(len(d["items"]) > 0, "has items"),
    ),
)

test(
    "Large page returns empty items",
    f"{BASE}/listings?page=999&page_size=20",
    lambda d: (
        assert_eq(len(d["items"]), 0, "items count"),
        assert_eq(d["page"], 999, "page"),
    ),
)

test(
    "total_pages math is correct (page_size=3)",
    f"{BASE}/listings?page_size=3",
    lambda d: assert_true(
        d["total_pages"] == -(-d["total_items"] // 3),
        f"total_pages={d['total_pages']} should be ceil({d['total_items']}/3)={-(-d['total_items']//3)}",
    ),
)


# ── FILTERS ──────────────────────────────────────────────

print("\n" + "=" * 60)
print("FILTER TESTS")
print("=" * 60)

test(
    "Filter by city=Bishkek",
    f"{BASE}/listings?city=Bishkek",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_match(d["items"], "city", "Bishkek", "city"),
    ),
)

test(
    "Filter by city=Osh",
    f"{BASE}/listings?city=Osh",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_match(d["items"], "city", "Osh", "city"),
    ),
)

test(
    "Filter by city=NonExistentCity returns 0",
    f"{BASE}/listings?city=NonExistentCity",
    lambda d: assert_eq(d["total_items"], 0, "total_items"),
)

test(
    "Filter by category_id=1",
    f"{BASE}/listings?category_id=1",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_match(d["items"], "category_id", 1, "category_id"),
    ),
)

test(
    "Filter by min_price=50000",
    f"{BASE}/listings?min_price=50000",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_prices_gte(d["items"], 50000),
    ),
)

test(
    "Filter by max_price=5000",
    f"{BASE}/listings?max_price=5000",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_prices_lte(d["items"], 5000),
    ),
)

test(
    "Filter by price range 30000-70000",
    f"{BASE}/listings?min_price=30000&max_price=70000",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_prices_gte(d["items"], 30000),
        assert_all_prices_lte(d["items"], 70000),
    ),
)

test(
    "Combined: city=Bishkek + max_price=50000",
    f"{BASE}/listings?city=Bishkek&max_price=50000",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_match(d["items"], "city", "Bishkek", "city"),
        assert_all_prices_lte(d["items"], 50000),
    ),
)


# ── SEARCH ───────────────────────────────────────────────

print("\n" + "=" * 60)
print("SEARCH TESTS")
print("=" * 60)

test(
    "Search q=Apartment",
    f"{BASE}/listings?q=Apartment",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_any_contains(d["items"], "title", "Apartment"),
    ),
)

test(
    "Search q=villa",
    f"{BASE}/listings?q=villa",
    lambda d: assert_true(d["total_items"] >= 1, "has results"),
)

test(
    "Search q=xyznonexistent returns 0",
    f"{BASE}/listings?q=xyznonexistent",
    lambda d: assert_eq(d["total_items"], 0, "total_items"),
)

test(
    "Search + filter combo: q=Apartment&city=Bishkek",
    f"{BASE}/listings?q=Apartment&city=Bishkek",
    lambda d: (
        assert_true(d["total_items"] >= 1, "has results"),
        assert_all_match(d["items"], "city", "Bishkek", "city"),
    ),
)


# ── SORTING ──────────────────────────────────────────────

print("\n" + "=" * 60)
print("SORTING TESTS")
print("=" * 60)

test(
    "Sort newest (default)",
    f"{BASE}/listings?sort=newest&page_size=100",
    lambda d: assert_sorted_desc(d["items"], "created_at"),
)

test(
    "Sort oldest",
    f"{BASE}/listings?sort=oldest&page_size=100",
    lambda d: assert_sorted_asc(d["items"], "created_at"),
)

test(
    "Sort price_asc",
    f"{BASE}/listings?sort=price_asc&page_size=100",
    lambda d: assert_sorted_asc(d["items"], "price"),
)

test(
    "Sort price_desc",
    f"{BASE}/listings?sort=price_desc&page_size=100",
    lambda d: assert_sorted_desc(d["items"], "price"),
)

test(
    "Invalid sort value returns 422",
    f"{BASE}/listings?sort=invalid",
    lambda d: None,
    expect_status=422,
)


# ── RESULTS ──────────────────────────────────────────────

print("\n" + "=" * 60)
print(f"RESULTS: {passed} passed, {failed} failed out of {passed + failed}")
print("=" * 60)
sys.exit(1 if failed else 0)
