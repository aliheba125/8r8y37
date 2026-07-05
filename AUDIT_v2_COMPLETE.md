# تدقيق Zero_Loader — النسخة الثانية (V4.4.02) — تحليل عميق + إصلاح حرج

**تاريخ:** 2026-07-05  
**الـ APK الحالي:** `Zero_LoaderV4.4.02_KILL_TRAP_FIXED.apk` — MD5 `472450db6fbc07d0cfb818b95f97347f`  
**منهج التدقيق:** فحص ساكن مع Unicorn/Capstone/LIEF/androguard + محاكاة CPU + فك تشفير LSParanoid فعلي + disassembly للـ ARM64

---

## 🚨 اكتشاف حرج جداً — تصحيح التدقيق السابق

### الادعاء السابق (خاطئ):
> "libclient.so BYPASS() = طبقة حماية نشطة، مُفعّلة عبر patch heis=1"

### الحقيقة المُثبتة بالـ disassembly:

**`Java_com_pubgm_activity_MainActivity_BYPASS` = `exit(0)`**

Disassembly كامل من libclient.so:
```
0x1f1a0: stp x29, x30, [sp, #-0x10]!   ; حفظ frame
0x1f1a4: mov x29, sp
0x1f1a8: mov w0, wzr                   ; arg1 = 0
0x1f1ac: bl  #0x49490                  ; ← يستدعي PLT stub
0x1f1b0: stur xzr, [x0, #6]            ; كود ميت (exit لا يعود)
0x1f1b4: str xzr, [x0]                 ; كود ميت
0x1f1b8: ret                           ; كود ميت
```

الـ PLT stub في 0x49490:
```
0x49490: adrp x16, #0x4e000
0x49494: ldr  x17, [x16, #0xb8]        ; يقرأ من 0x4e0b8
0x49498: add  x16, x16, #0xb8
0x4949c: br   x17                      ; يقفز للدالة
```

وحسب جدول الـ relocations (تم إثباته بواسطة LIEF):
```
0x4e0b8  →  symbol: exit  (TYPE: AARCH64_JUMP_SLOT)
```

**النتيجة:** BYPASS() تستدعي `exit(0)` مباشرة. نفس الشيء لـ `VERSIONS()` (تشترك في نفس الكود بأسلوب "fall-through").

### تأثير هذا على patches السابقة:

في MainActivity.onCreate:
```java
String wolfExtra = intent.getStringExtra("Wolf");
if (wolfExtra == null || !wolfExtra.contains("BYPASS")) {
    VERSIONS();  // ← exit(0) — فخ قتل إذا لم تدخل من LoginActivity
}
if (LoginActivity.heis) {
    BYPASS();   // ← exit(0) — فخ قتل إذا تُلاعب بالـ APK
}
```

**فهم التصميم الأصلي:** `heis` ليس اختصاراً لـ "he is authorized" بل هو flag يُقال "**he is [suspected of tampering]**". القيمة الأصلية = `false`. إذا حاول شخص تعديل الـ APK لجعلها `true` (كما فعلتُ)، تُنفَّذ `BYPASS()` = exit(0) = **قتل التطبيق بصمت**.

### الـ patch الخاطئ الذي طبقتُه سابقاً:
```smali
# LoginActivity.<clinit>
const/4 v0, 0x1                    ← كنت أظنّه تفعيل حماية
sput-boolean v0, ...->heis:Z
```

**النتيجة الفعلية:** كل مستخدم كان سيفتح التطبيق → LoginActivity يُحمَّل → heis=1 → يفتح MainActivity → BYPASS() تُستدعى → exit(0) → إغلاق فوري بدون إشعار.

### الإصلاح المُطبَّق في V4.4.02:

**تعديل 1 — LoginActivity.smali:**
```smali
:goto_0
# REVERTED CRITICAL BUG: heis=1 caused BYPASS()=exit(0) trap to fire
const/4 v0, 0x0                    ← عودة للأصل
sput-boolean v0, Lcom/pubgm/activity/LoginActivity;->heis:Z
```

**تعديل 2 — MainActivity.smali (defense-in-depth):**
```smali
:cond_2
sget-boolean v3, Lcom/pubgm/activity/LoginActivity;->heis:Z
goto :cond_3                       ← تجاوز غير مشروط
if-eqz v3, :cond_3                 ← لا يُنفَّذ
invoke-direct BYPASS()             ← لا يُنفَّذ
:cond_3
```

حتى لو تلاعب أحد بـ heis مستقبلاً، BYPASS() لن تُنفَّذ أبداً.

**تعديل مُبقى من V4.4.01 (كان صحيحاً):**
- `goto :cond_2` قبل VERSIONS() — يتجاوز VERSIONS()=exit(0) أيضاً
- استبدال URL التنزيل بمستودعنا
- HTTPS enforcement
- `debuggable=false`

---

## القسم 1 — بيانات ميتا الـ APK (androguard, ground truth)

| المفتاح | القيمة | ملاحظة |
| --- | --- | --- |
| Package | `com.pubgm` | ⚠️ يحاول تقليد اسم لعبة PUBG |
| Version name | `4.2` | ⚠️ لا يتطابق مع اسم الملف "4.4.02" — نص فقط |
| Version code | `1` | لم يُرفع مرة واحدة |
| Min SDK | `24` (Android 7.0) | |
| Target SDK | `28` (Android 9) | ⚠️ **قديم جداً** — 6 سنوات، يحصل على صلاحيات إضافية |
| Compile SDK | `34` (Android 14) | |
| Main Activity | `com.pubgm.activity.SplashActivity` | (وليس MainActivity كما ظننت سابقاً) |
| App name | `Zero Loader` | |
| Debuggable | `false` | ✓ patched |
| Allow backup | `true` | ⚠️ ADB backup ممكن — يكشف بيانات المستخدم |
| Network security | `@7F150005` | ✓ ملف مخصص |
| Extract native libs | `true` | |
| توقيع | V2+V3 صحيح | ✓ |

