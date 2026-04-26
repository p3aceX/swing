package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0335h extends AbstractC0316v {
    public static final int AES_CTR_KEY_FIELD_NUMBER = 2;
    private static final C0335h DEFAULT_INSTANCE;
    public static final int HMAC_KEY_FIELD_NUMBER = 3;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int VERSION_FIELD_NUMBER = 1;
    private C0339l aesCtrKey_;
    private Q hmacKey_;
    private int version_;

    static {
        C0335h c0335h = new C0335h();
        DEFAULT_INSTANCE = c0335h;
        AbstractC0316v.t(C0335h.class, c0335h);
    }

    public static C0334g C() {
        return (C0334g) DEFAULT_INSTANCE.h();
    }

    public static C0335h D(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (C0335h) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(C0335h c0335h) {
        c0335h.version_ = 0;
    }

    public static void x(C0335h c0335h, C0339l c0339l) {
        c0335h.getClass();
        c0339l.getClass();
        c0335h.aesCtrKey_ = c0339l;
    }

    public static void y(C0335h c0335h, Q q4) {
        c0335h.getClass();
        q4.getClass();
        c0335h.hmacKey_ = q4;
    }

    public final Q A() {
        Q q4 = this.hmacKey_;
        return q4 == null ? Q.z() : q4;
    }

    public final int B() {
        return this.version_;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0316v
    public final Object i(int i4) {
        com.google.crypto.tink.shaded.protobuf.X c0315u;
        switch (K.j.b(i4)) {
            case 0:
                return (byte) 1;
            case 1:
                return null;
            case 2:
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002\t\u0003\t", new Object[]{"version_", "aesCtrKey_", "hmacKey_"});
            case 3:
                return new C0335h();
            case 4:
                return new C0334g(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0335h.class) {
                    try {
                        c0315u = PARSER;
                        if (c0315u == null) {
                            c0315u = new C0315u();
                            PARSER = c0315u;
                        }
                    } catch (Throwable th) {
                        throw th;
                    }
                    break;
                }
                return c0315u;
            default:
                throw new UnsupportedOperationException();
        }
    }

    public final C0339l z() {
        C0339l c0339l = this.aesCtrKey_;
        return c0339l == null ? C0339l.z() : c0339l;
    }
}
