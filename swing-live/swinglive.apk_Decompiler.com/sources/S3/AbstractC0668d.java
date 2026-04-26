package s3;

import I3.p;
import Q3.C;
import Q3.E;
import Q3.F;
import Q3.O;
import Q3.r0;
import Q3.t0;
import Q3.y0;
import S3.e;
import S3.m;
import e1.AbstractC0367g;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.List;
import x3.AbstractC0729i;
import y3.C0763d;
import y3.C0768i;
import y3.InterfaceC0767h;

/* JADX INFO: renamed from: s3.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0668d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final List f6506a = AbstractC0729i.T("NativePRNGNonBlocking", "WINDOWS-PRNG", "DRBG");

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final e f6507b = m.a(1024, null, 6);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final y0 f6508c;

    static {
        C c5 = new C("nonce-generator");
        X3.e eVar = O.f1596a;
        t0 t0Var = t0.f1659b;
        eVar.getClass();
        InterfaceC0767h interfaceC0767hS = AbstractC0367g.A(eVar, t0Var).s(c5);
        E e = E.f1572b;
        p c0667c = new C0667c(2, null);
        InterfaceC0767h interfaceC0767hJ = F.j(C0768i.f6945a, interfaceC0767hS, true);
        X3.e eVar2 = O.f1596a;
        if (interfaceC0767hJ != eVar2 && interfaceC0767hJ.i(C0763d.f6944a) == null) {
            interfaceC0767hJ = interfaceC0767hJ.s(eVar2);
        }
        r0 r0Var = new r0(interfaceC0767hJ, c0667c);
        r0Var.e0(e, r0Var, c0667c);
        f6508c = r0Var;
    }

    public static final SecureRandom a(String str) {
        try {
            return str != null ? SecureRandom.getInstance(str) : new SecureRandom();
        } catch (NoSuchAlgorithmException unused) {
            return null;
        }
    }
}