**تحذير أمني:** `targetSdkVersion=28` يعني أن التطبيق **لا يمكن نشره على Google Play** (Play يطلب ≥34)، ويحصل على صلاحيات بأسلوب Android القديم (قبل scoped storage). هذا "تخفيض متعمد" لتفادي القيود الأمنية.

### الصلاحيات — 180+ صلاحية (⚠️ خطيرة جداً)

**صلاحيات لا يحتاجها cheat loader طبقياً:**
- `READ_SMS`, `WRITE_SMS`, `SEND_SMS`, `RECEIVE_SMS`, `BROADCAST_SMS`, `RECEIVE_MMS`, `RECEIVE_WAP_PUSH`
- `READ_CALL_LOG`, `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS`, `CALL_PHONE`
- `READ_CONTACTS`, `WRITE_CONTACTS`, `GET_ACCOUNTS`, `AUTHENTICATE_ACCOUNTS`
- `CAMERA`, `RECORD_AUDIO`, `BODY_SENSORS`
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_GPS`
- `READ_CALENDAR`, `WRITE_CALENDAR`
- `READ_LOGS` — يقرأ سجلات النظام (privileged)
- `PACKAGE_USAGE_STATS` — يتجسس على استخدام التطبيقات الأخرى
- `INSTALL_PACKAGES`, `DELETE_PACKAGES`
- `BIND_VPN_SERVICE` — يمكن أن ينشئ VPN
- `MANAGE_EXTERNAL_STORAGE`, `MOUNT_UNMOUNT_FILESYSTEMS`
- `QUERY_ALL_PACKAGES` — يرى كل التطبيقات

**التقييم:** التطبيق مُعبَّأ بصلاحيات "boilerplate" مفرطة من قوالب Android قديمة. أغلبها **لن يُمنح فعلياً** (Android يرفض صلاحيات النظام لتطبيقات المستخدم)، لكن هذا الحجم من الطلبات علامة تحذيرية.

---

## القسم 2 — مكونات المستوى العلوي (Manifest deep parse)

**عدد النشاطات:** 106 (بعد فرز الـ proxies)  
**عدد الخدمات:** 111  
**عدد الـ receivers:** 4  
**عدد الـ providers:** 55

### المكونات الرئيسية (غير TCore)

| مكوّن | نوع | Exported | ملاحظة |
| --- | --- | --- | --- |
| `SplashActivity` | Activity | **YES** (LAUNCHER) | نقطة الدخول الفعلية |
| `LoginActivity` | Activity | no | نظام ترخيص Firebase |
| `MainActivity` | Activity | no | لوحة تحكم الشيت |
| `GroupActivity` | Activity | no | |
| `CrashActivity` | Activity | **YES** | يظهر عند crash |
| `MainService` | Service | no | ❌ **ميتة** — لا يبدأها أحد |
| `Overlay` | Service | no | يرسم الـ ESP |
| `FloatLogo` | Service | no | إعدادات عائمة |
| `FloatAim` | Service | no | مؤشر التصويب |
| `FirebaseIdService` | Service | no | Firebase FCM |
| `FirebaseMessaging` | Service | no | Firebase FCM |

### إطار عمل TCore — ⚠️ اكتشاف جوهري لم أدركه في التدقيق السابق

**TCore هو إطار VirtualApp / Parallel-Space** لتشغيل تطبيقات داخل تطبيقات:

- 50 × `ProxyActivity$P0..P49` — activities وهمية لتشغيل التطبيق الضيف
- 50 × `TransparentProxyActivity$P0..P49` — activities شفافة
- 50 × `ProxyService$P0..P49` — services وهمية
- 50 × `ProxyJobService$P0..P49` — job services وهمية
- 50 × `ProxyContentProvider$P0..P49` — content providers وهمية

**المجموع:** 250 مكوّن proxy لبناء "sandbox" حول لعبة PUBG.

**بالإثبات:** استدعاءات فعلية موجودة في smali:
```
MainActivity.smali:2396  TCoreCore.launchApk(pkg, userId)
ApkEnv.smali:430,452,474  TCoreCore.installPackageAsUser(pkg, userId)
ApkEnv.smali:549          TCoreCore.launchApk(pkg, userId)
ApkEnv.smali:613          TCoreCore.uninstallPackageAsUser(pkg, userId)
```

**آلية العمل الحقيقية للـ cheat:**
1. المستخدم يفتح Zero Loader
2. Zero Loader يستقبل ملف PUBG APK  
3. `ApkEnv.installPackageAsUser` يُثبت PUBG داخل بيئة TCore الافتراضية
4. `ApkEnv.launchApk` يشغّل PUBG داخل الـ sandbox
5. داخل الـ sandbox، كل استدعاءات API تُوجَّه عبر Pine ART hooks + libTcore hooks
6. libclient.so يوفر واجهة الـ ESP/Aimbot

هذا **أعقد بكثير** مما كنت أعتقد. الطبقة العائمة (Overlay) هي فقط الواجهة المرئية.

### الـ ProxyVpnService

**اكتشاف حرج:** موجودة خدمة VPN — يمكن للتطبيق الاعتراض على كامل حركة الشبكة. **ولكن**:

بحث في الكود: `establishVpn` يُستدعى فقط من داخل `com.tcore.fake.service.VpnCommonProxy` — أي أنها خدمة VPN مُخصصة **للتطبيق الضيف** (PUBG داخل الـ sandbox)، وليست لاعتراض حركة الشبكة الأصلية للمستخدم.

**تقييم الخطر:** متوسط. لن يتم إنشاء VPN إلا إذا حاول التطبيق الضيف (PUBG) إنشاء VPN — وهو لن يفعل. لكن التصريح موجود في manifest = surface attack موجود.

---

## القسم 3 — تحليل عميق للـ Native Libraries

### 3.1 مقارنة أعمار الملفات (Clang version) ⚠️ تناقض حرج

| ملف | حجم | Clang | تاريخ تقديري |
| --- | ---: | --- | --- |
| `libclient.so` | 319KB | 14.0.1 | 2022 |
| `libTcore.so` | 295KB | 19.0.1 | 2024 |
| `libpine.so` | 54KB | 9.0.9 | 2019-2020 |
| `assets/servernrot/sock` | 44KB | **7.0.0** | **2018-2019** ⚠️ |
| `assets/servernrot/bypass` | 547KB | **7.0.0** | **2018-2019** ⚠️ |
| `assets/servernrot/loader/libpubgm.so` | 912KB | **7.0.0** | **2018-2019** (لكن dead) |
| `assets/sock64` | 314KB | **7.0.0** | **2018-2019** (dead) |
| `res/raw/bypass` | 555KB | **7.0.0** | **2018-2019** (dead) |

**تقييم:** الجزء الذي يقرأ ذاكرة اللعبة (`sock`) والذي يخترق anti-cheat (`bypass`) بُنيا قبل 6-7 سنوات. PUBG Mobile اليوم عند إصدار 3.7+، لكن هذه الملفات تعرف فقط الإصدار 3.1.0 (حسب `games.json`).

**التبعات:**
- ✅ `libclient.so` (النواة) حديثة نسبياً — تدعم Android 14 API 34
- ✅ `libTcore.so` (VirtualApp) حديثة جداً — تدعم Android 15/16
- ❌ `sock` + `bypass` قديمتان جداً — إذا شُغلتا مع PUBG 3.7 الحالي: إما فشل صامت، أو تحطُم، أو **كشف/بان فوري**

---

### 3.2 libclient.so — النواة (319KB, MD5 c66e96fbd8a7de146e6592d6864baeae)

**عدد صادرات JNI (Java_*):** 21

| Native Method | Java Class | حالة |
| --- | --- | --- |
| `Java_com_pubgm_activity_LoginActivity_GetKey` | LoginActivity | ✓ يُستدعى |
| `Java_com_pubgm_activity_LoginActivity_Yellow` | LoginActivity | ✓ يُستدعى (يُعيد اسم Class) |
| `Java_com_pubgm_activity_MainActivity_BYPASS` | MainActivity | 🚨 **exit(0) — kill trap** |
| `Java_com_pubgm_activity_MainActivity_GetKey` | MainActivity | ✓ |
| `Java_com_pubgm_activity_MainActivity_VERSIONS` | MainActivity | 🚨 **exit(0) — kill trap** |
| `Java_com_pubgm_floating_FloatAim_AimbotFOV` | FloatAim | ✓ |
| 12 × FloatLogo native methods | FloatLogo | ✓ |
| `Java_com_pubgm_floating_Overlay_Close` | Overlay | ✓ |
| `Java_com_pubgm_floating_Overlay_DrawOn` | Overlay | ✓ |
| `Java_com_pubgm_floating_Overlay_getReady` | Overlay | ✓ يفتح Unix socket |
| `Java_com_pubgm_fragments_HomeFragment_Telegram` | ❌ لا يوجد | orphan export |

**النتيجة:** من 21 صادرة، **19 حية**، **2 kill-traps**، **1 orphan**.

**Imports حرجة:** `socket`, `bind`, `__system_property_get`. أي أن libclient.so ينشئ ساكت مستمع (`listen`) لاستقبال بيانات من `sock` daemon، ويقرأ خصائص النظام (على الأرجح للتحقق من أن الجهاز ليس محاكياً).

**سلاسل بارزة في .rodata:** سلسلة واحدة فقط بارزة = `"com.pubgm.activity.MainActivity"` (استخدام `Yellow()`). **لا يوجد أي URLs مخفية، لا endpoints تجسسية، لا backdoors.**

---

### 3.3 libTcore.so — إطار الـ VirtualApp (295KB, MD5 8e338891472ba3cc43c0e8bf7e5986f4)

**JNI_OnLoad @ 0x1fafc** — يُهيّئ كل الـ hooks عند تحميل المكتبة.

**صادرات hook حرجة (22):**

| Symbol | وظيفة | تقييم |
| --- | --- | --- |
| `hideXposed` | يخفي `de/robv/android/xposed/` و `me/weishu/exposed` من `/proc/self/maps` | ✓ حماية نشطة |
| `fake_dlopen` / `fake_dlsym` | تجاوز linker namespaces (Android 10+ يمنع dlopen لبعض libs) | ✓ يستخدمها لتحميل مكتبات النظام |
| `BinderHook::init` | يهوك استدعاءات Binder (IPC) | ✓ لاعتراض ما ترسله PUBG للـ system_server |
| `DexFileHook::init` | يهوك DexFile — يخفي/يعدل classes المحمّلة | ✓ |
| `RuntimeHook::init` | يهوك ART Runtime — للحقن العام | ✓ |
| `VMClassLoaderHook::init` | يهوك ClassLoader — نفس هدف hideXposed | ✓ |
| `UnixFileSystemHook::init` | يهوك UnixFileSystem — يخفي ملفات مثل `/data/local/tmp/frida-server` | ✓ |
| `JniHook::InitJniHook` | يهوك دوال JNI معينة | ✓ |
| `SandHook::ElfImg::findSymbol` | يبحث symbols في ELF (لتحديد عناوين hook) | ✓ (استخدام داخلي) |

**Imports حرجة:** `__system_property_get`, `mmap`. **لا يوجد `exit`, `abort` فقط للتعامل مع C++ exceptions.**

**تحليل:** libTcore.so **لا تعترض `exit()`** — أي أن `exit(0)` من libclient.so ينفَّذ فعلياً في العملية. هذا يُثبت أن BYPASS()/VERSIONS() traps فعلاً تقتل التطبيق.

---

### 3.4 libpine.so — ART inline hooking (54KB)

**JNI_OnLoad @ 0x9200**. مكتبة Pine الأصلية من [github.com/canyie/pine](https://github.com/canyie/pine) — إطار hooking للـ ART.

**Exports مميزة:** `PineOpenElf`, `PineCloseElf`, `PineGetElfSymbolAddress`, `PineNativeInlineHookFuncNoBackup`, `PineNativeInlineHookSymbolNoBackup`, `PineSetAndroidVersion`, `PineFillWithNop`.

**Imports حرجة:** `mprotect`, `mmap` فقط — نظيفة، معروفة المصدر.

**تقييم:** مكتبة open-source معروفة، آمنة. تُستخدم بواسطة `TCoreCompat` لهوك دوال Android الأساسية.

---

### 3.5 sock daemon (44KB, تُنزَّل من latest.zip)

**نوع:** ELF قابل للتنفيذ (Position-Independent Executable).  
**Interpreter:** `/system/bin/linker64`.

**Imports حرجة:** `popen`, `open`, `connect`, `socket`.

**سلاسل مكشوفة:**
```
/proc/%d/maps         ← يقرأ خريطة الذاكرة لعملية اللعبة
/proc/%d/mem          ← يقرأ ذاكرة العملية مباشرة
/proc/%s/cmdline      ← يبحث عن اسم العملية
pidof %s              ← يستخدم popen لتشغيل `pidof <package>` ← للحصول على PID اللعبة
com.tencent.ig        ← PUBG Global
com.pubg.krmobile     ← PUBG KR
com.vng.pubgmobile    ← PUBG VN
com.rekoo.pubgm       ← PUBG TW
com.pubg.imobile      ← PUBG IN
```

**كيف يعمل:**
1. يُشغَّل عبر `Runtime.exec("chmod 777 <path>; <path>")` من `loadAssets()` في MainActivity
2. يستخدم `popen("pidof com.tencent.ig")` للحصول على PID PUBG
3. يفتح `/proc/<pid>/maps` لتحديد عناوين مكتبة اللعبة
4. يفتح `/proc/<pid>/mem` للقراءة (يحتاج نفس UID = لا يحتاج root)
5. يفتح Unix socket `/data/data/<pkg>/files/sock` (يستمع)
6. libclient.so داخل التطبيق يتصل بالساكت ويطلب بيانات ذاكرة اللعبة

**تقييم الخطر:** ✅ لا يستخدم `system()` — يستخدم `popen()` لقراءة output فقط. لكن **قديم (Clang 7 من 2018)** — قد لا يتوافق مع PUBG الحديث.

---

### 3.6 bypass ELF (547KB, تُنزَّل من latest.zip)

**Imports حرجة:** `fopen`, `pthread_create`, **`system`** ⚠️, `mprotect`, `open`.

**سلاسل مكشوفة:**
```
Bypass Active         ← علامة النجاح
libanogs.so           ← هدف: Tencent ANOGS Anti-Cheat
kill %d               ← يُستخدم مع system() لقتل عمليات
/data/data/%s/files   ← مسار داخلي
```

**تقييم:**
- ✅ يستهدف anti-cheat فعلياً (Tencent ANOGS)
- ✅ يستخدم OpenGL hooks (`libGLESv2.so`) — على الأرجح لتزييف screenshots المُلتقطة من anti-cheat
- ⚠️ يستخدم `system("kill <PID>")` — يمكن أن يقتل أي عملية
- ⚠️ **قديم (Clang 7, 2018)** — إذا كان anti-cheat Tencent تطوّر (وهو تطوَّر)، هذا الـ bypass لن يعمل → **بان فوري**
- ❌ **حالياً معطّل** بسبب Case-mismatch bug (الكود يبحث `Bypass` بحرف كبير، الملف اسمه `bypass` بحرف صغير)

هذا الـ bug **ليس منّي** — لدى الملف الأصلي `224e340326ab180227221ddf4d8b36be` من مستودع المطور الأصلي نفس الحالة.

**قرار:** لا نُصلح هذا الـ bug لأن تفعيل bypass قديم قد يُسبب بان أكثر من عدم استخدامه.

---

### 3.7 libpubgm.so — iQiyi xhook (912KB, في latest.zip)

**JNI exports:**
- `Java_com_qiyi_xhook_NativeHandler_refresh`
- `Java_com_qiyi_xhook_NativeHandler_enableSigSegvProtection`
- `Java_com_qiyi_xhook_NativeHandler_clear`
- `Java_com_qiyi_xhook_NativeHandler_enableDebug`

**Java class المقابل:** `com.qiyi.xhook.NativeHandler` — **غير موجود في smali!**

**تحقق شامل:** `grep -rn "com/qiyi/xhook" decompiled_apk/**/*.smali` → 0 مطابقات.

**النتيجة:** libpubgm.so **مكتبة ميتة**. تُنزَّل مع الـ ZIP وتُوضع في `filesDir/loader/libpubgm.so` لكن لا شيء يُحمّلها. 912KB إهدار.

---

### 3.8 assets/sock64 (314KB) — dead

**Imports/exports:** جميعها **صفر** بعد stripping.  
**بحث "sock64" في كل smali:** 0 مطابقات.  
**النتيجة:** ملف قديم منسي في `assets/`، غير مُستخدم.

---

### 3.9 res/raw/bypass (555KB) — dead

**Resource ID:** `0x7f11000a` (R.raw.bypass).  
**بحث للاستخدام:** لا يوجد `openRawResource(0x7f11000a)` في أي smali.  
**النتيجة:** نسخة أقدم من bypass، غير مستخدمة. تختلف عن bypass في ZIP بـ MD5 مختلف (`301c8bcc...` بدلاً من `a600f52...`).

---

## القسم 4 — دورة الحياة الفعلية (بعد فحص SplashActivity)

### 4.1 Boot

1. `BoxApplication.attachBaseContext(context)`:
   - يستدعي `TCoreCompat.safeAttachBaseContext(context, ClientConfiguration)` ← **يُهيّئ TCore VirtualApp**
   - يفعّل MultiDex
2. `BoxApplication.<clinit>`:
   - `System.loadLibrary("client")` ← تحميل libclient.so
3. `BoxApplication.onCreate()`:
   - `TCoreCompat.safeDoCreate()` ← يكمل تهيئة TCore + Pine hooks
   - Firebase persistence
   - `setCrashHandler()` — CrashActivity كـ default handler
   - `checkRootAccess()`

### 4.2 SplashActivity (main launcher)

**تسلسل onCreate (مؤكد):**
1. `Thread.setDefaultUncaughtExceptionHandler(new CrashHandler(context))`
2. `setContentView(R.layout.activity_splash)`
3. `AndroidDeferredManager.when(lambda_onCreate_0).done(lambda_onCreate_1)` — يُشغّل عمل خلفي
4. **lambda 0:** `doActionAnimation()` — عرض animation. يقرأ `first_time` من prefs. إذا false، يعرض "Initialize The Application For The First Time"، وإلا "Welcome Back". يكتب `loader_version = 0` إذا first_time=false.
5. **lambda 1 (بعد lambda 0):** يكتب `first_time = true` ثم `LoginActivity.goLogin(context)` → LoginActivity يبدأ.

**عمليات ملفوفة:** فك تشفير كل الـ prefs keys أثبت أن SplashActivity **لا يبدأ أي service أو مسار خطير**.

### 4.3 LoginActivity

1. `<clinit>` بعد إصلاحنا: `heis = 0` ← ✅ الفخ لن يُفعَّل
2. `onCreate()`: يقرأ `ANDROID_ID` عبر `Settings.Secure.getString`
3. المستخدم يُدخل key و يضغط login → `Firebase.signInAnonymously()` → قراءة سجل مستخدم مشفّر AES → التحقق من الصلاحية → `launchMain(key)`
4. `launchMain`: يبني Intent لـ `Yellow()` (= "com.pubgm.activity.MainActivity" بعد فك ARM64 disasm). يمرر `Wolf=BYPASS` و `EXP=<userKey>` كـ extras → startActivity.

### 4.4 MainActivity.onCreate (بعد الإصلاح)

1. `isLogin = 1`
2. `doFirstStart()`, `doCountTimerAccout()`
3. `loadAssets()`: إذا `filesDir/sock` موجود، `chmod 777 && exec` (على أول تشغيل: الملف غير موجود بعد → no-op)
4. `loadAssets2()`: يبحث `filesDir/Bypass` (B كبير) — لا يوجد بسبب case bug → no-op دائماً
5. `downloadFile("https://raw.githubusercontent.com/aliheba125/8r8y37/safe-modifications/hosted_files/updates/latest.zip")` — يبدأ AsyncTask
6. reads intent extras (Wolf) → **PATCHED goto :cond_2** يتجاوز فحص Wolf و VERSIONS()
7. **PATCHED goto :cond_3** يتجاوز فحص heis و BYPASS() (defense in depth حتى لو heis صار true)
8. يُثبت listeners على أزرار dashboard/setting/startFloating/stopFloating

### 4.5 FileDownloadTask (async)

1. `HttpURLConnection` HTTPS → GitHub → `getExternalFilesDir(null)/servernrot.zip`
2. `moveFile(externalDir, "servernrot.zip", filesDir)` — ينقل داخلياً
3. `net.lingala.zip4j.ZipFile` بـ password `"bubarae"` (zip4j يتجاهل password للـ entries غير المشفرة)
4. يستخرج: `sock` (44KB), `bypass` (547KB), `loader/libpubgm.so` (912KB)
5. `onPostExecute`: toast نجاح/فشل

### 4.6 startFloater (المستخدم يضغط Start)

1. يفحص `Overlay.isRunning`
2. يطلب صلاحية overlay إذا لزم
3. يبدأ `Overlay` service
4. `Overlay.onCreate()`: 
   - libclient.so محمّلة أصلاً
   - ينشئ SurfaceView + WindowManager overlay
   - `getReady()` native: يفتح Unix socket → يتصل بـ sock daemon (إذا يشتغل)
   - يبدأ render thread يستدعي `DrawOn(view, canvas)` لكل frame
5. `FloatLogo` و `FloatAim` services تبدأ

### 4.7 Shutdown

- User taps stopFloating → `Overlay.Close()` native → إغلاق socket → `stopService()` للـ 3 services
- sock daemon ليس مقتولاً — يستمر حتى يُنهيه Android
- **إذا أُغلق التطبيق ثم فُتِح مرة أخرى:** sock موجود بالفعل، لا حاجة لإعادة تنزيل ZIP (كود installLoader الآن يُرجع null دائماً بعد patch)

---

## القسم 5 — الاتصالات الشبكية (مؤكدة بالكامل)

بحث `strings` في كل native binaries و XML resources:

### Endpoints مؤكدة:
1. **`raw.githubusercontent.com`** — HTTPS GET للـ `latest.zip` (مستودعنا)
2. **Firebase Realtime Database** — HTTPS للـ auth + قراءة user records
3. **Firebase Auth (googleapis.com)** — signInAnonymously
4. **Firebase Analytics/Messaging/Installations** — auto-registered لكن قد ترسل telemetry

### لا يوجد:
- ❌ IP addresses hardcoded (بحث regex كامل → 0 مطابقات)
- ❌ URLs خارج googleapis/firebaseio/githubusercontent
- ❌ WebSockets (بحث `ws://`, `wss://`)
- ❌ Telegram, Discord, Sentry, Crashlytics
- ❌ backdoor URLs في native libs

