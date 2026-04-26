package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0315u;

/* JADX INFO: loaded from: classes.dex */
public final class f0 extends AbstractC0316v {
    private static final f0 DEFAULT_INSTANCE;
    public static final int KEY_DATA_FIELD_NUMBER = 1;
    public static final int KEY_ID_FIELD_NUMBER = 3;
    public static final int OUTPUT_PREFIX_TYPE_FIELD_NUMBER = 4;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int STATUS_FIELD_NUMBER = 2;
    private Y keyData_;
    private int keyId_;
    private int outputPrefixType_;
    private int status_;

    static {
        f0 f0Var = new f0();
        DEFAULT_INSTANCE = f0Var;
        AbstractC0316v.t(f0.class, f0Var);
    }

    public static e0 F() {
        return (e0) DEFAULT_INSTANCE.h();
    }

    public static void w(f0 f0Var, Y y4) {
        f0Var.getClass();
        f0Var.keyData_ = y4;
    }

    public static void x(f0 f0Var, r0 r0Var) {
        f0Var.getClass();
        f0Var.outputPrefixType_ = r0Var.b();
    }

    public static void y(f0 f0Var) {
        Z z4 = Z.ENABLED;
        f0Var.getClass();
        f0Var.status_ = z4.a();
    }

    public static void z(f0 f0Var, int i4) {
        f0Var.keyId_ = i4;
    }

    public final Y A() {
        Y y4 = this.keyData_;
        return y4 == null ? Y.z() : y4;
    }

    public final int B() {
        return this.keyId_;
    }

    public final r0 C() {
        r0 r0VarA = r0.a(this.outputPrefixType_);
        return r0VarA == null ? r0.UNRECOGNIZED : r0VarA;
    }

    public final Z D() {
        int i4 = this.status_;
        Z z4 = i4 != 0 ? i4 != 1 ? i4 != 2 ? i4 != 3 ? null : Z.DESTROYED : Z.DISABLED : Z.ENABLED : Z.UNKNOWN_STATUS;
        return z4 == null ? Z.UNRECOGNIZED : z4;
    }

    public final boolean E() {
        return this.keyData_ != null;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0004\u0000\u0000\u0001\u0004\u0004\u0000\u0000\u0000\u0001\t\u0002\f\u0003\u000b\u0004\f", new Object[]{"keyData_", "status_", "keyId_", "outputPrefixType_"});
            case 3:
                return new f0();
            case 4:
                return new e0(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (f0.class) {
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
