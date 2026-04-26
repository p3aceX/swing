package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0329b extends AbstractC0316v {
    private static final C0329b DEFAULT_INSTANCE;
    public static final int KEY_VALUE_FIELD_NUMBER = 2;
    public static final int PARAMS_FIELD_NUMBER = 3;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int VERSION_FIELD_NUMBER = 1;
    private AbstractC0303h keyValue_ = AbstractC0303h.f3791b;
    private C0333f params_;
    private int version_;

    static {
        C0329b c0329b = new C0329b();
        DEFAULT_INSTANCE = c0329b;
        AbstractC0316v.t(C0329b.class, c0329b);
    }

    public static C0328a C() {
        return (C0328a) DEFAULT_INSTANCE.h();
    }

    public static C0329b D(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (C0329b) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(C0329b c0329b) {
        c0329b.version_ = 0;
    }

    public static void x(C0329b c0329b, C0302g c0302g) {
        c0329b.getClass();
        c0329b.keyValue_ = c0302g;
    }

    public static void y(C0329b c0329b, C0333f c0333f) {
        c0329b.getClass();
        c0333f.getClass();
        c0329b.params_ = c0333f;
    }

    public final C0333f A() {
        C0333f c0333f = this.params_;
        return c0333f == null ? C0333f.x() : c0333f;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002\n\u0003\t", new Object[]{"version_", "keyValue_", "params_"});
            case 3:
                return new C0329b();
            case 4:
                return new C0328a(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0329b.class) {
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

    public final AbstractC0303h z() {
        return this.keyValue_;
    }
}
