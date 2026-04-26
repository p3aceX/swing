package W0;

import R0.o;
import S0.i;
import Y0.h;
import Y0.j;
import d1.F;
import d1.s0;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class e {
    static {
        S0.g[] gVarArr = {new S0.g(R0.c.class, 9)};
        HashMap map = new HashMap();
        for (S0.g gVar : gVarArr) {
            boolean zContainsKey = map.containsKey(gVar.f1732a);
            Class cls = gVar.f1732a;
            if (zContainsKey) {
                throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls.getCanonicalName());
            }
            map.put(cls, gVar);
        }
        if (gVarArr.length > 0) {
            Class cls2 = gVarArr[0].f1732a;
        }
        Collections.unmodifiableMap(map);
        int i4 = s0.CONFIG_NAME_FIELD_NUMBER;
        try {
            a();
        } catch (GeneralSecurityException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void a() {
        o.h(g.f2270b);
        if (V0.a.a()) {
            return;
        }
        o.f(new i(F.class, new S0.g[]{new S0.g(R0.c.class, 9)}, 8), true);
        j jVar = d.f2262a;
        h hVar = h.f2478b;
        hVar.e(d.f2262a);
        hVar.d(d.f2263b);
        hVar.c(d.f2264c);
        hVar.b(d.f2265d);
    }
}
