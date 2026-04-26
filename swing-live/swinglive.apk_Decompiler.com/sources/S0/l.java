package S0;

import A.C0003c;
import d1.O;
import f1.C0400a;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public abstract class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Y0.j f1764a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Y0.i f1765b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Y0.b f1766c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final Y0.a f1767d;

    static {
        C0400a c0400aB = Y0.s.b("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey");
        f1764a = new Y0.j(k.class);
        f1765b = new Y0.i(c0400aB);
        f1766c = new Y0.b(f.class);
        f1767d = new Y0.a(c0400aB, new C0003c(3));
    }

    public static j a(O o4) throws GeneralSecurityException {
        int iOrdinal = o4.ordinal();
        if (iOrdinal == 1) {
            return j.f1737c;
        }
        if (iOrdinal == 2) {
            return j.f1739f;
        }
        if (iOrdinal == 3) {
            return j.e;
        }
        if (iOrdinal == 4) {
            return j.f1740g;
        }
        if (iOrdinal == 5) {
            return j.f1738d;
        }
        throw new GeneralSecurityException("Unable to parse HashType: " + o4.a());
    }
}
