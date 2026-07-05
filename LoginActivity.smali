.class public Lcom/pubgm/activity/LoginActivity;
.super Lcom/pubgm/utils/ActivityCompat;
.source "LoginActivity.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/pubgm/activity/LoginActivity$AESCrypt;
    }
.end annotation


# static fields
.field public static ID:Ljava/lang/String;

.field public static OWNER:Ljava/lang/String;

.field private static final PASS:Ljava/lang/String;

.field public static PASSKEY:Ljava/lang/String;

.field private static final USER:Ljava/lang/String;

.field public static USERKEY:Ljava/lang/String;

.field private static dialog:Landroid/app/AlertDialog;

.field public static heis:Z


# instance fields
.field private Login:Lcom/google/firebase/database/DatabaseReference;

.field private animationView:Lcom/airbnb/lottie/LottieAnimationView;

.field private btnSignIn:Landroidx/cardview/widget/CardView;

.field private decryptData:Ljava/lang/String;

.field private mAuth:Lcom/google/firebase/auth/FirebaseAuth;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    const-wide v0, -0x6de7d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/pubgm/activity/LoginActivity;->USER:Ljava/lang/String;

    const-wide v0, -0x6e37d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/pubgm/activity/LoginActivity;->PASS:Ljava/lang/String;

    .line 60
    const-wide v0, -0x6e87d7e0b5bL

    :try_start_0
    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/UnsatisfiedLinkError; {:try_start_0 .. :try_end_0} :catch_0

    .line 63
    goto :goto_0

    .line 61
    :catch_0
    move-exception v0

    .line 62
    .local v0, "w":Ljava/lang/UnsatisfiedLinkError;
    invoke-virtual {v0}, Ljava/lang/UnsatisfiedLinkError;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/pubgm/utils/FLog;->error(Ljava/lang/String;)V

    .line 70
    .end local v0    # "w":Ljava/lang/UnsatisfiedLinkError;
    :goto_0
    const/4 v0, 0x0

    sput-boolean v0, Lcom/pubgm/activity/LoginActivity;->heis:Z

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .line 56
    invoke-direct {p0}, Lcom/pubgm/utils/ActivityCompat;-><init>()V

    return-void
.end method

.method private native GetKey()Ljava/lang/String;
.end method

