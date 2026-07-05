# تقرير الحماية من الباند وتجاوز Anti-Cheat (فحص معمق مُثبت بالأدلة)

**الملف:** `Zero_LoaderV4.4.02_KILL_TRAP_FIXED.apk`
**تاريخ:** 2026-07-05 | **النموذج:** Claude Opus 4.8
**السكربت:** `deep_analysis/12_anticheat_analysis.py` + بحث smali شامل

> هذا التقرير يجيب سؤالك تحديداً: **هل تأكدنا من حماية الباند؟ وهل تجاوز Anti-Cheat يعمل؟**
> الجواب المختصر المُثبت: **الحماية القوية معطّلة/ميتة. الموجود فعلياً حماية أساسية جزئية فقط.**

## مفتاح الثقة
- **[مؤكد-كود]** = مُثبت ببحث/تتبع smali شامل (صفر/عدد استدعاءات)
- **[مؤكد-تفكيك]** = مُثبت بتفكيك ARM64
- **[يحتاج dynamic]** = يحتاج تشغيل حي على جهاز مع PUBG + anti-cheat

---

## 1. ما هو **نشط فعلاً** من الحماية [مؤكد-كود]

### 1.1 إخفاء حزم الروت/Xposed عبر VirtualApp ✅ (نشط)
`ClientConfiguration.isHideRoot()` و`isHideXposed()` كلاهما يُرجع **true** (ثابت `const/4 v0, 0x1`)، ويقرأهما إطار TCore في:
- `TCoreCore.smali:2024, 2036`
- `AppSystemEnv.smali:244, 267`
- `IOCore.smali:688`

**الآلية:** عندما تستعلم PUBG (داخل sandbox) عن الحزم المثبّتة عبر `PackageManager`، يعترض `IPackageManagerProxy` ويُخفي هذه الحزم:

**حزم الروت المخفيّة (SuPackages):**
```
com.topjohnwu.magisk          (Magisk)
eu.chainfire.supersu          (SuperSU)
com.koushikdutta.superuser
com.thirdparty.superuser
com.noshufou.android.su
com.noshufou.android.su.elite
com.yellowes.su
```
**حزم Xposed المخفيّة (XposedPackages):**
```
de.robv.android.xposed.installer
```

**التقييم [مؤكد-كود]:** هذه الحماية **تهزم فقط الفحص الأساسي** الذي يسرد الحزم المثبتة بحثاً عن Magisk/Xposed. **لا تهزم** الفحص native، ولا مسح الذاكرة، ولا تفتيش `/proc`.

### 1.2 عزل VirtualApp (sandbox) ✅ (نشط)
PUBG تُشغَّل داخل حاوية افتراضية (`ApkEnv.launchApk` → `TCoreCore.launchApk`، مؤكد بـ `MainActivity.smali:2396`). هذا يوفّر عزلاً هيكلياً، لكنه **آلية تشغيل** أكثر من كونه إخفاءً من anti-cheat.

### 1.3 إعادة توجيه المسارات (I/O redirect) ✅ (نشط)
`NativeCore.enableIO()` + `addIORule()` مُستدعاة من `IOCore.enableRedirect` (من `BActivityThread:1889` — عملية الضيف). تعيد توجيه مسارات ملفات الضيف. غرضها **تشغيل** الـ sandbox، لا الإخفاء.

---

## 2. ما هو **ميت / معطّل** من الحماية (لا يحميك) [مؤكد-كود]

