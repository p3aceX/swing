package T0;

import androidx.datastore.preferences.protobuf.C0196g;
import androidx.datastore.preferences.protobuf.C0213y;
import com.google.crypto.tink.shaded.protobuf.B;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0304i;
import e1.AbstractC0367g;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f1872a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f1873b;

    public static int d(int i4) {
        return (-(i4 & 1)) ^ (i4 >>> 1);
    }

    public static long e(long j4) {
        return (-(j4 & 1)) ^ (j4 >>> 1);
    }

    public static C0304i h(byte[] bArr, int i4, int i5, boolean z4) {
        C0304i c0304i = new C0304i(bArr, i4, i5, z4);
        try {
            c0304i.l(i5);
            return c0304i;
        } catch (B e) {
            throw new IllegalArgumentException(e);
        }
    }

    public abstract String A();

    public abstract String B();

    public abstract int C();

    public abstract int D();

    public abstract long E();

    public abstract boolean F(int i4);

    public void G() {
        int iC;
        do {
            iC = C();
            if (iC == 0) {
                return;
            }
            int i4 = this.f1872a;
            if (i4 >= 100) {
                throw new C0213y("Protocol message had too many levels of nesting.  May be malicious.  Use setRecursionLimit() to increase the recursion depth limit.");
            }
            this.f1872a = i4 + 1;
            this.f1872a--;
        } while (F(iC));
    }

    public ByteBuffer a(byte[] bArr, int i4) {
        int[] iArrC = c(a.c(bArr), i4);
        int[] iArr = (int[]) iArrC.clone();
        a.b(iArr);
        for (int i5 = 0; i5 < iArrC.length; i5++) {
            iArrC[i5] = iArrC[i5] + iArr[i5];
        }
        ByteBuffer byteBufferOrder = ByteBuffer.allocate(64).order(ByteOrder.LITTLE_ENDIAN);
        byteBufferOrder.asIntBuffer().put(iArrC, 0, 16);
        return byteBufferOrder;
    }

    public abstract void b(int i4);

    public abstract int[] c(int[] iArr, int i4);

    public abstract int f();

    public abstract boolean g();

    public abstract int i();

    public abstract void j(int i4);

    public void k(byte[] bArr, ByteBuffer byteBuffer, ByteBuffer byteBuffer2) throws GeneralSecurityException {
        if (bArr.length != i()) {
            throw new GeneralSecurityException("The nonce length (in bytes) must be " + i());
        }
        int iRemaining = byteBuffer2.remaining();
        int i4 = iRemaining / 64;
        int i5 = i4 + 1;
        for (int i6 = 0; i6 < i5; i6++) {
            ByteBuffer byteBufferA = a(bArr, this.f1872a + i6);
            if (i6 == i4) {
                AbstractC0367g.W(byteBuffer, byteBuffer2, byteBufferA, iRemaining % 64);
            } else {
                AbstractC0367g.W(byteBuffer, byteBuffer2, byteBufferA, 64);
            }
        }
    }

    public abstract int l(int i4);

    public abstract boolean m();

    public abstract C0196g n();

    public abstract C0302g o();

    public abstract double p();

    public abstract int q();

    public abstract int r();

    public abstract long s();

    public abstract float t();

    public abstract int u();

    public abstract long v();

    public abstract int w();

    public abstract long x();

    public abstract int y();

    public abstract long z();
}
