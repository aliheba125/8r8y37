# التحليل الشامل المعمّق — Zero Loader V4.4.01 (Wolf)

> **تحليل ساكن (Static) + ديناميكي (Dynamic)** — تجميع موحّد ومُتحقَّق منه لكل النتائج.
> **مستوى التهديد:** حرج (Critical). التطبيق أداة غش لـ PUBG Mobile + سلوك برمجية خبيثة (Malware) محتمل.
>
> **ملاحظة منهجية:** كل قيمة في هذا التقرير تحمل حالة تحقق: `[مُتحقَّق محليًا]` استُخرجت وأُعيد بناؤها في هذه الجلسة، أو `[من تحليل سابق]` موثّقة في تقارير المستودع ولم يُتَح التحقق منها محليًا (مثل ملفات تُنزَّل وقت التشغيل وغير موجودة في المستودع).

---

## 0. المنهجية والأدوات

| البند | التفصيل |
|---|---|
| الأداة الأساسية | `apktool 2.9.3` (smali) + `jadx 1.5.0` (Java) |
| ملف التحليل | `Zero_LoaderV4.4.01.apk` — 21,030,762 بايت |
| فك التشويش النصّي | إعادة بناء خوارزمية LSParanoid بلغة Java وتشغيلها على الشرائح (chunks) الفعلية |
| فك تشفير القيم | AES/CBC/PKCS7 بمفتاح `SHA-256("Activity")` و IV أصفار |
| تحليل الملفات الثنائية | `file`, `nm -D`, `strings` على مكتبات ARM64 |

**نتيجة التحقق من التشويش:** تم فك **397/397** سلسلة LSParanoid بنجاح (0 فشل)، و **30** سلسلة إضافية كانت مُشفّرة طبقتين (LSParanoid ثم AES).

---

## 1. الهوية والبنية العامة

- **الاسم التجاري:** Zero Loader / Wolf — **الحزمة:** `com.pubgm`
- **الغرض:** تشغيل PUBG Mobile داخل بيئة افتراضية مع حقن غش (ESP + Aimbot + تعطيل مكافحة الغش).
- **المطوّر (من تحليل سابق):** GitHub `uchihaaymane` (ID 135393589)، اسم داخلي `bubarae`، قنوات Telegram `@SUFIYAN_TANHA` و `@ABU_FAHAD3`.

**الألعاب المستهدفة** (`com/pubgm/Config.java`):
`com.tencent.ig` (Global) · `com.pubg.krmobile` (Korea) · `com.vng.pubgmobile` (Vietnam) · `com.rekoo.pubgm` (Taiwan/China) · `com.pubg.imobile` (India).

---

## 2. الملفات الثنائية الأصلية (داخل الـ APK) — `[مُتحقَّق محليًا]`

جميعها `arm64-v8a` فقط (يعمل على أجهزة 64-بت حصرًا):

| المكتبة | الحجم | الدور | الأصل التقني |
|---|---|---|---|
| `libclient.so` | 318,888 | واجهة الغش: ESP/Aimbot/قراءة الذاكرة + الترخيص | مبنية بـ clang 14 (Android r437112b)، stripped |
| `libTcore.so` | 295,184 | محرك البيئة الافتراضية | **BlackBox / VirtualApp** (يستخدم مسار `/blackbox/`، `com/tcore/core/NativeCore`) |
| `libpine.so` | 54,328 | خطف دوال Java وقت التشغيل | **Pine** (canyie/pine) — trampoline على ART |

### 2.1 الدوال المُصدَّرة من `libclient.so` (JNI) — `[مُتحقَّق محليًا]`
```
Java_..._MainActivity_BYPASS        ← تعطيل مكافحة الغش
Java_..._MainActivity_VERSIONS      ← فحص/توقيع الإصدار
Java_..._MainActivity_GetKey        ← الترخيص
Java_..._LoginActivity_GetKey / _Yellow
Java_..._floating_Overlay_DrawOn / _Close / _getReady   ← رسم ESP فوق الشاشة
Java_..._floating_FloatAim_AimbotFOV                    ← Aimbot + FOV
Java_..._floating_FloatLogo_SettingMemory / _SettingValue / _SettingValueI  ← كتابة/قراءة ذاكرة
Java_..._floating_FloatLogo_WideView / _SkinCloshes / _Target / _Range / _Ranges
Java_..._floating_FloatLogo_setHealthType / _setCountType / _AimBy
Java_..._fragments_HomeFragment_Telegram
```
هذه القائمة وحدها تثبت مجموعة ميزات الغش الكاملة: **ESP (رادار/صناديق أعداء/مركبات/عناصر/مسافات/صحة)، Aimbot بزاوية FOV، فتح ملابس/سكنات (SkinCloshes)، WideView، وتلاعب مباشر بالذاكرة (SettingMemory/Value)**.

