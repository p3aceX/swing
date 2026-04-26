package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: loaded from: classes.dex */
public final class u0 extends AbstractC0316v {
    private static final u0 DEFAULT_INSTANCE;
    public static final int KEY_VALUE_FIELD_NUMBER = 3;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int VERSION_FIELD_NUMBER = 1;
    private AbstractC0303h keyValue_ = AbstractC0303h.f3791b;
    private int version_;

    static {
        u0 u0Var = new u0();
        DEFAULT_INSTANCE = u0Var;
        AbstractC0316v.t(u0.class, u0Var);
    }

    public static t0 A() {
        return (t0) DEFAULT_INSTANCE.h();
    }

    public static u0 B(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (u0) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(u0 u0Var) {
        u0Var.version_ = 0;
    }

    public static void x(u0 u0Var, C0302g c0302g) {
        u0Var.getClass();
        u0Var.keyValue_ = c0302g;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0002\u0000\u0000\u0001\u0003\u0002\u0000\u0000\u0000\u0001\u000b\u0003\n", new Object[]{"version_", "keyValue_"});
            case 3:
                return new u0();
            case 4:
                return new t0(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (u0.class) {
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

    public final AbstractC0303h y() {
        return this.keyValue_;
    }

    public final int z() {
        return this.version_;
    }
}
