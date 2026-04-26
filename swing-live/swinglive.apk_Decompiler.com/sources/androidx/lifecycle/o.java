package androidx.lifecycle;

/* JADX INFO: loaded from: classes.dex */
public final class o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public EnumC0222h f3073a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public l f3074b;

    public final void a(n nVar, EnumC0221g enumC0221g) {
        EnumC0222h enumC0222hA = enumC0221g.a();
        EnumC0222h enumC0222h = this.f3073a;
        J3.i.e(enumC0222h, "state1");
        if (enumC0222hA.compareTo(enumC0222h) < 0) {
            enumC0222h = enumC0222hA;
        }
        this.f3073a = enumC0222h;
        this.f3074b.a(nVar, enumC0221g);
        this.f3073a = enumC0222hA;
    }
}