| آلية الحماية | الحالة | الدليل |
| --- | --- | --- |
| `NativeCore.hideXposed()` (إخفاء Xposed من `/proc/self/maps` على مستوى native) | ❌ **ميتة** | **صفر استدعاءات خارجية** في كل الكود. مُعرّفة ومُسجّلة لكن لا تُستدعى أبداً |
| `bypass` ELF (تحييد Tencent anti-cheat: libanogs/libITOP/libCrashSight) | ❌ **معطّل** | خلل حالة الاسم `Bypass` vs `bypass` (من الأصل). لا يُشغّل أبداً |
| `NativeCore.disableHiddenApi()` (تجاوز قيود Hidden API) | ❌ ميتة | صفر استدعاءات (موجودة في الـ .so لكن غير مُستدعاة) |
| `NativeCore.init_seccomp()` | ❌ ميتة | صفر استدعاءات |
| `NativeCore.init(I)` | ❌ ميتة | صفر استدعاءات |
| كشف المحاكي | ❌ غير موجود | libclient يقرأ `ro.arch` فقط (معمارية المعالج)، لا `qemu/goldfish/ranchu` |
| كشف anti-debug / ptrace / TracerPid | ❌ غير موجود | لا سلاسل `TracerPid`/`ptrace`/`/proc/self/status` في libclient أو sock |
| كشف/إخفاء Frida | ❌ غير موجود | لا مراجع frida في أي مكتبة |

**نقطة حرجة [مؤكد-تفكيك]:** دالة `hideXposed()` **تعمل فعلاً** لو استُدعِيت (تنادي `VMClassLoaderHook::hideXposed`)، لكن **لا شيء يستدعيها** — إذاً إخفاء Xposed على مستوى native **غير مُفعّل**، فقط إخفاء اسم الحزمة (القسم 1.1).

---

## 3. نقطة الانكشاف الرئيسية (خطر الباند) [مؤكد-تفكيك]

**`sock` daemon يقرأ ويكتب في `/proc/<pubg_pid>/mem`** (سلسلة `"successfully wrote %d bytes to address 0x%lx"`).

- التلاعب بذاكرة عملية اللعبة من الخارج عبر `/proc/pid/mem` هو **أكثر ما تكشفه أنظمة anti-cheat الحديثة** (Tencent ACE/SafeGuard).
- **لا شيء في التطبيق يُخفي هذا التلاعب.**
- طبقة `bypass` التي **كان** يُفترض أن تحيّد `libanogs` (نواة anti-cheat لـ Tencent) **معطّلة**.

---

## 4. الإجابة المباشرة على سؤالك

### هل تأكدنا من حماية الباند؟
**نعم، فحصتها بالكامل الآن [مؤكد-كود].** النتيجة:
- **نشط:** إخفاء أسماء حزم الروت/Xposed من استعلامات PackageManager للعبة (7 حزم روت + Xposed installer). يهزم الفحص الأساسي فقط.
- **ميت/معطّل:** كل الحماية القوية (hideXposed native، bypass ELF، disableHiddenApi، seccomp، كشف المحاكي، anti-debug).

### هل تجاوز Anti-Cheat يعمل؟
**لا — غير مُفعّل [مؤكد-كود].** طبقة `bypass` المخصّصة لتحييد anti-cheat معطّلة (خلل حالة من الأصل)، و`hideXposed` على مستوى native لا تُستدعى. **اللاعب مكشوف للكشف native من anti-cheat على تلاعب `/proc/mem`.**

### هل يؤدي هذا لباند فعلي؟
**[يحتاج dynamic]** — لا يمكن الجزم ساكناً. يحتاج تشغيلاً حياً على جهاز مع PUBG + anti-cheat الحاليين. لكن **الأدلة الساكنة تشير بقوة** إلى أن الحماية ضعيفة والانكشاف عالٍ، خصوصاً مع:
1. `sock`/`bypass` مبنيان بـ Clang 7 من 2018 (offsets قد لا تطابق PUBG 3.7+).
2. طبقة تحييد anti-cheat معطّلة.
3. لا إخفاء native للتلاعب بالذاكرة.

---

## 5. تصحيح استنتاج سابق
في تقارير سابقة أدرجت `hideXposed` و`libTcore hooks` ضمن "طبقات حماية نشطة". **هذا غير دقيق:** `hideXposed()` على مستوى native **ميتة (صفر استدعاءات)**. النشط فقط هو إخفاء أسماء الحزم عبر VirtualApp (طبقة أضعف بكثير). أصحّح ذلك هنا صراحةً.

---

