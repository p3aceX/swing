package Z0;

import d1.C0329b;
import d1.s0;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class m {
    static {
        S0.g[] gVarArr = {new S0.g(R0.j.class, 11)};
        HashMap map = new HashMap();
        S0.g gVar = gVarArr[0];
        boolean zContainsKey = map.containsKey(gVar.f1732a);
        Class cls = gVar.f1732a;
        if (zContainsKey) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls.getCanonicalName());
        }
        map.put(cls, gVar);
        Class cls2 = gVarArr[0].f1732a;
        Collections.unmodifiableMap(map);
        int i4 = s0.CONFIG_NAME_FIELD_NUMBER;
        try {
            a();
        } catch (GeneralSecurityException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void a() {
        R0.o.h(p.f2592c);
        R0.o.h(i.f2577a);
        R0.o.f(new c(), true);
        Y0.j jVar = l.f2583a;
        Y0.h hVar = Y0.h.f2478b;
        hVar.e(l.f2583a);
        hVar.d(l.f2584b);
        hVar.c(l.f2585c);
        hVar.b(l.f2586d);
        Y0.g gVar = Y0.g.f2476b;
        gVar.b(c.f2554f);
        if (V0.a.a()) {
            return;
        }
        R0.o.f(new c(C0329b.class, new S0.g[]{new S0.g(R0.j.class, 10)}), true);
        hVar.e(f.f2573a);
        hVar.d(f.f2574b);
        hVar.c(f.f2575c);
        hVar.b(f.f2576d);
        gVar.b(c.e);
    }
}
