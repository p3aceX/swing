package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0337j extends AbstractC0316v {
    public static final int AES_CTR_KEY_FORMAT_FIELD_NUMBER = 1;
    private static final C0337j DEFAULT_INSTANCE;
    public static final int HMAC_KEY_FORMAT_FIELD_NUMBER = 2;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER;
    private C0341n aesCtrKeyFormat_;
    private T hmacKeyFormat_;

    static {
        C0337j c0337j = new C0337j();
        DEFAULT_INSTANCE = c0337j;
        AbstractC0316v.t(C0337j.class, c0337j);
    }

    public static C0336i A() {
        return (C0336i) DEFAULT_INSTANCE.h();
    }

    public static C0337j B(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (C0337j) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(C0337j c0337j, C0341n c0341n) {
        c0337j.getClass();
        c0337j.aesCtrKeyFormat_ = c0341n;
    }

    public static void x(C0337j c0337j, T t4) {
        c0337j.getClass();
        c0337j.hmacKeyFormat_ = t4;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\t\u0002\t", new Object[]{"aesCtrKeyFormat_", "hmacKeyFormat_"});
            case 3:
                return new C0337j();
            case 4:
                return new C0336i(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0337j.class) {
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

    public final C0341n y() {
        C0341n c0341n = this.aesCtrKeyFormat_;
        return c0341n == null ? C0341n.y() : c0341n;
    }

    public final T z() {
        T t4 = this.hmacKeyFormat_;
        return t4 == null ? T.y() : t4;
    }
}
