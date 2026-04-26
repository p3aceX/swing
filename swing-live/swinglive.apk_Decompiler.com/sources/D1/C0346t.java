package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.t, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0346t extends AbstractC0316v {
    private static final C0346t DEFAULT_INSTANCE;
    public static final int KEY_SIZE_FIELD_NUMBER = 2;
    public static final int PARAMS_FIELD_NUMBER = 1;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER;
    private int keySize_;
    private C0348v params_;

    static {
        C0346t c0346t = new C0346t();
        DEFAULT_INSTANCE = c0346t;
        AbstractC0316v.t(C0346t.class, c0346t);
    }

    public static C0345s A() {
        return (C0345s) DEFAULT_INSTANCE.h();
    }

    public static C0346t B(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (C0346t) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(C0346t c0346t, C0348v c0348v) {
        c0346t.getClass();
        c0346t.params_ = c0348v;
    }

    public static void x(C0346t c0346t, int i4) {
        c0346t.keySize_ = i4;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\t\u0002\u000b", new Object[]{"params_", "keySize_"});
            case 3:
                return new C0346t();
            case 4:
                return new C0345s(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0346t.class) {
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

    public final int y() {
        return this.keySize_;
    }

    public final C0348v z() {
        C0348v c0348v = this.params_;
        return c0348v == null ? C0348v.x() : c0348v;
    }
}
