package R0;

import D2.v;
import a1.C0187a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.B;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import d1.Y;
import d1.a0;
import d1.b0;
import d1.r0;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicReference;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public abstract class o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final AtomicReference f1703a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final ConcurrentHashMap f1704b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final ConcurrentHashMap f1705c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final ConcurrentHashMap f1706d;

    static {
        Logger.getLogger(o.class.getName());
        f1703a = new AtomicReference(new e());
        f1704b = new ConcurrentHashMap();
        f1705c = new ConcurrentHashMap();
        new ConcurrentHashMap();
        f1706d = new ConcurrentHashMap();
    }

    public static synchronized void a(String str, Map map, boolean z4) {
        if (z4) {
            try {
                ConcurrentHashMap concurrentHashMap = f1705c;
                if (concurrentHashMap.containsKey(str) && !((Boolean) concurrentHashMap.get(str)).booleanValue()) {
                    throw new GeneralSecurityException("New keys are already disallowed for key type " + str);
                }
            } finally {
            }
        }
        if (z4) {
            if (((e) f1703a.get()).f1682a.containsKey(str)) {
                for (Map.Entry entry : map.entrySet()) {
                    if (!f1706d.containsKey(entry.getKey())) {
                        throw new GeneralSecurityException("Attempted to register a new key template " + ((String) entry.getKey()) + " from an existing key manager of type " + str);
                    }
                }
            } else {
                for (Map.Entry entry2 : map.entrySet()) {
                    if (f1706d.containsKey(entry2.getKey())) {
                        throw new GeneralSecurityException("Attempted overwrite of a registered key template " + ((String) entry2.getKey()));
                    }
                }
            }
        }
    }

    public static Object b(b bVar, Class cls) throws GeneralSecurityException {
        C0187a c0187a;
        Y0.m mVar = (Y0.m) Y0.g.f2476b.f2477a.get();
        mVar.getClass();
        Y0.l lVar = new Y0.l(bVar.getClass(), cls);
        HashMap map = mVar.f2486a;
        if (!map.containsKey(lVar)) {
            throw new GeneralSecurityException("No PrimitiveConstructor for " + lVar + " available");
        }
        switch (((Y0.k) map.get(lVar)).f2483b.f41a) {
            case 10:
                c0187a = new C0187a();
                if (!B1.a.f(1)) {
                    throw new GeneralSecurityException("Can not use AES-CMAC in FIPS-mode.");
                }
                return c0187a;
            default:
                c0187a = new C0187a();
                if (!B1.a.g(2)) {
                    throw new GeneralSecurityException("Can not use HMAC in FIPS-mode, as BoringCrypto module is not available.");
                }
                return c0187a;
        }
    }

    public static Object c(String str, AbstractC0303h abstractC0303h, Class cls) throws GeneralSecurityException {
        e eVar = (e) f1703a.get();
        eVar.getClass();
        d dVarA = eVar.a(str);
        boolean zContains = ((Map) dVarA.f1680a.f2472c).keySet().contains(cls);
        Y0.d dVar = dVarA.f1680a;
        if (!zContains) {
            StringBuilder sb = new StringBuilder("Primitive type ");
            sb.append(cls.getName());
            sb.append(" not supported by key manager of type ");
            sb.append(dVar.getClass());
            sb.append(", supported primitives: ");
            Set<Class> setKeySet = ((Map) dVar.f2472c).keySet();
            StringBuilder sb2 = new StringBuilder();
            boolean z4 = true;
            for (Class cls2 : setKeySet) {
                if (!z4) {
                    sb2.append(", ");
                }
                sb2.append(cls2.getCanonicalName());
                z4 = false;
            }
            sb.append(sb2.toString());
            throw new GeneralSecurityException(sb.toString());
        }
        try {
            if (!((Map) dVar.f2472c).keySet().contains(cls) && !Void.class.equals(cls)) {
                throw new IllegalArgumentException("Given internalKeyMananger " + dVar.toString() + " does not support primitive class " + cls.getName());
            }
            try {
                AbstractC0296a abstractC0296aP = dVar.p(abstractC0303h);
                if (Void.class.equals(cls)) {
                    throw new GeneralSecurityException("Cannot create a primitive for Void");
                }
                dVar.r(abstractC0296aP);
                return dVar.m(abstractC0296aP, cls);
            } catch (B e) {
                throw new GeneralSecurityException("Failures parsing proto of type ".concat(((Class) dVar.f2470a).getName()), e);
            }
        } catch (IllegalArgumentException e4) {
            throw new GeneralSecurityException("Primitive type not supported", e4);
        }
    }

    public static Object d(String str, byte[] bArr) {
        C0302g c0302g = AbstractC0303h.f3791b;
        return c(str, AbstractC0303h.h(bArr, 0, bArr.length), a.class);
    }

    public static synchronized Y e(b0 b0Var) {
        f fVar;
        Y0.d dVar = ((e) f1703a.get()).a(b0Var.B()).f1680a;
        fVar = new f(dVar, (Class) dVar.f2471b);
        if (!((Boolean) f1705c.get(b0Var.B())).booleanValue()) {
            throw new GeneralSecurityException("newKey-operation not permitted for key type " + b0Var.B());
        }
        return fVar.e(b0Var.C());
    }

    public static synchronized void f(Y0.d dVar, boolean z4) {
        try {
            AtomicReference atomicReference = f1703a;
            e eVar = new e((e) atomicReference.get());
            eVar.b(dVar);
            String strL = dVar.l();
            a(strL, z4 ? dVar.n().h() : Collections.EMPTY_MAP, z4);
            if (!((e) atomicReference.get()).f1682a.containsKey(strL)) {
                f1704b.put(strL, new p1.d(16));
                if (z4) {
                    g(strL, dVar.n().h());
                }
            }
            f1705c.put(strL, Boolean.valueOf(z4));
            atomicReference.set(eVar);
        } catch (Throwable th) {
            throw th;
        }
    }

    public static void g(String str, Map map) {
        r0 r0Var;
        for (Map.Entry entry : map.entrySet()) {
            ConcurrentHashMap concurrentHashMap = f1706d;
            String str2 = (String) entry.getKey();
            byte[] bArrE = ((Y0.c) entry.getValue()).f2468a.e();
            int i4 = ((Y0.c) entry.getValue()).f2469b;
            a0 a0VarD = b0.D();
            a0VarD.e();
            b0.w((b0) a0VarD.f3838b, str);
            C0302g c0302gH = AbstractC0303h.h(bArrE, 0, bArrE.length);
            a0VarD.e();
            b0.x((b0) a0VarD.f3838b, c0302gH);
            int iB = K.j.b(i4);
            if (iB == 0) {
                r0Var = r0.TINK;
            } else if (iB == 1) {
                r0Var = r0.LEGACY;
            } else if (iB == 2) {
                r0Var = r0.RAW;
            } else {
                if (iB != 3) {
                    throw new IllegalArgumentException("Unknown output prefix type");
                }
                r0Var = r0.CRUNCHY;
            }
            a0VarD.e();
            b0.y((b0) a0VarD.f3838b, r0Var);
            concurrentHashMap.put(str2, new g((b0) a0VarD.b()));
        }
    }

    public static synchronized void h(n nVar) {
        Y0.g gVar = Y0.g.f2476b;
        synchronized (gVar) {
            v vVar = new v((Y0.m) gVar.f2477a.get());
            vVar.C(nVar);
            gVar.f2477a.set(new Y0.m(vVar));
        }
    }
}
