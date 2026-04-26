package com.google.android.gms.internal.p002firebaseauthapi;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;

/* JADX INFO: loaded from: classes.dex */
final class zzhk {
    private static final int[] zza = zza(new byte[]{101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107});

    private static int zza(int i4, int i5) {
        return (i4 >>> (-i5)) | (i4 << i5);
    }

    private static void zza(int[] iArr, int i4, int i5, int i6, int i7) {
        int i8 = iArr[i4] + iArr[i5];
        iArr[i4] = i8;
        int iZza = zza(i8 ^ iArr[i7], 16);
        iArr[i7] = iZza;
        int i9 = iArr[i6] + iZza;
        iArr[i6] = i9;
        int iZza2 = zza(iArr[i5] ^ i9, 12);
        iArr[i5] = iZza2;
        int i10 = iArr[i4] + iZza2;
        iArr[i4] = i10;
        int iZza3 = zza(iArr[i7] ^ i10, 8);
        iArr[i7] = iZza3;
        int i11 = iArr[i6] + iZza3;
        iArr[i6] = i11;
        iArr[i5] = zza(iArr[i5] ^ i11, 7);
    }

    public static void zza(int[] iArr, int[] iArr2) {
        int[] iArr3 = zza;
        System.arraycopy(iArr3, 0, iArr, 0, iArr3.length);
        System.arraycopy(iArr2, 0, iArr, iArr3.length, 8);
    }

    public static void zza(int[] iArr) {
        for (int i4 = 0; i4 < 10; i4++) {
            zza(iArr, 0, 4, 8, 12);
            zza(iArr, 1, 5, 9, 13);
            zza(iArr, 2, 6, 10, 14);
            zza(iArr, 3, 7, 11, 15);
            zza(iArr, 0, 5, 10, 15);
            zza(iArr, 1, 6, 11, 12);
            zza(iArr, 2, 7, 8, 13);
            zza(iArr, 3, 4, 9, 14);
        }
    }

    public static int[] zza(byte[] bArr) {
        IntBuffer intBufferAsIntBuffer = ByteBuffer.wrap(bArr).order(ByteOrder.LITTLE_ENDIAN).asIntBuffer();
        int[] iArr = new int[intBufferAsIntBuffer.remaining()];
        intBufferAsIntBuffer.get(iArr);
        return iArr;
    }
}