## 6. الخلاصة (مُثبتة)
| الطبقة | الحالة الحقيقية |
| --- | --- |
| إخفاء حزم روت/Xposed (PackageManager) | ✅ نشط — أساسي فقط |
| عزل VirtualApp sandbox | ✅ نشط — آلية تشغيل |
| I/O redirect | ✅ نشط — لتشغيل الضيف |
| hideXposed native | ❌ ميت (0 استدعاء) |
| bypass ELF (تحييد Tencent anti-cheat) | ❌ معطّل (خلل حالة) |
| disableHiddenApi / seccomp / init | ❌ ميت (0 استدعاء) |
| كشف محاكي / anti-debug / frida | ❌ غير موجود |
| إخفاء تلاعب `/proc/mem` | ❌ غير موجود — نقطة الانكشاف |

**الحكم:** الحماية من الباند **ضعيفة**؛ تجاوز anti-cheat **غير مُفعّل**. ما يحميك حالياً هو فقط إخفاء أسماء الحزم + عزل sandbox، وكلاهما لا يهزم الكشف native الحديث.



---

## 7. تحليل الوضعين: روت / بدون روت [مؤكد-كود]

التطبيق يعمل بوضعين، والتحقق والحماية يختلفان جوهرياً. **وضع بدون روت هو الأهم** (كما أشرت).

### 7.1 وضع بدون روت (VirtualApp / sandbox) — الأهم
**آلية التشغيل [مؤكد-كود]:**
- PUBG تُثبَّت **داخل** حاوية TCore الافتراضية: `ApkEnv.installByPackage` → `TCoreCore.installPackageAsUser(pkg, userId)` (`ApkEnv.smali:441`).
- تعمل PUBG بنفس UID التطبيق اللودر (داخل الـ sandbox).
- `sock` daemon يُشغَّل عبر `FloatLogo.ExecuteElf()` = `Runtime.exec(path, null, dir)` **بدون su** (`FloatLogo.smali` ~L376). لأن PUBG بنفس UID، يستطيع `sock` قراءة/كتابة `/proc/<pubg_pid>/mem` **بدون روت** — هذه هي فكرة الوضع بالكامل.
- ملاحظة [مؤكد-كود]: FloatLogo ينفّذ `ExecuteElf` (بدون روت) **أولاً**، ثم يجرّب `su -c chmod 777` و`su -c` — أوامر su **تفشل بصمت** (IOException مُبتلع) على الأجهزة بدون روت.

**الحماية النشطة في وضع بدون روت [مؤكد-كود]:**
- hooks إطار TCore تعمل **داخل عملية PUBG الضيف** (نفس العملية) → `IPackageManagerProxy` يعترض استعلامات PUBG ويُخفي حزم الروت (Magisk/SuperSU) وXposed installer. **يهزم الفحص الأساسي القائم على سرد الحزم.**

**نقاط الانكشاف في وضع بدون روت [مؤكد-كود للآلية / يحتاج dynamic للكشف الفعلي]:**
1. **كشف التشغيل داخل VirtualApp:** anti-cheat الحديث (Tencent ACE) يفحص إن كان مسار بيانات التطبيق افتراضياً، ويفحص العملية الأب، ووجود مكتبات غريبة. تشغيل PUBG داخل sandbox **بحد ذاته إشارة كشف قوية** لأنظمة anti-cheat غير-الروت. [يحتاج dynamic لتأكيد الكشف على النسخة الحالية]
2. **libclient.so محمّلة بنفس العملية:** `/proc/self/maps` للعبة سيُظهر `libclient.so` و`sock` — قابل للكشف من anti-cheat native.
3. **تحييد libanogs معطّل:** طبقة `bypass` (التي تحيّد نواة Tencent anti-cheat) **معطّلة** → المسح native داخل PUBG يعمل بحرية.
4. **إخفاء Xposed على مستوى native (`hideXposed`) ميت** → فقط إخفاء اسم الحزمة، لا إخفاء الآثار في `/proc/self/maps`.

### 7.2 وضع الروت
**آلية التشغيل [مؤكد-كود]:**
- يستخدم `su -c chmod 777 <sock>` و`su -c <sock>` (`FloatLogo.smali:423,452` و`ApkEnv.smali:151,184`)، و`Shell.su()` (`BoxApplication.smali:222`).
- يسمح بتشغيل `sock` ضد PUBG المثبّتة على النظام مباشرة (UID مختلف) عبر صلاحيات الروت.
- `bypass` fn3 (المُعطّل) يستخدم `su` لإشعار دعائي.

