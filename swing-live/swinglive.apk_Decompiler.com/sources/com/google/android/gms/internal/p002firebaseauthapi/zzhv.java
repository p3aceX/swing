package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzhv {
    private static long zza(byte[] bArr, int i4, int i5) {
        return (zza(bArr, i4) >> i5) & 67108863;
    }

    private static long zza(byte[] bArr, int i4) {
        return ((long) (((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16))) & 4294967295L;
    }

    private static void zza(byte[] bArr, long j4, int i4) {
        int i5 = 0;
        while (i5 < 4) {
            bArr[i4 + i5] = (byte) (255 & j4);
            i5++;
            j4 >>= 8;
        }
    }

    public static byte[] zza(byte[] bArr, byte[] bArr2) {
        if (bArr.length == 32) {
            long jZza = zza(bArr, 0, 0) & 67108863;
            long jZza2 = zza(bArr, 3, 2) & 67108611;
            long jZza3 = zza(bArr, 6, 4) & 67092735;
            long jZza4 = zza(bArr, 9, 6) & 66076671;
            long jZza5 = zza(bArr, 12, 8) & 1048575;
            long j4 = jZza2 * 5;
            long j5 = jZza3 * 5;
            long j6 = jZza4 * 5;
            long j7 = jZza5 * 5;
            int i4 = 17;
            byte[] bArr3 = new byte[17];
            long j8 = 0;
            int i5 = 0;
            long j9 = 0;
            long j10 = 0;
            long j11 = 0;
            long j12 = 0;
            while (i5 < bArr2.length) {
                int iMin = Math.min(16, bArr2.length - i5);
                System.arraycopy(bArr2, i5, bArr3, 0, iMin);
                bArr3[iMin] = 1;
                if (iMin != 16) {
                    Arrays.fill(bArr3, iMin + 1, i4, (byte) 0);
                }
                long jZza6 = j12 + zza(bArr3, 0, 0);
                long jZza7 = j8 + zza(bArr3, 3, 2);
                long jZza8 = j9 + zza(bArr3, 6, 4);
                long jZza9 = j10 + zza(bArr3, 9, 6);
                long jZza10 = j11 + (zza(bArr3, 12, 8) | ((long) (bArr3[16] << 24)));
                long j13 = (jZza10 * j4) + (jZza9 * j5) + (jZza8 * j6) + (jZza7 * j7) + (jZza6 * jZza);
                long j14 = (jZza10 * j5) + (jZza9 * j6) + (jZza8 * j7) + (jZza7 * jZza) + (jZza6 * jZza2);
                long j15 = (jZza10 * j6) + (jZza9 * j7) + (jZza8 * jZza) + (jZza7 * jZza2) + (jZza6 * jZza3);
                long j16 = (jZza10 * j7) + (jZza9 * jZza) + (jZza8 * jZza2) + (jZza7 * jZza3) + (jZza6 * jZza4);
                long j17 = jZza9 * jZza2;
                long j18 = jZza10 * jZza;
                long j19 = j14 + (j13 >> 26);
                long j20 = j15 + (j19 >> 26);
                long j21 = j16 + (j20 >> 26);
                long j22 = j18 + j17 + (jZza8 * jZza3) + (jZza7 * jZza4) + (jZza6 * jZza5) + (j21 >> 26);
                long j23 = j22 >> 26;
                j11 = j22 & 67108863;
                long j24 = (j23 * 5) + (j13 & 67108863);
                i5 += 16;
                j9 = j20 & 67108863;
                j10 = j21 & 67108863;
                i4 = 17;
                j12 = j24 & 67108863;
                j8 = (j19 & 67108863) + (j24 >> 26);
            }
            long j25 = j9 + (j8 >> 26);
            long j26 = j25 & 67108863;
            long j27 = j10 + (j25 >> 26);
            long j28 = j27 & 67108863;
            long j29 = j11 + (j27 >> 26);
            long j30 = j29 & 67108863;
            long j31 = ((j29 >> 26) * 5) + j12;
            long j32 = j31 >> 26;
            long j33 = j31 & 67108863;
            long j34 = (j8 & 67108863) + j32;
            long j35 = j33 + 5;
            long j36 = j35 & 67108863;
            long j37 = (j35 >> 26) + j34;
            long j38 = j26 + (j37 >> 26);
            long j39 = j28 + (j38 >> 26);
            long j40 = (j30 + (j39 >> 26)) - 67108864;
            long j41 = j40 >> 63;
            long j42 = ~j41;
            long j43 = (j33 & j41) | (j36 & j42);
            long j44 = (j34 & j41) | (j37 & 67108863 & j42);
            long j45 = (j26 & j41) | (j38 & 67108863 & j42);
            long j46 = (j28 & j41) | (j39 & 67108863 & j42);
            long j47 = (j43 | (j44 << 26)) & 4294967295L;
            long j48 = ((j44 >> 6) | (j45 << 20)) & 4294967295L;
            long j49 = ((j45 >> 12) | (j46 << 14)) & 4294967295L;
            long j50 = ((((j40 & j42) | (j30 & j41)) << 8) | (j46 >> 18)) & 4294967295L;
            long jZza11 = j47 + zza(bArr, 16);
            long j51 = jZza11 & 4294967295L;
            long jZza12 = j48 + zza(bArr, 20) + (jZza11 >> 32);
            long jZza13 = j49 + zza(bArr, 24) + (jZza12 >> 32);
            long jZza14 = (j50 + zza(bArr, 28) + (jZza13 >> 32)) & 4294967295L;
            byte[] bArr4 = new byte[16];
            zza(bArr4, j51, 0);
            zza(bArr4, jZza12 & 4294967295L, 4);
            zza(bArr4, jZza13 & 4294967295L, 8);
            zza(bArr4, jZza14, 12);
            return bArr4;
        }
        throw new IllegalArgumentException("The key length in bytes must be 32.");
    }
}
