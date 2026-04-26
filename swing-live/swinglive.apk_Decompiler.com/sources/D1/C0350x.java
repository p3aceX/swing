package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.x, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0350x extends AbstractC0316v {
    private static final C0350x DEFAULT_INSTANCE;
    public static final int KEY_VALUE_FIELD_NUMBER = 3;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int VERSION_FIELD_NUMBER = 1;
    private AbstractC0303h keyValue_ = AbstractC0303h.f3791b;
    private int version_;

    static {
        C0350x c0350x = new C0350x();
        DEFAULT_INSTANCE = c0350x;
        AbstractC0316v.t(C0350x.class, c0350x);
    }

    public static C0349w A() {
        return (C0349w) DEFAULT_INSTANCE.h();
    }

    public static C0350x B(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (C0350x) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(C0350x c0350x) {
        c0350x.version_ = 0;
    }

    public static void x(C0350x c0350x, C0302g c0302g) {
        c0350x.getClass();
        c0350x.keyValue_ = c0302g;
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
                return new C0350x();
            case 4:
                return new C0349w(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0350x.class) {
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
