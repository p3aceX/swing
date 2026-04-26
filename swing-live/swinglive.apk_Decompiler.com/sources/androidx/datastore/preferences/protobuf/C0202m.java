package androidx.datastore.preferences.protobuf;

import java.util.Collections;
import java.util.Map;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0202m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static volatile C0202m f3006a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0202m f3007b;

    static {
        C0202m c0202m = new C0202m();
        Map map = Collections.EMPTY_MAP;
        f3007b = c0202m;
    }

    public static C0202m a() {
        C0202m c0202m;
        Q q4 = Q.f2927c;
        C0202m c0202m2 = f3006a;
        if (c0202m2 != null) {
            return c0202m2;
        }
        synchronized (C0202m.class) {
            try {
                c0202m = f3006a;
                if (c0202m == null) {
                    Class cls = AbstractC0201l.f3005a;
                    C0202m c0202m3 = null;
                    if (cls != null) {
                        try {
                            c0202m3 = (C0202m) cls.getDeclaredMethod("getEmptyRegistry", new Class[0]).invoke(null, new Object[0]);
                        } catch (Exception unused) {
                        }
                    }
                    c0202m = c0202m3 != null ? c0202m3 : f3007b;
                    f3006a = c0202m;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return c0202m;
    }
}
