# تحليل تدفق تسجيل دخول Facebook في PUBG 4.4.0 داخل Shadow/Zero Loader (VirtualApp)

> مبني على: مصدر Facebook Android SDK **الرسمي** tag `sdk-version-13.2.0` (نفس الكود المُصرَّف داخل PUBG — تم تأكيد الإصدار من السجل الحي `sdk=android-13.2.0`) + السجلّات التشغيلية (29487 و 3767) + AndroidManifest للّودر + توضيح المستخدم عن آلية الاستنساخ.

## البيئات الأربع
| # | البيئة | الحزمة الحقيقية | داخل VA؟ |
|---|--------|------------------|----------|
| A | اللودر (Host) | `com.pubgm` | — |
| B | نسخة PUBG المستنسخة (Guest) | `com.tencent.ig` (وهمية داخل VA، عملية `:pN`) | ✅ |
| C | PUBG الأصلية المثبتة على الجهاز | `com.tencent.ig` (حقيقية) | ❌ |
| D | Chrome | `com.android.chrome` | ❌ |

**النقطة الجوهرية:** B و C يحملان نفس اسم الحزمة `com.tencent.ig`. لكن على مستوى نظام Android الحقيقي، الحزمة المسجّلة فعلياً هي **C** (الأصلية المثبتة)، لأن الاستنساخ يحافظ على اسم الحزمة الأصلي.

---

## تدفق التحكم الكامل (كل transition)

### المرحلة 1 — الانطلاق (داخل Guest B)
```
GameActivity (Unreal)
 → IMSDKProxyActivity (com.tencent.imsdk)         [log #352/#362 STARTACT]
 → LoginManager.logIn()  (FB SDK)
 → LoginClient.getHandlersToTry()  →  [GetToken, KatanaProxy, CustomTab, WebView]
 → FacebookActivity.onCreate() → يستضيف LoginFragment   [log #423 / #370 ACT_onCreate]
```
تأكيد ترتيب الـ handlers من `LoginClient.kt::getHandlersToTry` — يطابق السجل حرفياً.

### المرحلة 2 — تجربة الـ handlers بالترتيب (login_behavior=NATIVE_WITH_FALLBACK، مؤكد من رابط OAuth)
```
KatanaProxyLoginMethodHandler.tryAuthorize()
 → STARTACT com.facebook.katana/ProxyAuth      [log #429]  ← فشل (FB app غير مثبت في VA)
 → STARTACT com.facebook.wakizashi/ProxyAuth   [log #432]  ← فشل
CustomTabLoginMethodHandler.tryAuthorize()      [log SESSION #2]
 → redirect_uri = getValidRedirectURI() = fbconnect://cct.<applicationId>
                = fbconnect://cct.com.tencent.ig            ← مؤكد حرفياً في السجل
 → fragment.startActivityForResult(Intent(CustomTabMainActivity), reqCode=1)   [log #434 STARTACT CustomTabMainActivity]
```

### المرحلة 3 — فتح Chrome (عبور الحدود B → D)
```
CustomTabMainActivity.onCreate()   [CustomTabMainActivity.kt]
 → CustomTab.openCustomTab() → CustomTabsIntent.launchUrl(
        uri = https://m.facebook.com/v13.0/dialog/oauth?...&redirect_uri=fbconnect://cct.com.tencent.ig&... , pkg=com.android.chrome)
        [log #442/#443 STARTACT VIEW ... pkg=com.android.chrome + ALLOW_HTTP_VIEW_FALLTHROUGH]
 → registerReceiver(LocalBroadcast, CUSTOM_TAB_REDIRECT_ACTION)
 → shouldCloseCustomTab = false
```
هنا **ينتهي كل ما يستطيع سجلّنا رؤيته** — لأن ما بعده يحدث في Chrome (D) والنظام الحقيقي، خارج نطاق hooks الـ VA.

