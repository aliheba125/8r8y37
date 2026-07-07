#!/usr/bin/env python3
"""
إنشاء مفتاح ترخيص في Firebase — يعمل مع النسخة الأصلية بدون تعديل
══════════════════════════════════════════════════════════════════════

الاستخدام:
    pip install requests
    python3 create_key.py

ثم ادخل الـ USERNAME في التطبيق الأصلي واضغط Login
"""
import requests
from datetime import datetime, timedelta

# ══════════════════════════════════════════════════
#   غيّر هذه القيم فقط
# ══════════════════════════════════════════════════
USERNAME = "ali2026"         # ← هذا ما تدخله في التطبيق
DAYS = 99999                 # ← 99999 = غير محدود (274 سنة) / 30 = شهر / 7 = أسبوع
MAX_DEVICES = 999            # ← عدد الأجهزة المسموح
# ══════════════════════════════════════════════════

# إعدادات Firebase (مستخرجة من التطبيق)
API_KEY = "AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE"
DB_URL = "https://wolf-e99fb-default-rtdb.firebaseio.com"
AUTH_URL = "https://identitytoolkit.googleapis.com/v1"

def create_key():
    print("═══════════════════════════════════════════")
    print("   إنشاء مفتاح — Zero Loader V4.4.01")
    print("═══════════════════════════════════════════")
    print()

    # الخطوة 1: الحصول على توكن (حساب مجهول مجاني)
    print("[1/3] الحصول على توكن...")
    resp = requests.post(
        f"{AUTH_URL}/accounts:signUp?key={API_KEY}",
        json={"returnSecureToken": True}
    )
    data = resp.json()
    if "idToken" not in data:
        print(f"❌ فشل الحصول على توكن: {data.get('error', {}).get('message', 'خطأ غير معروف')}")
        return
    token = data["idToken"]
    print(f"    ✅ تم")
    print()

    # الخطوة 2: تجهيز بيانات المفتاح
    print("[2/3] تجهيز المفتاح...")
    now = datetime.now()
    exp = (now + timedelta(days=DAYS)).strftime("%Y%m%d%H%M%S")
    node_name = f"UserKey_{USERNAME.upper()}_{now.strftime('%Y%m%d%H%M%S')}"

    license_data = {
        "Key": node_name,
        "Username": USERNAME,           # ⚠️ هذا ما تدخله في التطبيق
        "Owner": "Zero_Loader",         # ⚠️ لازم بالضبط هذه القيمة (من فك تشفير smali)
        "Status": "Active",             # ⚠️ لازم "Active"
        "EXP": exp,                     # تاريخ الانتهاء بصيغة yyyyMMddHHmmss
        "Period": str(DAYS),
        "PeriodType": "days",
        "Devices": "0",
        "MaxDevices": str(MAX_DEVICES),
        "UUID": "null",
    }
    print(f"    Username:    {USERNAME}")
    print(f"    EXP:         {exp} ({DAYS} يوم)")
    print(f"    MaxDevices:  {MAX_DEVICES}")
    print(f"    Owner:       Zero_Loader")
    print()

    # الخطوة 3: الكتابة في Firebase
    print("[3/3] الكتابة في Firebase...")
    url = f"{DB_URL}/Login/{node_name}.json?auth={token}"
    resp = requests.put(url, json=license_data)

    if resp.status_code == 200:
        print(f"    ✅ تم بنجاح!")
        print()
        print("═══════════════════════════════════════════")
        print(f"   🎯 ادخل في التطبيق:  {USERNAME}")
        print(f"   📅 ينتهي:            سنة {exp[:4]}")
        print(f"   📱 أجهزة:            {MAX_DEVICES}")
        print("═══════════════════════════════════════════")
        print()
        print(f"   1. افتح Zero Loader (النسخة الأصلية)")
        print(f"   2. اكتب: {USERNAME}")
        print(f"   3. اضغط Login")
        print(f"   4. ✅ يدخل!")
    else:
        print(f"    ❌ فشل: {resp.text}")


def delete_key(node_name):
    """حذف مفتاح من Firebase"""
    resp = requests.post(
        f"{AUTH_URL}/accounts:signUp?key={API_KEY}",
        json={"returnSecureToken": True}
    )
    token = resp.json()["idToken"]
    url = f"{DB_URL}/Login/{node_name}.json?auth={token}"
    resp = requests.delete(url)
    if resp.status_code == 200:
        print(f"✅ تم حذف: {node_name}")
    else:
        print(f"❌ فشل: {resp.text}")


def list_my_keys():
    """عرض كل المفاتيح"""
    resp = requests.post(
        f"{AUTH_URL}/accounts:signUp?key={API_KEY}",
        json={"returnSecureToken": True}
    )
    token = resp.json()["idToken"]
    url = f"{DB_URL}/Login.json?auth={token}&shallow=true"
    resp = requests.get(url)
    data = resp.json()
    print(f"إجمالي المفاتيح: {len(data)}")


if __name__ == "__main__":
    create_key()
