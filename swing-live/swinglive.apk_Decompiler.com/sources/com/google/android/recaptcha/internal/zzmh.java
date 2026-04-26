package com.google.android.recaptcha.internal;

import android.util.Base64;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

/* JADX INFO: loaded from: classes.dex */
public final class zzmh {
    protected static final Charset zza = StandardCharsets.UTF_16;

    public static int zza(int i4, int i5) {
        if (i4 % 2 != 0) {
            return (i4 | i5) - (i4 & i5);
        }
        return ((~i4) & i5) | ((~i5) & i4);
    }

    public static String zzb(String str, byte[] bArr, zzmi zzmiVar) {
        byte[] bArr2 = bArr;
        int i4 = 0;
        byte[] bArrDecode = Base64.decode(str, 0);
        byte[] bArr3 = new byte[12];
        int length = bArrDecode.length - 12;
        byte[] bArr4 = new byte[length];
        System.arraycopy(bArrDecode, 0, bArr3, 0, 12);
        System.arraycopy(bArrDecode, 12, bArr4, 0, length);
        int[] iArr = {511133343, 1277647508, 107287496, 338123662};
        if (bArr2.length != 32) {
            throw new IllegalArgumentException();
        }
        int[] iArr2 = new int[16];
        for (int i5 = 0; i5 < 4; i5++) {
            iArr2[i5] = zza(iArr[i5], 2131181306);
        }
        for (int i6 = 4; i6 < 12; i6++) {
            iArr2[i6] = zze(bArr2, (i6 - 4) * 4);
        }
        iArr2[12] = 1;
        for (int i7 = 13; i7 < 16; i7++) {
            iArr2[i7] = zze(bArr3, (i7 - 13) * 4);
        }
        int[] iArr3 = new int[16];
        System.arraycopy(iArr2, 0, iArr3, 0, 16);
        byte[] bArr5 = new byte[length];
        int i8 = 1;
        int i9 = length;
        int i10 = 0;
        while (i9 > 0) {
            System.arraycopy(iArr3, i4, iArr2, i4, 16);
            iArr2[12] = i8;
            for (int i11 = i4; i11 < 10; i11++) {
                zzc(0, 4, 8, 12, iArr, bArr2, bArr3, i8, iArr2, iArr3);
                bArr2 = bArr;
                zzc(1, 5, 9, 13, iArr, bArr2, bArr3, i8, iArr2, iArr3);
                zzc(2, 6, 10, 14, iArr, bArr2, bArr3, i8, iArr2, iArr3);
                zzc(3, 7, 11, 15, iArr, bArr2, bArr3, i8, iArr2, iArr3);
                zzc(0, 5, 10, 15, iArr, bArr2, bArr3, i8, iArr2, iArr3);
                zzc(1, 6, 11, 12, iArr, bArr2, bArr3, i8, iArr2, iArr3);
                zzc(2, 7, 8, 13, iArr, bArr2, bArr3, i8, iArr2, iArr3);
                zzc(3, 4, 9, 14, iArr, bArr2, bArr3, i8, iArr2, iArr3);
            }
            byte[] bArr6 = new byte[64];
            for (int i12 = i4; i12 < 16; i12++) {
                int i13 = iArr2[i12];
                int i14 = i12 * 4;
                bArr6[i14] = (byte) (i13 & 255);
                bArr6[i14 + 1] = (byte) ((i13 >> 8) & 255);
                bArr6[i14 + 2] = (byte) ((i13 >> 16) & 255);
                bArr6[i14 + 3] = (byte) ((i13 >> 24) & 255);
            }
            for (int i15 = 0; i15 < Math.min(64, i9); i15++) {
                int i16 = i10 + i15;
                bArr5[i16] = (byte) zza(bArr6[i15], bArr4[i16]);
            }
            i8++;
            i9 -= 64;
            i10 += 64;
            bArr2 = bArr;
            i4 = 0;
        }
        return new String(bArr5, zza);
    }

    public static final void zzc(int i4, int i5, int i6, int i7, int[] iArr, byte[] bArr, byte[] bArr2, int i8, int[] iArr2, int[] iArr3) {
        zzd(i4, i5, i7, 16, iArr, bArr, bArr2, i8, iArr2, iArr3);
        zzd(i6, i7, i5, 12, iArr, bArr, bArr2, i8, iArr2, iArr3);
        zzd(i4, i5, i7, 8, iArr, bArr, bArr2, i8, iArr2, iArr3);
        zzd(i6, i7, i5, 7, iArr, bArr, bArr2, i8, iArr2, iArr3);
    }

    public static final void zzd(int i4, int i5, int i6, int i7, int[] iArr, byte[] bArr, byte[] bArr2, int i8, int[] iArr2, int[] iArr3) {
        int i9 = iArr2[i4] + iArr2[i5];
        iArr2[i4] = i9;
        int iZza = zza(iArr2[i6], i9);
        iArr2[i6] = (iZza << i7) | (iZza >>> (32 - i7));
    }

    private static final int zze(byte[] bArr, int i4) {
        int i5 = bArr[i4] & 255;
        int i6 = bArr[i4 + 1] & 255;
        int i7 = bArr[i4 + 2] & 255;
        return ((bArr[i4 + 3] & 255) << 24) | (i6 << 8) | i5 | (i7 << 16);
    }
}
