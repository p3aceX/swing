package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public abstract class I {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final H f2905a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final H f2906b;

    static {
        H h4;
        Q q4 = Q.f2927c;
        try {
            h4 = (H) Class.forName("androidx.datastore.preferences.protobuf.MapFieldSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            h4 = null;
        }
        f2905a = h4;
        f2906b = new H();
    }
}