.method private InitView()V
    .locals 7

    .line 116
    move-object v0, p0

    .line 117
    .local v0, "m_Context":Landroid/content/Context;
    sget v1, Lcom/pubgm/R$id;->textUsername:I

    invoke-virtual {p0, v1}, Lcom/pubgm/activity/LoginActivity;->findViewById(I)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/EditText;

    .line 119
    .local v1, "textUsername":Landroid/widget/EditText;
    iget-object v2, p0, Lcom/pubgm/activity/LoginActivity;->prefs:Lcom/pubgm/utils/FPrefs;

    const-wide v3, -0x5017d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    const-wide v4, -0x5067d7e0b5bL

    invoke-static {v4, v5}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Lcom/pubgm/utils/FPrefs;->read(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 120
    .local v2, "savedUser":Ljava/lang/String;
    if-eqz v2, :cond_0

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_0

    .line 121
    invoke-virtual {v1, v2}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 124
    :cond_0
    invoke-direct {p0, v0}, Lcom/pubgm/activity/LoginActivity;->firebase(Landroid/content/Context;)V

    .line 126
    sget v3, Lcom/pubgm/R$id;->btnSignIn:I

    invoke-virtual {p0, v3}, Lcom/pubgm/activity/LoginActivity;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Landroidx/cardview/widget/CardView;

    iput-object v3, p0, Lcom/pubgm/activity/LoginActivity;->btnSignIn:Landroidx/cardview/widget/CardView;

    .line 127
    new-instance v4, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda0;

    invoke-direct {v4, p0, v1}, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda0;-><init>(Lcom/pubgm/activity/LoginActivity;Landroid/widget/EditText;)V

    invoke-virtual {v3, v4}, Landroidx/cardview/widget/CardView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 156
    sget v3, Lcom/pubgm/R$id;->img_paste:I

    invoke-virtual {p0, v3}, Lcom/pubgm/activity/LoginActivity;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Landroid/widget/ImageView;

    .line 157
    .local v3, "paste":Landroid/widget/ImageView;
    new-instance v4, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda1;

    invoke-direct {v4, p0, v1}, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda1;-><init>(Lcom/pubgm/activity/LoginActivity;Landroid/widget/EditText;)V

    invoke-virtual {v3, v4}, Landroid/widget/ImageView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 164
    sget v4, Lcom/pubgm/R$id;->GetKey:I

    invoke-virtual {p0, v4}, Lcom/pubgm/activity/LoginActivity;->findViewById(I)Landroid/view/View;

    move-result-object v4

    check-cast v4, Landroid/widget/TextView;

    .line 165
    .local v4, "getKey":Landroid/widget/TextView;
    new-instance v5, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda2;

    invoke-direct {v5, p0}, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda2;-><init>(Lcom/pubgm/activity/LoginActivity;)V

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 171
    sget v5, Lcom/pubgm/R$id;->bahasa:I

    invoke-virtual {p0, v5}, Lcom/pubgm/activity/LoginActivity;->findViewById(I)Landroid/view/View;

    move-result-object v5

    check-cast v5, Lcom/skydoves/powerspinner/PowerSpinnerView;

    .line 172
    .local v5, "powerSpinnerView":Lcom/skydoves/powerspinner/PowerSpinnerView;
    new-instance v6, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda3;

    invoke-direct {v6, p0}, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda3;-><init>(Lcom/pubgm/activity/LoginActivity;)V

    invoke-virtual {v5, v6}, Lcom/skydoves/powerspinner/PowerSpinnerView;->setOnSpinnerItemSelectedListener(Lcom/skydoves/powerspinner/OnSpinnerItemSelectedListener;)V

    .line 180
    return-void
.end method

.method static synthetic access$000(Lcom/pubgm/activity/LoginActivity;Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;Ljava/lang/String;Landroid/app/ProgressDialog;)V
    .locals 0
    .param p0, "x0"    # Lcom/pubgm/activity/LoginActivity;
    .param p1, "x1"    # Lcom/pubgm/activity/LoginActivity;
    .param p2, "x2"    # Ljava/lang/String;
    .param p3, "x3"    # Ljava/lang/String;
    .param p4, "x4"    # Landroid/app/ProgressDialog;

    .line 56
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/pubgm/activity/LoginActivity;->launchMain(Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;Ljava/lang/String;Landroid/app/ProgressDialog;)V

    return-void
.end method

.method static synthetic access$100(Lcom/pubgm/activity/LoginActivity;)Lcom/google/firebase/database/DatabaseReference;
    .locals 1
    .param p0, "x0"    # Lcom/pubgm/activity/LoginActivity;

    .line 56
    iget-object v0, p0, Lcom/pubgm/activity/LoginActivity;->Login:Lcom/google/firebase/database/DatabaseReference;

    return-object v0
.end method

.method static synthetic access$200(Lcom/pubgm/activity/LoginActivity;)Ljava/lang/String;
    .locals 1
    .param p0, "x0"    # Lcom/pubgm/activity/LoginActivity;

    .line 56
    invoke-direct {p0}, Lcom/pubgm/activity/LoginActivity;->getAppVersion()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$300(Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;)V
    .locals 0
    .param p0, "x0"    # Lcom/pubgm/activity/LoginActivity;
    .param p1, "x1"    # Ljava/lang/String;

    .line 56
    invoke-direct {p0, p1}, Lcom/pubgm/activity/LoginActivity;->gotoUrl(Ljava/lang/String;)V

    return-void
.end method

.method private firebase(Landroid/content/Context;)V
    .locals 3
    .param p1, "m_Context"    # Landroid/content/Context;

    .line 328
    invoke-static {}, Lcom/google/firebase/database/FirebaseDatabase;->getInstance()Lcom/google/firebase/database/FirebaseDatabase;

    move-result-object v0

    const-wide v1, -0x59e7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    .line 329
    invoke-virtual {p0, v1}, Lcom/pubgm/activity/LoginActivity;->SU(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/FirebaseDatabase;->getReference(Ljava/lang/String;)Lcom/google/firebase/database/DatabaseReference;

    move-result-object v0

    new-instance v1, Lcom/pubgm/activity/LoginActivity$2;

    invoke-direct {v1, p0, p1}, Lcom/pubgm/activity/LoginActivity$2;-><init>(Lcom/pubgm/activity/LoginActivity;Landroid/content/Context;)V

    .line 330
    invoke-virtual {v0, v1}, Lcom/google/firebase/database/DatabaseReference;->addListenerForSingleValueEvent(Lcom/google/firebase/database/ValueEventListener;)V

    .line 373
    return-void
.end method

.method private getAppVersion()Ljava/lang/String;
    .locals 3

    .line 377
    :try_start_0
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v0

    .line 378
    .local v0, "packageInfo":Landroid/content/pm/PackageInfo;
    iget-object v1, v0, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;
    :try_end_0
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_0 .. :try_end_0} :catch_0

    return-object v1

    .line 379
    .end local v0    # "packageInfo":Landroid/content/pm/PackageInfo;
    :catch_0
    move-exception v0

    .line 380
    .local v0, "e":Landroid/content/pm/PackageManager$NameNotFoundException;
    const-wide v1, -0x5b77d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method

.method public static goLogin(Landroid/content/Context;)V
    .locals 2
    .param p0, "context"    # Landroid/content/Context;

    .line 80
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lcom/pubgm/activity/LoginActivity;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 81
    .local v0, "i":Landroid/content/Intent;
    const v1, 0x10008000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 82
    invoke-virtual {p0, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 83
    return-void
.end method

.method private gotoUrl(Ljava/lang/String;)V
    .locals 3
    .param p1, "s"    # Ljava/lang/String;

    .line 403
    new-instance v0, Landroid/content/Intent;

    const-wide v1, -0x5d17d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v2

    invoke-direct {v0, v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    invoke-virtual {p0, v0}, Lcom/pubgm/activity/LoginActivity;->startActivity(Landroid/content/Intent;)V

    .line 404
    return-void
.end method

.method static synthetic lambda$onCreate$0(Lcom/google/firebase/auth/AuthResult;)V
    .locals 3
    .param p0, "r"    # Lcom/google/firebase/auth/AuthResult;

    .line 98
    const-wide v0, -0x6c87d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    const-wide v1, -0x6cd7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method static synthetic lambda$onCreate$1(Ljava/lang/Exception;)V
    .locals 4
    .param p0, "e"    # Ljava/lang/Exception;

    .line 99
    const-wide v0, -0x6b17d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v2, -0x6b67d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method static synthetic lambda$showD$8(Landroid/content/DialogInterface;I)V
    .locals 0
    .param p0, "d"    # Landroid/content/DialogInterface;
    .param p1, "w"    # I

    .line 415
    return-void
.end method

.method private launchMain(Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;Ljava/lang/String;Landroid/app/ProgressDialog;)V
    .locals 5
    .param p1, "m_Context"    # Lcom/pubgm/activity/LoginActivity;
    .param p2, "exp"    # Ljava/lang/String;
    .param p3, "ppp"    # Ljava/lang/String;
    .param p4, "progressDialog"    # Landroid/app/ProgressDialog;

    .line 308
    :try_start_0
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 309
    .local v0, "usageMap":Ljava/util/HashMap;, "Ljava/util/HashMap<Ljava/lang/String;Ljava/lang/Object;>;"
    const-wide v1, -0x5327d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/text/SimpleDateFormat;

    const-wide v3, -0x53c7d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    sget-object v4, Ljava/util/Locale;->ENGLISH:Ljava/util/Locale;

    invoke-direct {v2, v3, v4}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    .line 310
    invoke-static {}, Ljava/util/Calendar;->getInstance()Ljava/util/Calendar;

    move-result-object v3

    invoke-virtual {v3}, Ljava/util/Calendar;->getTime()Ljava/util/Date;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v2

    .line 309
    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 311
    const-wide v1, -0x54d7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v3, Landroid/os/Build;->MANUFACTURER:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-wide v3, -0x55a7d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    sget-object v3, Landroid/os/Build;->MODEL:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 312
    const-wide v1, -0x55c7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v3, -0x56c7d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    sget-object v3, Landroid/os/Build$VERSION;->RELEASE:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 313
    iget-object v1, p0, Lcom/pubgm/activity/LoginActivity;->Login:Lcom/google/firebase/database/DatabaseReference;

    invoke-virtual {v1, p3}, Lcom/google/firebase/database/DatabaseReference;->child(Ljava/lang/String;)Lcom/google/firebase/database/DatabaseReference;

    move-result-object v1

    invoke-virtual {v1, v0}, Lcom/google/firebase/database/DatabaseReference;->updateChildren(Ljava/util/Map;)Lcom/google/android/gms/tasks/Task;

    .line 315
    new-instance v1, Landroid/content/Intent;

    invoke-virtual {p1}, Lcom/pubgm/activity/LoginActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->Yellow()Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v3

    invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 316
    .local v1, "i":Landroid/content/Intent;
    const-wide v2, -0x5757d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    const-wide v3, -0x57a7d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 317
    const-wide v2, -0x5817d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 318
    invoke-virtual {p1, v1}, Lcom/pubgm/activity/LoginActivity;->startActivity(Landroid/content/Intent;)V

    .line 319
    const-wide v2, -0x5857d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p0, v2}, Lcom/pubgm/activity/LoginActivity;->SU(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {p1, v2}, Lcom/pubgm/activity/LoginActivity;->showMessage(Landroid/content/Context;Ljava/lang/String;)V

    .line 320
    const/4 v2, 0x0

    invoke-virtual {p1, v2}, Lcom/pubgm/activity/LoginActivity;->finishActivity(I)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 323
    .end local v0    # "usageMap":Ljava/util/HashMap;, "Ljava/util/HashMap<Ljava/lang/String;Ljava/lang/Object;>;"
    .end local v1    # "i":Landroid/content/Intent;
    goto :goto_0

    .line 321
    :catch_0
    move-exception v0

    .line 322
    .local v0, "e":Ljava/lang/Exception;
    invoke-virtual {v0}, Ljava/lang/Exception;->printStackTrace()V

    .line 324
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    invoke-virtual {p4}, Landroid/app/ProgressDialog;->dismiss()V

    .line 325
    return-void
.end method

.method private loadbahasa()V
    .locals 4

    .line 397
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getPackageName()Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Lcom/pubgm/activity/LoginActivity;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v0

    const-wide v1, -0x5c97d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    const-wide v2, -0x5d07d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    .line 398
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 399
    .local v0, "bahasa":Ljava/lang/String;
    invoke-direct {p0, v0}, Lcom/pubgm/activity/LoginActivity;->setLokasi(Ljava/lang/String;)V

    .line 400
    return-void
.end method

.method private setLokasi(Ljava/lang/String;)V
    .locals 4
    .param p1, "lang"    # Ljava/lang/String;

    .line 387
    new-instance v0, Ljava/util/Locale;

    const-wide v1, -0x5bf7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/util/Locale;-><init>(Ljava/lang/String;)V

    invoke-static {v0}, Ljava/util/Locale;->setDefault(Ljava/util/Locale;)V

    .line 388
    new-instance v0, Landroid/content/res/Configuration;

    invoke-direct {v0}, Landroid/content/res/Configuration;-><init>()V

    .line 389
    .local v0, "config":Landroid/content/res/Configuration;
    new-instance v1, Ljava/util/Locale;

    invoke-direct {v1, p1}, Ljava/util/Locale;-><init>(Ljava/lang/String;)V

    iput-object v1, v0, Landroid/content/res/Configuration;->locale:Ljava/util/Locale;

    .line 390
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getBaseContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    .line 391
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getBaseContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v2

    .line 390
    invoke-virtual {v1, v0, v2}, Landroid/content/res/Resources;->updateConfiguration(Landroid/content/res/Configuration;Landroid/util/DisplayMetrics;)V

    .line 392
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {p0, v1, v2}, Lcom/pubgm/activity/LoginActivity;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v1

    .line 393
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v1

    const-wide v2, -0x5c27d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-interface {v1, v2, p1}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v1

    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 394
    return-void
.end method

.method public static showD(Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;)V
    .locals 3
    .param p0, "_context"    # Lcom/pubgm/activity/LoginActivity;
    .param p1, "_s"    # Ljava/lang/String;

    .line 411
    new-instance v0, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    invoke-direct {v0, p0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;-><init>(Landroid/content/Context;)V

    const-wide v1, -0x5ec7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    .line 412
    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setTitle(Ljava/lang/CharSequence;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    .line 413
    invoke-virtual {v0, p1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setMessage(Ljava/lang/CharSequence;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    .line 414
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setCancelable(Z)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    const-wide v1, -0x5f87d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda8;

    invoke-direct {v2}, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda8;-><init>()V

    .line 415
    invoke-virtual {v0, v1, v2}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;

    move-result-object v0

    .line 416
    invoke-virtual {v0}, Lcom/google/android/material/dialog/MaterialAlertDialogBuilder;->show()Landroidx/appcompat/app/AlertDialog;

    .line 417
    sget v0, Lcom/pubgm/R$drawable;->ic_error:I

    const-wide v1, -0x5fb7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v0, v1}, Lcom/pubgm/activity/LoginActivity;->toastImage(ILjava/lang/CharSequence;)V

    .line 418
    return-void
.end method

.method public static showMessage(Landroid/content/Context;Ljava/lang/String;)V
    .locals 1
    .param p0, "_context"    # Landroid/content/Context;
    .param p1, "_s"    # Ljava/lang/String;

    .line 407
    const/4 v0, 0x0

    invoke-static {p0, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 408
    return-void
.end method


# virtual methods
.method public SU(Ljava/lang/String;)Ljava/lang/String;
    .locals 3
    .param p1, "_data"    # Ljava/lang/String;

    .line 529
    :try_start_0
    invoke-static {p1}, Lcom/pubgm/activity/LoginActivity$AESCrypt;->decrypt(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/pubgm/activity/LoginActivity;->decryptData:Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 532
    goto :goto_0

    .line 530
    :catch_0
    move-exception v0

    .line 531
    .local v0, "e":Ljava/lang/Exception;
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/pubgm/activity/LoginActivity;->showMessage(Landroid/content/Context;Ljava/lang/String;)V

    .line 533
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    iget-object v0, p0, Lcom/pubgm/activity/LoginActivity;->decryptData:Ljava/lang/String;

    return-object v0
.end method

.method public native Yellow()Ljava/lang/String;
.end method

.method public firebaseGet(Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;)V
    .locals 4
    .param p1, "m_Context"    # Lcom/pubgm/activity/LoginActivity;
    .param p2, "userKey"    # Ljava/lang/String;

    .line 183
    new-instance v0, Ljava/util/Locale;

    const-wide v1, -0x5077d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/util/Locale;-><init>(Ljava/lang/String;)V

    invoke-static {v0}, Ljava/util/Locale;->setDefault(Ljava/util/Locale;)V

    .line 184
    iget-object v0, p0, Lcom/pubgm/activity/LoginActivity;->Login:Lcom/google/firebase/database/DatabaseReference;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/DatabaseReference;->keepSynced(Z)V

    .line 186
    new-instance v0, Landroid/app/ProgressDialog;

    const/4 v1, 0x5

    invoke-direct {v0, p1, v1}, Landroid/app/ProgressDialog;-><init>(Landroid/content/Context;I)V

    .line 187
    .local v0, "progressDialog":Landroid/app/ProgressDialog;
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setProgressStyle(I)V

    .line 188
    const-wide v2, -0x50a7d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Landroid/app/ProgressDialog;->setMessage(Ljava/lang/CharSequence;)V

    .line 189
    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    .line 190
    invoke-virtual {v0}, Landroid/app/ProgressDialog;->show()V

    .line 192
    invoke-static {}, Lcom/google/firebase/database/FirebaseDatabase;->getInstance()Lcom/google/firebase/database/FirebaseDatabase;

    move-result-object v1

    const-wide v2, -0x5197d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    .line 193
    invoke-virtual {p0, v2}, Lcom/pubgm/activity/LoginActivity;->SU(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/google/firebase/database/FirebaseDatabase;->getReference(Ljava/lang/String;)Lcom/google/firebase/database/DatabaseReference;

    move-result-object v1

    new-instance v2, Lcom/pubgm/activity/LoginActivity$1;

    invoke-direct {v2, p0, p2, p1, v0}, Lcom/pubgm/activity/LoginActivity$1;-><init>(Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;Lcom/pubgm/activity/LoginActivity;Landroid/app/ProgressDialog;)V

    .line 194
    invoke-virtual {v1, v2}, Lcom/google/firebase/database/DatabaseReference;->addListenerForSingleValueEvent(Lcom/google/firebase/database/ValueEventListener;)V

    .line 303
    return-void
.end method

.method synthetic lambda$InitView$2$com-pubgm-activity-LoginActivity(Ljava/lang/String;Lcom/google/firebase/auth/AuthResult;)V
    .locals 4
    .param p1, "userKey"    # Ljava/lang/String;
    .param p2, "authResult"    # Lcom/google/firebase/auth/AuthResult;

    .line 145
    const-wide v0, -0x6817d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v2, -0x6867d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-interface {p2}, Lcom/google/firebase/auth/AuthResult;->getUser()Lcom/google/firebase/auth/FirebaseUser;

    move-result-object v2

    invoke-virtual {v2}, Lcom/google/firebase/auth/FirebaseUser;->getUid()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 146
    invoke-static {}, Lcom/google/firebase/database/FirebaseDatabase;->getInstance()Lcom/google/firebase/database/FirebaseDatabase;

    move-result-object v0

    const-wide v1, -0x6987d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/pubgm/activity/LoginActivity;->SU(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/FirebaseDatabase;->getReference(Ljava/lang/String;)Lcom/google/firebase/database/DatabaseReference;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/DatabaseReference;->keepSynced(Z)V

    .line 147
    invoke-virtual {p0, p0, p1}, Lcom/pubgm/activity/LoginActivity;->firebaseGet(Lcom/pubgm/activity/LoginActivity;Ljava/lang/String;)V

    .line 148
    return-void
.end method

.method synthetic lambda$InitView$3$com-pubgm-activity-LoginActivity(Ljava/lang/Exception;)V
    .locals 4
    .param p1, "e"    # Ljava/lang/Exception;

    .line 150
    const-wide v0, -0x6587d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v2, -0x65d7d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 151
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v1, -0x66e7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Lcom/pubgm/activity/LoginActivity;->showMessage(Landroid/content/Context;Ljava/lang/String;)V

    .line 152
    return-void
.end method

.method synthetic lambda$InitView$4$com-pubgm-activity-LoginActivity(Landroid/widget/EditText;Landroid/view/View;)V
    .locals 5
    .param p1, "textUsername"    # Landroid/widget/EditText;
    .param p2, "v"    # Landroid/view/View;

    .line 128
    invoke-virtual {p1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    .line 130
    .local v0, "userKey":Ljava/lang/String;
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 131
    sget v1, Lcom/pubgm/R$string;->please_enter_username:I

    invoke-virtual {p0, v1}, Lcom/pubgm/activity/LoginActivity;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1}, Landroid/widget/EditText;->setError(Ljava/lang/CharSequence;)V

    .line 132
    return-void

    .line 135
    :cond_0
    iget-object v1, p0, Lcom/pubgm/activity/LoginActivity;->prefs:Lcom/pubgm/utils/FPrefs;

    const-wide v2, -0x63a7d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/pubgm/utils/FPrefs;->write(Ljava/lang/String;Ljava/lang/String;)V

    .line 136
    sput-object v0, Lcom/pubgm/activity/LoginActivity;->USERKEY:Ljava/lang/String;

    .line 138
    # PATCHED: Skip Firebase, launch MainActivity with BYPASS extra
    new-instance v1, Landroid/content/Intent;

    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v2

    const-class v3, Lcom/pubgm/activity/MainActivity;

    invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    const-string v2, "Wolf"

    const-string v3, "BYPASS"

    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    const-string v2, "EXP"

    const-string v3, "2030-12-31"

    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    const v2, 0x10008000

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    invoke-virtual {p0, v1}, Lcom/pubgm/activity/LoginActivity;->startActivity(Landroid/content/Intent;)V

    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->finish()V

    return-void
.end method

.method synthetic lambda$InitView$5$com-pubgm-activity-LoginActivity(Landroid/widget/EditText;Landroid/view/View;)V
    .locals 2
    .param p1, "textUsername"    # Landroid/widget/EditText;
    .param p2, "view"    # Landroid/view/View;

    .line 158
    const-wide v0, -0x6307d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/pubgm/activity/LoginActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/ClipboardManager;

    .line 159
    .local v0, "clipboard":Landroid/content/ClipboardManager;
    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/content/ClipboardManager;->getText()Ljava/lang/CharSequence;

    move-result-object v1

    if-eqz v1, :cond_0

    .line 160
    invoke-virtual {v0}, Landroid/content/ClipboardManager;->getText()Ljava/lang/CharSequence;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 162
    :cond_0
    return-void
.end method

.method synthetic lambda$InitView$6$com-pubgm-activity-LoginActivity(Landroid/view/View;)V
    .locals 3
    .param p1, "view"    # Landroid/view/View;

    .line 166
    new-instance v0, Landroid/content/Intent;

    const-wide v1, -0x6157d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 167
    .local v0, "intent":Landroid/content/Intent;
    invoke-direct {p0}, Lcom/pubgm/activity/LoginActivity;->GetKey()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 168
    invoke-virtual {p0, v0}, Lcom/pubgm/activity/LoginActivity;->startActivity(Landroid/content/Intent;)V

    .line 169
    return-void
.end method

.method synthetic lambda$InitView$7$com-pubgm-activity-LoginActivity(ILjava/lang/String;ILjava/lang/String;)V
    .locals 5
    .param p1, "oldIndex"    # I
    .param p2, "oldItem"    # Ljava/lang/String;
    .param p3, "newIndex"    # I
    .param p4, "newItem"    # Ljava/lang/String;

    .line 174
    if-nez p3, :cond_0

    const-wide v0, -0x6087d7e0b5bL

    goto :goto_0

    :cond_0
    const-wide v0, -0x60b7d7e0b5bL

    :goto_0
    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    .line 175
    .local v0, "lang":Ljava/lang/String;
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {p0, v1, v2}, Lcom/pubgm/activity/LoginActivity;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v1

    .line 176
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v1

    const-wide v3, -0x60e7d7e0b5bL

    invoke-static {v3, v4}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v3

    invoke-interface {v1, v3, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v1

    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 177
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-static {v1, p4, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v1

    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    .line 178
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->recreate()V

    .line 179
    return-void
.end method

.method protected onActivityResult(IILandroid/content/Intent;)V
    .locals 1
    .param p1, "requestCode"    # I
    .param p2, "resultCode"    # I
    .param p3, "data"    # Landroid/content/Intent;

    .line 434
    invoke-super {p0, p1, p2, p3}, Lcom/pubgm/utils/ActivityCompat;->onActivityResult(IILandroid/content/Intent;)V

    .line 435
    sget v0, Lcom/pubgm/activity/LoginActivity;->REQUEST_OVERLAY_PERMISSION:I

    if-ne p1, v0, :cond_0

    .line 436
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->InstllUnknownApp()V

    goto :goto_0

    .line 437
    :cond_0
    sget v0, Lcom/pubgm/activity/LoginActivity;->REQUEST_MANAGE_UNKNOWN_APP_SOURCES:I

    if-ne p1, v0, :cond_1

    .line 438
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->isPermissionGaranted()Z

    move-result v0

    if-nez v0, :cond_1

    .line 439
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->takeFilePermissions()V

    .line 442
    :cond_1
    :goto_0
    return-void
.end method

.method public onBackPressed()V
    .locals 0

    .line 421
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 4
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .line 87
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/pubgm/activity/LoginActivity;->isLogin:Z

    .line 88
    invoke-super {p0, p1}, Lcom/pubgm/utils/ActivityCompat;->onCreate(Landroid/os/Bundle;)V

    .line 89
    sget v0, Lcom/pubgm/R$layout;->activity_login:I

    invoke-virtual {p0, v0}, Lcom/pubgm/activity/LoginActivity;->setContentView(I)V

    .line 91
    invoke-static {p0}, Lcom/google/firebase/FirebaseApp;->initializeApp(Landroid/content/Context;)Lcom/google/firebase/FirebaseApp;

    .line 92
    invoke-static {}, Lcom/google/firebase/auth/FirebaseAuth;->getInstance()Lcom/google/firebase/auth/FirebaseAuth;

    move-result-object v0

    iput-object v0, p0, Lcom/pubgm/activity/LoginActivity;->mAuth:Lcom/google/firebase/auth/FirebaseAuth;

    .line 95
    invoke-virtual {v0}, Lcom/google/firebase/auth/FirebaseAuth;->getCurrentUser()Lcom/google/firebase/auth/FirebaseUser;

    move-result-object v0

    .line 96
    .local v0, "currentUser":Lcom/google/firebase/auth/FirebaseUser;
    if-nez v0, :cond_0

    .line 97
    iget-object v1, p0, Lcom/pubgm/activity/LoginActivity;->mAuth:Lcom/google/firebase/auth/FirebaseAuth;

    invoke-virtual {v1}, Lcom/google/firebase/auth/FirebaseAuth;->signInAnonymously()Lcom/google/android/gms/tasks/Task;

    move-result-object v1

    new-instance v2, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda4;

    invoke-direct {v2}, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda4;-><init>()V

    .line 98
    invoke-virtual {v1, v2}, Lcom/google/android/gms/tasks/Task;->addOnSuccessListener(Lcom/google/android/gms/tasks/OnSuccessListener;)Lcom/google/android/gms/tasks/Task;

    move-result-object v1

    new-instance v2, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda5;

    invoke-direct {v2}, Lcom/pubgm/activity/LoginActivity$$ExternalSyntheticLambda5;-><init>()V

    .line 99
    invoke-virtual {v1, v2}, Lcom/google/android/gms/tasks/Task;->addOnFailureListener(Lcom/google/android/gms/tasks/OnFailureListener;)Lcom/google/android/gms/tasks/Task;

    .line 102
    :cond_0
    invoke-static {}, Lcom/google/firebase/database/FirebaseDatabase;->getInstance()Lcom/google/firebase/database/FirebaseDatabase;

    move-result-object v1

    const-wide v2, -0x4d17d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    .line 103
    invoke-virtual {p0, v2}, Lcom/pubgm/activity/LoginActivity;->SU(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/google/firebase/database/FirebaseDatabase;->getReference(Ljava/lang/String;)Lcom/google/firebase/database/DatabaseReference;

    move-result-object v1

    iput-object v1, p0, Lcom/pubgm/activity/LoginActivity;->Login:Lcom/google/firebase/database/DatabaseReference;

    .line 105
    nop

    .line 106
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-wide v2, -0x4ea7d7e0b5bL

    invoke-static {v2, v3}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v2

    .line 105
    invoke-static {v1, v2}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    sput-object v1, Lcom/pubgm/activity/LoginActivity;->ID:Ljava/lang/String;

    .line 109
    const-wide v1, -0x4f57d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    sput-object v1, Lcom/pubgm/activity/LoginActivity;->OWNER:Ljava/lang/String;

    .line 111
    invoke-direct {p0}, Lcom/pubgm/activity/LoginActivity;->InitView()V

    .line 112
    invoke-direct {p0}, Lcom/pubgm/activity/LoginActivity;->loadbahasa()V

    .line 113
    return-void
.end method

.method public onRequestPermissionsResult(I[Ljava/lang/String;[I)V
    .locals 1
    .param p1, "requestCode"    # I
    .param p2, "permissions"    # [Ljava/lang/String;
    .param p3, "grantResults"    # [I

    .line 426
    invoke-super {p0, p1, p2, p3}, Lcom/pubgm/utils/ActivityCompat;->onRequestPermissionsResult(I[Ljava/lang/String;[I)V

    .line 427
    sget v0, Lcom/pubgm/activity/LoginActivity;->PERMISSION_REQUEST_STORAGE:I

    if-ne p1, v0, :cond_0

    .line 428
    invoke-virtual {p0}, Lcom/pubgm/activity/LoginActivity;->OverlayPermision()V

    .line 430
    :cond_0
    return-void
.end method