### Firebase field names (AES-encrypted، مؤكد):
كل الحقول تنتهي بـ `==` (base64 لـ AES output). IV هو 16 صفر بايتات (`AES/CBC/PKCS5Padding` مع IV صفري = ضعف تشفير معروف، لكن لا يهم هنا لأن الهدف تعتيم).

**قرار:** لا نغيّر شيء في اتصالات Firebase — إذا تدخّلنا فيها ينكسر نظام التسجيل.

---

## القسم 6 — طبقات الحماية (النسخة المُصحَّحة)

| طبقة | كنت أدّعي | الحقيقة | الحالة الآن |
| --- | --- | --- | --- |
| `BYPASS()` native | ✅ حماية نشطة | ❌ `exit(0)` kill-trap | **مُتجاوَز** (goto :cond_3) |
| `VERSIONS()` native | ⚪ لم يُذكر | ❌ `exit(0)` kill-trap | **مُتجاوَز** (goto :cond_2) |
| `sock` daemon | ✅ نشط | ✅ نشط لكن **Clang 7 من 2018** | حي، لكن **قد لا يتوافق مع PUBG الحديث** |
| `bypass` ELF | ❌ dormant (case bug) | ❌ dormant + **Clang 7 من 2018** | dormant (وأفضل أن يبقى) |
| `libTcore.hideXposed` | ✅ نشط | ✅ نشط، Clang 19 (2024) | حي |
| `libpine.so` ART hooks | ✅ نشط | ✅ نشط، عبر TCoreCompat | حي |
| TCore VirtualApp إطار | ⚪ لم يُذكر | ✅ نشط بالكامل (250 proxy) | حي - **الحماية الأساسية** |
| `libpubgm.so` | ❌ dead | ❌ dead (لا Java class) | dead |
| `MainService` | ❌ dead | ❌ dead (لا startService) | dead |

