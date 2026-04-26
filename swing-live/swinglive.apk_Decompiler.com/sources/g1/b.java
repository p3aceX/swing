package G1;

import J3.i;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final byte[] f496a = {1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7};

    public static byte[] a(byte[] bArr, int i4) {
        int i5;
        i.e(bArr, "buffer");
        int i6 = i4 / 2;
        byte[] bArr2 = new byte[i6];
        int i7 = 0;
        for (int i8 = 0; i8 < i6; i8++) {
            int i9 = i7 + 1;
            int i10 = bArr[i7] & 255;
            i7 += 2;
            short s4 = (short) ((bArr[i9] << 8) | i10);
            int i11 = (((short) (~s4)) >> 8) & 128;
            if (i11 != 128) {
                s4 = (short) (-s4);
            }
            if (s4 > 32635) {
                s4 = 32635;
            }
            if (s4 >= 256) {
                byte b5 = f496a[(s4 >> 8) & 127];
                i5 = ((s4 >> (b5 + 3)) & 15) | (b5 << 4);
            } else {
                i5 = s4 >> 4;
            }
            bArr2[i8] = (byte) (i5 ^ (i11 ^ 85));
        }
        return bArr2;
    }
}
