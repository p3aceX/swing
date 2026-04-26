package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0333f extends AbstractC0316v {
    private static final C0333f DEFAULT_INSTANCE;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int TAG_SIZE_FIELD_NUMBER = 1;
    private int tagSize_;

    static {
        C0333f c0333f = new C0333f();
        DEFAULT_INSTANCE = c0333f;
        AbstractC0316v.t(C0333f.class, c0333f);
    }

    public static void w(C0333f c0333f) {
        c0333f.tagSize_ = 16;
    }

    public static C0333f x() {
        return DEFAULT_INSTANCE;
    }

    public static C0332e z() {
        return (C0332e) DEFAULT_INSTANCE.h();
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0000\u0000\u0001\u000b", new Object[]{"tagSize_"});
            case 3:
                return new C0333f();
            case 4:
                return new C0332e(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0333f.class) {
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
        return this.tagSize_;
    }
}
