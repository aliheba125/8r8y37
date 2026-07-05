.class public Lcom/pubgm/BoxApplication;
.super Landroid/app/Application;
.source "BoxApplication.java"


# static fields
.field public static final STATUS_BY:Ljava/lang/String;

.field public static gApp:Lcom/pubgm/BoxApplication;


# instance fields
.field private isNetworkConnected:Z


# direct methods
.method static constructor <clinit>()V
    .locals 2

    const-wide v0, -0xd967d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/pubgm/BoxApplication;->STATUS_BY:Ljava/lang/String;

    .line 47
    const-wide v0, -0xd9d7d7e0b5bL

    :try_start_0
    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/UnsatisfiedLinkError; {:try_start_0 .. :try_end_0} :catch_0

    .line 50
    goto :goto_0

    .line 48
    :catch_0
    move-exception v0

    .line 49
    .local v0, "w":Ljava/lang/UnsatisfiedLinkError;
    invoke-virtual {v0}, Ljava/lang/UnsatisfiedLinkError;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/pubgm/utils/FLog;->error(Ljava/lang/String;)V

    .line 51
    .end local v0    # "w":Ljava/lang/UnsatisfiedLinkError;
    :goto_0
    return-void
.end method

.method public constructor <init>()V
    .locals 1

    .line 27
    invoke-direct {p0}, Landroid/app/Application;-><init>()V

    .line 30
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/pubgm/BoxApplication;->isNetworkConnected:Z

    return-void
.end method

.method private native BoxApp()Ljava/lang/String;
.end method

.method public static get()Lcom/pubgm/BoxApplication;
    .locals 1

    .line 34
    sget-object v0, Lcom/pubgm/BoxApplication;->gApp:Lcom/pubgm/BoxApplication;

    return-object v0
.end method


# virtual methods
.method protected attachBaseContext(Landroid/content/Context;)V
    .locals 1
    .param p1, "base"    # Landroid/content/Context;

    .line 55
    invoke-super {p0, p1}, Landroid/app/Application;->attachBaseContext(Landroid/content/Context;)V

    .line 56
    invoke-static {p1}, Landroidx/multidex/MultiDex;->install(Landroid/content/Context;)V

    .line 58
    new-instance v0, Lcom/pubgm/BoxApplication$1;

    invoke-direct {v0, p0, p1}, Lcom/pubgm/BoxApplication$1;-><init>(Lcom/pubgm/BoxApplication;Landroid/content/Context;)V

    .line 82
    .local v0, "clientConfiguration":Lcom/tcore/app/configuration/ClientConfiguration;
    invoke-static {p1, v0}, Lcom/pubgm/compat/TCoreCompat;->safeAttachBaseContext(Landroid/content/Context;Lcom/tcore/app/configuration/ClientConfiguration;)V

    .line 83
    return-void
.end method

.method public checkRootAccess()Z
    .locals 2

    .line 117
    invoke-static {}, Lcom/topjohnwu/superuser/Shell;->rootAccess()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 118
    const-wide v0, -0xd677d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    .line 119
    const/4 v0, 0x1

    return v0

    .line 121
    :cond_0
    const-wide v0, -0xd747d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    .line 122
    const/4 v0, 0x0

    return v0
.end method

.method public doChmod(Ljava/lang/String;I)V
    .locals 3
    .param p1, "shell"    # Ljava/lang/String;
    .param p2, "mask"    # I

    .line 145
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v1, -0xd8d7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-wide v1, -0xd947d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/pubgm/BoxApplication;->doExe(Ljava/lang/String;)V

    .line 146
    return-void
.end method