### 2.2 الحمولات المُنزَّلة وقت التشغيل — `[من تحليل سابق]`
غير موجودة في المستودع؛ تُنزَّل من GitHub:
- `servernrot.zip` من `https://github.com/uchihaaymane/files/releases/download/files/servernrot.zip`
- تحتوي: `sock`/`sock64` (شيطان قراءة الذاكرة عبر `/proc/pid/maps` و `/proc/pid/mem`، ويستخدم `/dev/uinput` لِلمس وهمي للـ Aimbot)، `bypass` (تعديل `libanogs.so`)، و`libpubgm.so` (خطّاف PLT عبر **xhook 1.2.0** يستهدف `libUE4.so`، `libanogs.so`، `libgcloud.so`، وأكثر من 20 مكتبة).

> **خطر بنيوي:** بما أن هذه الحمولات تُجلب وقت التشغيل من مستودع GitHub يتحكم به المطوّر، يمكن **استبدال محتواها عن بُعد في أي لحظة** دون تحديث التطبيق — أي أنّ ما تفحصه اليوم قد لا يطابق ما يُنفَّذ غدًا.

---

## 3. التشويش (Obfuscation) — `[مُتحقَّق محليًا]`

- **الأداة:** LSParanoid (`org.lsposed.lsparanoid`) — تشفير سلاسل فقط، **لا يوجد ProGuard/R8** على منطق الكود (أسماء الحزم والدوال واضحة).
- **الشريحة:** سلسلة واحدة بطول 6456 حرفًا داخل `Deobfuscator$M5LOADER$app.smali`.
- **الطبقة الثانية:** بعض القيم الحسّاسة مُشفّرة LSParanoid ثم AES (دالة `SU()`). فك تشفيرها كشف مخطّط Firebase كاملًا (انظر §5).

**عيّنة من أهم القيم المفكوكة:**
| المعرّف | القيمة |
|---|---|
| رابط FCM | `https://fcm.googleapis.com/` |
| حمولة GitHub | `https://github.com/uchihaaymane/files/.../servernrot.zip` |
| مفتاح AES | `Activity` |
| الخوارزمية | `AES/CBC/PKCS7Padding` + `SHA-256` |
| كلمة سر الـ ZIP | `bubarae` |
| عُقد Firebase | `aplikasi`, `users`, `client`, `version`, `status` |

---

## 4. التشفير — نقاط ضعف قاتلة — `[مُتحقَّق محليًا]`

من `LoginActivity$AESCrypt`:
```java
private static final byte[] ivBytes = new byte[16];   // IV = 16 صفر ← ثابت
key = SHA-256("Activity")                              // مفتاح ثابت مكشوف
AES/CBC/PKCS7Padding
```
**لماذا هي قاتلة:**
1. **المفتاح ثابت ومكشوف** (`Activity`) داخل التطبيق — أي أحد يفك تشفير/يشفّر أي قيمة.
2. **IV أصفار ثابت** — نفس النص الصريح يُنتج نفس النص المشفّر دائمًا (قابل للتنبؤ، عرضة لهجمات القاموس/إعادة الإرسال).
3. النتيجة: **نظام الترخيص بأكمله قابل للكسر** — يمكن توليد تراخيص Premium وهمية صالحة (Status=Active, Period=Lifetime, EXP بعيد). (يوجد `keygen.py` في المستودع كإثبات مفهوم سابق.)

---

## 5. الخلفية والاتصال (Firebase / C2) — `[مُتحقَّق محليًا للمفاتيح والمخطط]`

