package S0;

import d1.C0326B;
import d1.C0335h;
import d1.C0350x;
import d1.J;
import d1.m0;
import d1.p0;
import d1.s0;
import d1.u0;
import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;
import java.util.Collections;
import java.util.HashMap;
import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;

/* JADX INFO: renamed from: S0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0154a {
    static {
        g[] gVarArr = {new g(R0.a.class, 0)};
        HashMap map = new HashMap();
        for (int i4 = 0; i4 < 1; i4++) {
            g gVar = gVarArr[i4];
            boolean zContainsKey = map.containsKey(gVar.f1732a);
            Class cls = gVar.f1732a;
            if (zContainsKey) {
                throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls.getCanonicalName());
            }
            map.put(cls, gVar);
        }
        Class cls2 = gVarArr[0].f1732a;
        Collections.unmodifiableMap(map);
        g[] gVarArr2 = {new g(R0.a.class, 3)};
        HashMap map2 = new HashMap();
        g gVar2 = gVarArr2[0];
        boolean zContainsKey2 = map2.containsKey(gVar2.f1732a);
        Class cls3 = gVar2.f1732a;
        if (zContainsKey2) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls3.getCanonicalName());
        }
        map2.put(cls3, gVar2);
        Class cls4 = gVarArr2[0].f1732a;
        Collections.unmodifiableMap(map2);
        g[] gVarArr3 = {new g(R0.a.class, 4)};
        HashMap map3 = new HashMap();
        g gVar3 = gVarArr3[0];
        boolean zContainsKey3 = map3.containsKey(gVar3.f1732a);
        Class cls5 = gVar3.f1732a;
        if (zContainsKey3) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls5.getCanonicalName());
        }
        map3.put(cls5, gVar3);
        Class cls6 = gVarArr3[0].f1732a;
        Collections.unmodifiableMap(map3);
        g[] gVarArr4 = {new g(R0.a.class, 2)};
        HashMap map4 = new HashMap();
        g gVar4 = gVarArr4[0];
        boolean zContainsKey4 = map4.containsKey(gVar4.f1732a);
        Class cls7 = gVar4.f1732a;
        if (zContainsKey4) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls7.getCanonicalName());
        }
        map4.put(cls7, gVar4);
        Class cls8 = gVarArr4[0].f1732a;
        Collections.unmodifiableMap(map4);
        g[] gVarArr5 = {new g(R0.a.class, 6)};
        HashMap map5 = new HashMap();
        g gVar5 = gVarArr5[0];
        boolean zContainsKey5 = map5.containsKey(gVar5.f1732a);
        Class cls9 = gVar5.f1732a;
        if (zContainsKey5) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls9.getCanonicalName());
        }
        map5.put(cls9, gVar5);
        Class cls10 = gVarArr5[0].f1732a;
        Collections.unmodifiableMap(map5);
        g[] gVarArr6 = {new g(R0.a.class, 7)};
        HashMap map6 = new HashMap();
        g gVar6 = gVarArr6[0];
        boolean zContainsKey6 = map6.containsKey(gVar6.f1732a);
        Class cls11 = gVar6.f1732a;
        if (zContainsKey6) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls11.getCanonicalName());
        }
        map6.put(cls11, gVar6);
        Class cls12 = gVarArr6[0].f1732a;
        Collections.unmodifiableMap(map6);
        g[] gVarArr7 = {new g(R0.a.class, 5)};
        HashMap map7 = new HashMap();
        g gVar7 = gVarArr7[0];
        boolean zContainsKey7 = map7.containsKey(gVar7.f1732a);
        Class cls13 = gVar7.f1732a;
        if (zContainsKey7) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls13.getCanonicalName());
        }
        map7.put(cls13, gVar7);
        Class cls14 = gVarArr7[0].f1732a;
        Collections.unmodifiableMap(map7);
        g[] gVarArr8 = {new g(R0.a.class, 8)};
        HashMap map8 = new HashMap();
        g gVar8 = gVarArr8[0];
        boolean zContainsKey8 = map8.containsKey(gVar8.f1732a);
        Class cls15 = gVar8.f1732a;
        if (zContainsKey8) {
            throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls15.getCanonicalName());
        }
        map8.put(cls15, gVar8);
        Class cls16 = gVarArr8[0].f1732a;
        Collections.unmodifiableMap(map8);
        int i5 = s0.CONFIG_NAME_FIELD_NUMBER;
        try {
            a();
        } catch (GeneralSecurityException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void a() {
        R0.o.h(e.f1731b);
        Z0.m.a();
        R0.o.f(new i(C0335h.class, new g[]{new g(R0.a.class, 0)}, 0), true);
        Y0.j jVar = l.f1764a;
        Y0.h hVar = Y0.h.f2478b;
        hVar.e(l.f1764a);
        hVar.d(l.f1765b);
        hVar.c(l.f1766c);
        hVar.b(l.f1767d);
        R0.o.f(new i(C0350x.class, new g[]{new g(R0.a.class, 3)}, 2), true);
        hVar.e(r.f1778a);
        hVar.d(r.f1779b);
        hVar.c(r.f1780c);
        hVar.b(r.f1781d);
        if (V0.a.a()) {
            return;
        }
        R0.o.f(new i(d1.r.class, new g[]{new g(R0.a.class, 2)}, 1), true);
        hVar.e(o.f1771a);
        hVar.d(o.f1772b);
        hVar.c(o.f1773c);
        hVar.b(o.f1774d);
        try {
            Cipher.getInstance("AES/GCM-SIV/NoPadding");
            R0.o.f(new i(C0326B.class, new g[]{new g(R0.a.class, 4)}, 3), true);
            hVar.e(u.f1784a);
            hVar.d(u.f1785b);
            hVar.c(u.f1786c);
            hVar.b(u.f1787d);
        } catch (NoSuchAlgorithmException | NoSuchPaddingException unused) {
        }
        R0.o.f(new i(J.class, new g[]{new g(R0.a.class, 5)}, 4), true);
        Y0.j jVar2 = x.f1788a;
        Y0.h hVar2 = Y0.h.f2478b;
        hVar2.e(x.f1788a);
        hVar2.d(x.f1789b);
        hVar2.c(x.f1790c);
        hVar2.b(x.f1791d);
        R0.o.f(new i(m0.class, new g[]{new g(R0.a.class, 6)}, 5), true);
        R0.o.f(new i(p0.class, new g[]{new g(R0.a.class, 7)}, 6), true);
        R0.o.f(new i(u0.class, new g[]{new g(R0.a.class, 8)}, 7), true);
        hVar2.e(B.f1723a);
        hVar2.d(B.f1724b);
        hVar2.c(B.f1725c);
        hVar2.b(B.f1726d);
    }
}
