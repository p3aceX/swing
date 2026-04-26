package d1;

import com.google.crypto.tink.shaded.protobuf.AbstractC0297b;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.C0305j;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import com.google.crypto.tink.shaded.protobuf.C0315u;
import com.google.crypto.tink.shaded.protobuf.InterfaceC0319y;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class g0 extends AbstractC0316v {
    private static final g0 DEFAULT_INSTANCE;
    public static final int KEY_FIELD_NUMBER = 2;
    private static volatile com.google.crypto.tink.shaded.protobuf.X PARSER = null;
    public static final int PRIMARY_KEY_ID_FIELD_NUMBER = 1;
    private InterfaceC0319y key_ = com.google.crypto.tink.shaded.protobuf.a0.f3769d;
    private int primaryKeyId_;

    static {
        g0 g0Var = new g0();
        DEFAULT_INSTANCE = g0Var;
        AbstractC0316v.t(g0.class, g0Var);
    }

    public static d0 C() {
        return (d0) DEFAULT_INSTANCE.h();
    }

    public static g0 D(ByteArrayInputStream byteArrayInputStream, C0309n c0309n) throws com.google.crypto.tink.shaded.protobuf.B {
        AbstractC0316v abstractC0316vS = AbstractC0316v.s(DEFAULT_INSTANCE, new C0305j(byteArrayInputStream), c0309n);
        AbstractC0316v.g(abstractC0316vS);
        return (g0) abstractC0316vS;
    }

    public static g0 E(byte[] bArr, C0309n c0309n) {
        g0 g0Var = DEFAULT_INSTANCE;
        int length = bArr.length;
        AbstractC0316v abstractC0316vQ = g0Var.q();
        try {
            com.google.crypto.tink.shaded.protobuf.Z z4 = com.google.crypto.tink.shaded.protobuf.Z.f3766c;
            z4.getClass();
            com.google.crypto.tink.shaded.protobuf.c0 c0VarA = z4.a(abstractC0316vQ.getClass());
            U1.c cVar = new U1.c();
            c0309n.getClass();
            c0VarA.g(abstractC0316vQ, bArr, 0, length, cVar);
            c0VarA.d(abstractC0316vQ);
            AbstractC0316v.g(abstractC0316vQ);
            return (g0) abstractC0316vQ;
        } catch (com.google.crypto.tink.shaded.protobuf.B e) {
            if (e.f3723a) {
                throw new com.google.crypto.tink.shaded.protobuf.B(e.getMessage(), e);
            }
            throw e;
        } catch (com.google.crypto.tink.shaded.protobuf.e0 e4) {
            throw new com.google.crypto.tink.shaded.protobuf.B(e4.getMessage());
        } catch (IOException e5) {
            if (e5.getCause() instanceof com.google.crypto.tink.shaded.protobuf.B) {
                throw ((com.google.crypto.tink.shaded.protobuf.B) e5.getCause());
            }
            throw new com.google.crypto.tink.shaded.protobuf.B(e5.getMessage(), e5);
        } catch (IndexOutOfBoundsException unused) {
            throw com.google.crypto.tink.shaded.protobuf.B.g();
        }
    }

    public static void w(g0 g0Var, int i4) {
        g0Var.primaryKeyId_ = i4;
    }

    public static void x(g0 g0Var, f0 f0Var) {
        g0Var.getClass();
        InterfaceC0319y interfaceC0319y = g0Var.key_;
        if (!((AbstractC0297b) interfaceC0319y).f3772a) {
            int size = interfaceC0319y.size();
            g0Var.key_ = interfaceC0319y.c(size == 0 ? 10 : size * 2);
        }
        g0Var.key_.add(f0Var);
    }

    public final List A() {
        return this.key_;
    }

    public final int B() {
        return this.primaryKeyId_;
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
                return new com.google.crypto.tink.shaded.protobuf.b0(DEFAULT_INSTANCE, "\u0000\u0002\u0000\u0000\u0001\u0002\u0002\u0000\u0001\u0000\u0001\u000b\u0002\u001b", new Object[]{"primaryKeyId_", "key_", f0.class});
            case 3:
                return new g0();
            case 4:
                return new d0(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                com.google.crypto.tink.shaded.protobuf.X x4 = PARSER;
                if (x4 != null) {
                    return x4;
                }
                synchronized (g0.class) {
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

    public final f0 y(int i4) {
        return (f0) this.key_.get(i4);
    }

    public final int z() {
        return this.key_.size();
    }
}