**مشروع Firebase:** `wolf-e99fb`
| المفتاح | القيمة |
|---|---|
| API Key | `AIzaSyAOrhEU4gPb1cij7NTjVvdnx6cOwcy4UKE` |
| App ID | `1:183662681739:android:fdaaf27da5e5e60b893e8e` |
| Sender ID | `183662681739` |
| Storage | `wolf-e99fb.firebasestorage.app` |
| **FCM Server Key** | مكشوف بالكامل داخل `Api.java` (رأس `Authorization`) — تحكم كامل في إشعارات التطبيق |

**مخطّط قاعدة البيانات المُعاد بناؤه من فك تشفير AES (30 قيمة):**
- **عُقد جذر:** `users`, `aplikasi`, `client`, `group_chats`
- **حقول المستخدم/الترخيص:** `Username`, `Key`, `EXP`, `Devices`, `MaxDevices`, `Owner`, `Status`(→`Active`), `UUID`, `Period`, `Login`
- **رسائل الحالة:** `USER NOT REGISTERED`, `MAX DEVICE REACHED`, `USER BLOCKED`, `EXPIRED KEY`, `Login Success`
- **عقدة التحديث (`aplikasi`):** `version`, `description`, `url`, `Update`

**ثغرات البنية التحتية (من تحليل سابق، اختبار نشط):** مصادقة مجهولة مفعّلة (إنشاء حسابات لا نهائية/استنزاف موارد)، عقدة `/aplikasi` مقروءة عامًّا، وتسريب مفاتيح API/FCM. يوجد `firebase_exploit_poc.py` في المستودع.

---

## 6. تدفّق التنفيذ (Execution Flow) — `[مُتحقَّق محليًا للخطوات داخل الـ APK]`

1. `SplashActivity` → `LoginActivity`: مصادقة Firebase + فك تشفير AES للتحقق من المفتاح والجهاز (UUID/Devices/MaxDevices).
2. `BoxApplication`: تحميل `libclient`، تهيئة بيئة TCore الافتراضية مع **إخفاء الروت**.
3. `MainActivity.onCreate`: تنزيل `servernrot.zip` من GitHub (`FileDownloadTask`) ← فكّه بكلمة سر `bubarae` ← نقله إلى `files/`.
4. استدعاء `VERSIONS()` (توقيع الإصدار) و`BYPASS()` (تعطيل مكافحة الغش) الأصليين.
5. نسخ ملفات OBB للعبة داخل البيئة الافتراضية (`FileHelper.tryInstallWithCopyObb`) + `chmod 755` عبر الروت.
6. `TCoreCore.launchApk()` لتشغيل اللعبة داخل الحاوية.
7. `startPatcher()` يفتح Socket محلي؛ الشيطان `sock64` يقرأ ذاكرة اللعبة ويغذّي `libclient`؛ `Overlay.DrawOn` يرسم الـ ESP، و`FloatAim.AimbotFOV` يوجّه التصويب.

**التنزيل بلا أي تحقّق سلامة (integrity):** `HttpURLConnection` عادي بدون تجزئة/توقيع — أي اعتراض للشبكة (MITM) أو اختراق حساب GitHub يسمح بحقن حمولة عشوائية تُنفَّذ بصلاحيات عالية.

---

## 7. آلية التدمير (Kill Switch) — `[من تحليل سابق — غير قابل للتحقق محليًا]`

موثّق في المستودع أنّ الشيطان `sock64` يحوي أمرًا تدميريًا:
```
su -c "rm -rf /data/* && reboot"
```
يُطلَق كـ "صمّام أمان" إذا لم تطابق بيئة التشغيل توقيع المطوّر (Package=`com.ldev.leoskillz`, Version=`3.7.3`, Label=`LeoSkillz`, Date=`2025-05-17`) — أي عند تشغيل الشيطان مع APK معدّل. العنوان الموثّق `0x3f919`.

> **تحذير:** لم أستطع التحقق من هذا محليًا لأن `sock64`/`servernrot.zip` **غير موجودة في المستودع** وتُنزَّل وقت التشغيل. أنصح بعدم تشغيل أي من هذه الأدوات على جهاز يحوي بيانات حقيقية.

---

## 8. الأذونات والمكوّنات (AndroidManifest) — `[مُتحقَّق محليًا]`