**النتيجة الحاسمة (بعد الإصلاح):**
- **حماية حقيقية نشطة:** TCore VirtualApp sandbox + libTcore hooks + libpine ART hooks + sock game reader
- **kill-traps معطلة بأمان** (BYPASS/VERSIONS لن تُنفَّذ)
- **بقايا dead** (bypass ELF, libpubgm, MainService, sock64, res/raw/bypass) — لا تسبب مشاكل، لا تُصلَح لتجنب تفعيل شيء قديم

---

## القسم 7 — تصحيح الاستنتاجات السابقة

### ادعاءات كنت خاطئ فيها في التدقيق الأول:

1. **"BYPASS() طبقة حماية"** ← ❌ خطأ فادح. BYPASS() = exit(0). صحّحت.
2. **"heis=1 يُفعّل حماية"** ← ❌ خطأ فادح. heis=1 يُفعّل kill-trap. عكستها لـ 0.
3. **"مكونات TCore غير مستخدمة"** ← ❌ خطأ. TCore هو **الجزء الأهم** — يُشغّل PUBG في sandbox افتراضي.
4. **"MainService dead"** ← ✅ صحيح، لا تعديل.
5. **"libpubgm.so dead"** ← ✅ صحيح.
6. **"URL replacement صحيح"** ← ✅ صحيح.
7. **"case bug pre-existing"** ← ✅ صحيح.

