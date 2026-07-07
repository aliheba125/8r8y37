# Shadow VIP — Diagnostic Build v5 — Findings & Build Notes

## 1. Root cause of the "208 characters" problem (PROVEN)

The guest game (PUBG) does **not** run in the loader process. VirtualApp runs it
in an isolated process (`:pN`). The evidence is in the user's own exported log:

```
07-08 01:18:xx I/PUBGDIAG( 7216): #2832..#3201  S4 BINDSVC ... (3000+ events, GUEST process)
07-08 01:18:43 I/PUBGDIAG( 3158): ===== SESSION SUMMARY :: events=4 ... pid=3158 =====  (HOST process)
```

- **PID 7216** = guest process (session S4) — thousands of events.
- **PID 3158** = host/loader process — only 4 events.

The old export (`exportFromHost`) ran in the **host** process, so it summarized the
host's near-empty state and captured the host's logcat → ~208 chars. The rich guest
timeline lived in a different process and was invisible to it.

## 2. The v5 fix — true per-guest-process capture

`DiagLog` now writes **from whichever process it runs in**, continuously:

- In-memory `StringBuffer` accumulates every event (thread-safe).
- A background daemon thread (`DiagLog$W`) flushes every ~2s to public Downloads.
- Each process writes its **own** file: `Download/pubg_diag_<pid>.log` (host and
  guest no longer overwrite each other; the **largest** file is the guest).
- Overwrite-in-place: legacy path first, MediaStore (`DiagDl29`, API 29+) fallback
  reusing a single `Uri` with `openOutputStream(uri, "wt")` — one file, always current.
- Flush also fires on: uncaught crash (`DiagLog$CH`), login-session start, blocked
  events, and each periodic tick — so the file reflects the full lifetime up to the
  last ~2s, even if the guest is killed. No dependency on the loader becoming visible.
- **Consecutive de-duplication**: identical repeated lines collapse into
  `^ (previous line repeated N more times)` so the log is readable instead of 99% spam.
- Rich summary header written at the top of every flush: Session ID, Process PID,
  Duration, Events, LoginSessions, startActivity, blockedHttpView, onNewIntent,
  Exceptions, Output File.

`exportFromHost` (loader `onResume`) now only **displays** — it lists the
`pubg_diag_*.log` files in Downloads with their sizes so you know which to send.

## 3. Runtime finding — WebView renderer fails to bind in the VA (partial evidence)

The captured guest log (PID 7216) shows an **infinite bind loop** (3000+ times in
seconds):

```
S4 BINDSVC cmp=ComponentInfo{com.google.android.webview/org.chromium.content.app.SandboxedProcessService0}
```

This is WebView (Chromium) repeatedly trying to bind its **sandboxed renderer
process** and failing. Confirmed by absence: the VA core has **zero** handling for
isolated/sandboxed processes — no references to `isolatedProcess`,
`SandboxedProcessService`, `chromium`, or `WebViewFactory` anywhere in
`com/tcore/`. `SandboxedProcessService0` is declared `android:isolatedProcess="true"`
in the WebView package; VirtualApp cannot host isolated processes, so the bind never
completes and Chromium retries forever.

### IMPORTANT scope correction (per user testing)
The user reports this large log was captured **while the loader was cloning/installing
the APK into the VA container** (the "install" button step), **not** confirmed during
an actual in-game login attempt. After install, the exported log again showed only the
**host** summary (`pid=3158 events=4 uptimeMs=1996339`) — i.e. the real run was still
being read from the wrong (host) process.

So what is **proven** so far:
- WebView's sandboxed renderer **cannot bind inside this VA** (structural VA limit). ✅
- The guest run is captured in a `:pN` process the old export never read. ✅

What is **not yet proven** (needs the v5 guest log from a real login attempt):
- That this same WebView-renderer failure is what blocks the Facebook/Twitter/Google
  **login page** during gameplay. This is a strong hypothesis, but until we see the
  guest's per-process log for an actual login attempt, it stays a hypothesis, not a
  conclusion.

v5 is built precisely to capture that missing evidence: the guest process now writes
its own complete, de-duplicated `Download/pubg_diag_<pid>.log` during the real run.

If confirmed, this is a structural VirtualApp limitation (not a one-line bug): the fix
would require the VA to support isolated/sandboxed service processes, or to force
WebView into single-process mode for the guest.

## 4. What to test with v5
1. Install `Shadow_VIP_DIAG.apk`, grant storage permission.
2. Launch PUBG from the loader, attempt Facebook / Twitter / Google login.
3. Return to the launcher; open the **Download** folder.
4. Send the **largest** `pubg_diag_<pid>.log` — that is the guest process's full,
   de-duplicated timeline with the summary header at the top.
