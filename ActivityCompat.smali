.class public Lcom/pubgm/utils/ActivityCompat;
.super Landroidx/appcompat/app/AppCompatActivity;
.source "ActivityCompat.java"


# static fields
.field public static PERMISSION_REQUEST_STORAGE:I

.field public static REQUEST_MANAGE_UNKNOWN_APP_SOURCES:I

.field public static REQUEST_OVERLAY_PERMISSION:I

.field private static activityCompat:Lcom/pubgm/utils/ActivityCompat;

.field private static executorService:Ljava/util/concurrent/ExecutorService;

.field public static gamename:Ljava/lang/String;

.field public static name:Ljava/lang/String;

.field public static url:Ljava/lang/String;

.field public static version:I


# instance fields
.field private backPressedTime:J

.field private bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

.field public currentAuth:Lcom/google/firebase/auth/FirebaseAuth;

.field public isLogin:Z

.field public prefs:Lcom/pubgm/utils/FPrefs;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .line 66
    const/16 v0, 0x155d

    sput v0, Lcom/pubgm/utils/ActivityCompat;->REQUEST_OVERLAY_PERMISSION:I

    .line 67
    const/16 v0, 0x64

    sput v0, Lcom/pubgm/utils/ActivityCompat;->PERMISSION_REQUEST_STORAGE:I

    .line 68
    const/16 v0, 0xc8

    sput v0, Lcom/pubgm/utils/ActivityCompat;->REQUEST_MANAGE_UNKNOWN_APP_SOURCES:I

    .line 77
    invoke-static {}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor()Ljava/util/concurrent/ExecutorService;

    move-result-object v0

    sput-object v0, Lcom/pubgm/utils/ActivityCompat;->executorService:Ljava/util/concurrent/ExecutorService;

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .line 64
    invoke-direct {p0}, Landroidx/appcompat/app/AppCompatActivity;-><init>()V

    .line 69
    # PATCHED: isLogin = true by default
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/pubgm/utils/ActivityCompat;->isLogin:Z

    .line 274
    const-wide/16 v0, 0x0

    iput-wide v0, p0, Lcom/pubgm/utils/ActivityCompat;->backPressedTime:J

    return-void
.end method

.method private doActionAnimation(Lcom/airbnb/lottie/LottieAnimationView;Landroid/widget/TextView;Ljava/lang/String;)V
    .locals 3
    .param p1, "lottie"    # Lcom/airbnb/lottie/LottieAnimationView;
    .param p2, "txt"    # Landroid/widget/TextView;
    .param p3, "pkg"    # Ljava/lang/String;

    .line 327
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v1, -0x148a7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-wide v1, -0x149b7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p2, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 328
    sget v0, Lcom/pubgm/R$raw;->anim_lora:I

    invoke-virtual {p1, v0}, Lcom/airbnb/lottie/LottieAnimationView;->setAnimation(I)V

    .line 329
    invoke-virtual {p1}, Lcom/airbnb/lottie/LottieAnimationView;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object v0

    const-wide/16 v1, 0x7d0

    invoke-virtual {v0, v1, v2}, Landroid/view/ViewPropertyAnimator;->setStartDelay(J)Landroid/view/ViewPropertyAnimator;

    .line 330
    invoke-virtual {p1}, Lcom/airbnb/lottie/LottieAnimationView;->playAnimation()V

    .line 331
    return-void
.end method

.method public static getActivityCompat()Lcom/pubgm/utils/ActivityCompat;
    .locals 1

    .line 80
    sget-object v0, Lcom/pubgm/utils/ActivityCompat;->activityCompat:Lcom/pubgm/utils/ActivityCompat;

    return-object v0
.end method

.method private hideSystemUI()V
    .locals 2

    .line 303
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    .line 304
    .local v0, "decorView":Landroid/view/View;
    const/16 v1, 0xf06

    invoke-virtual {v0, v1}, Landroid/view/View;->setSystemUiVisibility(I)V

    .line 314
    return-void
.end method

.method static synthetic lambda$launch$3(Landroidx/appcompat/app/AlertDialog;)V
    .locals 8
    .param p0, "dialog"    # Landroidx/appcompat/app/AlertDialog;

    .line 335
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    .line 336
    .local v0, "startTime":J
    invoke-virtual {p0}, Landroidx/appcompat/app/AlertDialog;->dismiss()V

    .line 337
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v2

    sub-long/2addr v2, v0

    .line 338
    .local v2, "elapsedTime":J
    const-wide/16 v4, 0x1f4

    sub-long/2addr v4, v2

    .line 339
    .local v4, "delta":J
    const-wide/16 v6, 0x0

    cmp-long v6, v4, v6

    if-lez v6, :cond_0

    .line 340
    invoke-static {v4, v5}, Lcom/pubgm/utils/UiKit;->sleep(J)V

    .line 342
    :cond_0
    return-void
.end method

.method static synthetic lambda$launch$4(Ljava/lang/String;Ljava/lang/Void;)V
    .locals 1
    .param p0, "pkg"    # Ljava/lang/String;
    .param p1, "ree"    # Ljava/lang/Void;

    .line 343
    invoke-static {}, Lcom/pubgm/libhelper/ApkEnv;->getInstance()Lcom/pubgm/libhelper/ApkEnv;

    move-result-object v0

    invoke-virtual {v0, p0}, Lcom/pubgm/libhelper/ApkEnv;->launchApk(Ljava/lang/String;)V

    .line 344
    return-void
.end method

.method static synthetic lambda$launchSplash$7(Landroidx/appcompat/app/AlertDialog;Ljava/lang/Throwable;)V
    .locals 0
    .param p0, "dialog"    # Landroidx/appcompat/app/AlertDialog;
    .param p1, "fa"    # Ljava/lang/Throwable;

    .line 370
    invoke-virtual {p0}, Landroidx/appcompat/app/AlertDialog;->dismiss()V

    return-void
.end method

.method private showSystemUI()V
    .locals 2

    .line 319
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    .line 320
    .local v0, "decorView":Landroid/view/View;
    const/16 v1, 0x700

    invoke-virtual {v0, v1}, Landroid/view/View;->setSystemUiVisibility(I)V

    .line 324
    return-void
.end method