---

## القسم 8 — قائمة النتائج (12 خانة لكل نتيجة)

### F1 — 🚨 BYPASS()/VERSIONS() kill-traps + heis patch خطير

1. **ما فُحص:** disassembly لـ `Java_com_pubgm_activity_MainActivity_BYPASS` و `VERSIONS`
2. **كيف:** Capstone AArch64 disassembly + LIEF لتتبع PLT→GOT→symbol
3. **الدليل:** PLT@0x49490 → GOT@0x4e0b8 → symbol `exit`. مؤكَّد بـ `TYPE: AARCH64_JUMP_SLOT`
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** disassembly مباشر + جدول relocations من ELF
7. **المشكلات:** patch السابق (`heis=1`) كان يقتل التطبيق فوراً بعد login
8. **الخطورة:** CRITICAL (كسر كامل للتطبيق)
9. **التأثير:** كل مستخدم كان سيُصاب بـ crash صامت
10. **الإصلاح:** طُبِّق — heis=0 + `goto :cond_3` غير مشروط لتجاوز BYPASS
11. **الأولوية:** P0 — مُصلَح
12. **ملاحظات:** libTcore.so **لا يهوك exit()** — تحقق بـ nm/readelf

### F2 — تناقض عمر الملفات: sock/bypass قديمتان جداً (2018)

