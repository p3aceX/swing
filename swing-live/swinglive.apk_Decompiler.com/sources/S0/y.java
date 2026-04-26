package S0;

import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import d1.b0;
import java.nio.BufferUnderflowException;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class y implements R0.a {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final byte[] f1792c = new byte[0];

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final b0 f1793a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final X0.b f1794b;

    public y(b0 b0Var, X0.b bVar) {
        this.f1793a = b0Var;
        this.f1794b = bVar;
    }

    @Override // R0.a
    public final byte[] a(byte[] bArr, byte[] bArr2) {
        AbstractC0296a abstractC0296aA;
        b0 b0Var = this.f1793a;
        AtomicReference atomicReference = R0.o.f1703a;
        synchronized (R0.o.class) {
            try {
                Y0.d dVar = ((R0.e) R0.o.f1703a.get()).a(b0Var.B()).f1680a;
                Class cls = (Class) dVar.f2471b;
                if (!((Map) dVar.f2472c).keySet().contains(cls) && !Void.class.equals(cls)) {
                    throw new IllegalArgumentException("Given internalKeyMananger " + dVar.toString() + " does not support primitive class " + cls.getName());
                }
                if (!((Boolean) R0.o.f1705c.get(b0Var.B())).booleanValue()) {
                    throw new GeneralSecurityException("newKey-operation not permitted for key type " + b0Var.B());
                }
                AbstractC0303h abstractC0303hC = b0Var.C();
                try {
                    Q.b bVarN = dVar.n();
                    AbstractC0296a abstractC0296aI = bVarN.i(abstractC0303hC);
                    bVarN.j(abstractC0296aI);
                    abstractC0296aA = bVarN.a(abstractC0296aI);
                } catch (com.google.crypto.tink.shaded.protobuf.B e) {
                    throw new GeneralSecurityException("Failures parsing proto of type ".concat(((Class) dVar.n().f1509a).getName()), e);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        byte[] bArrE = abstractC0296aA.e();
        byte[] bArrA = this.f1794b.a(bArrE, f1792c);
        byte[] bArrA2 = ((R0.a) R0.o.d(this.f1793a.B(), bArrE)).a(bArr, bArr2);
        return ByteBuffer.allocate(bArrA.length + 4 + bArrA2.length).putInt(bArrA.length).put(bArrA).put(bArrA2).array();
    }

    @Override // R0.a
    public final byte[] b(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        try {
            ByteBuffer byteBufferWrap = ByteBuffer.wrap(bArr);
            int i4 = byteBufferWrap.getInt();
            if (i4 <= 0 || i4 > bArr.length - 4) {
                throw new GeneralSecurityException("invalid ciphertext");
            }
            byte[] bArr3 = new byte[i4];
            byteBufferWrap.get(bArr3, 0, i4);
            byte[] bArr4 = new byte[byteBufferWrap.remaining()];
            byteBufferWrap.get(bArr4, 0, byteBufferWrap.remaining());
            return ((R0.a) R0.o.d(this.f1793a.B(), this.f1794b.b(bArr3, f1792c))).b(bArr4, bArr2);
        } catch (IndexOutOfBoundsException e) {
            e = e;
            throw new GeneralSecurityException("invalid ciphertext", e);
        } catch (NegativeArraySizeException e4) {
            e = e4;
            throw new GeneralSecurityException("invalid ciphertext", e);
        } catch (BufferUnderflowException e5) {
            e = e5;
            throw new GeneralSecurityException("invalid ciphertext", e);
        }
    }
}
