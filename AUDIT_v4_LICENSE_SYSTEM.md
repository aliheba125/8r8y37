# تدقيق Zero_Loader — النسخة الرابعة — نظام الترخيص Firebase (مفكوك بالكامل)

**تاريخ:** 2026-07-05
**المنهج:** فك تشفير طبقتين (LSParanoid dex + AES-256-CBC) + تتبع منطق التحقق + مسح شامل لكل السلاسل + اختبار عملي

كل نتيجة هنا مُثبتة بفك تشفير فعلي أو تتبع كود، لا تخمين.

---

## 1. إعدادات Firebase (مكشوفة في الموارد)

من `res/values/strings.xml`:

| المفتاح | القيمة |
| --- | --- |
| `project_id` | `wolf-e99fb` |
| `google_api_key` | `AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE` |
| `google_app_id` | `1:183662681739:android:fdaaf27da5e5e60b893e8e` |
| `gcm_defaultSenderId` | `183662681739` |
| DB URL (مشتق) | `https://wolf-e99fb-default-rtdb.firebaseio.com` |

**⚠️ هذه قاعدة بيانات المطوّر الأصلي (`Zero_Loader` / `ABU_FAHAD3`)** — ليست لك. لا يمكنك إضافة أكواد إليها. لتشغيل نظامك الخاص تحتاج Firebase خاص بك (القسم 6).

**ملاحظة أمنية:** api_key الخاص بـ Firebase ليس سراً بطبيعته (مصمم ليكون في العميل)، لكن **أمان قاعدة البيانات يعتمد كلياً على Security Rules**. إذا كانت قواعد المطوّر مفتوحة، أي شخص يستطيع قراءة/كتابة الأكواد. لم أختبر قاعدة المطوّر الحية (وصول غير مصرّح لطرف ثالث).

---

## 2. طبقتا التشفير (مفكوكتان)

**الطبقة 1 — LSParanoid:** تعتيم سلاسل dex (فككتها بـ port من الخوارزمية).
**الطبقة 2 — AES:** أسماء حقول Firebase مشفّرة إضافياً.

مواصفات AES المُثبتة من `LoginActivity$AESCrypt`:
```
الخوارزمية: AES/CBC/PKCS7Padding
المفتاح:    SHA-256("Activity") = 38da1505ca8373288489495101b14f24ac95078f520ad64df18272aa6054f750
الـ IV:     16 بايت أصفار (ثابت — ضعف تشفير معروف، لكن الهدف تعتيم فقط)
CHARSET:   UTF-8
SU() method = AESCrypt.decrypt() (غلاف)
```

**إثبات:** فككت `g9VUTnC69mUjgu5vPZ/9ag==` → `'Login'` بنجاح بهذه المفاتيح.

---

## 3. بنية قاعدة بيانات الترخيص (مفكوكة بالكامل)

```
wolf-e99fb-default-rtdb
└── Login/
    └── <Key>/                    ← كل كود ترخيص عقدة
        ├── Key         : string  (الكود نفسه)
        ├── Username    : string
        ├── Owner       : string  (يجب == "Zero_Loader")
        ├── Status      : string  (نشط/محظور)
        ├── Active      : string/bool
        ├── EXP         : string  (تاريخ الانتهاء "yyyyMMddHHmmss")
        ├── Period      : number  (مدة الاشتراك)
        ├── PeriodType  : string  ("hours" أو "days")
        ├── Devices     : number  (عدد الأجهزة المسجّلة)
        ├── MaxDevices  : number  (الحد الأقصى للأجهزة)
        ├── UUID        : string  (مرتبط بـ android_id)
        └── Update      : string
```

رسائل الحالة المفكوكة:
`Login Success`, `Login Failed`, `EXPIRED KEY`, `MAX DEVICE REACHED`, `USER BLOCKED`, `USER NOT REGISTERED`

---

## 4. منطق التحقق الكامل (LoginActivity$1.onDataChange)

تسلسل مُثبت بالتفكيك:

