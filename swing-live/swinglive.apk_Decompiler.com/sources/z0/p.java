package Z0;

import f1.C0400a;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class p implements R0.n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Logger f2590a = Logger.getLogger(p.class.getName());

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final byte[] f2591b = {0};

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final p f2592c = new p();

    @Override // R0.n
    public final Class a() {
        return R0.j.class;
    }

    @Override // R0.n
    public final Object b(C0747k c0747k) throws GeneralSecurityException {
        Iterator it = ((ConcurrentHashMap) c0747k.f6831b).values().iterator();
        while (it.hasNext()) {
            for (R0.l lVar : (List) it.next()) {
                R0.b bVar = lVar.f1701h;
                if (bVar instanceof n) {
                    n nVar = (n) bVar;
                    byte[] bArr = lVar.f1697c;
                    C0400a c0400aA = C0400a.a(bArr == null ? null : Arrays.copyOf(bArr, bArr.length));
                    if (!c0400aA.equals(nVar.b())) {
                        throw new GeneralSecurityException("Mac Key with parameters " + nVar.c() + " has wrong output prefix (" + nVar.b() + ") instead of (" + c0400aA + ")");
                    }
                }
            }
        }
        return new o(c0747k);
    }

    @Override // R0.n
    public final Class c() {
        return R0.j.class;
    }
}
