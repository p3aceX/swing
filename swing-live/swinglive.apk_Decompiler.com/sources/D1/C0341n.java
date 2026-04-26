package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: renamed from: d1.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0341n extends AbstractC0316v {
    private static final C0341n DEFAULT_INSTANCE;
    public static final int KEY_SIZE_FIELD_NUMBER = 2;
    public static final int PARAMS_FIELD_NUMBER = 1;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER;
    private int keySize_;
    private C0343p params_;

    static {
        C0341n c0341n = new C0341n();
        DEFAULT_INSTANCE = c0341n;
        AbstractC0316v.t(C0341n.class, c0341n);
    }

    public static C0340m B() {
        return (C0340m) DEFAULT_INSTANCE.h();
    }

    public static void w(C0341n c0341n, C0343p c0343p) {
        c0341n.getClass();
        c0341n.params_ = c0343p;
    }

    public static void x(C0341n c0341n, int i4) {
        c0341n.keySize_ = i4;
    }

    public static C0341n y() {
        return DEFAULT_INSTANCE;
    }

    public final C0343p A() {
        C0343p c0343p = this.params_;
        return c0343p == null ? C0343p.x() : c0343p;
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
                return new C0341n();
            case 4:
                return new C0340m(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (C0341n.class) {
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

    public final int z() {
        return this.keySize_;
    }
}