```
1. المستخدم يُدخل Key → Firebase signInAnonymously → قراءة Login/<Key>
2. إذا لم يوجد السجل → "USER NOT REGISTERED"
3. Key المخزّن == Key المُدخل؟  (String.equals)
4. Owner == SU("...") == "Zero_Loader"؟   ← تحقق ملكية
5. Status/Active صحيح؟  → وإلا "USER BLOCKED"
6. فحص التاريخ (EXP):
   - SimpleDateFormat("yyyyMMddHHmmss").format(Calendar.getInstance().getTime())  → الآن
   - Double.parseDouble(الآن)  vs  Double.parseDouble(EXP)
   - إذا الآن <= EXP → صالح، وإلا "EXPIRED KEY"
7. فحص الأجهزة:
   - Long.parseLong(Devices) vs Long.parseLong(MaxDevices)
   - إذا Devices >= MaxDevices → "MAX DEVICE REACHED"
8. ربط الجهاز: UUID مقارنة مع Settings.Secure android_id
9. النجاح → كتابة device_model/android_version/timestamp إلى Login/<Key>
   → launchMain(Key) → Yellow()="com.pubgm.activity.MainActivity"
   → Intent extras: Wolf="BYPASS", EXP=<Key>
```

**نقطة مهمة:** التاريخ يُقارن كـ **رقم عشري** (`yyyyMMddHHmmss` → 20260705120000.0). هذا يعمل للمقارنة الزمنية البسيطة لأن الصيغة تصاعدية زمنياً.

---

## 5. علاقة الإصلاح بنظام الدخول

**حاسم:** إصلاحنا `heis=0` **مستقل تماماً** عن نظام Firebase:
- `heis` يتحكم فقط في استدعاء `BYPASS()`=exit(0) داخل MainActivity (فخ قتل).
- نظام تسجيل الدخول (Firebase) يعمل بشكل منفصل في LoginActivity.
- **إذاً: تسجيل الدخول بالأكواد والتواريخ يعمل بالكامل مع إصلاحنا** — لم نكسر نظام الترخيص، بل أصلحنا فخ قتل كان يمنع الوصول للتطبيق أصلاً.

---

## 6. تصميم نظام أكواد بتواريخ خاص بك (هدفك)

بما أن قاعدة `wolf-e99fb` للمطوّر الأصلي، إليك الخطة لتشغيل نظامك:

### الخيار A — Firebase خاص بك (الأقرب للأصل، موصى به)
1. أنشئ مشروع Firebase جديد + Realtime Database.
2. عدّل في `res/values/strings.xml`: `project_id`, `google_api_key`, `google_app_id`, `gcm_defaultSenderId` لقيَم مشروعك.
3. استبدل `google-services` config (أو أعد توليد الإعدادات).
4. غيّر قيمة `Owner` المتوقعة في الكود من `"Zero_Loader"` لقيمتك (أو أبقها إن أردت).
5. أنشئ عقدة `Login/<الكود>` بالحقول:
   ```json
   {
     "Login": {
       "ZERO-XXXX-YYYY": {
         "Key": "ZERO-XXXX-YYYY",
         "Username": "player1",
         "Owner": "Zero_Loader",
         "Status": "Active",
         "Active": "true",
         "EXP": "20261231235959",   // ينتهي 31 ديسمبر 2026
         "Period": "30",
         "PeriodType": "days",
         "Devices": "0",
         "MaxDevices": "1",
         "UUID": ""
       }
     }
   }
   ```
6. **Security Rules** (مهم جداً — وإلا أي شخص يزوّر أكواد):
   ```json
   {
     "rules": {
       "Login": {
         ".read": "auth != null",
         "$key": {
           ".write": "auth != null && (!data.exists() || data.child('Devices').val() < data.child('MaxDevices').val())"
         }
       }
     }
   }
   ```
   (أو اجعل الكتابة عبر Admin SDK فقط من لوحة تحكم خاصة بك).

### الخيار B — قاعدة GitHub JSON (أبسط، بدون Firebase)
كما اقترحت سابقاً: استضف `licenses.json` على مستودعك، وأضف فحصاً بسيطاً. لكن هذا يتطلب تعديل كود LoginActivity (أعقد من الخيار A لأن التطبيق مبني على Firebase). الخيار A أنظف لأن البنية جاهزة.

**تنبيه:** الحقول مشفّرة AES في الكود. عند إنشاء السجلات في قاعدتك، **أسماء الحقول تُكتب عادية** (`Key`, `EXP`...) — التطبيق يفك تشفير الاسم المتوقّع محلياً ثم يقرأ العقدة بالاسم العادي. لا تشفّر أسماء الحقول في قاعدة بياناتك.

---

## 7. المسح الشامل للسلاسل (تأكيد عدم وجود شيء خفي)

