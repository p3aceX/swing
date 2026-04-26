package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0313s implements O {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0313s f3835b = new C0313s(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3836a;

    public /* synthetic */ C0313s(int i4) {
        this.f3836a = i4;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.O
    public final boolean a(Class cls) {
        switch (this.f3836a) {
            case 0:
                return AbstractC0316v.class.isAssignableFrom(cls);
            default:
                return false;
        }
    }

    @Override // com.google.crypto.tink.shaded.protobuf.O
    public final b0 b(Class cls) {
        switch (this.f3836a) {
            case 0:
                if (!AbstractC0316v.class.isAssignableFrom(cls)) {
                    throw new IllegalArgumentException("Unsupported message type: ".concat(cls.getName()));
                }
                try {
                    return (b0) AbstractC0316v.j(cls.asSubclass(AbstractC0316v.class)).i(3);
                } catch (Exception e) {
                    throw new RuntimeException("Unable to get message info for ".concat(cls.getName()), e);
                }
            default:
                throw new IllegalStateException("This should never be called.");
        }
    }
}
