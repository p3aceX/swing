package Z0;

import A.C0003c;
import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import d1.C0329b;
import d1.C0331d;
import d1.C0333f;
import d1.O;
import d1.Q;
import d1.S;
import d1.T;
import d1.U;
import d1.V;
import d1.X;
import e1.q;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class c extends Y0.d {
    public static final Y0.k e = new Y0.k(a.class, new C0003c(10));

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final Y0.k f2554f = new Y0.k(j.class, new C0003c(12));

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ int f2555d = 1;

    public /* synthetic */ c(Class cls, S0.g[] gVarArr) {
        super(cls, gVarArr);
    }

    public static Y0.c s(int i4, int i5, O o4, int i6) {
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
        T.x((T) sB.f3838b, i4);
        return new Y0.c((T) sB.b(), i6);
    }

    public static void t(C0333f c0333f) {
        if (c0333f.y() < 10) {
            throw new GeneralSecurityException("tag size too short");
        }
        if (c0333f.y() > 16) {
            throw new GeneralSecurityException("tag size too long");
        }
    }

    public static void u(V v) {
        if (v.A() < 10) {
            throw new GeneralSecurityException("tag size too small");
        }
        int iOrdinal = v.z().ordinal();
        if (iOrdinal == 1) {
            if (v.A() > 20) {
                throw new GeneralSecurityException("tag size too big");
            }
            return;
        }
        if (iOrdinal == 2) {
            if (v.A() > 48) {
                throw new GeneralSecurityException("tag size too big");
            }
            return;
        }
        if (iOrdinal == 3) {
            if (v.A() > 32) {
                throw new GeneralSecurityException("tag size too big");
            }
        } else if (iOrdinal == 4) {
            if (v.A() > 64) {
                throw new GeneralSecurityException("tag size too big");
            }
        } else {
            if (iOrdinal != 5) {
                throw new GeneralSecurityException("unknown hash type");
            }
            if (v.A() > 28) {
                throw new GeneralSecurityException("tag size too big");
            }
        }
    }

    @Override // Y0.d
    public int k() {
        switch (this.f2555d) {
            case 1:
                return 2;
            default:
                return super.k();
        }
    }

    @Override // Y0.d
    public final String l() {
        switch (this.f2555d) {
            case 0:
                return "type.googleapis.com/google.crypto.tink.AesCmacKey";
            default:
                return "type.googleapis.com/google.crypto.tink.HmacKey";
        }
    }

    @Override // Y0.d
    public final Q.b n() {
        switch (this.f2555d) {
            case 0:
                return new b(C0331d.class);
            default:
                return new S0.h(this);
        }
    }

    @Override // Y0.d
    public final X o() {
        switch (this.f2555d) {
        }
        return X.SYMMETRIC;
    }

    @Override // Y0.d
    public final AbstractC0296a p(AbstractC0303h abstractC0303h) {
        switch (this.f2555d) {
            case 0:
                return C0329b.D(abstractC0303h, C0309n.a());
            default:
                return Q.E(abstractC0303h, C0309n.a());
        }
    }

    @Override // Y0.d
    public final void r(AbstractC0296a abstractC0296a) throws GeneralSecurityException {
        switch (this.f2555d) {
            case 0:
                C0329b c0329b = (C0329b) abstractC0296a;
                q.c(c0329b.B());
                if (c0329b.z().size() != 32) {
                    throw new GeneralSecurityException("AesCmacKey size wrong, must be 32 bytes");
                }
                t(c0329b.A());
                return;
            default:
                Q q4 = (Q) abstractC0296a;
                q.c(q4.C());
                if (q4.A().size() < 16) {
                    throw new GeneralSecurityException("key too short");
                }
                u(q4.B());
                return;
        }
    }

    public c() {
        super(Q.class, new S0.g(R0.j.class, 11));
    }
}