### المرحلة 4 — العودة (المكان الذي ينكسر فيه كل شيء) — عبور D → ؟
```
المستخدم يوافق ("متابعة باسم أعلام قبيلة") داخل Chrome (D)
 → خادم Facebook يرد 302 → fbconnect://cct.com.tencent.ig?...token...
 → Chrome (D، خارج VA) يُطلق Intent(VIEW, fbconnect://cct.com.tencent.ig) عبر ActivityManager الحقيقي
 → نظام Android الحقيقي يبحث: من يملك scheme=fbconnect host=cct.com.tencent.ig؟
     • C (PUBG الأصلية): تملك CustomTabActivity exported بهذا الـ filter بالضبط  ✅ ← الفائز
     • A (اللودر com.pubgm): لا يملك الـ filter  ❌
     • B (النسخة الافتراضية): ليست حزمة نظام حقيقية — غير مرئية لـ PackageManager  ❌
 → الـ callback يُوجَّه إلى C (PUBG الأصلية خارج VA)
```
**هذا يفسّر بدقة ما رأيته:** شاشة "PUBG MOBILE" البيضاء = تطبيق PUBG **الأصلي** (C) يُفتح خارج البيئة الافتراضية، لكنه لم يبدأ أي جلسة OAuth (لا `pendingRequest`) → لا يفعل شيئاً مفيداً → شاشة فارغة. وفي الوقت نفسه النسخة داخل VA (B) تبقى تنتظر `onActivityResult` الذي **لن يصل أبداً**.

### كيف كان يُفترض أن يكتمل (في تثبيت عادي غير مُستنسخ)
```
fbconnect redirect → CustomTabActivity (exported، receiver)   [CustomTabActivity.kt]
 → Intent(CustomTabMainActivity, action=CUSTOM_TAB_REDIRECT_ACTION, EXTRA_URL, flags=CLEAR_TOP|SINGLE_TOP)
 → CustomTabMainActivity.onNewIntent() → sendResult(RESULT_OK) → setResult()+finish()
 → LoginFragment.onActivityResult(reqCode=1)
 → CustomTabLoginMethodHandler.onActivityResult() → parse token
 → LoginManager → CallbackManagerImpl.onActivityResult(reqCode=Login) → FacebookCallback الخاص باللعبة
```

**آلية الاستقبال المتوقّعة = `onActivityResult` (وليس `onNewIntent` على مستوى اللعبة).** الـ `onNewIntent` يحدث داخلياً في `CustomTabMainActivity` فقط، ونتيجته تُسلَّم للّعبة عبر `startActivityForResult/onActivityResult`.

خصائص الـ Activities (من manifest الـ SDK):
- `CustomTabActivity`: `exported=true` + intent-filter `fbconnect://cct.${applicationId}` — **هذا هو المدخل الحرج الذي يجب أن يكون قابلاً للتحليل من النظام الحقيقي.**
- `CustomTabMainActivity`: بلا `launchMode` مخصص (standard) — يعتمد على intent flags `CLEAR_TOP|SINGLE_TOP`.
- `FacebookActivity`: `FragmentActivity` عادية.
- `taskAffinity`: افتراضي (اسم الحزمة).

---

## السبب الجذري (فرضية قوية مبنية على الكود، بانتظار إثبات تجريبي واحد)

**تصادم هوية الحزمة (Package-Identity Collision):**
النسخة المستنسخة (B) والأصلية (C) تتشاركان اسم الحزمة `com.tencent.ig`. عنوان الـ OAuth redirect **مشتق من اسم الحزمة** (`fbconnect://cct.com.tencent.ig`). على مستوى النظام الحقيقي، الحزمة الوحيدة المسجّلة لهذا الـ scheme/host هي **الأصلية (C)** — فتختطف الـ callback، ولا يعود أبداً للنسخة داخل VA.

هذا **أدق** من استنتاجي السابق ("لا يوجد مستقبِل"): الحقيقة أن **المستقبِل الخطأ موجود** (PUBG الأصلية).

### ما هو مُثبت مقابل ما يحتاج إثباتاً
| العنصر | الحالة |
|--------|--------|
| إصلاح BLOCK_HTTP نجح، Chrome يفتح، المستخدم يوافق | ✅ مُثبت (سجل) |
| redirect_uri = `fbconnect://cct.com.tencent.ig` | ✅ مُثبت (سجل) |
| FB SDK يُصرّح CustomTabActivity exported بـ `fbconnect://cct.${applicationId}` | ✅ مُثبت (مصدر SDK 13.2.0) |
| اللودر (com.pubgm) لا يملك هذا الـ filter | ✅ مُثبت (manifest اللودر) |
| آلية العودة = onActivityResult عبر CustomTabActivity→CustomTabMainActivity | ✅ مُثبت (مصدر SDK) |
| **أن الـ callback يُختطف فعلياً إلى PUBG الأصلية (C)** | ⚠️ **فرضية قوية — تحتاج اختباراً فاصلاً** |

