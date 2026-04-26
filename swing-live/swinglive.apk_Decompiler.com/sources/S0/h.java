package S0;

import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import d1.C0325A;
import d1.C0326B;
import d1.C0334g;
import d1.C0335h;
import d1.C0337j;
import d1.C0338k;
import d1.C0339l;
import d1.C0341n;
import d1.C0343p;
import d1.C0344q;
import d1.C0346t;
import d1.C0348v;
import d1.C0349w;
import d1.C0350x;
import d1.C0352z;
import d1.D;
import d1.E;
import d1.F;
import d1.G;
import d1.H;
import d1.I;
import d1.J;
import d1.L;
import d1.O;
import d1.P;
import d1.Q;
import d1.T;
import d1.V;
import d1.l0;
import d1.m0;
import d1.n0;
import d1.o0;
import d1.p0;
import d1.q0;
import d1.t0;
import d1.u0;
import d1.v0;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class h extends Q.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f1734b = 0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Y0.d f1735c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, byte b5, boolean z4) {
        super(n0.class);
        this.f1735c = iVar;
    }

    @Override // Q.b
    public final AbstractC0296a a(AbstractC0296a abstractC0296a) {
        switch (this.f1734b) {
            case 0:
                C0337j c0337j = (C0337j) abstractC0296a;
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
                Collections.unmodifiableMap(map);
                C0341n c0341nY = c0337j.y();
                C0338k c0338kD = C0339l.D();
                C0343p c0343pA = c0341nY.A();
                c0338kD.e();
                C0339l.x((C0339l) c0338kD.f3838b, c0343pA);
                byte[] bArrA = e1.p.a(c0341nY.z());
                C0302g c0302gH = AbstractC0303h.h(bArrA, 0, bArrA.length);
                c0338kD.e();
                C0339l.y((C0339l) c0338kD.f3838b, c0302gH);
                c0338kD.e();
                C0339l.w((C0339l) c0338kD.f3838b);
                C0339l c0339l = (C0339l) c0338kD.b();
                g[] gVarArr2 = {new g(R0.j.class, 11)};
                HashMap map2 = new HashMap();
                for (g gVar2 : gVarArr2) {
                    boolean zContainsKey2 = map2.containsKey(gVar2.f1732a);
                    Class cls3 = gVar2.f1732a;
                    if (zContainsKey2) {
                        throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls3.getCanonicalName());
                    }
                    map2.put(cls3, gVar2);
                }
                if (gVarArr2.length > 0) {
                    Class cls4 = gVarArr2[0].f1732a;
                }
                Collections.unmodifiableMap(map2);
                T tZ = c0337j.z();
                P pD = Q.D();
                pD.e();
                Q.w((Q) pD.f3838b);
                V vA = tZ.A();
                pD.e();
                Q.x((Q) pD.f3838b, vA);
                byte[] bArrA2 = e1.p.a(tZ.z());
                C0302g c0302gH2 = AbstractC0303h.h(bArrA2, 0, bArrA2.length);
                pD.e();
                Q.y((Q) pD.f3838b, c0302gH2);
                Q q4 = (Q) pD.b();
                C0334g c0334gC = C0335h.C();
                c0334gC.e();
                C0335h.x((C0335h) c0334gC.f3838b, c0339l);
                c0334gC.e();
                C0335h.y((C0335h) c0334gC.f3838b, q4);
                ((i) this.f1735c).getClass();
                c0334gC.e();
                C0335h.w((C0335h) c0334gC.f3838b);
                return (C0335h) c0334gC.b();
            case 1:
                C0346t c0346t = (C0346t) abstractC0296a;
                C0344q c0344qC = d1.r.C();
                byte[] bArrA3 = e1.p.a(c0346t.y());
                C0302g c0302gH3 = AbstractC0303h.h(bArrA3, 0, bArrA3.length);
                c0344qC.e();
                d1.r.y((d1.r) c0344qC.f3838b, c0302gH3);
                C0348v c0348vZ = c0346t.z();
                c0344qC.e();
                d1.r.x((d1.r) c0344qC.f3838b, c0348vZ);
                ((i) this.f1735c).getClass();
                c0344qC.e();
                d1.r.w((d1.r) c0344qC.f3838b);
                return (d1.r) c0344qC.b();
            case 2:
                C0349w c0349wA = C0350x.A();
                byte[] bArrA4 = e1.p.a(((C0352z) abstractC0296a).x());
                C0302g c0302gH4 = AbstractC0303h.h(bArrA4, 0, bArrA4.length);
                c0349wA.e();
                C0350x.x((C0350x) c0349wA.f3838b, c0302gH4);
                ((i) this.f1735c).getClass();
                c0349wA.e();
                C0350x.w((C0350x) c0349wA.f3838b);
                return (C0350x) c0349wA.b();
            case 3:
                C0325A c0325aA = C0326B.A();
                byte[] bArrA5 = e1.p.a(((D) abstractC0296a).x());
                C0302g c0302gH5 = AbstractC0303h.h(bArrA5, 0, bArrA5.length);
                c0325aA.e();
                C0326B.x((C0326B) c0325aA.f3838b, c0302gH5);
                ((i) this.f1735c).getClass();
                c0325aA.e();
                C0326B.w((C0326B) c0325aA.f3838b);
                return (C0326B) c0325aA.b();
            case 4:
                I iA = J.A();
                ((i) this.f1735c).getClass();
                iA.e();
                J.w((J) iA.f3838b);
                byte[] bArrA6 = e1.p.a(32);
                C0302g c0302gH6 = AbstractC0303h.h(bArrA6, 0, bArrA6.length);
                iA.e();
                J.x((J) iA.f3838b, c0302gH6);
                return (J) iA.b();
            case 5:
                l0 l0VarA = m0.A();
                l0VarA.e();
                m0.x((m0) l0VarA.f3838b, (n0) abstractC0296a);
                ((i) this.f1735c).getClass();
                l0VarA.e();
                m0.w((m0) l0VarA.f3838b);
                return (m0) l0VarA.b();
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                o0 o0VarA = p0.A();
                o0VarA.e();
                p0.x((p0) o0VarA.f3838b, (q0) abstractC0296a);
                ((i) this.f1735c).getClass();
                o0VarA.e();
                p0.w((p0) o0VarA.f3838b);
                return (p0) o0VarA.b();
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                t0 t0VarA = u0.A();
                ((i) this.f1735c).getClass();
                t0VarA.e();
                u0.w((u0) t0VarA.f3838b);
                byte[] bArrA7 = e1.p.a(32);
                C0302g c0302gH7 = AbstractC0303h.h(bArrA7, 0, bArrA7.length);
                t0VarA.e();
                u0.x((u0) t0VarA.f3838b, c0302gH7);
                return (u0) t0VarA.b();
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                E eA = F.A();
                byte[] bArrA8 = e1.p.a(((H) abstractC0296a).x());
                C0302g c0302gH8 = AbstractC0303h.h(bArrA8, 0, bArrA8.length);
                eA.e();
                F.x((F) eA.f3838b, c0302gH8);
                ((i) this.f1735c).getClass();
                eA.e();
                F.w((F) eA.f3838b);
                return (F) eA.b();
            default:
                T t4 = (T) abstractC0296a;
                P pD2 = Q.D();
                ((Z0.c) this.f1735c).getClass();
                pD2.e();
                Q.w((Q) pD2.f3838b);
                V vA2 = t4.A();
                pD2.e();
                Q.x((Q) pD2.f3838b, vA2);
                byte[] bArrA9 = e1.p.a(t4.z());
                C0302g c0302gH9 = AbstractC0303h.h(bArrA9, 0, bArrA9.length);
                pD2.e();
                Q.y((Q) pD2.f3838b, c0302gH9);
                return (Q) pD2.b();
        }
    }

    @Override // Q.b
    public Map h() {
        switch (this.f1734b) {
            case 0:
                HashMap map = new HashMap();
                map.put("AES128_CTR_HMAC_SHA256", i.t(16, 16, 1));
                map.put("AES128_CTR_HMAC_SHA256_RAW", i.t(16, 16, 3));
                map.put("AES256_CTR_HMAC_SHA256", i.t(32, 32, 1));
                map.put("AES256_CTR_HMAC_SHA256_RAW", i.t(32, 32, 3));
                return Collections.unmodifiableMap(map);
            case 1:
                HashMap map2 = new HashMap();
                map2.put("AES128_EAX", i.s(16, 1));
                map2.put("AES128_EAX_RAW", i.s(16, 3));
                map2.put("AES256_EAX", i.s(32, 1));
                map2.put("AES256_EAX_RAW", i.s(32, 3));
                return Collections.unmodifiableMap(map2);
            case 2:
                HashMap map3 = new HashMap();
                map3.put("AES128_GCM", i.u(16, 1));
                map3.put("AES128_GCM_RAW", i.u(16, 3));
                map3.put("AES256_GCM", i.u(32, 1));
                map3.put("AES256_GCM_RAW", i.u(32, 3));
                return Collections.unmodifiableMap(map3);
            case 3:
                HashMap map4 = new HashMap();
                map4.put("AES128_GCM_SIV", i.v(16, 1));
                map4.put("AES128_GCM_SIV_RAW", i.v(16, 3));
                map4.put("AES256_GCM_SIV", i.v(32, 1));
                map4.put("AES256_GCM_SIV_RAW", i.v(32, 3));
                return Collections.unmodifiableMap(map4);
            case 4:
                HashMap map5 = new HashMap();
                map5.put("CHACHA20_POLY1305", new Y0.c(L.w(), 1));
                map5.put("CHACHA20_POLY1305_RAW", new Y0.c(L.w(), 3));
                return Collections.unmodifiableMap(map5);
            case 5:
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
            default:
                return super.h();
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                HashMap map6 = new HashMap();
                map6.put("XCHACHA20_POLY1305", new Y0.c(v0.w(), 1));
                map6.put("XCHACHA20_POLY1305_RAW", new Y0.c(v0.w(), 3));
                return Collections.unmodifiableMap(map6);
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                HashMap map7 = new HashMap();
                G gY = H.y();
                gY.e();
                H.w((H) gY.f3838b);
                map7.put("AES256_SIV", new Y0.c((H) gY.b(), 1));
                G gY2 = H.y();
                gY2.e();
                H.w((H) gY2.f3838b);
                map7.put("AES256_SIV_RAW", new Y0.c((H) gY2.b(), 3));
                return Collections.unmodifiableMap(map7);
            case 9:
                HashMap map8 = new HashMap();
                O o4 = O.SHA256;
                map8.put("HMAC_SHA256_128BITTAG", Z0.c.s(32, 16, o4, 1));
                map8.put("HMAC_SHA256_128BITTAG_RAW", Z0.c.s(32, 16, o4, 3));
                map8.put("HMAC_SHA256_256BITTAG", Z0.c.s(32, 32, o4, 1));
                map8.put("HMAC_SHA256_256BITTAG_RAW", Z0.c.s(32, 32, o4, 3));
                O o5 = O.SHA512;
                map8.put("HMAC_SHA512_128BITTAG", Z0.c.s(64, 16, o5, 1));
                map8.put("HMAC_SHA512_128BITTAG_RAW", Z0.c.s(64, 16, o5, 3));
                map8.put("HMAC_SHA512_256BITTAG", Z0.c.s(64, 32, o5, 1));
                map8.put("HMAC_SHA512_256BITTAG_RAW", Z0.c.s(64, 32, o5, 3));
                map8.put("HMAC_SHA512_512BITTAG", Z0.c.s(64, 64, o5, 1));
                map8.put("HMAC_SHA512_512BITTAG_RAW", Z0.c.s(64, 64, o5, 3));
                return Collections.unmodifiableMap(map8);
        }
    }

    @Override // Q.b
    public final AbstractC0296a i(AbstractC0303h abstractC0303h) {
        switch (this.f1734b) {
            case 0:
                return C0337j.B(abstractC0303h, C0309n.a());
            case 1:
                return C0346t.B(abstractC0303h, C0309n.a());
            case 2:
                return C0352z.z(abstractC0303h, C0309n.a());
            case 3:
                return D.z(abstractC0303h, C0309n.a());
            case 4:
                return L.x(abstractC0303h, C0309n.a());
            case 5:
                return n0.y(abstractC0303h, C0309n.a());
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return q0.A(abstractC0303h, C0309n.a());
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return v0.x(abstractC0303h, C0309n.a());
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return H.z(abstractC0303h, C0309n.a());
            default:
                return T.C(abstractC0303h, C0309n.a());
        }
    }

    @Override // Q.b
    public final void j(AbstractC0296a abstractC0296a) throws GeneralSecurityException {
        switch (this.f1734b) {
            case 0:
                C0337j c0337j = (C0337j) abstractC0296a;
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
                Collections.unmodifiableMap(map);
                C0341n c0341nY = c0337j.y();
                e1.q.a(c0341nY.z());
                C0343p c0343pA = c0341nY.A();
                if (c0343pA.y() < 12 || c0343pA.y() > 16) {
                    throw new GeneralSecurityException("invalid IV size");
                }
                g[] gVarArr2 = {new g(R0.j.class, 11)};
                HashMap map2 = new HashMap();
                for (g gVar2 : gVarArr2) {
                    boolean zContainsKey2 = map2.containsKey(gVar2.f1732a);
                    Class cls3 = gVar2.f1732a;
                    if (zContainsKey2) {
                        throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls3.getCanonicalName());
                    }
                    map2.put(cls3, gVar2);
                }
                if (gVarArr2.length > 0) {
                    Class cls4 = gVarArr2[0].f1732a;
                }
                Collections.unmodifiableMap(map2);
                T tZ = c0337j.z();
                if (tZ.z() < 16) {
                    throw new GeneralSecurityException("key too short");
                }
                Z0.c.u(tZ.A());
                e1.q.a(c0337j.y().z());
                return;
            case 1:
                C0346t c0346t = (C0346t) abstractC0296a;
                e1.q.a(c0346t.y());
                if (c0346t.z().y() != 12 && c0346t.z().y() != 16) {
                    throw new GeneralSecurityException("invalid IV size; acceptable values have 12 or 16 bytes");
                }
                return;
            case 2:
                e1.q.a(((C0352z) abstractC0296a).x());
                return;
            case 3:
                e1.q.a(((D) abstractC0296a).x());
                return;
            case 4:
                return;
            case 5:
                return;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                q0 q0Var = (q0) abstractC0296a;
                if (q0Var.y().isEmpty() || !q0Var.z()) {
                    throw new GeneralSecurityException("invalid key format: missing KEK URI or DEK template");
                }
                return;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                H h4 = (H) abstractC0296a;
                if (h4.x() == 64) {
                    return;
                }
                throw new InvalidAlgorithmParameterException("invalid key size: " + h4.x() + ". Valid keys must have 64 bytes.");
            default:
                T t4 = (T) abstractC0296a;
                if (t4.z() < 16) {
                    throw new GeneralSecurityException("key too short");
                }
                Z0.c.u(t4.A());
                return;
        }
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, byte b5, byte b6) {
        super(q0.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, char c5) {
        super(C0352z.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, byte b5) {
        super(C0346t.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, int i4) {
        super(D.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, short s4) {
        super(L.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, byte b5, char c5) {
        super(v0.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, byte b5, int i4) {
        super(H.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar) {
        super(C0337j.class);
        this.f1735c = iVar;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(Z0.c cVar) {
        super(T.class);
        this.f1735c = cVar;
    }
}