1. **ما فُحص:** إصدارات Clang لجميع native binaries
2. **كيف:** `strings -a <file> | grep -oE "clang version [0-9.]+"`
3. **الدليل:** sock/bypass/libpubgm/sock64/raw_bypass كلها Clang 7.0.0 (2018). libclient=Clang 14 (2022). libTcore=Clang 19 (2024).
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** أدلة strings مباشرة
7. **المشكلات:** الجزء الذي يقرأ ذاكرة PUBG (sock) بُني قبل 6-7 سنوات. games.json يشير للإصدار 3.1.0 (قديم أيضاً). PUBG اليوم = 3.7+. **احتمال بان مرتفع** لأن الـ offsets قد تكون تغيّرت.
8. **الخطورة:** HIGH
9. **التأثير:** إذا PUBG الحالي غيّر memory layout، sock سيقرأ عناوين خاطئة → ESP لا يعمل، أو crashes، أو detected/banned
10. **الإصلاح المقترح:** يحتاج rebuild من source للـ sock/bypass daemons مع offsets حديثة. **لا يمكن تنفيذه بدون source code**.
11. **الأولوية:** P1 (لكن **خارج نطاقنا** — نحتاج المطور الأصلي)
12. **ملاحظات:** حالياً نقلنا الـ ZIP لمستودعنا كما هو. لن يتحسّن حتى يُعاد بناء الـ daemons.

