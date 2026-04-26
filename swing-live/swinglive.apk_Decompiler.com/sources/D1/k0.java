package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0297b;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0315u;
import com.google.crypto.tink.shaded.protobuf.InterfaceC0319y;

/* JADX INFO: loaded from: classes.dex */
public final class k0 extends AbstractC0316v {
    private static final k0 DEFAULT_INSTANCE;
    public static final int KEY_INFO_FIELD_NUMBER = 2;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int PRIMARY_KEY_ID_FIELD_NUMBER = 1;
    private InterfaceC0319y keyInfo_ = com.google.crypto.tink.shaded.protobuf.a0.f3769d;
    private int primaryKeyId_;

    static {
        k0 k0Var = new k0();
        DEFAULT_INSTANCE = k0Var;
        AbstractC0316v.t(k0.class, k0Var);
    }

    public static void w(k0 k0Var, int i4) {
        k0Var.primaryKeyId_ = i4;
    }

    public static void x(k0 k0Var, j0 j0Var) {
        k0Var.getClass();
        InterfaceC0319y interfaceC0319y = k0Var.keyInfo_;
        if (!((AbstractC0297b) interfaceC0319y).f3772a) {
            int size = interfaceC0319y.size();
            k0Var.keyInfo_ = interfaceC0319y.c(size == 0 ? 10 : size * 2);
        }
        k0Var.keyInfo_.add(j0Var);
    }

    public static h0 z() {
        return (h0) DEFAULT_INSTANCE.h();
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0001\u0000\u0001\u000b\u0002\u001b", new Object[]{"primaryKeyId_", "keyInfo_", j0.class});
            case 3:
                return new k0();
            case 4:
                return new h0(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (k0.class) {
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

    public final j0 y() {
        return (j0) this.keyInfo_.get(0);
    }
}
