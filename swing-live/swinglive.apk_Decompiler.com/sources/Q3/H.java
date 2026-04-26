package Q3;

/* JADX INFO: loaded from: classes.dex */
public abstract class H {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final K f1590a;

    static {
        String property;
        K k4;
        int i4 = V3.u.f2250a;
        try {
            property = System.getProperty("kotlinx.coroutines.main.delay");
        } catch (SecurityException unused) {
            property = null;
        }
        if (property != null ? Boolean.parseBoolean(property) : false) {
            X3.e eVar = O.f1596a;
            R3.d dVar = V3.o.f2244a;
            R3.d dVar2 = dVar.e;
            k4 = dVar;
            if (dVar == null) {
                k4 = G.f1585p;
            }
        } else {
            k4 = G.f1585p;
        }
        f1590a = k4;
    }
}