**الانكشاف في وضع الروت:** وجود الروت نفسه إشارة باند إن لم يُخفَ. إخفاء الروت هنا يعتمد على إخفاء الحزم فقط (نفس القيد)، مع أن الروت الحقيقي (Magisk) قد يُخفي نفسه على مستوى النظام خارج التطبيق.

### 7.3 المقارنة
| الجانب | بدون روت (sandbox) | روت |
| --- | --- | --- |
| تشغيل sock | `ExecuteElf` (بدون su) | `su -c` |
| وصول /proc/mem | نفس UID (sandbox) | روت (أي UID) |
| PUBG أين تعمل | داخل حاوية TCore | على النظام أو الحاوية |
| إخفاء حزم روت/Xposed | ✅ نشط (in-process hooks) | ✅ نشط |
| تحييد anti-cheat native (bypass) | ❌ معطّل | ❌ معطّل |
| كشف الافتراضية/الحاوية | 🔴 خطر عالٍ [يحتاج dynamic] | أقل (على النظام) |
| كشف الروت | لا يوجد روت | 🔴 وجود su/Magisk |

---

## 8. الخلاصة النهائية بعد تحليل الوضعين

**وضع بدون روت (الأهم):**
- الحماية النشطة الوحيدة = إخفاء أسماء حزم الروت/Xposed عبر hooks داخل عملية PUBG. **يهزم الفحص الأساسي فقط.**
- الحماية القوية (تحييد libanogs عبر bypass، إخفاء native عبر hideXposed) **معطّلة/ميتة**.
- خطر إضافي: تشغيل PUBG داخل VirtualApp قابل للكشف من anti-cheat الحديث + libclient ظاهرة في `/proc/self/maps` للعبة.
- **الحكم [مؤكد-كود للآلية]:** حماية الباند في وضع بدون روت **ضعيفة** — تعتمد على إخفاء الحزم فقط. تجاوز anti-cheat الفعلي **غير مُفعّل**.

**التأكيد النهائي على كشف الباند الفعلي = [يحتاج dynamic]:** يتطلب تشغيلاً حياً على جهاز مع PUBG الحالية + anti-cheat لقياس هل يُكتشف فعلاً. الأدلة الساكنة تشير بقوة لانكشاف عالٍ.



---

## 9. هل bypass تجاوز حقيقي أم دعاية/كذبة؟ (تفكيك حاسم) [مؤكد-تفكيك]

فككت آلية bypass بالكامل. الحكم: **ليس كذبة، لكنه معطّل + قديم + منتج مدفوع بدعاية مكثّفة.**

### 9.1 آلية حقيقية موجودة [مؤكد-تفكيك]
- **يجمع عناوين أساس مكتبات anti-cheat** من `/proc/<pid>/maps` عبر دالة `getModuleBase` (0xe7f8: fopen maps → fgets → strstr(libname) → strtok "-" → strtoul base). القائمة المستهدفة:
  `libUE4.so`, `libanogs.so`, `libCrashSight.so`, `libanort.so`, `libTDataMaster.so`, `libTBlueData.so`, `libgcloud.so`, `libhdmpve.so`, `liblog.so`, `libdl.so`
- **بدائية تعديل ذاكرة حقيقية** (0xe990): تُحلّل سلسلة hex إلى بايتات → `pwrite64(/proc/pid/mem)` → `pread64` للتحقق من نجاح الكتابة.
- سلاسل الإثبات: `"successfully wrote %d bytes to address 0x%lx"`, `"Failed to write bytes to address 0x%lx"`, `"pwrite64 failed"`.

### 9.2 لكنه دعاية/تجاري بكثافة [مؤكد]
- سلسلة **`" TO BUY BYPASS : @ABU_FAHAD3 "`** → **منتج مدفوع** يُباع عبر تيليجرام.
- `"Bypass Active✓"` + `"Telegram : @ABU_FAHAD3"` تُطبع عند التشغيل.
- أمرا system() من أصل 3 دعاية بحتة (فتح تيليجرام + إشعار روت دعائي).

