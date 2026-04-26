package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public abstract class B {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final A f2894a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final A f2895b;

    static {
        A a5;
        Q q4 = Q.f2927c;
        try {
            a5 = (A) Class.forName("androidx.datastore.preferences.protobuf.ListFieldSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            a5 = null;
        }
        f2894a = a5;
        f2895b = new A();
    }
}
