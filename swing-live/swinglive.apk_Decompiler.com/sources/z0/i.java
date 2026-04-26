package Z0;

import java.security.GeneralSecurityException;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class i implements R0.n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final i f2577a = new i();

    @Override // R0.n
    public final Class a() {
        return g.class;
    }

    @Override // R0.n
    public final Object b(C0747k c0747k) throws GeneralSecurityException {
        if (((R0.l) c0747k.f6832c) == null) {
            throw new GeneralSecurityException("no primary in primitive set");
        }
        Iterator it = ((ConcurrentHashMap) c0747k.f6831b).values().iterator();
        while (it.hasNext()) {
            Iterator it2 = ((List) it.next()).iterator();
            while (it2.hasNext()) {
            }
        }
        return new h();
    }

    @Override // R0.n
    public final Class c() {
        return g.class;
    }
}
