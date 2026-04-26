package R0;

import java.security.GeneralSecurityException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public final class e {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Logger f1681b = Logger.getLogger(e.class.getName());

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ConcurrentHashMap f1682a;

    public e(e eVar) {
        this.f1682a = new ConcurrentHashMap(eVar.f1682a);
    }

    public final synchronized d a(String str) {
        if (!this.f1682a.containsKey(str)) {
            throw new GeneralSecurityException("No key manager found for key type " + str);
        }
        return (d) this.f1682a.get(str);
    }

    public final synchronized void b(Y0.d dVar) {
        int iK = dVar.k();
        if (!(iK != 1 ? B1.a.g(iK) : B1.a.f(iK))) {
            throw new GeneralSecurityException("failed to register key manager " + dVar.getClass() + " as it is not FIPS compatible.");
        }
        c(new d(dVar));
    }

    public final synchronized void c(d dVar) {
        try {
            Y0.d dVar2 = dVar.f1680a;
            Class cls = (Class) dVar2.f2471b;
            if (!((Map) dVar2.f2472c).keySet().contains(cls) && !Void.class.equals(cls)) {
                throw new IllegalArgumentException("Given internalKeyMananger " + dVar2.toString() + " does not support primitive class " + cls.getName());
            }
            String strL = dVar2.l();
            d dVar3 = (d) this.f1682a.get(strL);
            if (dVar3 != null && !dVar3.f1680a.getClass().equals(dVar.f1680a.getClass())) {
                f1681b.warning("Attempted overwrite of a registered key manager for key type ".concat(strL));
                throw new GeneralSecurityException("typeUrl (" + strL + ") is already registered with " + dVar3.f1680a.getClass().getName() + ", cannot be re-registered with " + dVar.f1680a.getClass().getName());
            }
            this.f1682a.putIfAbsent(strL, dVar);
        } catch (Throwable th) {
            throw th;
        }
    }

    public e() {
        this.f1682a = new ConcurrentHashMap();
    }
}
