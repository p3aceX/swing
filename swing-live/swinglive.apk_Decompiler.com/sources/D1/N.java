package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0305j;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;
import java.io.ByteArrayInputStream;

/* JADX INFO: loaded from: classes.dex */
public final class N extends AbstractC0316v {
    private static final N DEFAULT_INSTANCE;
    public static final int ENCRYPTED_KEYSET_FIELD_NUMBER = 2;
    public static final int KEYSET_INFO_FIELD_NUMBER = 3;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER;
    private AbstractC0303h encryptedKeyset_ = AbstractC0303h.f3791b;
    private k0 keysetInfo_;

    static {
        N n4 = new N();
        DEFAULT_INSTANCE = n4;
        AbstractC0316v.t(N.class, n4);
    }

    public static N A(ByteArrayInputStream byteArrayInputStream, C0309n c0309n) throws com.google.crypto.tink.shaded.protobuf.B {
        AbstractC0316v abstractC0316vS = AbstractC0316v.s(DEFAULT_INSTANCE, new C0305j(byteArrayInputStream), c0309n);
        AbstractC0316v.g(abstractC0316vS);
        return (N) abstractC0316vS;
    }

    public static void w(N n4, C0302g c0302g) {
        n4.getClass();
        n4.encryptedKeyset_ = c0302g;
    }

    public static void x(N n4, k0 k0Var) {
        n4.getClass();
        n4.keysetInfo_ = k0Var;
    }

    public static M z() {
        return (M) DEFAULT_INSTANCE.h();
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0002\u0000\u0000\u0002\u0003\u0002\u0000\u0000\u0000\u0002\n\u0003\t", new Object[]{"encryptedKeyset_", "keysetInfo_"});
            case 3:
                return new N();
            case 4:
                return new M(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (N.class) {
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
        return this.encryptedKeyset_;
    }
}
