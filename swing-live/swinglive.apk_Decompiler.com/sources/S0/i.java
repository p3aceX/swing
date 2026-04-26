package S0;

import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import d1.C0326B;
import d1.C0327C;
import d1.C0335h;
import d1.C0336i;
import d1.C0337j;
import d1.C0339l;
import d1.C0340m;
import d1.C0341n;
import d1.C0342o;
import d1.C0343p;
import d1.C0345s;
import d1.C0346t;
import d1.C0347u;
import d1.C0348v;
import d1.C0350x;
import d1.C0351y;
import d1.C0352z;
import d1.D;
import d1.F;
import d1.J;
import d1.O;
import d1.Q;
import d1.S;
import d1.T;
import d1.U;
import d1.V;
import d1.X;
import d1.m0;
import d1.p0;
import d1.u0;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class i extends Y0.d {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ int f1736d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ i(Class cls, g[] gVarArr, int i4) {
        super(cls, gVarArr);
        this.f1736d = i4;
    }

    public static Y0.c s(int i4, int i5) {
        C0345s c0345sA = C0346t.A();
        c0345sA.e();
        C0346t.x((C0346t) c0345sA.f3838b, i4);
        C0347u c0347uZ = C0348v.z();
        c0347uZ.e();
        C0348v.w((C0348v) c0347uZ.f3838b);
        C0348v c0348v = (C0348v) c0347uZ.b();
        c0345sA.e();
        C0346t.w((C0346t) c0345sA.f3838b, c0348v);
        return new Y0.c((C0346t) c0345sA.b(), i5);
    }

    public static Y0.c t(int i4, int i5, int i6) {
        O o4 = O.SHA256;
        C0340m c0340mB = C0341n.B();
        C0342o c0342oZ = C0343p.z();
        c0342oZ.e();
        C0343p.w((C0343p) c0342oZ.f3838b);
        C0343p c0343p = (C0343p) c0342oZ.b();
        c0340mB.e();
        C0341n.w((C0341n) c0340mB.f3838b, c0343p);
        c0340mB.e();
        C0341n.x((C0341n) c0340mB.f3838b, i4);
        C0341n c0341n = (C0341n) c0340mB.b();
        S sB = T.B();
        U uB = V.B();
        uB.e();
        V.w((V) uB.f3838b, o4);
        uB.e();
        V.x((V) uB.f3838b, i5);
        V v = (V) uB.b();
        sB.e();
        T.w((T) sB.f3838b, v);
        sB.e();
        T.x((T) sB.f3838b, 32);
        T t4 = (T) sB.b();
        C0336i c0336iA = C0337j.A();
        c0336iA.e();
        C0337j.w((C0337j) c0336iA.f3838b, c0341n);
        c0336iA.e();
        C0337j.x((C0337j) c0336iA.f3838b, t4);
        return new Y0.c((C0337j) c0336iA.b(), i6);
    }

    public static Y0.c u(int i4, int i5) {
        C0351y c0351yY = C0352z.y();
        c0351yY.e();
        C0352z.w((C0352z) c0351yY.f3838b, i4);
        return new Y0.c((C0352z) c0351yY.b(), i5);
    }

    public static Y0.c v(int i4, int i5) {
        C0327C c0327cY = D.y();
        c0327cY.e();
        D.w((D) c0327cY.f3838b, i4);
        return new Y0.c((D) c0327cY.b(), i5);
    }

    @Override // Y0.d
    public int k() {
        switch (this.f1736d) {
            case 0:
                return 2;
            case 1:
            default:
                return super.k();
            case 2:
                return 2;
        }
    }

    @Override // Y0.d
    public final String l() {
        switch (this.f1736d) {
            case 0:
                return "type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey";
            case 1:
                return "type.googleapis.com/google.crypto.tink.AesEaxKey";
            case 2:
                return "type.googleapis.com/google.crypto.tink.AesGcmKey";
            case 3:
                return "type.googleapis.com/google.crypto.tink.AesGcmSivKey";
            case 4:
                return "type.googleapis.com/google.crypto.tink.ChaCha20Poly1305Key";
            case 5:
                return "type.googleapis.com/google.crypto.tink.KmsAeadKey";
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return "type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey";
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return "type.googleapis.com/google.crypto.tink.XChaCha20Poly1305Key";
            default:
                return "type.googleapis.com/google.crypto.tink.AesSivKey";
        }
    }

    @Override // Y0.d
    public final Q.b n() {
        switch (this.f1736d) {
            case 0:
                return new h(this);
            case 1:
                return new h(this, (byte) 0);
            case 2:
                return new h(this, (char) 0);
            case 3:
                return new h(this, 0);
            case 4:
                return new h(this, (short) 0);
            case 5:
                return new h(this, (byte) 0, false);
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return new h(this, (byte) 0, (byte) 0);
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return new h(this, (byte) 0, (char) 0);
            default:
                return new h(this, (byte) 0, 0);
        }
    }

    @Override // Y0.d
    public final X o() {
        switch (this.f1736d) {
        }
        return X.SYMMETRIC;
    }

    @Override // Y0.d
    public final AbstractC0296a p(AbstractC0303h abstractC0303h) {
        switch (this.f1736d) {
            case 0:
                return C0335h.D(abstractC0303h, C0309n.a());
            case 1:
                return d1.r.D(abstractC0303h, C0309n.a());
            case 2:
                return C0350x.B(abstractC0303h, C0309n.a());
            case 3:
                return C0326B.B(abstractC0303h, C0309n.a());
            case 4:
                return J.B(abstractC0303h, C0309n.a());
            case 5:
                return m0.B(abstractC0303h, C0309n.a());
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return p0.B(abstractC0303h, C0309n.a());
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return u0.B(abstractC0303h, C0309n.a());
            default:
                return F.B(abstractC0303h, C0309n.a());
        }
    }

    @Override // Y0.d
    public final void r(AbstractC0296a abstractC0296a) throws GeneralSecurityException {
        switch (this.f1736d) {
            case 0:
                C0335h c0335h = (C0335h) abstractC0296a;
                e1.q.c(c0335h.B());
                g[] gVarArr = {new g(e1.l.class, 1)};
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
                C0339l c0339lZ = c0335h.z();
                e1.q.c(c0339lZ.C());
                e1.q.a(c0339lZ.A().size());
                C0343p c0343pB = c0339lZ.B();
                if (c0343pB.y() < 12 || c0343pB.y() > 16) {
                    throw new GeneralSecurityException("invalid IV size");
                }
                g[] gVarArr2 = {new g(R0.j.class, 11)};
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
                Q qA = c0335h.A();
                e1.q.c(qA.C());
                if (qA.A().size() < 16) {
                    throw new GeneralSecurityException("key too short");
                }
                Z0.c.u(qA.B());
                return;
            case 1:
                d1.r rVar = (d1.r) abstractC0296a;
                e1.q.c(rVar.B());
                e1.q.a(rVar.z().size());
                if (rVar.A().y() != 12 && rVar.A().y() != 16) {
                    throw new GeneralSecurityException("invalid IV size; acceptable values have 12 or 16 bytes");
                }
                return;
            case 2:
                C0350x c0350x = (C0350x) abstractC0296a;
                e1.q.c(c0350x.z());
                e1.q.a(c0350x.y().size());
                return;
            case 3:
                C0326B c0326b = (C0326B) abstractC0296a;
                e1.q.c(c0326b.z());
                e1.q.a(c0326b.y().size());
                return;
            case 4:
                J j4 = (J) abstractC0296a;
                e1.q.c(j4.z());
                if (j4.y().size() != 32) {
                    throw new GeneralSecurityException("invalid ChaCha20Poly1305Key: incorrect key length");
                }
                return;
            case 5:
                e1.q.c(((m0) abstractC0296a).z());
                return;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                e1.q.c(((p0) abstractC0296a).z());
                return;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                u0 u0Var = (u0) abstractC0296a;
                e1.q.c(u0Var.z());
                if (u0Var.y().size() != 32) {
                    throw new GeneralSecurityException("invalid XChaCha20Poly1305Key: incorrect key length");
                }
                return;
            default:
                F f4 = (F) abstractC0296a;
                e1.q.c(f4.z());
                if (f4.y().size() == 64) {
                    return;
                }
                throw new InvalidKeyException("invalid key size: " + f4.y().size() + ". Valid keys must have 64 bytes.");
        }
    }
}
