package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class C implements J {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public J[] f2896a;

    @Override // androidx.datastore.preferences.protobuf.J
    public final boolean a(Class cls) {
        for (J j4 : this.f2896a) {
            if (j4.a(cls)) {
                return true;
            }
        }
        return false;
    }

    @Override // androidx.datastore.preferences.protobuf.J
    public final T b(Class cls) {
        for (J j4 : this.f2896a) {
            if (j4.a(cls)) {
                return j4.b(cls);
            }
        }
        throw new UnsupportedOperationException("No factory is available for message type: ".concat(cls.getName()));
    }
}