---

## الاختبار الفاصل المقترح (غير مدمّر، بلا أي تعديل كود)

**عطّل أو ألغِ تثبيت PUBG الأصلية (C) مؤقتاً، وأبقِ النسخة داخل VA فقط، ثم أعد محاولة Facebook:**
- إن **اختفت** شاشة "PUBG MOBILE" البيضاء وتغيّر السلوك (مثلاً ActivityNotFound أو لا شيء) → **إثبات قاطع** أن C كانت تختطف الـ redirect ← الحل يتجه لمنع تصادم الهوية / اعتراض الـ redirect داخل VA.
- إن **بقيت** نفس الشاشة البيضاء رغم غياب C → السبب مختلف، ونعيد التوجيه.

بديل غير مدمّر إن لم ترغب بإلغاء التثبيت: بعد ظهور الشاشة البيضاء، افتح قائمة التطبيقات الأخيرة (Recents) — هل يظهر تطبيق PUBG **ثانٍ** منفصل عن اللودر؟ وجوده = تأكيد أن الأصلية فُتحت.



---

## تأكيد من كود اللودر نفسه (فك تشفير Shadow_VIP.apk)

الكلاس: `com/tcore/fake/service/ActivityManagerCommonProxy$StartActivity` (خطّاف `startActivity` في VirtualApp).

منطق الخطّاف (مبسّط من smali):
```
hook(who, method, args):
  intent = extractIntent(args)
  if intent.action == "android.intent.action.VIEW"
        && intent.dataString != null
        && intent.dataString.startsWith("http"):
        return -1          ← ★ BLOCK_HTTP_VIEW الأصلي (أزلناه في v6 → ALLOW_HTTP_VIEW_FALLTHROUGH)
  # بعد الإزالة يسقط هنا:
  if intent.getParcelableExtra("_B_|_target_") != null: return real.invoke()   # مُوجّه مسبقاً
  if isRequestInstall(intent): ... # تثبيت APK
  resolve = BPackageManager.resolveActivity(intent, userId)   # يحاول ضمن حزم VA
  if resolve == null:
     if intent has package (=com.android.chrome): re-resolve;
        if still null: setPackage(chrome) + real.invoke()   ← يُمرّر للنظام الحقيقي (Chrome يفتح فعلاً)
  else:
     setComponent(resolved) ; BActivityManager.startActivityAms(...)  # يوجّه داخل الـ Guest
```

### ماذا يثبت هذا الكود بشكل قاطع
1. **الخطّاف يعترض فقط الـ intents الصادرة من داخل الـ Guest.** الـ redirect العائد `fbconnect://` يُصدره **Chrome** (نظام حقيقي، خارج VA) → **لا يمرّ على هذا الخطّاف إطلاقاً**.
2. سبب فتح Chrome بعد إصلاحنا: عند إزالة `return -1`، الـ URL الـ https (المتّجه لـ com.android.chrome) لا يُحلّ داخل VA → يُمرَّر للنظام الحقيقي عبر `real.invoke()` → Chrome يفتح. ✅ (يطابق ALLOW_HTTP_VIEW_FALLTHROUGH ثم فتح Chrome).
3. **لا توجد أي آلية في اللودر لالتقاط `fbconnect://cct.com.tencent.ig` العائد** — لا intent-filter له، ولا يمرّ عبر الخطّاف. لذلك يذهب حتماً لمالكه على النظام الحقيقي = **PUBG الأصلية (C)**.

### الخلاصة النهائية (الآن مُثبتة على مستوى الكود + المصدر)
> بعد ضغط "متابعة"، Chrome يُصدر `fbconnect://cct.com.tencent.ig` إلى نظام Android الحقيقي. اللودر لا يملك ولا يعترض هذا الـ scheme. المالك الوحيد المسجّل حقيقياً هو **PUBG الأصلية المثبتة خارج VA** → فتُفتح هي (شاشة "PUBG MOBILE" البيضاء)، والنسخة داخل VA تبقى معلّقة تنتظر `onActivityResult`.

هذا يطابق حدسك حرفياً: *"يحوّلنا إلى النسخة الأصلية خارج التطبيق، والمفروض يوجّهنا داخل اللعبة الموجودة داخل التطبيق."*

