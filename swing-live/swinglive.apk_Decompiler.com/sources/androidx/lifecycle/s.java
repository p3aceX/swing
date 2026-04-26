package androidx.lifecycle;

/* JADX INFO: loaded from: classes.dex */
public final class s extends t implements l {
    public final n e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ u f3084f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public s(u uVar, n nVar, v vVar) {
        super(uVar, vVar);
        this.f3084f = uVar;
        this.e = nVar;
    }

    @Override // androidx.lifecycle.l
    public final void a(n nVar, EnumC0221g enumC0221g) {
        n nVar2 = this.e;
        EnumC0222h enumC0222h = nVar2.i().f3077c;
        if (enumC0222h == EnumC0222h.f3067a) {
            this.f3084f.g(this.f3085a);
            return;
        }
        EnumC0222h enumC0222h2 = null;
        while (enumC0222h2 != enumC0222h) {
            b(e());
            enumC0222h2 = enumC0222h;
            enumC0222h = nVar2.i().f3077c;
        }
    }

    @Override // androidx.lifecycle.t
    public final void c() {
        this.e.i().b(this);
    }

    @Override // androidx.lifecycle.t
    public final boolean d(n nVar) {
        return this.e == nVar;
    }

    @Override // androidx.lifecycle.t
    public final boolean e() {
        return this.e.i().f3077c.compareTo(EnumC0222h.f3070d) >= 0;
    }
}
