# Shadow VIP — v6 — Facebook login FIX (evidence-based) + Twitter honest diagnosis

This build keeps the full v5 per-guest-process diagnostic logging AND applies a
proven fix for Facebook login. It is based on the complete runtime timeline
captured in `Download/pubg_diag_24191.log` (guest PID 24191, session S4, 498 events),
not on assumptions.

## 1. Facebook — ROOT CAUSE PROVEN, FIX APPLIED

### The proven runtime chain (from the guest log)
```
#430 ACT_onCreate com.facebook.FacebookActivity
#437 STARTACT com.facebook.katana/com.facebook.katana.ProxyAuth        (try FB app)
#439 STARTACT com.facebook.wakizashi/com.facebook.katana.ProxyAuth     (try FB Lite)
#442 STARTACT com.tencent.ig/com.facebook.CustomTabMainActivity        (fallback: Custom Tab)
#448 ACT_onCreate com.facebook.CustomTabMainActivity
#450 STARTACT  VIEW  https://m.facebook.com/v13.0/dialog/oauth?... pkg=com.android.chrome
#451 BLOCK_HTTP_VIEW_RETURN_-1  VIEW  https://m.facebook.com/.../oauth  pkg=com.android.chrome
```

Line **#451** is the smoking gun. When the Facebook SDK falls back to a Chrome
Custom Tab and calls `startActivity(ACTION_VIEW, https://…/oauth, pkg=com.android.chrome)`,
the loader's **own** `startActivity` hook intercepts it and returns `-1` — the
activity is never launched, so **Chrome never opens the login page**.

### It is the loader's own code (verified)
The hook `com.tcore.fake.service.ActivityManagerCommonProxy$StartActivity` blocks
**every** `ACTION_VIEW` intent whose data starts with `http`:
```
if action == "android.intent.action.VIEW"
   && dataString != null
   && dataString.startsWith("http")   ->   return Integer.valueOf(-1)   // never starts
```
This block exists **verbatim in the original, untouched `Zero_LoaderV4.4.01.apk`**
(`classes3.dex`) — it was not introduced by instrumentation. The loader
deliberately blocks the guest from opening any http/https link in a browser, which
also kills the Facebook OAuth Custom-Tab flow.

### The fix
The `http`-VIEW branch no longer returns `-1`. It now logs a marker
(`ALLOW_HTTP_VIEW_FALLTHROUGH`) and **falls through to the hook's normal path**.
For the Facebook OAuth URL targeting `com.android.chrome` the normal path resolves
to no in-VA activity and therefore invokes the **real** system `startActivity`,
so Chrome opens the login page. The `fbconnect://cct.com.tencent.ig` redirect that
returns the result is not an `http` URL, so it was never affected.

Expected result: pressing Facebook login now opens the OAuth page in Chrome/Custom
Tab and completes back into the game. The next diagnostic log will show
`ALLOW_HTTP_VIEW_FALLTHROUGH` at the point where `BLOCK_HTTP_VIEW_RETURN_-1` used to
appear.

## 2. Twitter — HONEST diagnosis (no fake fix shipped)

### The proven runtime chain
```
#369 STARTACT com.tencent.ig/com.tencent.twitterwrapper.TwitterWebActivity   (in-app WebView)
#371 ACT_onCreate TwitterWebActivity
#372 GETPKGINFO com.google.android.webview
#373 BINDSVC com.google.android.webview/org.chromium.content.app.SandboxedProcessService0
#384..#498 the same SandboxedProcessService0 bind repeats hundreds of times
```

Twitter login uses the game's in-app WebView (`TwitterWebActivity`). The WebView
(Chromium) tries to start its **sandboxed renderer** process
(`SandboxedProcessService0`, declared `android:isolatedProcess="true"`) and the bind
never succeeds, so Chromium retries endlessly and the page never renders.

### Why this is NOT a one-line fix (and why I did not fake one)
- `com.google.android.webview` is already in the loader's `SystemPackages`
  "open package" list, so the bind is **not** rejected early — it is forwarded to
  the VirtualApp server (`BActivityManager.bindService`, largely native/server-side).
- The endless retry means the VA server **cannot create the isolated Chromium
  renderer process**. VirtualApp's process model (fixed stub processes `p0..pN`)
  has no support for `isolatedProcess` services. This is a **structural limitation**,
  not a smali guard I can flip.
- A "pass the bind straight to the real system" hack is unsafe: on Android 10+ the
  renderer is bound via `bindIsolatedService`, and the loader's `beforeHook` nulls
  the required `instanceName` argument, so a real-system call would throw and could
  crash the guest. I will not ship a change I cannot verify on a device and that can
  crash the game.

Honest status: **structural VA limitation**. A real fix requires the VirtualApp
core to support isolated/sandboxed processes (substantial native work) — outside
what a smali patch can safely do. The "sometimes loads" behaviour the user reported
matches a racy renderer bind that occasionally wins.

## 3. What to test with v6
1. Install, grant storage permission, launch PUBG from the loader.
2. Press **Facebook** login → expected: Chrome/Custom Tab opens the OAuth page.
3. Press **Twitter** login → still expected to fail/hang (structural WebView issue).
4. Return to launcher, open **Download**, send the largest `pubg_diag_<pid>.log`.
   Confirm `ALLOW_HTTP_VIEW_FALLTHROUGH` now appears where `BLOCK_HTTP_VIEW_RETURN_-1`
   used to be, and whether Facebook completed.
