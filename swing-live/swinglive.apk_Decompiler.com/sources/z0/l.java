package Z0;

import A.C0003c;
import Y0.s;
import d1.O;
import d1.r0;
import f1.C0400a;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public abstract class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Y0.j f2583a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Y0.i f2584b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Y0.b f2585c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final Y0.a f2586d;

    static {
        C0400a c0400aB = s.b("type.googleapis.com/google.crypto.tink.HmacKey");
        f2583a = new Y0.j(k.class);
        f2584b = new Y0.i(c0400aB);
        f2585c = new Y0.b(j.class);
        f2586d = new Y0.a(c0400aB, new C0003c(13));
    }

    public static d a(O o4) throws GeneralSecurityException {
        int iOrdinal = o4.ordinal();
        if (iOrdinal == 1) {
            return d.f2559g;
        }
        if (iOrdinal == 2) {
            return d.f2562j;
        }
        if (iOrdinal == 3) {
            return d.f2561i;
        }
        if (iOrdinal == 4) {
            return d.f2563k;
        }
        if (iOrdinal == 5) {
            return d.f2560h;
        }
        throw new GeneralSecurityException("Unable to parse HashType: " + o4.a());
    }

    public static d b(r0 r0Var) throws GeneralSecurityException {
        int iOrdinal = r0Var.ordinal();
        if (iOrdinal == 1) {
            return d.f2564l;
        }
        if (iOrdinal == 2) {
            return d.f2566n;
        }
        if (iOrdinal == 3) {
            return d.f2567o;
        }
        if (iOrdinal == 4) {
            return d.f2565m;
        }
        throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + r0Var.b());
    }
}
