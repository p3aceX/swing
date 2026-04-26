package J3;

/* JADX INFO: loaded from: classes.dex */
public abstract class k extends n implements N3.c, N3.d {
    public k(String str, String str2) {
        super(b.f816a, n3.l.class, str, str2, 0);
    }

    @Override // J3.c
    public final N3.a c() {
        s.f833a.getClass();
        return this;
    }

    @Override // N3.c
    public final void d() {
        if (this.f828m) {
            throw new UnsupportedOperationException("Kotlin reflection is not yet supported for synthetic Java properties. Please follow/upvote https://youtrack.jetbrains.com/issue/KT-55980");
        }
        N3.a aVarF = f();
        if (aVarF == this) {
            throw new H3.a("Kotlin reflection implementation is not found at runtime. Make sure you have kotlin-reflect.jar in the classpath");
        }
        ((k) ((N3.d) aVarF)).d();
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        return get(obj);
    }
}