# virtual methods
.method public InstllUnknownApp()V
    .locals 3

    .line 204
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1a

    if-lt v0, v1, :cond_1

    .line 205
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/pm/PackageManager;->canRequestPackageInstalls()Z

    move-result v0

    if-nez v0, :cond_0

    .line 206
    new-instance v0, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    invoke-direct {v0, p0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;-><init>(Landroid/content/Context;)V

    .line 207
    .local v0, "builder":Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;
    const-wide v1, -0x13d17d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setMessage(Ljava/lang/CharSequence;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    .line 208
    const-wide v1, -0x13f97d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Lcom/pubgm/utils/ActivityCompat$1;

    invoke-direct {v2, p0}, Lcom/pubgm/utils/ActivityCompat$1;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    invoke-virtual {v0, v1, v2}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    .line 215
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setCancelable(Z)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    .line 216
    invoke-virtual {v0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->show()Landroidx/appcompat/app/AlertDialog;

    .line 217
    .end local v0    # "builder":Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;
    goto :goto_0

    .line 218
    :cond_0
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->isPermissionGaranted()Z

    move-result v0

    if-nez v0, :cond_1

    .line 219
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->takeFilePermissions()V

    .line 223
    :cond_1
    :goto_0
    return-void
.end method

.method public ManageFiles()V
    .locals 3

    .line 246
    nop

    .line 247
    const-wide v0, -0x14217d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-eqz v0, :cond_0

    .line 249
    const/4 v0, 0x1

    new-array v0, v0, [Ljava/lang/String;

    const-wide v1, -0x144b7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    aput-object v1, v0, v2

    sget v1, Lcom/pubgm/utils/ActivityCompat;->PERMISSION_REQUEST_STORAGE:I

    invoke-static {p0, v0, v1}, Landroidx/core/app/ActivityCompat;->requestPermissions(Landroid/app/Activity;[Ljava/lang/String;I)V

    goto :goto_0

    .line 253
    :cond_0
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->OverlayPermision()V

    .line 256
    :goto_0
    return-void
.end method

.method public OverlayPermision()V
    .locals 3

    .line 226
    nop

    .line 227
    invoke-static {p0}, Landroid/provider/Settings;->canDrawOverlays(Landroid/content/Context;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 228
    new-instance v0, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    invoke-direct {v0, p0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;-><init>(Landroid/content/Context;)V

    .line 229
    .local v0, "builder":Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;
    const-wide v1, -0x13fd7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setMessage(Ljava/lang/CharSequence;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    .line 230
    const-wide v1, -0x141d7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Lcom/pubgm/utils/ActivityCompat$2;

    invoke-direct {v2, p0}, Lcom/pubgm/utils/ActivityCompat$2;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    invoke-virtual {v0, v1, v2}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    .line 237
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setCancelable(Z)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    .line 238
    invoke-virtual {v0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->show()Landroidx/appcompat/app/AlertDialog;

    .line 239
    .end local v0    # "builder":Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;
    goto :goto_0

    .line 240
    :cond_0
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->InstllUnknownApp()V

    .line 243
    :goto_0
    return-void
.end method

.method public RestartAppp()V
    .locals 3

    .line 137
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    .line 138
    .local v0, "pm":Landroid/content/pm/PackageManager;
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPackageName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v1

    .line 139
    .local v1, "intent":Landroid/content/Intent;
    if-eqz v1, :cond_0

    .line 140
    const v2, 0x14008000

    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 141
    invoke-virtual {p0, v1}, Lcom/pubgm/utils/ActivityCompat;->startActivity(Landroid/content/Intent;)V

    .line 143
    :cond_0
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->finish()V

    .line 144
    invoke-static {}, Landroid/os/Process;->myPid()I

    move-result v2

    invoke-static {v2}, Landroid/os/Process;->killProcess(I)V

    .line 145
    const/4 v2, 0x0

    invoke-static {v2}, Ljava/lang/System;->exit(I)V

    .line 146
    return-void
.end method

.method public ShowLatestUpdateError(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V
    .locals 14
    .param p1, "GameName"    # Ljava/lang/String;
    .param p2, "Name"    # Ljava/lang/String;
    .param p3, "Version"    # I
    .param p4, "Url"    # Ljava/lang/String;

    .line 510
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    sget v1, Lcom/pubgm/R$drawable;->ic_error:I

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v3

    const-wide v0, -0x16177d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v4

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v1, -0x16257d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    move-object v1, p1

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-wide v5, -0x162f7d7e0b5bL

    invoke-static {v5, v6}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    move/from16 v11, p3

    invoke-virtual {v0, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-wide v5, -0x163c7d7e0b5bL

    invoke-static {v5, v6}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const/4 v12, 0x0

    new-instance v13, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda12;

    move-object v5, v13

    move-object v6, p0

    move-object v7, p1

    move-object/from16 v8, p2

    move/from16 v9, p3

    move-object/from16 v10, p4

    invoke-direct/range {v5 .. v10}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda12;-><init>(Lcom/pubgm/utils/ActivityCompat;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V

    const/4 v8, 0x0

    move-object v2, p0

    move-object v5, v0

    move v6, v12

    move-object v7, v13

    invoke-virtual/range {v2 .. v8}, Lcom/pubgm/utils/ActivityCompat;->showBottomSheetDialog(Landroid/graphics/drawable/Drawable;Ljava/lang/String;Ljava/lang/String;ZLandroid/view/View$OnClickListener;Landroid/view/View$OnClickListener;)V

    .line 515
    return-void
.end method

.method public ShowRestartApp()V
    .locals 9

    .line 149
    nop

    .line 150
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    sget v1, Lcom/pubgm/R$drawable;->ic_check:I

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v3

    const-wide v0, -0x13507d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v4

    const-wide v0, -0x13737d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v5

    const/4 v6, 0x0

    new-instance v7, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda2;

    invoke-direct {v7, p0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda2;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    const/4 v8, 0x0

    .line 149
    move-object v2, p0

    invoke-virtual/range {v2 .. v8}, Lcom/pubgm/utils/ActivityCompat;->showBottomSheetDialog(Landroid/graphics/drawable/Drawable;Ljava/lang/String;Ljava/lang/String;ZLandroid/view/View$OnClickListener;Landroid/view/View$OnClickListener;)V

    .line 160
    return-void
.end method

.method public ShowUpdateError()V
    .locals 9

    .line 502
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    sget v1, Lcom/pubgm/R$drawable;->ic_error:I

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v3

    const-wide v0, -0x15c87d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v4

    const-wide v0, -0x15d57d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v5

    const/4 v6, 0x0

    new-instance v7, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda1;

    invoke-direct {v7, p0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda1;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    const/4 v8, 0x0

    move-object v2, p0

    invoke-virtual/range {v2 .. v8}, Lcom/pubgm/utils/ActivityCompat;->showBottomSheetDialog(Landroid/graphics/drawable/Drawable;Ljava/lang/String;Ljava/lang/String;ZLandroid/view/View$OnClickListener;Landroid/view/View$OnClickListener;)V

    .line 507
    return-void
.end method

.method public checkLatestLoader(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V
    .locals 10
    .param p1, "GameName"    # Ljava/lang/String;
    .param p2, "Name"    # Ljava/lang/String;
    .param p3, "Version"    # I
    .param p4, "Url"    # Ljava/lang/String;

    .line 473
    new-instance v0, Landroid/app/ProgressDialog;

    const/4 v1, 0x5

    invoke-direct {v0, p0, v1}, Landroid/app/ProgressDialog;-><init>(Landroid/content/Context;I)V

    .line 474
    .local v0, "progressDialog":Landroid/app/ProgressDialog;
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    .line 475
    invoke-virtual {v0}, Landroid/app/ProgressDialog;->show()V

    .line 476
    sget-object v1, Lcom/pubgm/utils/ActivityCompat;->executorService:Ljava/util/concurrent/ExecutorService;

    new-instance v9, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda0;

    move-object v2, v9

    move-object v3, p0

    move-object v4, v0

    move-object v5, p1

    move-object v6, p2

    move v7, p3

    move-object v8, p4

    invoke-direct/range {v2 .. v8}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda0;-><init>(Lcom/pubgm/utils/ActivityCompat;Landroid/app/ProgressDialog;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V

    invoke-interface {v1, v9}, Ljava/util/concurrent/ExecutorService;->submit(Ljava/lang/Runnable;)Ljava/util/concurrent/Future;

    .line 493
    return-void
.end method

.method public checkLoader()V
    .locals 3

    .line 443
    new-instance v0, Landroid/app/ProgressDialog;

    const/4 v1, 0x5

    invoke-direct {v0, p0, v1}, Landroid/app/ProgressDialog;-><init>(Landroid/content/Context;I)V

    .line 444
    .local v0, "progressDialog":Landroid/app/ProgressDialog;
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    .line 445
    invoke-virtual {v0}, Landroid/app/ProgressDialog;->show()V

    .line 446
    sget-object v1, Lcom/pubgm/utils/ActivityCompat;->executorService:Ljava/util/concurrent/ExecutorService;

    new-instance v2, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda8;

    invoke-direct {v2, p0, v0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda8;-><init>(Lcom/pubgm/utils/ActivityCompat;Landroid/app/ProgressDialog;)V

    invoke-interface {v1, v2}, Ljava/util/concurrent/ExecutorService;->submit(Ljava/lang/Runnable;)Ljava/util/concurrent/Future;

    .line 464
    return-void
.end method

.method protected defer()Lorg/jdeferred/android/AndroidDeferredManager;
    .locals 1

    .line 271
    invoke-static {}, Lcom/pubgm/utils/UiKit;->defer()Lorg/jdeferred/android/AndroidDeferredManager;

    move-result-object v0

    return-object v0
.end method

.method public dismissBottomSheetDialog()V
    .locals 2

    .line 593
    :try_start_0
    iget-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    invoke-virtual {v0}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 594
    iget-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    invoke-virtual {v0}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->dismiss()V

    .line 595
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 599
    :cond_0
    goto :goto_0

    .line 597
    :catch_0
    move-exception v0

    .line 598
    .local v0, "err":Ljava/lang/Exception;
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/pubgm/utils/FLog;->error(Ljava/lang/String;)V

    .line 600
    .end local v0    # "err":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public getPref()Lcom/pubgm/utils/FPrefs;
    .locals 1

    .line 84
    invoke-static {p0}, Lcom/pubgm/utils/FPrefs;->with(Landroid/content/Context;)Lcom/pubgm/utils/FPrefs;

    move-result-object v0

    return-object v0
.end method

.method public isPermissionGaranted()Z
    .locals 2

    .line 196
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    .line 197
    invoke-static {}, Landroid/os/Environment;->isExternalStorageManager()Z

    move-result v0

    return v0

    .line 199
    :cond_0
    const-wide v0, -0x13a87d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-nez v0, :cond_1

    const/4 v0, 0x1

    goto :goto_0

    :cond_1
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method synthetic lambda$ShowLatestUpdateError$16$com-pubgm-utils-ActivityCompat(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Landroid/view/View;)V
    .locals 2
    .param p1, "GameName"    # Ljava/lang/String;
    .param p2, "Name"    # Ljava/lang/String;
    .param p3, "Version"    # I
    .param p4, "Url"    # Ljava/lang/String;
    .param p5, "v"    # Landroid/view/View;

    .line 511
    invoke-static {}, Lcom/pubgm/activity/MainActivity;->get()Lcom/pubgm/activity/MainActivity;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/pubgm/activity/MainActivity;->doShowProgress(Z)V

    .line 512
    invoke-virtual {p0, p1, p2, p3, p4}, Lcom/pubgm/utils/ActivityCompat;->checkLatestLoader(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V

    .line 513
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->dismissBottomSheetDialog()V

    .line 514
    return-void
.end method

.method synthetic lambda$ShowRestartApp$0$com-pubgm-utils-ActivityCompat(Landroid/view/View;)V
    .locals 2
    .param p1, "v"    # Landroid/view/View;

    .line 155
    invoke-static {}, Lcom/pubgm/activity/MainActivity;->get()Lcom/pubgm/activity/MainActivity;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/pubgm/activity/MainActivity;->doShowProgress(Z)V

    .line 156
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->RestartAppp()V

    .line 157
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->dismissBottomSheetDialog()V

    .line 158
    return-void
.end method

.method synthetic lambda$ShowUpdateError$15$com-pubgm-utils-ActivityCompat(Landroid/view/View;)V
    .locals 2
    .param p1, "v"    # Landroid/view/View;

    .line 503
    invoke-static {}, Lcom/pubgm/activity/MainActivity;->get()Lcom/pubgm/activity/MainActivity;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/pubgm/activity/MainActivity;->doShowProgress(Z)V

    .line 504
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->checkLoader()V

    .line 505
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->dismissBottomSheetDialog()V

    .line 506
    return-void
.end method

.method synthetic lambda$checkLatestLoader$13$com-pubgm-utils-ActivityCompat(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V
    .locals 0
    .param p1, "GameName"    # Ljava/lang/String;
    .param p2, "Name"    # Ljava/lang/String;
    .param p3, "Version"    # I
    .param p4, "Url"    # Ljava/lang/String;

    .line 481
    invoke-virtual {p0, p1, p2, p3, p4}, Lcom/pubgm/utils/ActivityCompat;->ShowLatestUpdateError(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V

    return-void
.end method

.method synthetic lambda$checkLatestLoader$14$com-pubgm-utils-ActivityCompat(Landroid/app/ProgressDialog;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V
    .locals 8
    .param p1, "progressDialog"    # Landroid/app/ProgressDialog;
    .param p2, "GameName"    # Ljava/lang/String;
    .param p3, "Name"    # Ljava/lang/String;
    .param p4, "Version"    # I
    .param p5, "Url"    # Ljava/lang/String;

    .line 477
    invoke-static/range {p0 .. p5}, Lcom/pubgm/libhelper/FileHelper;->DownloadLatestVersion(Lcom/pubgm/utils/ActivityCompat;Landroid/app/ProgressDialog;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 478
    .local v0, "failMsg":Ljava/lang/String;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v2, -0x16867d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    .line 479
    if-eqz v0, :cond_0

    .line 480
    sget v1, Lcom/pubgm/R$drawable;->ic_error:I

    invoke-virtual {p0, v1, v0}, Lcom/pubgm/utils/ActivityCompat;->toastImage(ILjava/lang/CharSequence;)V

    .line 481
    new-instance v1, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda9;

    move-object v2, v1

    move-object v3, p0

    move-object v4, p2

    move-object v5, p3

    move v6, p4

    move-object v7, p5

    invoke-direct/range {v2 .. v7}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda9;-><init>(Lcom/pubgm/utils/ActivityCompat;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V

    invoke-virtual {p0, v1}, Lcom/pubgm/utils/ActivityCompat;->runOnUiThread(Ljava/lang/Runnable;)V

    goto :goto_0

    .line 483
    :cond_0
    sget v1, Lcom/pubgm/R$drawable;->ic_check:I

    const-wide v2, -0x169a7d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p0, v1, v2}, Lcom/pubgm/utils/ActivityCompat;->toastImage(ILjava/lang/CharSequence;)V

    .line 484
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPref()Lcom/pubgm/utils/FPrefs;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v3, -0x16be7d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {p2}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, p4}, Lcom/pubgm/utils/FPrefs;->writeInt(Ljava/lang/String;I)V

    .line 487
    :goto_0
    :try_start_0
    invoke-virtual {p1}, Landroid/app/ProgressDialog;->dismiss()V

    .line 488
    invoke-static {}, Lcom/pubgm/activity/MainActivity;->get()Lcom/pubgm/activity/MainActivity;

    move-result-object v1

    invoke-virtual {v1}, Lcom/pubgm/activity/MainActivity;->doHideProgress()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 491
    goto :goto_1

    .line 489
    :catchall_0
    move-exception v1

    .line 490
    .local v1, "e":Ljava/lang/Throwable;
    invoke-virtual {v1}, Ljava/lang/Throwable;->printStackTrace()V

    .line 492
    .end local v1    # "e":Ljava/lang/Throwable;
    :goto_1
    return-void
.end method

.method synthetic lambda$checkLoader$10$com-pubgm-utils-ActivityCompat()V
    .locals 0

    .line 451
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->ShowUpdateError()V

    return-void
.end method

.method synthetic lambda$checkLoader$11$com-pubgm-utils-ActivityCompat()V
    .locals 0

    .line 455
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->ShowRestartApp()V

    return-void
.end method

.method synthetic lambda$checkLoader$12$com-pubgm-utils-ActivityCompat(Landroid/app/ProgressDialog;)V
    .locals 5
    .param p1, "progressDialog"    # Landroid/app/ProgressDialog;

    .line 447
    invoke-static {p0, p1}, Lcom/pubgm/libhelper/FileHelper;->installLoader(Lcom/pubgm/utils/ActivityCompat;Landroid/app/ProgressDialog;)Ljava/lang/String;

    move-result-object v0

    .line 448
    .local v0, "failMsg":Ljava/lang/String;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v2, -0x16ce7d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    .line 449
    if-eqz v0, :cond_0

    .line 450
    sget v1, Lcom/pubgm/R$drawable;->ic_error:I

    invoke-virtual {p0, v1, v0}, Lcom/pubgm/utils/ActivityCompat;->toastImage(ILjava/lang/CharSequence;)V

    .line 451
    new-instance v1, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda3;

    invoke-direct {v1, p0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda3;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    invoke-virtual {p0, v1}, Lcom/pubgm/utils/ActivityCompat;->runOnUiThread(Ljava/lang/Runnable;)V

    goto :goto_0

    .line 453
    :cond_0
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPref()Lcom/pubgm/utils/FPrefs;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v3, -0x16e27d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    sget-object v3, Lcom/pubgm/utils/ActivityCompat;->gamename:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    sget v3, Lcom/pubgm/utils/ActivityCompat;->version:I

    invoke-virtual {v1, v2, v3}, Lcom/pubgm/utils/FPrefs;->writeInt(Ljava/lang/String;I)V

    .line 455
    new-instance v1, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda4;

    invoke-direct {v1, p0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda4;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    invoke-virtual {p0, v1}, Lcom/pubgm/utils/ActivityCompat;->runOnUiThread(Ljava/lang/Runnable;)V

    .line 458
    :goto_0
    :try_start_0
    invoke-virtual {p1}, Landroid/app/ProgressDialog;->dismiss()V

    .line 459
    invoke-static {}, Lcom/pubgm/activity/MainActivity;->get()Lcom/pubgm/activity/MainActivity;

    move-result-object v1

    invoke-virtual {v1}, Lcom/pubgm/activity/MainActivity;->doHideProgress()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 462
    goto :goto_1

    .line 460
    :catchall_0
    move-exception v1

    .line 461
    .local v1, "e":Ljava/lang/Throwable;
    invoke-virtual {v1}, Ljava/lang/Throwable;->printStackTrace()V

    .line 463
    .end local v1    # "e":Ljava/lang/Throwable;
    :goto_1
    return-void
.end method

.method synthetic lambda$launchSplash$5$com-pubgm-utils-ActivityCompat(Lcom/airbnb/lottie/LottieAnimationView;Landroid/widget/TextView;Ljava/lang/String;)V
    .locals 8
    .param p1, "lottie"    # Lcom/airbnb/lottie/LottieAnimationView;
    .param p2, "txt"    # Landroid/widget/TextView;
    .param p3, "pkg"    # Ljava/lang/String;

    .line 363
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    .line 364
    .local v0, "startTime":J
    invoke-direct {p0, p1, p2, p3}, Lcom/pubgm/utils/ActivityCompat;->doActionAnimation(Lcom/airbnb/lottie/LottieAnimationView;Landroid/widget/TextView;Ljava/lang/String;)V

    .line 365
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v2

    sub-long/2addr v2, v0

    .line 366
    .local v2, "elapsedTime":J
    const-wide/16 v4, 0xbb8

    sub-long/2addr v4, v2

    .line 367
    .local v4, "delta":J
    const-wide/16 v6, 0x0

    cmp-long v6, v4, v6

    if-lez v6, :cond_0

    .line 368
    invoke-static {v4, v5}, Lcom/pubgm/utils/UiKit;->sleep(J)V

    .line 370
    :cond_0
    return-void
.end method

.method synthetic lambda$launchSplash$6$com-pubgm-utils-ActivityCompat(Landroidx/appcompat/app/AlertDialog;Ljava/lang/String;Ljava/lang/Void;)V
    .locals 0
    .param p1, "dialog"    # Landroidx/appcompat/app/AlertDialog;
    .param p2, "pkg"    # Ljava/lang/String;
    .param p3, "ree"    # Ljava/lang/Void;

    .line 370
    invoke-virtual {p0, p1, p2}, Lcom/pubgm/utils/ActivityCompat;->launch(Landroidx/appcompat/app/AlertDialog;Ljava/lang/String;)V

    return-void
.end method

.method synthetic lambda$takeFilePermissions$1$com-pubgm-utils-ActivityCompat(Landroid/content/DialogInterface;I)V
    .locals 4
    .param p1, "d"    # Landroid/content/DialogInterface;
    .param p2, "w"    # I

    .line 170
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    .line 171
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 172
    .local v0, "intent":Landroid/content/Intent;
    const-wide v1, -0x16f27d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 173
    const-wide v1, -0x172a7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPackageName()Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x0

    invoke-static {v1, v2, v3}, Landroid/net/Uri;->fromParts(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    .line 174
    .local v1, "uri":Landroid/net/Uri;
    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 175
    invoke-virtual {p0, v0}, Lcom/pubgm/utils/ActivityCompat;->startActivity(Landroid/content/Intent;)V

    .line 176
    .end local v0    # "intent":Landroid/content/Intent;
    .end local v1    # "uri":Landroid/net/Uri;
    goto :goto_0

    .line 177
    :cond_0
    const/4 v0, 0x2

    new-array v0, v0, [Ljava/lang/String;

    const-wide v1, -0x17327d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    aput-object v1, v0, v2

    const-wide v1, -0x175b7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x1

    aput-object v1, v0, v2

    invoke-static {p0, v0, v2}, Landroidx/core/app/ActivityCompat;->requestPermissions(Landroid/app/Activity;[Ljava/lang/String;I)V

    .line 185
    :goto_0
    return-void
.end method

.method synthetic lambda$takeFilePermissions$2$com-pubgm-utils-ActivityCompat(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "d"    # Landroid/content/DialogInterface;
    .param p2, "w"    # I

    .line 189
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->finish()V

    .line 190
    const/4 v0, 0x0

    invoke-static {v0}, Ljava/lang/System;->exit(I)V

    .line 191
    return-void
.end method

.method synthetic lambda$tryAskUpdateLoader$8$com-pubgm-utils-ActivityCompat(Landroid/view/View;)V
    .locals 2
    .param p1, "v"    # Landroid/view/View;

    .line 414
    invoke-static {}, Lcom/pubgm/activity/MainActivity;->get()Lcom/pubgm/activity/MainActivity;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/pubgm/activity/MainActivity;->doShowProgress(Z)V

    .line 415
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->checkLoader()V

    .line 416
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->dismissBottomSheetDialog()V

    .line 417
    return-void
.end method

.method synthetic lambda$tryAskVersionLoader$9$com-pubgm-utils-ActivityCompat(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Landroid/view/View;)V
    .locals 2
    .param p1, "GameName"    # Ljava/lang/String;
    .param p2, "Name"    # Ljava/lang/String;
    .param p3, "Version"    # I
    .param p4, "Url"    # Ljava/lang/String;
    .param p5, "v"    # Landroid/view/View;

    .line 430
    invoke-static {}, Lcom/pubgm/activity/MainActivity;->get()Lcom/pubgm/activity/MainActivity;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/pubgm/activity/MainActivity;->doShowProgress(Z)V

    .line 431
    invoke-virtual {p0, p1, p2, p3, p4}, Lcom/pubgm/utils/ActivityCompat;->checkLatestLoader(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V

    .line 432
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->dismissBottomSheetDialog()V

    .line 433
    return-void
.end method

.method public launch(Landroidx/appcompat/app/AlertDialog;Ljava/lang/String;)V
    .locals 2
    .param p1, "dialog"    # Landroidx/appcompat/app/AlertDialog;
    .param p2, "pkg"    # Ljava/lang/String;

    .line 334
    invoke-static {}, Lcom/pubgm/utils/UiKit;->defer()Lorg/jdeferred/android/AndroidDeferredManager;

    move-result-object v0

    new-instance v1, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda14;

    invoke-direct {v1, p1}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda14;-><init>(Landroidx/appcompat/app/AlertDialog;)V

    invoke-virtual {v0, v1}, Lorg/jdeferred/android/AndroidDeferredManager;->when(Ljava/lang/Runnable;)Lorg/jdeferred/Promise;

    move-result-object v0

    new-instance v1, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda15;

    invoke-direct {v1, p2}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda15;-><init>(Ljava/lang/String;)V

    .line 342
    invoke-interface {v0, v1}, Lorg/jdeferred/Promise;->done(Lorg/jdeferred/DoneCallback;)Lorg/jdeferred/Promise;

    .line 345
    return-void
.end method

.method public launchSplash(Ljava/lang/String;)V
    .locals 8
    .param p1, "pkg"    # Ljava/lang/String;

    .line 349
    :try_start_0
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getLayoutInflater()Landroid/view/LayoutInflater;

    move-result-object v0

    sget v1, Lcom/pubgm/R$layout;->launcher:I

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v0

    .line 350
    .local v0, "view":Landroid/view/View;
    sget v1, Lcom/pubgm/R$id;->cv_lauch:I

    invoke-virtual {v0, v1}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroidx/cardview/widget/CardView;

    .line 351
    .local v1, "cv":Landroidx/cardview/widget/CardView;
    sget v2, Lcom/pubgm/R$id;->start_client:I

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/TextView;

    .line 352
    .local v2, "txt":Landroid/widget/TextView;
    sget v3, Lcom/pubgm/R$id;->animationRobott:I

    invoke-virtual {v0, v3}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Lcom/airbnb/lottie/LottieAnimationView;

    .line 354
    .local v3, "lottie":Lcom/airbnb/lottie/LottieAnimationView;
    new-instance v4, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    invoke-direct {v4, p0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;-><init>(Landroid/content/Context;)V

    .line 355
    .local v4, "builder":Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;
    const/4 v5, 0x0

    invoke-virtual {v4, v5}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setCancelable(Z)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v5

    .line 356
    invoke-virtual {v5, v0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setView(Landroid/view/View;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v5

    .line 357
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getResources()Landroid/content/res/Resources;

    move-result-object v6

    sget v7, Lcom/pubgm/R$drawable;->background_trans:I

    invoke-virtual {v6, v7}, Landroid/content/res/Resources;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v6

    invoke-virtual {v5, v6}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setBackground(Landroid/graphics/drawable/Drawable;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    .line 359
    invoke-virtual {v4}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->create()Landroidx/appcompat/app/AlertDialog;

    move-result-object v5

    .line 360
    .local v5, "dialog":Landroidx/appcompat/app/AlertDialog;
    invoke-virtual {v5}, Landroidx/appcompat/app/AlertDialog;->show()V

    .line 362
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->defer()Lorg/jdeferred/android/AndroidDeferredManager;

    move-result-object v6

    new-instance v7, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda5;

    invoke-direct {v7, p0, v3, v2, p1}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda5;-><init>(Lcom/pubgm/utils/ActivityCompat;Lcom/airbnb/lottie/LottieAnimationView;Landroid/widget/TextView;Ljava/lang/String;)V

    invoke-virtual {v6, v7}, Lorg/jdeferred/android/AndroidDeferredManager;->when(Ljava/lang/Runnable;)Lorg/jdeferred/Promise;

    move-result-object v6

    new-instance v7, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda6;

    invoke-direct {v7, p0, v5, p1}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda6;-><init>(Lcom/pubgm/utils/ActivityCompat;Landroidx/appcompat/app/AlertDialog;Ljava/lang/String;)V

    .line 370
    invoke-interface {v6, v7}, Lorg/jdeferred/Promise;->done(Lorg/jdeferred/DoneCallback;)Lorg/jdeferred/Promise;

    move-result-object v6

    new-instance v7, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda7;

    invoke-direct {v7, v5}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda7;-><init>(Landroidx/appcompat/app/AlertDialog;)V

    invoke-interface {v6, v7}, Lorg/jdeferred/Promise;->fail(Lorg/jdeferred/FailCallback;)Lorg/jdeferred/Promise;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 374
    nop

    .end local v0    # "view":Landroid/view/View;
    .end local v1    # "cv":Landroidx/cardview/widget/CardView;
    .end local v2    # "txt":Landroid/widget/TextView;
    .end local v3    # "lottie":Lcom/airbnb/lottie/LottieAnimationView;
    .end local v4    # "builder":Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;
    .end local v5    # "dialog":Landroidx/appcompat/app/AlertDialog;
    goto :goto_0

    .line 372
    :catch_0
    move-exception v0

    .line 373
    .local v0, "err":Ljava/lang/Exception;
    invoke-virtual {v0}, Ljava/lang/Exception;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/pubgm/utils/FLog;->error(Ljava/lang/String;)V

    .line 375
    .end local v0    # "err":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public onBackPressed()V
    .locals 6

    .line 278
    iget-boolean v0, p0, Lcom/pubgm/utils/ActivityCompat;->isLogin:Z

    if-eqz v0, :cond_1

    .line 279
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    .line 280
    .local v0, "t":J
    iget-wide v2, p0, Lcom/pubgm/utils/ActivityCompat;->backPressedTime:J

    sub-long v2, v0, v2

    const-wide/16 v4, 0x7d0

    cmp-long v2, v2, v4

    if-lez v2, :cond_0

    .line 281
    iput-wide v0, p0, Lcom/pubgm/utils/ActivityCompat;->backPressedTime:J

    .line 282
    const-wide v2, -0x14757d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p0, v2}, Lcom/pubgm/utils/ActivityCompat;->toast(Ljava/lang/CharSequence;)V

    goto :goto_0

    .line 284
    :cond_0
    invoke-super {p0}, Landroidx/appcompat/app/AppCompatActivity;->onBackPressed()V

    .line 287
    .end local v0    # "t":J
    :cond_1
    :goto_0
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 1
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .line 88
    sput-object p0, Lcom/pubgm/utils/ActivityCompat;->activityCompat:Lcom/pubgm/utils/ActivityCompat;

    .line 89
    invoke-super {p0, p1}, Landroidx/appcompat/app/AppCompatActivity;->onCreate(Landroid/os/Bundle;)V

    .line 90
    new-instance v0, Lcom/pubgm/activity/CrashHandler;

    invoke-direct {v0, p0}, Lcom/pubgm/activity/CrashHandler;-><init>(Landroid/content/Context;)V

    invoke-static {v0}, Ljava/lang/Thread;->setDefaultUncaughtExceptionHandler(Ljava/lang/Thread$UncaughtExceptionHandler;)V

    .line 91
    sget v0, Lcom/pubgm/R$color;->background:I

    invoke-virtual {p0, v0}, Lcom/pubgm/utils/ActivityCompat;->setNavBar(I)V

    .line 93
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPref()Lcom/pubgm/utils/FPrefs;

    move-result-object v0

    iput-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->prefs:Lcom/pubgm/utils/FPrefs;

    .line 94
    invoke-static {}, Lcom/google/firebase/auth/FirebaseAuth;->getInstance()Lcom/google/firebase/auth/FirebaseAuth;

    move-result-object v0

    iput-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->currentAuth:Lcom/google/firebase/auth/FirebaseAuth;

    .line 96
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->ManageFiles()V

    .line 97
    return-void
.end method

.method public onWindowFocusChanged(Z)V
    .locals 0
    .param p1, "hasFocus"    # Z

    .line 291
    invoke-super {p0, p1}, Landroidx/appcompat/app/AppCompatActivity;->onWindowFocusChanged(Z)V

    .line 292
    if-eqz p1, :cond_0

    .line 293
    invoke-direct {p0}, Lcom/pubgm/utils/ActivityCompat;->hideSystemUI()V

    goto :goto_0

    .line 295
    :cond_0
    invoke-direct {p0}, Lcom/pubgm/utils/ActivityCompat;->showSystemUI()V

    .line 297
    :goto_0
    return-void
.end method

.method public restartApp(Ljava/lang/String;)V
    .locals 3
    .param p1, "clazz"    # Ljava/lang/String;

    .line 108
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPackageName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0

    .line 109
    .local v0, "lauchIntent":Landroid/content/Intent;
    const v1, 0x14008000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 110
    const-wide v1, -0x13457d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 111
    invoke-virtual {p0, v0}, Lcom/pubgm/utils/ActivityCompat;->startActivity(Landroid/content/Intent;)V

    .line 112
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Ljava/lang/Runtime;->exit(I)V

    .line 113
    return-void
.end method

.method public setCurrentLoaderVersion()V
    .locals 3

    .line 518
    invoke-static {}, Lcom/google/firebase/database/FirebaseDatabase;->getInstance()Lcom/google/firebase/database/FirebaseDatabase;

    move-result-object v0

    const-wide v1, -0x167f7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/FirebaseDatabase;->getReference(Ljava/lang/String;)Lcom/google/firebase/database/DatabaseReference;

    move-result-object v0

    new-instance v1, Lcom/pubgm/utils/ActivityCompat$4;

    invoke-direct {v1, p0}, Lcom/pubgm/utils/ActivityCompat$4;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/DatabaseReference;->addValueEventListener(Lcom/google/firebase/database/ValueEventListener;)Lcom/google/firebase/database/ValueEventListener;

    .line 554
    return-void
.end method

.method public setNavBar(I)V
    .locals 2
    .param p1, "color"    # I

    .line 100
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getWindow()Landroid/view/Window;

    move-result-object v0

    const/high16 v1, -0x80000000

    invoke-virtual {v0, v1}, Landroid/view/Window;->addFlags(I)V

    .line 101
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getWindow()Landroid/view/Window;

    move-result-object v0

    const/high16 v1, 0x4000000

    invoke-virtual {v0, v1}, Landroid/view/Window;->clearFlags(I)V

    .line 102
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    const/4 v1, 0x4

    invoke-virtual {v0, v1}, Landroid/view/View;->setSystemUiVisibility(I)V

    .line 103
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    const/16 v1, 0x2000

    invoke-virtual {v0, v1}, Landroid/view/View;->setSystemUiVisibility(I)V

    .line 104
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-static {p0, p1}, Landroidx/core/content/ContextCompat;->getColor(Landroid/content/Context;I)I

    move-result v1

    invoke-virtual {v0, v1}, Landroid/view/Window;->setStatusBarColor(I)V

    .line 105
    return-void
.end method

.method public showBottomSheetDialog(Landroid/graphics/drawable/Drawable;Ljava/lang/String;Ljava/lang/String;ZLandroid/view/View$OnClickListener;Landroid/view/View$OnClickListener;)V
    .locals 6
    .param p1, "icon"    # Landroid/graphics/drawable/Drawable;
    .param p2, "title"    # Ljava/lang/String;
    .param p3, "msg"    # Ljava/lang/String;
    .param p4, "cancelable"    # Z
    .param p5, "listener"    # Landroid/view/View$OnClickListener;
    .param p6, "listenerCancle"    # Landroid/view/View$OnClickListener;

    .line 563
    new-instance v0, Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    invoke-direct {v0, p0}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;-><init>(Landroid/content/Context;)V

    iput-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    .line 564
    invoke-virtual {v0, p4}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->setCancelable(Z)V

    .line 565
    iget-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    sget v1, Lcom/pubgm/R$layout;->bottom_sheet_dialog_layout:I

    invoke-virtual {v0, v1}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->setContentView(I)V

    .line 567
    iget-object v0, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    sget v1, Lcom/pubgm/R$id;->icon:I

    invoke-virtual {v0, v1}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/ImageView;

    .line 568
    .local v0, "img":Landroid/widget/ImageView;
    if-eqz p1, :cond_0

    .line 569
    invoke-virtual {v0, p1}, Landroid/widget/ImageView;->setImageDrawable(Landroid/graphics/drawable/Drawable;)V

    .line 571
    :cond_0
    iget-object v1, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    sget v2, Lcom/pubgm/R$id;->title:I

    invoke-virtual {v1, v2}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->findViewById(I)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/TextView;

    .line 572
    .local v1, "title_tv":Landroid/widget/TextView;
    invoke-virtual {v1, p2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 573
    iget-object v2, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    sget v3, Lcom/pubgm/R$id;->msg:I

    invoke-virtual {v2, v3}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/TextView;

    .line 574
    .local v2, "msg_tv":Landroid/widget/TextView;
    invoke-virtual {v2, p3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 576
    iget-object v3, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    sget v4, Lcom/pubgm/R$id;->btn:I

    invoke-virtual {v3, v4}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Lcom/google/android/material/button/MaterialButton;

    .line 577
    .local v3, "download":Lcom/google/android/material/button/MaterialButton;
    if-eqz p5, :cond_1

    .line 578
    invoke-virtual {v3, p5}, Lcom/google/android/material/button/MaterialButton;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 581
    :cond_1
    iget-object v4, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    sget v5, Lcom/pubgm/R$id;->btn_cancle:I

    invoke-virtual {v4, v5}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->findViewById(I)Landroid/view/View;

    move-result-object v4

    check-cast v4, Lcom/google/android/material/button/MaterialButton;

    .line 582
    .local v4, "cancle":Lcom/google/android/material/button/MaterialButton;
    if-eqz p6, :cond_2

    .line 583
    invoke-virtual {v4, p6}, Lcom/google/android/material/button/MaterialButton;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    goto :goto_0

    .line 585
    :cond_2
    const/16 v5, 0x8

    invoke-virtual {v4, v5}, Lcom/google/android/material/button/MaterialButton;->setVisibility(I)V

    .line 588
    :goto_0
    iget-object v5, p0, Lcom/pubgm/utils/ActivityCompat;->bottomSheetDialog:Lcom/google/android/material/bottomsheet/BottomSheetDialog;

    invoke-virtual {v5}, Lcom/google/android/material/bottomsheet/BottomSheetDialog;->show()V

    .line 589
    return-void
.end method

.method public takeFilePermissions()V
    .locals 3

    .line 163
    new-instance v0, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    invoke-direct {v0, p0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;-><init>(Landroid/content/Context;)V

    .line 164
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setCancelable(Z)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    sget v1, Lcom/pubgm/R$string;->file_access_title:I

    .line 165
    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setTitle(I)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    sget v1, Lcom/pubgm/R$string;->file_access_message:I

    .line 166
    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setMessage(I)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    sget v1, Lcom/pubgm/R$string;->grant_permission:I

    new-instance v2, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda10;

    invoke-direct {v2, p0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda10;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    .line 167
    invoke-virtual {v0, v1, v2}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    sget v1, Lcom/pubgm/R$string;->exit:I

    new-instance v2, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda11;

    invoke-direct {v2, p0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda11;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    .line 186
    invoke-virtual {v0, v1, v2}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    .line 192
    invoke-virtual {v0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->show()Landroidx/appcompat/app/AlertDialog;

    .line 193
    return-void
.end method

.method public toast(Ljava/lang/CharSequence;)V
    .locals 2
    .param p1, "msg"    # Ljava/lang/CharSequence;

    .line 116
    invoke-static {}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->make()Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    move-result-object v0

    .line 117
    .local v0, "_toast":Lcom/blankj/molihuan/utilcode/util/ToastUtils;
    const v1, 0x106000b

    invoke-virtual {v0, v1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setBgColor(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 118
    sget v1, Lcom/pubgm/R$mipmap;->icon:I

    invoke-virtual {v0, v1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setLeftIcon(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 120
    const v1, 0x106000c

    invoke-virtual {v0, v1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setTextColor(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 121
    invoke-virtual {v0}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setNotUseSystemToast()Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 123
    invoke-virtual {v0, p1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->show(Ljava/lang/CharSequence;)V

    .line 125
    return-void
.end method

.method public toastImage(ILjava/lang/CharSequence;)V
    .locals 2
    .param p1, "id"    # I
    .param p2, "msg"    # Ljava/lang/CharSequence;

    .line 128
    invoke-static {}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->make()Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    move-result-object v0

    .line 129
    .local v0, "_toast":Lcom/blankj/molihuan/utilcode/util/ToastUtils;
    const v1, 0x106000b

    invoke-virtual {v0, v1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setBgColor(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 130
    invoke-virtual {v0, p1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setLeftIcon(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 131
    const v1, 0x106000c

    invoke-virtual {v0, v1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setTextColor(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 132
    invoke-virtual {v0}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setNotUseSystemToast()Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 133
    invoke-virtual {v0, p2}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->show(Ljava/lang/CharSequence;)V

    .line 134
    return-void
.end method

.method public tryAskUpdateLoader()V
    .locals 9

    .line 412
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPref()Lcom/pubgm/utils/FPrefs;

    move-result-object v0

    const-wide v1, -0x14a77d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/pubgm/utils/FPrefs;->contains(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPref()Lcom/pubgm/utils/FPrefs;

    move-result-object v0

    const-wide v1, -0x14bc7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/pubgm/utils/FPrefs;->contains(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getPref()Lcom/pubgm/utils/FPrefs;

    move-result-object v0

    const-wide v1, -0x14d07d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/pubgm/utils/FPrefs;->contains(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 413
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    sget v1, Lcom/pubgm/R$drawable;->ic_new_update:I

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v3

    const-wide v0, -0x14e37d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v4

    const-wide v0, -0x14f37d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v5

    const/4 v6, 0x0

    new-instance v7, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda16;

    invoke-direct {v7, p0}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda16;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    const/4 v8, 0x0

    move-object v2, p0

    invoke-virtual/range {v2 .. v8}, Lcom/pubgm/utils/ActivityCompat;->showBottomSheetDialog(Landroid/graphics/drawable/Drawable;Ljava/lang/String;Ljava/lang/String;ZLandroid/view/View$OnClickListener;Landroid/view/View$OnClickListener;)V

    .line 419
    :cond_0
    return-void
.end method

.method public tryAskVersionLoader(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V
    .locals 14
    .param p1, "GameName"    # Ljava/lang/String;
    .param p2, "Name"    # Ljava/lang/String;
    .param p3, "Version"    # I
    .param p4, "Url"    # Ljava/lang/String;

    .line 429
    invoke-virtual {p0}, Lcom/pubgm/utils/ActivityCompat;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    sget v1, Lcom/pubgm/R$drawable;->ic_new_update:I

    invoke-virtual {v0, v1}, Landroid/content/res/Resources;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v3

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    move-object v1, p1

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-wide v4, -0x15527d7e0b5bL

    invoke-static {v4, v5}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    move/from16 v10, p3

    invoke-virtual {v0, v10}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-wide v4, -0x15667d7e0b5bL

    invoke-static {v4, v5}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-wide v4, -0x15697d7e0b5bL

    invoke-static {v4, v5}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v11

    const/4 v12, 0x0

    new-instance v13, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda13;

    move-object v4, v13

    move-object v5, p0

    move-object v6, p1

    move-object/from16 v7, p2

    move/from16 v8, p3

    move-object/from16 v9, p4

    invoke-direct/range {v4 .. v9}, Lcom/pubgm/utils/ActivityCompat$$ExternalSyntheticLambda13;-><init>(Lcom/pubgm/utils/ActivityCompat;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V

    const/4 v8, 0x0

    move-object v2, p0

    move-object v4, v0

    move-object v5, v11

    move v6, v12

    move-object v7, v13

    invoke-virtual/range {v2 .. v8}, Lcom/pubgm/utils/ActivityCompat;->showBottomSheetDialog(Landroid/graphics/drawable/Drawable;Ljava/lang/String;Ljava/lang/String;ZLandroid/view/View$OnClickListener;Landroid/view/View$OnClickListener;)V

    .line 434
    return-void
.end method

.method public tryUpdateLoader()V
    .locals 3

    .line 378
    invoke-static {}, Lcom/google/firebase/database/FirebaseDatabase;->getInstance()Lcom/google/firebase/database/FirebaseDatabase;

    move-result-object v0

    const-wide v1, -0x14a07d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/FirebaseDatabase;->getReference(Ljava/lang/String;)Lcom/google/firebase/database/DatabaseReference;

    move-result-object v0

    new-instance v1, Lcom/pubgm/utils/ActivityCompat$3;

    invoke-direct {v1, p0}, Lcom/pubgm/utils/ActivityCompat$3;-><init>(Lcom/pubgm/utils/ActivityCompat;)V

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/DatabaseReference;->addValueEventListener(Lcom/google/firebase/database/ValueEventListener;)Lcom/google/firebase/database/ValueEventListener;

    .line 403
    return-void
.end method
