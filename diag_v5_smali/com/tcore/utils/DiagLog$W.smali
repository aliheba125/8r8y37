.class Lcom/tcore/utils/DiagLog$W;
.super Ljava/lang/Object;
.source "DiagLog.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/tcore/utils/DiagLog;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "W"
.end annotation


# direct methods
.method constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    :goto_0
    :try_start_0
    const-wide/16 v0, 0x7d0

    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V

    sget-boolean v0, Lcom/tcore/utils/DiagLog;->dirty:Z

    if-eqz v0, :goto_0

    const/4 v0, 0x0

    sput-boolean v0, Lcom/tcore/utils/DiagLog;->dirty:Z

    invoke-static {}, Lcom/tcore/utils/DiagLog;->flushNow()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    goto :goto_0
.end method
