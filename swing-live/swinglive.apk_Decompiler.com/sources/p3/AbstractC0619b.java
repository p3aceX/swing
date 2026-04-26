package p3;

import J3.i;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: p3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0619b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final ByteBuffer f6207a;

    static {
        ByteBuffer byteBufferAllocate = ByteBuffer.allocate(0);
        i.d(byteBufferAllocate, "allocate(...)");
        f6207a = byteBufferAllocate;
    }

    public static final void a(byte[] bArr, long j4, int i4) {
        for (int i5 = 0; i5 < 8; i5++) {
            bArr[i5 + i4] = (byte) (j4 >>> ((7 - i5) * 8));
        }
    }

    public static final void b(byte[] bArr, short s4) {
        for (int i4 = 0; i4 < 2; i4++) {
            bArr[i4 + 11] = (byte) (s4 >>> ((1 - i4) * 8));
        }
    }
}
