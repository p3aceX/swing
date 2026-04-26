package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0331d extends AbstractC0316v {
    private static final C0331d DEFAULT_INSTANCE;
    public static final int KEY_SIZE_FIELD_NUMBER = 1;
    public static final int PARAMS_FIELD_NUMBER = 2;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER;
    private int keySize_;
    private C0333f params_;

    static {
        C0331d c0331d = new C0331d();
        DEFAULT_INSTANCE = c0331d;
        AbstractC0316v.t(C0331d.class, c0331d);
    }

    public static C0330c A() {
        return (C0330c) DEFAULT_INSTANCE.h();
    }

    public static C0331d B(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (C0331d) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(C0331d c0331d) {
        c0331d.keySize_ = 32;
    }

    public static void x(C0331d c0331d, C0333f c0333f) {
        c0331d.getClass();
        c0331d.params_ = c0333f;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0000\u0000\u0001\u000b\u0002\t", new Object[]{"keySize_", "params_"});
            case 3:
                return new C0331d();
            case 4:
                return new C0330c(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0331d.class) {
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

    public final C0333f z() {
        C0333f c0333f = this.params_;
        return c0333f == null ? C0333f.x() : c0333f;
    }
}
