package S0;

import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import d1.C0326B;
import d1.C0329b;
import d1.C0335h;
import d1.C0339l;
import d1.C0350x;
import d1.F;
import d1.J;
import d1.O;
import d1.Q;
import d1.m0;
import d1.p0;
import d1.u0;
import e1.C0361a;
import e1.C0362b;
import e1.C0363c;
import e1.C0364d;
import e1.C0368h;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import javax.crypto.spec.SecretKeySpec;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Class f1732a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f1733b;

    public g(Class cls, int i4) {
        this.f1733b = i4;
        this.f1732a = cls;
    }

    public final Object a(AbstractC0296a abstractC0296a) throws GeneralSecurityException {
        switch (this.f1733b) {
            case 0:
                C0335h c0335h = (C0335h) abstractC0296a;
                g[] gVarArr = {new g(e1.l.class, 1)};
                HashMap map = new HashMap();
                for (g gVar : gVarArr) {
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
                Map mapUnmodifiableMap = Collections.unmodifiableMap(map);
                C0339l c0339lZ = c0335h.z();
                g gVar2 = (g) mapUnmodifiableMap.get(e1.l.class);
                if (gVar2 == null) {
                    throw new IllegalArgumentException("Requested primitive class " + e1.l.class.getCanonicalName() + " not supported.");
                }
                e1.l lVar = (e1.l) gVar2.a(c0339lZ);
                g[] gVarArr2 = {new g(R0.j.class, 11)};
                HashMap map2 = new HashMap();
                for (g gVar3 : gVarArr2) {
                    boolean zContainsKey2 = map2.containsKey(gVar3.f1732a);
                    Class cls3 = gVar3.f1732a;
                    if (zContainsKey2) {
                        throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls3.getCanonicalName());
                    }
                    map2.put(cls3, gVar3);
                }
                if (gVarArr2.length > 0) {
                    Class cls4 = gVarArr2[0].f1732a;
                }
                Map mapUnmodifiableMap2 = Collections.unmodifiableMap(map2);
                Q qA = c0335h.A();
                g gVar4 = (g) mapUnmodifiableMap2.get(R0.j.class);
                if (gVar4 != null) {
                    return new C0368h(lVar, (R0.j) gVar4.a(qA), c0335h.A().B().A());
                }
                throw new IllegalArgumentException("Requested primitive class " + R0.j.class.getCanonicalName() + " not supported.");
            case 1:
                C0339l c0339l = (C0339l) abstractC0296a;
                return new C0361a(c0339l.A().j(), c0339l.B().y());
            case 2:
                d1.r rVar = (d1.r) abstractC0296a;
                return new C0362b(rVar.z().j(), rVar.A().y());
            case 3:
                return new C0363c(((C0350x) abstractC0296a).y().j(), 0);
            case 4:
                return new U0.a(((C0326B) abstractC0296a).y().j());
            case 5:
                return new C0363c(((J) abstractC0296a).y().j(), 1);
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                String strX = ((m0) abstractC0296a).y().x();
                return R0.i.a(strX).c(strX);
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                p0 p0Var = (p0) abstractC0296a;
                String strY = p0Var.y().y();
                return new y(p0Var.y().x(), R0.i.a(strY).c(strY));
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return new C0363c(((u0) abstractC0296a).y().j(), 2);
            case 9:
                return new C0364d(((F) abstractC0296a).y().j());
            case 10:
                C0329b c0329b = (C0329b) abstractC0296a;
                return new e1.o(new C0747k(c0329b.z().j()), c0329b.A().y());
            default:
                Q q4 = (Q) abstractC0296a;
                O oZ = q4.B().z();
                SecretKeySpec secretKeySpec = new SecretKeySpec(q4.A().j(), "HMAC");
                int iA = q4.B().A();
                int iOrdinal = oZ.ordinal();
                if (iOrdinal == 1) {
                    return new e1.o(new e1.n("HMACSHA1", secretKeySpec), iA);
                }
                if (iOrdinal == 2) {
                    return new e1.o(new e1.n("HMACSHA384", secretKeySpec), iA);
                }
                if (iOrdinal == 3) {
                    return new e1.o(new e1.n("HMACSHA256", secretKeySpec), iA);
                }
                if (iOrdinal == 4) {
                    return new e1.o(new e1.n("HMACSHA512", secretKeySpec), iA);
                }
                if (iOrdinal == 5) {
                    return new e1.o(new e1.n("HMACSHA224", secretKeySpec), iA);
                }
                throw new GeneralSecurityException("unknown hash");
        }
    }
}
