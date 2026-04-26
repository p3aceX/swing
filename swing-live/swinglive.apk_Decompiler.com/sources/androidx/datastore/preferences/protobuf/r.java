package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class r implements J {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final r f3031b = new r(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3032a;

    public /* synthetic */ r(int i4) {
        this.f3032a = i4;
    }

    @Override // androidx.datastore.preferences.protobuf.J
    public final boolean a(Class cls) {
        switch (this.f3032a) {
            case 0:
                return AbstractC0209u.class.isAssignableFrom(cls);
            default:
                return false;
        }
    }

    @Override // androidx.datastore.preferences.protobuf.J
    public final T b(Class cls) {
        switch (this.f3032a) {
            case 0:
                if (!AbstractC0209u.class.isAssignableFrom(cls)) {
                    throw new IllegalArgumentException("Unsupported message type: ".concat(cls.getName()));
                }
                try {
                    return (T) AbstractC0209u.d(cls.asSubclass(AbstractC0209u.class)).c(3);
                } catch (Exception e) {
                    throw new RuntimeException("Unable to get message info for ".concat(cls.getName()), e);
                }
            default:
                throw new IllegalStateException("This should never be called.");
        }
    }
}
