package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0339l extends AbstractC0316v {
    private static final C0339l DEFAULT_INSTANCE;
    public static final int KEY_VALUE_FIELD_NUMBER = 3;
    public static final int PARAMS_FIELD_NUMBER = 2;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int VERSION_FIELD_NUMBER = 1;
    private AbstractC0303h keyValue_ = AbstractC0303h.f3791b;
    private C0343p params_;
    private int version_;

    static {
        C0339l c0339l = new C0339l();
        DEFAULT_INSTANCE = c0339l;
        AbstractC0316v.t(C0339l.class, c0339l);
    }

    public static C0338k D() {
        return (C0338k) DEFAULT_INSTANCE.h();
    }

    public static void w(C0339l c0339l) {
        c0339l.version_ = 0;
    }

    public static void x(C0339l c0339l, C0343p c0343p) {
        c0339l.getClass();
        c0343p.getClass();
        c0339l.params_ = c0343p;
    }

    public static void y(C0339l c0339l, C0302g c0302g) {
        c0339l.getClass();
        c0339l.keyValue_ = c0302g;
    }

    public static C0339l z() {
        return DEFAULT_INSTANCE;
    }

    public final AbstractC0303h A() {
        return this.keyValue_;
    }

    public final C0343p B() {
        C0343p c0343p = this.params_;
        return c0343p == null ? C0343p.x() : c0343p;
    }

    public final int C() {
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002\t\u0003\n", new Object[]{"version_", "params_", "keyValue_"});
            case 3:
                return new C0339l();
            case 4:
                return new C0338k(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0339l.class) {
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
}