.method public doExe(Ljava/lang/String;)V
    .locals 3
    .param p1, "shell"    # Ljava/lang/String;

    .line 127
    # NEUTRALIZED: Prevent destructive shell commands
    return-void

    invoke-virtual {p0}, Lcom/pubgm/BoxApplication;->checkRootAccess()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 128
    const/4 v0, 0x1

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    aput-object p1, v0, v1

    invoke-static {v0}, Lcom/topjohnwu/superuser/Shell;->su([Ljava/lang/String;)Lcom/topjohnwu/superuser/Shell$Job;

    move-result-object v0

    invoke-virtual {v0}, Lcom/topjohnwu/superuser/Shell$Job;->exec()Lcom/topjohnwu/superuser/Shell$Result;

    goto :goto_0

    .line 131
    :cond_0
    :try_start_0
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/Runtime;->exec(Ljava/lang/String;)Ljava/lang/Process;

    .line 132
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v1, -0xd857d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 135
    goto :goto_0

    .line 133
    :catch_0
    move-exception v0

    .line 134
    .local v0, "e":Ljava/io/IOException;
    invoke-virtual {v0}, Ljava/io/IOException;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/pubgm/utils/FLog;->error(Ljava/lang/String;)V

    .line 137
    .end local v0    # "e":Ljava/io/IOException;
    :goto_0
    return-void
.end method

.method public doExecute(Ljava/lang/String;)V
    .locals 1
    .param p1, "shell"    # Ljava/lang/String;

    .line 140
    const/16 v0, 0x309

    invoke-virtual {p0, p1, v0}, Lcom/pubgm/BoxApplication;->doChmod(Ljava/lang/String;I)V

    .line 141
    invoke-virtual {p0, p1}, Lcom/pubgm/BoxApplication;->doExe(Ljava/lang/String;)V

    .line 142
    return-void
.end method

.method public isInternetAvailable()Z
    .locals 1

    .line 38
    iget-boolean v0, p0, Lcom/pubgm/BoxApplication;->isNetworkConnected:Z

    return v0
.end method

.method public onCreate()V
    .locals 3

    .line 86
    invoke-super {p0}, Landroid/app/Application;->onCreate()V

    .line 87
    sput-object p0, Lcom/pubgm/BoxApplication;->gApp:Lcom/pubgm/BoxApplication;

    .line 88
    invoke-static {}, Lcom/google/firebase/database/FirebaseDatabase;->getInstance()Lcom/google/firebase/database/FirebaseDatabase;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/google/firebase/database/FirebaseDatabase;->setPersistenceEnabled(Z)V

    .line 89
    invoke-static {}, Lcom/pubgm/compat/TCoreCompat;->safeDoCreate()V

    .line 92
    invoke-static {p0}, Lcom/google/android/material/color/DynamicColors;->applyToActivitiesIfAvailable(Landroid/app/Application;)V

    .line 93
    const/4 v0, 0x2

    invoke-static {v0}, Landroidx/appcompat/app/AppCompatDelegate;->setDefaultNightMode(I)V

    .line 94
    invoke-virtual {p0}, Lcom/pubgm/BoxApplication;->setCrashHandler()V

    .line 96
    invoke-static {}, Lcom/pubgm/utils/BuildCompat;->isA11below()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 97
    const-wide v0, -0xd2d7d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    goto :goto_0

    .line 99
    :cond_0
    const-wide v0, -0xd3e7d7e0b5bL

    invoke-static {v0, v1}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    .line 101
    :goto_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v1, -0xd4f7d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    .line 102
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-wide v1, -0xd597d7e0b5bL

    invoke-static {v1, v2}, Lorg/lsposed/lsparanoid/Deobfuscator$M5LOADER$app;->getString(J)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-object v1, Landroid/os/Build$VERSION;->RELEASE:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/pubgm/utils/FLog;->info(Ljava/lang/String;)V

    .line 104
    new-instance v0, Lcom/pubgm/utils/NetworkConnection$CheckInternet;

    invoke-direct {v0, p0}, Lcom/pubgm/utils/NetworkConnection$CheckInternet;-><init>(Landroid/content/Context;)V

    .line 105
    .local v0, "network":Lcom/pubgm/utils/NetworkConnection$CheckInternet;
    invoke-virtual {v0}, Lcom/pubgm/utils/NetworkConnection$CheckInternet;->registerNetworkCallback()V

    .line 106
    return-void
.end method

.method public setCrashHandler()V
    .locals 1

    .line 113
    new-instance v0, Lcom/pubgm/activity/CrashHandler;

    invoke-direct {v0, p0}, Lcom/pubgm/activity/CrashHandler;-><init>(Landroid/content/Context;)V

    invoke-static {v0}, Ljava/lang/Thread;->setDefaultUncaughtExceptionHandler(Ljava/lang/Thread$UncaughtExceptionHandler;)V

    .line 114
    return-void
.end method

.method public setInternetAvailable(Z)V
    .locals 0
    .param p1, "b"    # Z

    .line 42
    iput-boolean p1, p0, Lcom/pubgm/BoxApplication;->isNetworkConnected:Z

    .line 43
    return-void
.end method

.method public showToastWithImage(ILjava/lang/CharSequence;)V
    .locals 2
    .param p1, "id"    # I
    .param p2, "msg"    # Ljava/lang/CharSequence;

    .line 153
    invoke-static {}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->make()Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    move-result-object v0

    .line 154
    .local v0, "_toast":Lcom/blankj/molihuan/utilcode/util/ToastUtils;
    const v1, 0x106000b

    invoke-virtual {v0, v1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setBgColor(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 155
    invoke-virtual {v0, p1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setLeftIcon(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 156
    const v1, 0x106000c

    invoke-virtual {v0, v1}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setTextColor(I)Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 157
    invoke-virtual {v0}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->setNotUseSystemToast()Lcom/blankj/molihuan/utilcode/util/ToastUtils;

    .line 158
    invoke-virtual {v0, p2}, Lcom/blankj/molihuan/utilcode/util/ToastUtils;->show(Ljava/lang/CharSequence;)V

    .line 159
    return-void
.end method

.method public toast(Ljava/lang/CharSequence;)V
    .locals 1
    .param p1, "msg"    # Ljava/lang/CharSequence;

    .line 149
    const/4 v0, 0x0

    invoke-static {p0, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 150
    return-void
.end method
