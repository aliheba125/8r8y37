.class public Lcom/tcore/fake/service/ActivityManagerCommonProxy$StartActivity;
.super Lcom/tcore/fake/hook/MethodHook;
.source "SourceFile"


# annotations
.annotation runtime Lcom/tcore/fake/hook/ProxyMethod;
    value = "startActivity"
.end annotation

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/tcore/fake/service/ActivityManagerCommonProxy;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "StartActivity"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lcom/tcore/fake/hook/MethodHook;-><init>()V

    return-void
.end method

.method private extractIntent([Ljava/lang/Object;)Landroid/content/Intent;
    .locals 4

    invoke-static {}, Lcom/tcore/utils/compat/BuildCompat;->isR()Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x3

    goto :goto_0

    :cond_0
    const/4 v0, 0x2

    :goto_0
    aget-object v0, p1, v0

    instance-of v1, v0, Landroid/content/Intent;

    if-eqz v1, :cond_1

    check-cast v0, Landroid/content/Intent;

    return-object v0

    :cond_1
    array-length v0, p1

    const/4 v1, 0x0

    :goto_1
    if-ge v1, v0, :cond_3

    aget-object v2, p1, v1

    instance-of v3, v2, Landroid/content/Intent;

    if-eqz v3, :cond_2

    check-cast v2, Landroid/content/Intent;

    return-object v2

    :cond_2
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    :cond_3
    const/4 p1, 0x0

    return-object p1
.end method


# virtual methods
.method public hook(Ljava/lang/Object;Ljava/lang/reflect/Method;[Ljava/lang/Object;)Ljava/lang/Object;
    .locals 12

    invoke-static {p3}, Lcom/tcore/utils/MethodParameterUtils;->replaceFirstAppPkg([Ljava/lang/Object;)Ljava/lang/String;

    invoke-direct {p0, p3}, Lcom/tcore/fake/service/ActivityManagerCommonProxy$StartActivity;->extractIntent([Ljava/lang/Object;)Landroid/content/Intent;

    move-result-object v0

    const-string v3, "STARTACT"

    invoke-static {v3, v0}, Lcom/tcore/utils/DiagLog;->intent(Ljava/lang/String;Landroid/content/Intent;)V

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Hook in : "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v2, "ActivityManagerCommonProxy"

    invoke-static {v2, v1}, Lcom/tcore/utils/Slog;->d(Ljava/lang/String;Ljava/lang/String;)I

    invoke-virtual {v0}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v1

    const-string v2, "android.intent.action.VIEW"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-virtual {v0}, Landroid/content/Intent;->getDataString()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_0

    const-string v2, "http"

    invoke-virtual {v1, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "ALLOW_HTTP_VIEW_FALLTHROUGH"

    invoke-static {v1, v0}, Lcom/tcore/utils/DiagLog;->intent(Ljava/lang/String;Landroid/content/Intent;)V

    :cond_0
    const-string v1, "_B_|_target_"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->getParcelableExtra(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object v1

    if-eqz v1, :cond_1

    invoke-virtual {p2, p1, p3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    :cond_1
    invoke-static {v0}, Lcom/tcore/utils/ComponentUtils;->isRequestInstall(Landroid/content/Intent;)Z

    move-result v1

    const/4 v2, 0x0

    if-eqz v1, :cond_3

    invoke-static {}, Lcom/tcore/TCoreCore;->get()Lcom/tcore/TCoreCore;

    move-result-object v1

    invoke-static {}, Lcom/tcore/app/BActivityThread;->getApplication()Landroid/app/Application;

    move-result-object v3

    invoke-virtual {v0}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/tcore/fake/provider/FileProviderHandler;->convertFile(Landroid/content/Context;Landroid/net/Uri;)Ljava/io/File;

    move-result-object v3

    invoke-virtual {v1, v3}, Lcom/tcore/TCoreCore;->requestInstallPackage(Ljava/io/File;)Z

    move-result v1

    if-eqz v1, :cond_2

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    return-object p1

    :cond_2
    invoke-static {}, Lcom/tcore/app/BActivityThread;->getApplication()Landroid/app/Application;

    move-result-object v1

    invoke-virtual {v0}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/tcore/fake/provider/FileProviderHandler;->convertFileUri(Landroid/content/Context;Landroid/net/Uri;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    invoke-virtual {p2, p1, p3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    :cond_3
    invoke-virtual {v0}, Landroid/content/Intent;->getDataString()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_4

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "package:"

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-static {}, Lcom/tcore/app/BActivityThread;->getAppPackageName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_4

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-static {}, Lcom/tcore/TCoreCore;->getHostPkg()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    :cond_4
    invoke-static {}, Lcom/tcore/TCoreCore;->getBPackageManager()Lcom/tcore/fake/frameworks/BPackageManager;

    move-result-object v1

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getResolvedType([Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-static {}, Lcom/tcore/app/BActivityThread;->getUserId()I

    move-result v4

    const/16 v5, 0x80

    invoke-virtual {v1, v0, v5, v3, v4}, Lcom/tcore/fake/frameworks/BPackageManager;->resolveActivity(Landroid/content/Intent;ILjava/lang/String;I)Landroid/content/pm/ResolveInfo;

    move-result-object v1

    if-nez v1, :cond_7

    invoke-virtual {v0}, Landroid/content/Intent;->getPackage()Ljava/lang/String;

    move-result-object v1

    if-nez v1, :cond_5

    invoke-virtual {v0}, Landroid/content/Intent;->getComponent()Landroid/content/ComponentName;

    move-result-object v3

    if-nez v3, :cond_5

    invoke-static {}, Lcom/tcore/app/BActivityThread;->getAppPackageName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v3}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_0

    :cond_5
    invoke-virtual {v0}, Landroid/content/Intent;->getPackage()Ljava/lang/String;

    move-result-object v1

    :goto_0
    invoke-static {}, Lcom/tcore/TCoreCore;->getBPackageManager()Lcom/tcore/fake/frameworks/BPackageManager;

    move-result-object v3

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getResolvedType([Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-static {}, Lcom/tcore/app/BActivityThread;->getUserId()I

    move-result v6

    invoke-virtual {v3, v0, v5, v4, v6}, Lcom/tcore/fake/frameworks/BPackageManager;->resolveActivity(Landroid/content/Intent;ILjava/lang/String;I)Landroid/content/pm/ResolveInfo;

    move-result-object v3

    if-nez v3, :cond_6

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    invoke-virtual {p2, p1, p3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    :cond_6
    move-object v1, v3

    :cond_7
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object p1

    invoke-virtual {v0, p1}, Landroid/content/Intent;->setExtrasClassLoader(Ljava/lang/ClassLoader;)V

    iget-object p1, v1, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    new-instance p2, Landroid/content/ComponentName;

    iget-object v1, p1, Landroid/content/pm/ActivityInfo;->packageName:Ljava/lang/String;

    iget-object p1, p1, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    invoke-direct {p2, v1, p1}, Landroid/content/ComponentName;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v0, p2}, Landroid/content/Intent;->setComponent(Landroid/content/ComponentName;)Landroid/content/Intent;

    invoke-static {}, Lcom/tcore/TCoreCore;->getBActivityManager()Lcom/tcore/fake/frameworks/BActivityManager;

    move-result-object v3

    invoke-static {}, Lcom/tcore/app/BActivityThread;->getUserId()I

    move-result v4

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getIntent([Ljava/lang/Object;)Landroid/content/Intent;

    move-result-object v5

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getResolvedType([Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v6

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getResultTo([Ljava/lang/Object;)Landroid/os/IBinder;

    move-result-object v7

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getResultWho([Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v8

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getRequestCode([Ljava/lang/Object;)I

    move-result v9

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getFlags([Ljava/lang/Object;)I

    move-result v10

    invoke-static {p3}, Lcom/tcore/utils/compat/StartActivityCompat;->getOptions([Ljava/lang/Object;)Landroid/os/Bundle;

    move-result-object v11

    invoke-virtual/range {v3 .. v11}, Lcom/tcore/fake/frameworks/BActivityManager;->startActivityAms(ILandroid/content/Intent;Ljava/lang/String;Landroid/os/IBinder;Ljava/lang/String;IILandroid/os/Bundle;)I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    return-object p1
.end method
