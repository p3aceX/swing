package androidx.datastore.preferences.protobuf;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0204o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0203n f3008a = new C0203n();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0203n f3009b;

    static {
        C0203n c0203n;
        Q q4 = Q.f2927c;
        try {
            c0203n = (C0203n) Class.forName("androidx.datastore.preferences.protobuf.ExtensionSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            c0203n = null;
        }
        f3009b = c0203n;
    }
}
