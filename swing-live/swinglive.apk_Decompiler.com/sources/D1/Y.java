package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: loaded from: classes.dex */
public final class Y extends AbstractC0316v {
    private static final Y DEFAULT_INSTANCE;
    public static final int KEY_MATERIAL_TYPE_FIELD_NUMBER = 3;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int TYPE_URL_FIELD_NUMBER = 1;
    public static final int VALUE_FIELD_NUMBER = 2;
    private int keyMaterialType_;
    private String typeUrl_ = "";
    private AbstractC0303h value_ = AbstractC0303h.f3791b;

    static {
        Y y4 = new Y();
        DEFAULT_INSTANCE = y4;
        AbstractC0316v.t(Y.class, y4);
    }

    public static W D() {
        return (W) DEFAULT_INSTANCE.h();
    }

    public static void w(Y y4, String str) {
        y4.getClass();
        str.getClass();
        y4.typeUrl_ = str;
    }

    public static void x(Y y4, C0302g c0302g) {
        y4.getClass();
        y4.value_ = c0302g;
    }

    public static void y(Y y4, X x4) {
        y4.getClass();
        if (x4 != X.UNRECOGNIZED) {
            y4.keyMaterialType_ = x4.f3908a;
        } else {
            x4.getClass();
            throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
        }
    }

    public static Y z() {
        return DEFAULT_INSTANCE;
    }

    public final X A() {
        int i4 = this.keyMaterialType_;
        X x4 = i4 != 0 ? i4 != 1 ? i4 != 2 ? i4 != 3 ? i4 != 4 ? null : X.REMOTE : X.ASYMMETRIC_PUBLIC : X.ASYMMETRIC_PRIVATE : X.SYMMETRIC : X.UNKNOWN_KEYMATERIAL;
        return x4 == null ? X.UNRECOGNIZED : x4;
    }

    public final String B() {
        return this.typeUrl_;
    }

    public final AbstractC0303h C() {
        return this.value_;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0003\u0000\u0000\u0001\u0003\u0003\u0000\u0000\u0000\u0001Ȉ\u0002\n\u0003\f", new Object[]{"typeUrl_", "value_", "keyMaterialType_"});
            case 3:
                return new Y();
            case 4:
                return new W(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (Y.class) {
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