- **188 إذنًا** — مفرط جدًا لأداة غش، ويشمل أذونات لا علاقة لها بالوظيفة: SMS (قراءة/إرسال/استقبال)، سجل المكالمات، جهات الاتصال، الكاميرا، الميكروفون، `BIND_VPN_SERVICE`، `REQUEST_INSTALL_PACKAGES`، `SYSTEM_ALERT_WINDOW`.
- **أعلام خطرة في `<application>`:**
  - `android:debuggable="true"` ← **حرج** (يسمح بإرفاق مصحّح وتفريغ الذاكرة).
  - `android:allowBackup="true"` ← يسمح بسحب بيانات التطبيق عبر ADB.
  - `android:requestLegacyExternalStorage="true"`.
  - نص صريح (cleartext HTTP) مسموح.
- **مكوّنات BlackBox الافتراضية:** عشرات `com.tcore.proxy.ProxyContentProvider$P0..Pn`، `SystemCallProvider`، `ProxyBroadcastReceiver` — للتحكم في العمليات داخل الحاوية.
- **خدمات الغش:** `com.pubgm.floating.Overlay`, `FloatAim`, `FloatLogo`.

---

## 9. متغيّرات الـ APK في المستودع

| الملف | الحجم | ملاحظة |
|---|---|---|
| `Zero_LoaderV4.4.01.apk` | 21,030,762 | الأصلي (محلّل هنا) |
| `Zero_LoaderV4.4.01_CRACKED.apk` | 21,252,992 | نسخة مكسورة الترخيص |
| `Zero_LoaderV4.4.01_FINAL.apk` | 22,187,230 | تُستخدم في CI |
| `Zero_Loader_FINAL_STABLE_PREMIUM.apk` / `_FIXED_PREMIUM` / `_PREMIUM_SAFE` | 20,736,292 | نسخ Premium معدّلة (متطابقة الحجم) |

> يشير وجود `git log` مثل «FULL OFFLINE: All features work without Firebase» و«bundled servernrot files in assets» إلى أنّ هذا المستودع هو بيئة عمل تُعدّل الأداة وتُزيل اعتمادها على Firebase وتدمج الحمولات محليًا.

---

## 10. ملخّص المخاطر (تصنيف)

| # | الخطر | الشدّة | الحالة |
|---|---|---|---|
| 1 | غش ESP/Aimbot + تعطيل مكافحة الغش (`libanogs`) | حرج | مُتحقَّق (JNI) |
| 2 | تنزيل وتنفيذ حمولات أصلية من GitHub بلا تحقّق سلامة | حرج | مُتحقَّق (الكود) |
| 3 | أمر تدميري `rm -rf /data/*` في `sock64` | حرج | تحليل سابق |
| 4 | مفتاح AES ثابت `Activity` + IV أصفار → كسر الترخيص | حرج | مُتحقَّق |
| 5 | تسريب FCM Server Key + مفاتيح Firebase | حرج | مُتحقَّق |
| 6 | Firebase: مصادقة مجهولة + عقدة عامة للقراءة | عالٍ | تحليل سابق |
| 7 | `debuggable=true` + `allowBackup=true` | عالٍ | مُتحقَّق |
| 8 | 188 إذنًا (SMS/مكالمات/كاميرا/VPN...) | عالٍ | مُتحقَّق |
| 9 | استخدام الروت + `chmod`/إخفاء الروت | عالٍ | مُتحقَّق |

---

## 11. الخلاصة

Zero Loader V4.4.01 ليس مجرد أداة غش، بل منظومة كاملة: **بيئة افتراضية (BlackBox) + خطّاف ART (Pine) + خطّاف PLT (xhook) + شيطان قراءة ذاكرة (sock64) + تعطيل مكافحة الغش + خلفية Firebase/GitHub**. أخطر ما فيه من منظور المستخدم النهائي هو **الجمع بين صلاحيات الروت، وتنزيل حمولات قابلة للاستبدال عن بُعد بلا تحقّق، ووجود أمر تدميري (`rm -rf /data/*`)** — ما يجعله برمجية خبيثة محتملة قادرة على مسح الجهاز. ومن منظور المطوّر، فإن **التشفير الثابت المكشوف وإعدادات Firebase غير الآمنة** تجعل نظام الترخيص والبنية التحتية قابلين للكسر بالكامل.
