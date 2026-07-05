.class public Lcom/pubgm/ifc/User;
.super Ljava/lang/Object;
.source "User.java"


# instance fields
.field private id:Ljava/lang/String;

.field private imageURL:Ljava/lang/String;

.field private userKey:Ljava/lang/String;

.field private username:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 19
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 21
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0
    .param p1, "id"    # Ljava/lang/String;
    .param p2, "username"    # Ljava/lang/String;
    .param p3, "userKey"    # Ljava/lang/String;
    .param p4, "imageURL"    # Ljava/lang/String;

    .line 12
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 13
    iput-object p1, p0, Lcom/pubgm/ifc/User;->id:Ljava/lang/String;

    .line 14
    iput-object p2, p0, Lcom/pubgm/ifc/User;->username:Ljava/lang/String;

    .line 15
    iput-object p3, p0, Lcom/pubgm/ifc/User;->userKey:Ljava/lang/String;

    .line 16
    iput-object p4, p0, Lcom/pubgm/ifc/User;->imageURL:Ljava/lang/String;

    .line 17
    return-void
.end method


# virtual methods
.method public getId()Ljava/lang/String;
    .locals 1

    .line 24
    iget-object v0, p0, Lcom/pubgm/ifc/User;->id:Ljava/lang/String;

    return-object v0
.end method

.method public getImageURL()Ljava/lang/String;
    .locals 1

    .line 48
    iget-object v0, p0, Lcom/pubgm/ifc/User;->imageURL:Ljava/lang/String;

    return-object v0
.end method

.method public getUserKey()Ljava/lang/String;
    .locals 1

    .line 40
    iget-object v0, p0, Lcom/pubgm/ifc/User;->userKey:Ljava/lang/String;

    return-object v0
.end method

.method public getUsername()Ljava/lang/String;
    .locals 1

    .line 32
    iget-object v0, p0, Lcom/pubgm/ifc/User;->username:Ljava/lang/String;

    return-object v0
.end method

.method public isPremium()Z
    .locals 1

    .line 56
    # PATCHED: Always return true for premium access
    const/4 v0, 0x1

    return v0
.end method

.method public setId(Ljava/lang/String;)V
    .locals 0
    .param p1, "id"    # Ljava/lang/String;

    .line 28
    iput-object p1, p0, Lcom/pubgm/ifc/User;->id:Ljava/lang/String;

    .line 29
    return-void
.end method

.method public setImageURL(Ljava/lang/String;)V
    .locals 0
    .param p1, "imageURL"    # Ljava/lang/String;

    .line 52
    iput-object p1, p0, Lcom/pubgm/ifc/User;->imageURL:Ljava/lang/String;

    .line 53
    return-void
.end method

.method public setUserKey(Ljava/lang/String;)V
    .locals 0
    .param p1, "userKey"    # Ljava/lang/String;

    .line 44
    iput-object p1, p0, Lcom/pubgm/ifc/User;->userKey:Ljava/lang/String;

    .line 45
    return-void
.end method

.method public setUsername(Ljava/lang/String;)V
    .locals 0
    .param p1, "username"    # Ljava/lang/String;

    .line 36
    iput-object p1, p0, Lcom/pubgm/ifc/User;->username:Ljava/lang/String;

    .line 37
    return-void
.end method