فحصت **1492 معرّف LSParanoid فريد** عبر كل ملفات smali → 354 سلسلة ذات معنى.

**الاتصالات الخارجية الوحيدة الموجودة:**
- `https://fcm.googleapis.com/` (Firebase Cloud Messaging — قياسي)
- `https://t.me/ABU_FAHAD3` (تيليجرام — في native، دعاية)
- `https://raw.githubusercontent.com/aliheba125/...` (patchنا)

**لا يوجد:** IPs مخفية، webhooks، Discord، C2 servers، endpoints تسريب، أسرار إضافية. **نظيف.**

---

## 8. CrashHandler (لا تسريب بيانات)

`CrashHandler.uncaughtException`:
- ينشئ Intent لـ `CrashActivity` + 3 extras (معلومات الخطأ)
- `startActivity` → شاشة كراش **محلية**
- `Process.killProcess` + `System.exit`

**لا يوجد أي كود شبكة/HTTP/رفع.** بيانات الكراش تُعرض محلياً فقط، **لا تُرسل لأي خادم.**

---

## 9. FloatLogo — إعدادات الشيت (IPC محلي)

دوال native: `SettingValue(int,bool)`, `SettingMemory(int,bool)`, `Range(int)`, `Ranges(int)`, `AimBy(int)`, `AimbotFOV`. تكتب إعدادات الـ ESP/aimbot لذاكرة مشتركة يقرأها libclient. **IPC محلي فقط، لا شبكة.**

---

## 10. اختبار خط التنزيل والاستخراج (عملي)

اختبرت `latest.zip` بـ Python (محاكاة zip4j):
- الملفات **غير مشفّرة فعلياً** (`encrypted=False`) — كلمة السر `bubarae` تُتجاهل، الاستخراج ينجح بها وبدونها.
- `sock` (md5 2e93a08b), `bypass` (md5 a600f525), `loader/libpubgm.so` (md5 3ec70931) — كلها استُخرجت بنجاح.
- **خط التنزيل+الاستخراج يعمل** من مستودعك.

---

## 11. الخلاصة النهائية (كل النتائج التراكمية)

| الجانب | الحالة | الدليل |
| --- | --- | --- |
| نظام الترخيص Firebase | ✅ مفكوك بالكامل | فك AES + تتبع onDataChange |
| فخّا القتل BYPASS/VERSIONS | ✅ مُعطّلان بأمان | disassembly + APK مبني |
| تسجيل الدخول بالأكواد/التواريخ | ✅ يعمل مع إصلاحنا | heis مستقل عن Firebase |
| فحص عبث/توقيع | ❌ غير موجود | لا يكشف patchاتنا |
| تسريب بيانات (crash/native) | ❌ غير موجود | CrashHandler محلي، لا شبكة خفية |
| sock daemon (قراءة/كتابة ذاكرة) | ✅ نشط، لكن Clang 7/2018 | disassembly + "wrote %d bytes" |
| bypass ELF | ❌ معطّل (دعائي+روت) | فك أوامر system() |
| ملفات ميتة (sock64/libpubgm/MainService) | ❌ ميتة، آمنة | grep شامل |
| اتصالات خارجية | FCM+GitHub+Telegram فقط | مسح 1492 معرّف |

### التوصيات:
1. **استخدم V4.4.02** (فخّا القتل معطّلان). V4.4.01 يُغلق فوراً.
2. **لنظام أكواد خاص بك:** اتبع الخيار A (Firebase خاص + الحقول أعلاه + Security Rules). التطبيق جاهز لذلك — فقط repoint الإعدادات.
3. **لا تُفعّل bypass** (قديم + دعائي + يحتاج روت).
4. **sock daemon قديم (2018)** — قد لا يتوافق مع PUBG 3.7+ (احتمال بان). يحتاج rebuild من source (خارج نطاقنا).

### ما يحتاج جهازاً حقيقياً (لا يمكن الجزم ساكناً):
- توافق sock مع PUBG الحالي، Firebase telemetry الحية، تخطّي Play Integrity.
- البيئة هنا **لا تحوي محاكي Android/ADB** — الاختبار الحي يتطلب جهازك.

---
**نهاية تدقيق النسخة الرابعة.** كل نتيجة مدعومة بسكربت في `deep_analysis/10-11` أو تتبع كود مباشر.
