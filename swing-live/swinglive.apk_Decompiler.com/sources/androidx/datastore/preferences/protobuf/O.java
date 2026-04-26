package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public abstract class O {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final N f2925a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final N f2926b;

    static {
        N n4;
        Q q4 = Q.f2927c;
        try {
            n4 = (N) Class.forName("androidx.datastore.preferences.protobuf.NewInstanceSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            n4 = null;
        }
        f2925a = n4;
        f2926b = new N();
    }
}
