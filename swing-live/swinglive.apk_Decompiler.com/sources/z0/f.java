package Z0;

import A.C0003c;
import Y0.s;
import d1.r0;
import f1.C0400a;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public abstract class f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Y0.j f2573a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Y0.i f2574b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Y0.b f2575c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final Y0.a f2576d;

    static {
        C0400a c0400aB = s.b("type.googleapis.com/google.crypto.tink.AesCmacKey");
        f2573a = new Y0.j(e.class);
        f2574b = new Y0.i(c0400aB);
        f2575c = new Y0.b(a.class);
        f2576d = new Y0.a(c0400aB, new C0003c(11));
    }

    public static d a(r0 r0Var) throws GeneralSecurityException {
        int iOrdinal = r0Var.ordinal();
        if (iOrdinal == 1) {
            return d.f2556c;
        }
        if (iOrdinal == 2) {
            return d.e;
        }
        if (iOrdinal == 3) {
            return d.f2558f;
        }
        if (iOrdinal == 4) {
            return d.f2557d;
        }
        throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var.b());
    }
}
