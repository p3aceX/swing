package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: loaded from: classes.dex */
public final class T extends AbstractC0316v {
    private static final T DEFAULT_INSTANCE;
    public static final int KEY_SIZE_FIELD_NUMBER = 2;
    public static final int PARAMS_FIELD_NUMBER = 1;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int VERSION_FIELD_NUMBER = 3;
    private int keySize_;
    private V params_;
    private int version_;

    static {
        T t4 = new T();
        DEFAULT_INSTANCE = t4;
        AbstractC0316v.t(T.class, t4);
    }

    public static S B() {
        return (S) DEFAULT_INSTANCE.h();
    }

    public static T C(AbstractC0303h abstractC0303h, C0309n c0309n) {
        return (T) AbstractC0316v.r(DEFAULT_INSTANCE, abstractC0303h, c0309n);
    }

    public static void w(T t4, V v) {
        t4.getClass();
        t4.params_ = v;
    }

    public static void x(T t4, int i4) {
        t4.keySize_ = i4;
    }

    public static T y() {
        return DEFAULT_INSTANCE;
    }

    public final V A() {
        V v = this.params_;
        return v == null ? V.y() : v;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001\t\u0002\u000b\u0003\u000b", new Object[]{"params_", "keySize_", "version_"});
            case 3:
                return new T();
            case 4:
                return new S(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (T.class) {
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
