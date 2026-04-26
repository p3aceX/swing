package A;

import I.C0053n;
import android.content.Context;
import android.view.View;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.firebase.concurrent.ExecutorsRegistrar;
import d1.C0326B;
import d1.C0329b;
import d1.C0335h;
import d1.C0350x;
import d1.r0;
import d1.u0;
import f1.C0400a;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ScheduledExecutorService;
import m3.InterfaceC0556c;
import u1.C0688a;
import u1.C0689b;
import u1.C0690c;
import x1.C0717b;
import x1.C0719d;
import y0.C0747k;

/* JADX INFO: renamed from: A.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0003c implements l1.d, InterfaceC0556c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f41a;

    public /* synthetic */ C0003c(int i4) {
        this.f41a = i4;
    }

    private final R0.b f(Y0.n nVar) throws GeneralSecurityException {
        S0.j jVar;
        if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.ChaCha20Poly1305Key")) {
            throw new IllegalArgumentException("Wrong type URL in call to ChaCha20Poly1305Parameters.parseParameters");
        }
        try {
            d1.J jB = d1.J.B((AbstractC0303h) nVar.f2490c, C0309n.a());
            if (jB.z() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            r0 r0Var = (r0) nVar.e;
            int iOrdinal = r0Var.ordinal();
            if (iOrdinal == 1) {
                jVar = S0.j.f1753t;
            } else if (iOrdinal == 2) {
                jVar = S0.j.f1754u;
            } else if (iOrdinal == 3) {
                jVar = S0.j.v;
            } else {
                if (iOrdinal != 4) {
                    throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var.b());
                }
                jVar = S0.j.f1754u;
            }
            return S0.v.b(jVar, new C0690c(C0400a.a(jB.y().j()), 25), (Integer) nVar.f2492f);
        } catch (com.google.crypto.tink.shaded.protobuf.B unused) {
            throw new GeneralSecurityException("Parsing ChaCha20Poly1305Key failed");
        }
    }

    private final R0.b g(Y0.n nVar) throws GeneralSecurityException {
        S0.j jVar;
        if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.XChaCha20Poly1305Key")) {
            throw new IllegalArgumentException("Wrong type URL in call to XChaCha20Poly1305Parameters.parseParameters");
        }
        try {
            u0 u0VarB = u0.B((AbstractC0303h) nVar.f2490c, C0309n.a());
            if (u0VarB.z() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            r0 r0Var = (r0) nVar.e;
            int iOrdinal = r0Var.ordinal();
            if (iOrdinal == 1) {
                jVar = S0.j.f1755w;
            } else if (iOrdinal == 2) {
                jVar = S0.j.f1756x;
            } else if (iOrdinal == 3) {
                jVar = S0.j.f1757y;
            } else {
                if (iOrdinal != 4) {
                    throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var.b());
                }
                jVar = S0.j.f1756x;
            }
            return S0.z.b(jVar, new C0690c(C0400a.a(u0VarB.y().j()), 25), (Integer) nVar.f2492f);
        } catch (com.google.crypto.tink.shaded.protobuf.B unused) {
            throw new GeneralSecurityException("Parsing XChaCha20Poly1305Key failed");
        }
    }

    private final R0.b h(Y0.n nVar) throws GeneralSecurityException {
        if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.AesSivKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to AesSivParameters.parseParameters");
        }
        try {
            d1.F fB = d1.F.B((AbstractC0303h) nVar.f2490c, C0309n.a());
            if (fB.z() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            int size = fB.y().size();
            if (size != 32 && size != 48 && size != 64) {
                throw new InvalidAlgorithmParameterException(String.format("Invalid key size %d; only 32-byte, 48-byte and 64-byte AES-SIV keys are supported", Integer.valueOf(size)));
            }
            r0 r0Var = (r0) nVar.e;
            Map map = W0.d.e;
            if (!map.containsKey(r0Var)) {
                throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var.b());
            }
            W0.b bVar = (W0.b) map.get(r0Var);
            if (bVar == null) {
                throw new GeneralSecurityException("Variant is not set");
            }
            W0.c cVar = new W0.c(size, bVar);
            C0747k c0747k = new C0747k(18, false);
            c0747k.f6832c = null;
            c0747k.f6833d = null;
            c0747k.f6831b = cVar;
            c0747k.f6832c = new C0690c(C0400a.a(fB.y().j()), 25);
            c0747k.f6833d = (Integer) nVar.f2492f;
            return c0747k.u();
        } catch (com.google.crypto.tink.shaded.protobuf.B unused) {
            throw new GeneralSecurityException("Parsing AesSivKey failed");
        }
    }

    private final R0.b i(Y0.n nVar) throws GeneralSecurityException {
        if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.AesCmacKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to AesCmacParameters.parseParameters");
        }
        try {
            C0329b c0329bD = C0329b.D((AbstractC0303h) nVar.f2490c, C0309n.a());
            if (c0329bD.B() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            C0747k c0747k = new C0747k(22, false);
            c0747k.f6831b = null;
            c0747k.f6832c = null;
            c0747k.f6833d = Z0.d.f2558f;
            c0747k.X(c0329bD.z().size());
            int iY = c0329bD.A().y();
            if (iY < 10 || 16 < iY) {
                throw new GeneralSecurityException(com.google.crypto.tink.shaded.protobuf.S.d(iY, "Invalid tag size for AesCmacParameters: "));
            }
            c0747k.f6832c = Integer.valueOf(iY);
            c0747k.f6833d = Z0.f.a((r0) nVar.e);
            Z0.e eVarW = c0747k.w();
            C0747k c0747k2 = new C0747k(21, false);
            c0747k2.f6832c = null;
            c0747k2.f6833d = null;
            c0747k2.f6831b = eVarW;
            c0747k2.f6832c = new C0690c(C0400a.a(c0329bD.z().j()), 25);
            c0747k2.f6833d = (Integer) nVar.f2492f;
            return c0747k2.v();
        } catch (com.google.crypto.tink.shaded.protobuf.B | IllegalArgumentException unused) {
            throw new GeneralSecurityException("Parsing AesCmacKey failed");
        }
    }

    @Override // m3.InterfaceC0556c
    public boolean a(View view) {
        return view.hasFocus();
    }

    public com.google.android.gms.common.internal.r b(Context context) {
        switch (this.f41a) {
            case 25:
                return new com.google.android.gms.common.internal.r(context, 22);
            default:
                return new C0717b(context, 22);
        }
    }

    public l3.q c(Context context, com.google.android.gms.common.internal.r rVar) {
        switch (this.f41a) {
            case 27:
                return new l3.q(context, rVar);
            default:
                return new C0719d(context, rVar);
        }
    }

    public R0.b d(Y0.n nVar) throws GeneralSecurityException {
        switch (this.f41a) {
            case 3:
                if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey")) {
                    throw new IllegalArgumentException("Wrong type URL in call to AesCtrHmacAeadProtoSerialization.parseKey");
                }
                try {
                    C0335h c0335hD = C0335h.D((AbstractC0303h) nVar.f2490c, C0309n.a());
                    if (c0335hD.B() != 0) {
                        throw new GeneralSecurityException("Only version 0 keys are accepted");
                    }
                    R0.k kVar = new R0.k(1);
                    kVar.f1691b = null;
                    kVar.f1692c = null;
                    kVar.f1693d = null;
                    kVar.e = null;
                    S0.j jVar = S0.j.f1743j;
                    kVar.f1694f = jVar;
                    int size = c0335hD.z().A().size();
                    if (size != 16 && size != 24 && size != 32) {
                        throw new InvalidAlgorithmParameterException(String.format("Invalid key size %d; only 16-byte, 24-byte and 32-byte AES keys are supported", Integer.valueOf(size)));
                    }
                    kVar.f1691b = Integer.valueOf(size);
                    int size2 = c0335hD.A().A().size();
                    if (size2 < 16) {
                        throw new InvalidAlgorithmParameterException(String.format("Invalid key size in bytes %d; HMAC key must be at least 16 bytes", Integer.valueOf(size2)));
                    }
                    kVar.f1692c = Integer.valueOf(size2);
                    int iA = c0335hD.A().B().A();
                    if (iA < 10) {
                        throw new GeneralSecurityException(String.format("Invalid tag size in bytes %d; must be at least 10 bytes", Integer.valueOf(iA)));
                    }
                    kVar.f1693d = Integer.valueOf(iA);
                    kVar.e = S0.l.a(c0335hD.A().B().z());
                    r0 r0Var = (r0) nVar.e;
                    int iOrdinal = r0Var.ordinal();
                    if (iOrdinal == 1) {
                        jVar = S0.j.f1741h;
                    } else if (iOrdinal == 2) {
                        jVar = S0.j.f1742i;
                    } else if (iOrdinal != 3) {
                        if (iOrdinal != 4) {
                            throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var.b());
                        }
                        jVar = S0.j.f1742i;
                    }
                    kVar.f1694f = jVar;
                    S0.k kVarI = kVar.i();
                    C0053n c0053n = new C0053n(6, false);
                    c0053n.f707c = null;
                    c0053n.f708d = null;
                    c0053n.e = null;
                    c0053n.f706b = kVarI;
                    c0053n.f707c = new C0690c(C0400a.a(c0335hD.z().A().j()), 25);
                    c0053n.f708d = new C0690c(C0400a.a(c0335hD.A().A().j()), 25);
                    c0053n.e = (Integer) nVar.f2492f;
                    return c0053n.c();
                } catch (com.google.crypto.tink.shaded.protobuf.B unused) {
                    throw new GeneralSecurityException("Parsing AesCtrHmacAeadKey failed");
                }
            case 4:
                if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.AesEaxKey")) {
                    throw new IllegalArgumentException("Wrong type URL in call to AesEaxParameters.parseParameters");
                }
                try {
                    d1.r rVarD = d1.r.D((AbstractC0303h) nVar.f2490c, C0309n.a());
                    if (rVarD.B() != 0) {
                        throw new GeneralSecurityException("Only version 0 keys are accepted");
                    }
                    S0.j jVar2 = S0.j.f1746m;
                    int size3 = rVarD.z().size();
                    if (size3 != 16 && size3 != 24 && size3 != 32) {
                        throw new InvalidAlgorithmParameterException(String.format("Invalid key size %d; only 16-byte, 24-byte and 32-byte AES keys are supported", Integer.valueOf(size3)));
                    }
                    int iY = rVarD.A().y();
                    if (iY != 12 && iY != 16) {
                        throw new GeneralSecurityException(String.format("Invalid IV size in bytes %d; acceptable values have 12 or 16 bytes", Integer.valueOf(iY)));
                    }
                    r0 r0Var2 = (r0) nVar.e;
                    int iOrdinal2 = r0Var2.ordinal();
                    if (iOrdinal2 == 1) {
                        jVar2 = S0.j.f1744k;
                    } else if (iOrdinal2 == 2) {
                        jVar2 = S0.j.f1745l;
                    } else if (iOrdinal2 != 3) {
                        if (iOrdinal2 != 4) {
                            throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var2.b());
                        }
                        jVar2 = S0.j.f1745l;
                    }
                    S0.n nVar2 = new S0.n(size3, iY, 16, jVar2);
                    C0747k c0747k = new C0747k(14, false);
                    c0747k.f6832c = null;
                    c0747k.f6833d = null;
                    c0747k.f6831b = nVar2;
                    c0747k.f6832c = new C0690c(C0400a.a(rVarD.z().j()), 25);
                    c0747k.f6833d = (Integer) nVar.f2492f;
                    return c0747k.r();
                } catch (com.google.crypto.tink.shaded.protobuf.B unused2) {
                    throw new GeneralSecurityException("Parsing AesEaxcKey failed");
                }
            case 5:
                if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.AesGcmKey")) {
                    throw new IllegalArgumentException("Wrong type URL in call to AesGcmParameters.parseParameters");
                }
                try {
                    C0350x c0350xB = C0350x.B((AbstractC0303h) nVar.f2490c, C0309n.a());
                    if (c0350xB.z() != 0) {
                        throw new GeneralSecurityException("Only version 0 keys are accepted");
                    }
                    S0.j jVar3 = S0.j.f1749p;
                    int size4 = c0350xB.y().size();
                    if (size4 != 16 && size4 != 24 && size4 != 32) {
                        throw new InvalidAlgorithmParameterException(String.format("Invalid key size %d; only 16-byte, 24-byte and 32-byte AES keys are supported", Integer.valueOf(size4)));
                    }
                    r0 r0Var3 = (r0) nVar.e;
                    int iOrdinal3 = r0Var3.ordinal();
                    if (iOrdinal3 == 1) {
                        jVar3 = S0.j.f1747n;
                    } else if (iOrdinal3 == 2) {
                        jVar3 = S0.j.f1748o;
                    } else if (iOrdinal3 != 3) {
                        if (iOrdinal3 != 4) {
                            throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var3.b());
                        }
                        jVar3 = S0.j.f1748o;
                    }
                    S0.q qVar = new S0.q(size4, 12, 16, jVar3);
                    C0747k c0747k2 = new C0747k(15, false);
                    c0747k2.f6832c = null;
                    c0747k2.f6833d = null;
                    c0747k2.f6831b = qVar;
                    c0747k2.f6832c = new C0690c(C0400a.a(c0350xB.y().j()), 25);
                    c0747k2.f6833d = (Integer) nVar.f2492f;
                    return c0747k2.s();
                } catch (com.google.crypto.tink.shaded.protobuf.B unused3) {
                    throw new GeneralSecurityException("Parsing AesGcmKey failed");
                }
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.AesGcmSivKey")) {
                    throw new IllegalArgumentException("Wrong type URL in call to AesGcmSivParameters.parseParameters");
                }
                try {
                    C0326B c0326bB = C0326B.B((AbstractC0303h) nVar.f2490c, C0309n.a());
                    if (c0326bB.z() != 0) {
                        throw new GeneralSecurityException("Only version 0 keys are accepted");
                    }
                    S0.j jVar4 = S0.j.f1752s;
                    int size5 = c0326bB.y().size();
                    if (size5 != 16 && size5 != 32) {
                        throw new InvalidAlgorithmParameterException(String.format("Invalid key size %d; only 16-byte and 32-byte AES keys are supported", Integer.valueOf(size5)));
                    }
                    r0 r0Var4 = (r0) nVar.e;
                    int iOrdinal4 = r0Var4.ordinal();
                    if (iOrdinal4 == 1) {
                        jVar4 = S0.j.f1750q;
                    } else if (iOrdinal4 == 2) {
                        jVar4 = S0.j.f1751r;
                    } else if (iOrdinal4 != 3) {
                        if (iOrdinal4 != 4) {
                            throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var4.b());
                        }
                        jVar4 = S0.j.f1751r;
                    }
                    S0.t tVar = new S0.t(size5, jVar4);
                    C0747k c0747k3 = new C0747k(16, false);
                    c0747k3.f6832c = null;
                    c0747k3.f6833d = null;
                    c0747k3.f6831b = tVar;
                    c0747k3.f6832c = new C0690c(C0400a.a(c0326bB.y().j()), 25);
                    c0747k3.f6833d = (Integer) nVar.f2492f;
                    return c0747k3.t();
                } catch (com.google.crypto.tink.shaded.protobuf.B unused4) {
                    throw new GeneralSecurityException("Parsing AesGcmSivKey failed");
                }
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return f(nVar);
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return g(nVar);
            case 9:
                return h(nVar);
            case 10:
            default:
                if (!((String) nVar.f2488a).equals("type.googleapis.com/google.crypto.tink.HmacKey")) {
                    throw new IllegalArgumentException("Wrong type URL in call to HmacProtoSerialization.parseKey");
                }
                try {
                    d1.Q qE = d1.Q.E((AbstractC0303h) nVar.f2490c, C0309n.a());
                    if (qE.C() != 0) {
                        throw new GeneralSecurityException("Only version 0 keys are accepted");
                    }
                    C0053n c0053n2 = new C0053n(8, false);
                    c0053n2.f706b = null;
                    c0053n2.f707c = null;
                    c0053n2.f708d = null;
                    c0053n2.e = Z0.d.f2567o;
                    c0053n2.f706b = Integer.valueOf(qE.A().size());
                    c0053n2.f707c = Integer.valueOf(qE.B().A());
                    c0053n2.f708d = Z0.l.a(qE.B().z());
                    c0053n2.e = Z0.l.b((r0) nVar.e);
                    Z0.k kVarD = c0053n2.d();
                    C0747k c0747k4 = new C0747k(23, false);
                    c0747k4.f6832c = null;
                    c0747k4.f6833d = null;
                    c0747k4.f6831b = kVarD;
                    c0747k4.f6832c = new C0690c(C0400a.a(qE.A().j()), 25);
                    c0747k4.f6833d = (Integer) nVar.f2492f;
                    return c0747k4.x();
                } catch (com.google.crypto.tink.shaded.protobuf.B | IllegalArgumentException unused5) {
                    throw new GeneralSecurityException("Parsing HmacKey failed");
                }
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return i(nVar);
        }
    }

    @Override // l1.d
    public Object e(R0.k kVar) {
        switch (this.f41a) {
            case 19:
                return (ScheduledExecutorService) ExecutorsRegistrar.f3865a.get();
            case 20:
                return (ScheduledExecutorService) ExecutorsRegistrar.f3867c.get();
            case 21:
                return (ScheduledExecutorService) ExecutorsRegistrar.f3866b.get();
            case 22:
                l1.n nVar = ExecutorsRegistrar.f3865a;
                return m1.k.f5790a;
            default:
                Set setD = kVar.d(l1.r.a(C0688a.class));
                C0690c c0690c = C0690c.f6639c;
                if (c0690c == null) {
                    synchronized (C0690c.class) {
                        try {
                            c0690c = C0690c.f6639c;
                            if (c0690c == null) {
                                c0690c = new C0690c(0);
                                C0690c.f6639c = c0690c;
                            }
                        } finally {
                        }
                        break;
                    }
                }
                return new C0689b(setD, c0690c);
        }
    }
}
