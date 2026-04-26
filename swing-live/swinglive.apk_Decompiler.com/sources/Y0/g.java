package Y0;

import D2.v;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final g f2476b = new g();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicReference f2477a = new AtomicReference(new m(new v(28)));

    public final Class a(Class cls) {
        HashMap map = ((m) this.f2477a.get()).f2487b;
        if (map.containsKey(cls)) {
            return ((R0.n) map.get(cls)).a();
        }
        throw new GeneralSecurityException("No input primitive class for " + cls + " available");
    }

    public final synchronized void b(k kVar) {
        v vVar = new v((m) this.f2477a.get());
        vVar.B(kVar);
        this.f2477a.set(new m(vVar));
    }
}
