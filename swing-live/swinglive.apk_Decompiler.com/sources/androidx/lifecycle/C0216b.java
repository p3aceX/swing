package androidx.lifecycle;

/* JADX INFO: renamed from: androidx.lifecycle.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0216b implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final DefaultLifecycleObserver f3064a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final l f3065b;

    public C0216b(DefaultLifecycleObserver defaultLifecycleObserver, l lVar) {
        this.f3064a = defaultLifecycleObserver;
        this.f3065b = lVar;
    }

    @Override // androidx.lifecycle.l
    public final void a(n nVar, EnumC0221g enumC0221g) {
        if (AbstractC0215a.f3063a[enumC0221g.ordinal()] == 7) {
            throw new IllegalArgumentException("ON_ANY must not been send by anybody");
        }
        l lVar = this.f3065b;
        if (lVar != null) {
            lVar.a(nVar, enumC0221g);
        }
    }
}