### 9.3 القيود الحاسمة [مؤكد]
- **لا يستخدم `mprotect`** (صفر استدعاءات) ولا `dlopen` → لا يعدّل كود المكتبات في مساحته، بل عبر `/proc/pid/mem` خارجياً فقط.
- **معطّل**: خلل حالة الاسم (`Bypass` مقابل `bypass`) → لا يُشغَّل أبداً في هذا البناء.
- **قديم**: Clang 7 (2018) → offsets/منطق لإصدار anti-cheat من 2018.
- **[غير مؤكد]**: لا توجد بايتات ترقيع ثابتة في `.rodata` → مصدر بيانات الترقيع (البايتات المكتوبة) غير موجود ساكناً في الملف (على الأرجح يأتي وقت التشغيل عبر socket). لذا **لا أستطيع إثبات الترقيعات الدقيقة التي يطبّقها**، فقط أنه يملك القدرة + يستهدف مكتبات anti-cheat محددة.

### 9.4 الحكم النهائي على bypass
**تجاوز حقيقي بدائي (memory patcher عبر /proc/mem يستهدف مكتبات Tencent anti-cheat بالاسم)، مُباع كمنتج مدفوع، لكنه معطّل في هذا البناء وعمره 6+ سنوات.** هل ترقيعاته تهزم anti-cheat الحالي = **[يحتاج dynamic] ومشكوك فيه بشدة** بسبب العمر. **ليس كذبة، لكنه ليس حماية فعّالة حالياً.**

---

## 10. الوضع العادي مقابل الوضع الوحشي (Brutal) — هل يفعّل وظائف خفية؟

### 10.1 التسمية الداخلية [مؤكد-كود]
- `statusafe` = **"Safe"** (0x7f120178)
- `statunsafe` = **"Brutal"** (0x7f120175)

التطبيق نفسه يصنّف الوضع الوحشي كـ **"غير آمن" (unsafe)** — أي أعلى خطورة باند.

### 10.2 صفحة Controls تفعّل وظائف backend حقيقية (ليست واجهة فقط) [مؤكد-كود]
زر aimbot في صفحة Controls له مستمع `FloatLogo$181` — عند التفعيل:
```
1. startService(FloatAim)            ← يبدأ خدمة مؤشر التصويب
2. SettingValue(0xb=11, bool)  native ← يكتب في محرك الذاكرة (تفعيل aimbot فهرس 11)
```
وميزات Controls الأخرى تستدعي دوال native تكتب في محرك الشيت:
- `FloatAim.AimbotFOV(bool)` native — تفعيل دائرة/زاوية التصويب
- `FloatLogo.AimBy(I)`, `Range(I)`, `Ranges(I)`, `Target(I)`, `WideView(I)`, `SettingValueI(II)` native — معاملات aimbot
- `aimknocked` switch = "Ignore Bots"

**SettingValue يُستدعى 14 مرة، SettingMemory مرة** في FloatLogo — هذه كلها كتابات فعلية لمحرك الذاكرة (libclient → sock → `/proc/mem` للعبة).

### 10.3 الحكم على الوضعين [مؤكد-كود]
**الوضع الوحشي (Brutal) ليس مجرد صفحة واجهة إضافية — بل يفعّل aimbot فعلياً** عبر دوال native (`SettingValue`/`SettingMemory`/`AimbotFOV`) تكتب في محرك الذاكرة الذي يعدّل ذاكرة اللعبة.
- **الوضع العادي (Safe):** ESP فقط (رؤية، عناصر، مركبات، skins) — قراءة ذاكرة غالباً.
- **الوضع الوحشي (Brutal/unsafe):** يضيف aimbot (تحكم بالتصويب) — **كتابة/تلاعب أعمق بذاكرة اللعبة = خطر باند أعلى**، ولهذا سمّاه المطوّر داخلياً "unsafe".

**تصحيح لملاحظتك:** الفرق ليس واجهة فقط — الوضع الوحشي **يفعّل وظائف backend حقيقية** (aimbot memory writes). هذا مُثبت من الكود، ليس استنتاجاً من الصور.