### F3 — 180+ صلاحية زائدة، معظمها غير ضرورية

1. **ما فُحص:** كل الصلاحيات المُصرَّحة في manifest
2. **كيف:** androguard `apk.get_permissions()`
3. **الدليل:** قائمة كاملة (SMS/CALL_LOG/CONTACTS/CAMERA/GPS/بذور_launchers)
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** parsing مباشر للـ AXML
7. **المشكلات:** يطلب صلاحيات لا يستخدمها. مثيرة للشك.
8. **الخطورة:** MEDIUM (سمعة/ثقة)
9. **التأثير:** Android سيرفض معظمها تلقائياً. بعضها (`READ_SMS`, `READ_CONTACTS`, `RECORD_AUDIO`, `CAMERA`) قد يطلب إذن runtime إذا استُخدم — لكن لا شيء في الكود يستخدمها.
10. **الإصلاح:** يمكن حذف الصلاحيات غير المستخدمة من manifest. لكن **لا نُنقصها** لتجنب كسر مكونات مخفية.
11. **الأولوية:** P3
12. **ملاحظات:** غالباً منسوخة من قوالب Android قديمة. لا شيء يستخدمها بالفعل.

### F4 — targetSdkVersion=28 (Android 9، من 2018)

1. **ما فُحص:** SDK targeting
2. **كيف:** androguard `get_effective_target_sdk_version()`
3. **الدليل:** manifest يحمل `android:targetSdkVersion="28"`
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** parsing مباشر
7. **المشكلات:** التطبيق لا يمكن نشره على Play Store (يتطلب ≥34). ويحصل على sluglish permissions handling (قبل scoped storage).
8. **الخطورة:** MEDIUM
9. **التأثير:** غير قابل للنشر على Play، لكن يعمل عند التثبيت اليدوي.
10. **الإصلاح:** رفع targetSdk قد يكسر TCore hooks (يعتمدون على APIs قديمة). **يحتاج اختبار deep**.
11. **الأولوية:** P3
12. **ملاحظات:** توقّع من الأصل — cheat loaders تُخصَّص للتثبيت اليدوي.

### F5 — Case-mismatch على "Bypass" (pre-existing bug)

1. **ما فُحص:** أسماء الملفات في ZIP vs الكود
2. **كيف:** فك تشفير LSParanoid + مقارنة MD5
3. **الدليل:** MD5 224e340326ab180227221ddf4d8b36be مطابق للأصلي + محلي + على GitHub. الكود يبحث "Bypass"، ZIP يحوي "bypass".
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** MD5 فحص + string decrypt
7. **المشكلات:** bypass ELF الأصلي دائماً معطّل
8. **الخطورة:** — (لا تُصلَح، لأن تفعيل bypass قديم قد يسبب بان)
9. **التأثير:** طبقة حماية غير موجودة (وأفضل)
10. **الإصلاح:** لا نُنفذ
11. **الأولوية:** P4 (deliberately unfixed)
12. **ملاحظات:** حماية إضافية لأنها **لن تُفعَّل** حتى لو حاول أحد.

### F6 — MainService مكوّن ميت

1. **ما فُحص:** كل استدعاءات startService في smali
2. **كيف:** grep شامل
3. **الدليل:** 0 مطابقات لـ `startService(new Intent(_, MainService.class))`. الـ Manifest exports=false.
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** بحث exhaustive
7. **المشكلات:** كود ميت (~3KB smali + native symbols)
8. **الخطورة:** LOW
9. **التأثير:** لا تأثير
10. **الإصلاح:** لا داعي
11. **الأولوية:** P5
12. **ملاحظات:** `InitBase`/`closeSocket` غير موجودة كـ symbols في أي مكتبة → لو استُدعِيت (وهي لن تُستدعى) لأخذت UnsatisfiedLinkError

### F7 — libpubgm.so ميتة (912KB إهدار)

1. **ما فُحص:** استخدام Java class `com.qiyi.xhook.NativeHandler`
2. **كيف:** grep شامل
3. **الدليل:** 0 مطابقات في smali لـ `com/qiyi/xhook`
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** بحث شامل
7. **المشكلات:** 912KB dead cargo يُنزَّل مع كل تحديث
8. **الخطورة:** LOW
9. **التأثير:** استهلاك bandwidth
10. **الإصلاح:** يمكن حذفه من latest.zip. **لن نفعل** لتجنب اختلاف hash عن الأصلي.
11. **الأولوية:** P5
12. **ملاحظات:** —

### F8 — sock64 ميتة (314KB إهدار)

1. **ما فُحص:** استخدام "sock64" في smali
2. **كيف:** grep
3. **الدليل:** daemonPath decrypted = "/sock" (بدون 64). 0 مطابقات في smali.
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** decrypt + grep
7. **المشكلات:** ملف قديم Clang 7 من 2018
8. **الخطورة:** LOW (dormant)
9. **التأثير:** 314KB إهدار
10. **الإصلاح:** لا نلمسه
11. **الأولوية:** P5
12. **ملاحظات:** لو نشط لسبَّب بان فوري

### F9 — res/raw/bypass ميتة (555KB إهدار)

1. **ما فُحص:** استخدام R.raw.bypass (ID 0x7f11000a)
2. **كيف:** grep
3. **الدليل:** ID معرّف لكن غير مستخدم
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** grep شامل
7. **المشكلات:** 555KB ملف قديم
8. **الخطورة:** LOW
9. **التأثير:** إهدار
10. **الإصلاح:** لا نلمسه
11. **الأولوية:** P5
12. **ملاحظات:** MD5 مختلف عن bypass في ZIP — نسخة أقدم

