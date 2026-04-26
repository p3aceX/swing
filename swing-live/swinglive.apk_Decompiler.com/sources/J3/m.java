package J3;

/* JADX INFO: loaded from: classes.dex */
public final class m extends n implements N3.c {
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
        ((N3.c) ((N3.d) aVarF)).d();
    }

    @Override // N3.c
    public final Object get(Object obj) {
        throw null;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        d();
        throw null;
    }
}