### الاختبار الفاصل الوحيد المتبقّي للإثبات 100%
عطّل/ألغِ تثبيت PUBG الأصلية (C) مؤقتاً وأعد المحاولة:
- الشاشة البيضاء تختفي / يتغيّر السلوك ⇒ تأكيد قاطع أن (C) كانت تختطف الـ callback.



---

## خريطة الـ Intent الكاملة — مُتحقَّقة من كود اللودر بالكامل

### كيف يُشغّل VirtualApp أنشطة الـ Guest (آلية Stub)
- `ActivityStack.getStartStubActivityIntentInner` → يختار stub عبر `ProxyManifest.getProxyActivity(userId)` = `com.tcore.proxy.ProxyActivity$Pn` (خانات P0–P49، كل واحدة في عملية `:pn`).
- `ProxyActivityRecord.saveStub()` يُغلّف الـ Intent الحقيقي للهدف داخل إطلاق الـ stub كـ extras: `_B_|_target_`, `_B_|_activity_info_`, `_B_|_user_id_`, `_B_|_activity_record_v_`.
- `ProxyActivity$Pn.onCreate` → `ProxyActivityRecord.create()` يفكّ `_B_|_target_` ثم يُشغّل نشاط الـ Guest الحقيقي داخلياً.

**الإثبات الحاسم:** أنشطة الـ stub (`ProxyActivity$Pn`) في manifest اللودر **بلا أي intent-filter** (فقط configChanges + process). أنشطة الـ Guest الحقيقية (`com.facebook.CustomTabActivity`, `FacebookActivity`...) موجودة فقط داخل manifest حزمة الـ Guest، ويحلّلها VA في `BPackageManager` **الخاص به** — ولا تُسجَّل إطلاقاً في PackageManager الحقيقي للنظام. ⇒ النظام الحقيقي لا يعرف أن `fbconnect://cct.com.tencent.ig` يخص الـ VA.

### الإجابة على كل بند طلبته (من الكود):
| الآلية | أين تُعالَج | النتيجة |
|--------|-------------|---------|
| **ACTION_VIEW** | `ActivityManagerCommonProxy$StartActivity.hook` | http كان يُحجب (return -1)، أصلحناه؛ غير المحلول داخلياً يُمرَّر للنظام الحقيقي |
| **Custom Tabs** | Guest → `CustomTabMainActivity` → `launchUrl(pkg=chrome)` | يُمرَّر لـ Chrome الحقيقي (خارج VA) |
| **fbconnect://** | **لا شيء في اللودر** (grep: صفر نتائج) | يُترك كلياً للنظام الحقيقي |
| **Deep Links** الوحيدة في اللودر | manifest سطر 583/591 | `genericidp://firebase.auth` و `recaptcha://firebase.auth` فقط — تخص Firebase اللودر، **لا علاقة بـ fbconnect** |
| **Intent Routing** | `BActivityManager.startActivityAms` | يوجّه الأنشطة **الصادرة من داخل** VA فقط عبر stubs |
| **ProxyActivity/StubActivity** | `ProxyActivity$P0..P49` | stubs بلا intent-filters — غير مرئية كمستقبِلات deep-link للنظام |
| **BActivityManager** | داخلي للـ VA | لا يرى الـ intents الصادرة من Chrome |

### أين يذهب الـ Intent بعد مغادرة Chrome — الجواب القاطع
الـ redirect `fbconnect://` يُصدره **Chrome (عملية مستقلة خارج VA)** إلى ActivityManager الحقيقي مباشرةً. **لا يمرّ على أي خطّاف في اللودر** (خطّافات VA تعترض فقط النداءات الصادرة من داخل عملية الـ Guest/اللودر عبر binder proxy المُرقَّع — لا intents يُطلقها Chrome من عمليته). النظام الحقيقي يحلّه → يجد `com.tencent.ig` الأصلية (تملك الـ filter) → يفتحها.

**⇒ VirtualApp لا يستطيع اعتراضه في الوضع الحالي، لأنه لا يسجّل أي مستقبِل لهذا الـ scheme على النظام الحقيقي.** الاعتراض ممكن فقط لو سجّل اللودر `fbconnect://cct.com.tencent.ig` في manifof الحقيقي (مع تضارب متوقّع مع الأصلية) ثم أعاد توجيهه للـ Guest عبر `startActivityAms`.