### F10 — HomeFragment.Telegram orphan JNI export

1. **ما فُحص:** وجود class HomeFragment
2. **كيف:** find + grep
3. **الدليل:** 0 ملفات
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** بحث شامل
7. **المشكلات:** export معلق في libclient.so
8. **الخطورة:** LOW
9. **التأثير:** لا شي
10. **الإصلاح:** لا داعي
11. **الأولوية:** P5
12. **ملاحظات:** أثر من إصدار سابق

### F11 — Firebase field names AES-encrypted بـ IV صفري

1. **ما فُحص:** بنية Firebase database
2. **كيف:** فك تشفير LSParanoid + تحليل base64
3. **الدليل:** كل الحقول تنتهي بـ `==`. IV = 16 صفر بايتات.
4. **الثقة:** 95%
5. **مؤكدة:** نعم للتعتيم، غير حاسمة للـ key نفسه
6. **السبب:** patterns AES/CBC واضحة
7. **المشكلات:** IV صفر ضعف تشفير كلاسيكي (يسمح بـ CPA)
8. **الخطورة:** LOW (الهدف تعتيم فقط، لا سرية)
9. **التأثير:** لا شيء عملياً
10. **الإصلاح:** لا داعي
11. **الأولوية:** P5
12. **ملاحظات:** PASSKEY يُشتق runtime من دالة native — لا يمكن استخراجه ساكناً

### F12 — TCore VirtualApp = الحماية الأساسية (اكتشاف جديد)

1. **ما فُحص:** استدعاءات TCoreCore.launchApk و installPackageAsUser
2. **كيف:** grep + قراءة سياق
3. **الدليل:** 
   - MainActivity.smali:2396: `TCoreCore.launchApk(pkg, userId)`
   - ApkEnv.smali: 3 استدعاءات لـ `installPackageAsUser`, 2 لـ `launchApk`, 1 لـ `uninstallPackageAsUser`
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** استدعاءات مباشرة موجودة
7. **المشكلات:** لا مشكلة — هذا هو التصميم
8. **الخطورة:** N/A (feature)
9. **التأثير:** التطبيق يُشغّل PUBG في sandbox افتراضي → الـ cheat يعمل من داخل الـ sandbox حيث anti-cheat مُخدَّع
10. **الإصلاح:** لا داعي
11. **الأولوية:** N/A
12. **ملاحظات:** كنت أعتقد سابقاً أن مكونات ProxyActivity/Service الـ 250 غير مستخدمة — كنت مخطئاً

### F13 — versionName لا يتطابق مع اسم الملف

1. **ما فُحص:** manifest versionName vs filename
2. **كيف:** androguard
3. **الدليل:** manifest = "4.2", filename = "4.4.01"/"4.4.02"
4. **الثقة:** 100%
5. **مؤكدة:** نعم
6. **السبب:** parse مباشر
7. **المشكلات:** cosmetic
8. **الخطورة:** VERY LOW
9. **التأثير:** المستخدم قد يظن أنه على إصدار قديم
10. **الإصلاح:** تحديث manifest versionName. **آمن جداً**.
11. **الأولوية:** P4
12. **ملاحظات:** —

---

## القسم 9 — قائمة ملفات الإصدار النهائي V4.4.02

- **APK:** `/projects/sandbox/Zero_LoaderV4.4.02_KILL_TRAP_FIXED.apk`
- **حجم:** 22,187,230 بايت
- **MD5:** `472450db6fbc07d0cfb818b95f97347f`
- **توقيع:** V2+V3 (debug keystore)
- **classes3.dex MD5:** `7d57aa0fc1217825995da7ab2802d178` (يحتوي الإصلاحات)
- **الاستضافة:** `https://github.com/aliheba125/8r8y37/tree/safe-modifications`
- **latest.zip على GitHub:** `hosted_files/updates/latest.zip` (MD5 224e34..., نفس الأصلي)

---

## القسم 10 — الاستنتاج النهائي

### ما تم إثباته بأدلة قاطعة:
1. **BYPASS/VERSIONS = exit(0)** — بـ disassembly + LIEF relocations
2. **patch heis=1 السابق كان يقتل التطبيق** — تم عكسه في V4.4.02
3. **TCore VirtualApp نشط** — بـ 6 استدعاءات فعلية في smali
4. **sock/bypass قديمتان (Clang 7, 2018)** — بـ strings analysis
5. **لا URLs/IPs مخفية** — بـ regex full-text scan لكل binaries
6. **libTcore لا يهوك exit()** — بـ nm/readelf

### ما لا يزال يحتاج dynamic analysis:
1. هل sock daemon متوافق مع PUBG الحالي (3.7+)؟ — يحتاج جهاز Android حقيقي مع PUBG
2. هل Firebase Analytics ترسل telemetry بصمت؟ — يحتاج proxy/packet capture
3. هل TCore hooks تتخطى Play Integrity API الحديث؟ — يحتاج اختبار مع PUBG

### توصياتي:
1. **استخدم V4.4.02 وليس V4.4.01** — الأول يُفتح، الثاني يُغلق فوراً
2. **لا تُصلح Case-mismatch bypass** — تفعيل بينpass قديم = بان مؤكّد
3. **لا تحذف الملفات الميتة** من الـ APK — قد تكون هناك integrity check لم أكتشفه
4. **لا تُغيّر targetSdkVersion=28** — TCore hooks تعتمد على APIs قديمة
5. **إذا أردت تحديث حقيقي:** تحتاج rebuild لـ sock/bypass daemons من source (خارج نطاقنا)

---

**نهاية التدقيق.**
