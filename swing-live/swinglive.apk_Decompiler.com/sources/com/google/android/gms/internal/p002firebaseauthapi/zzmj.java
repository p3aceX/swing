package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzmj {
    private static final int[] zza = {0, 3, 6, 9, 12, 16, 19, 22, 25, 28};
    private static final int[] zzb = {0, 2, 3, 5, 6, 0, 1, 3, 4, 6};
    private static final int[] zzc = {67108863, 33554431};
    private static final int[] zzd = {26, 25};

    public static void zza(long[] jArr, long[] jArr2) {
        long[] jArr3 = new long[10];
        long[] jArr4 = new long[10];
        long[] jArr5 = new long[10];
        long[] jArr6 = new long[10];
        long[] jArr7 = new long[10];
        long[] jArr8 = new long[10];
        long[] jArr9 = new long[10];
        long[] jArr10 = new long[10];
        long[] jArr11 = new long[10];
        long[] jArr12 = new long[10];
        zzb(jArr3, jArr2);
        zzb(jArr12, jArr3);
        zzb(jArr11, jArr12);
        zza(jArr4, jArr11, jArr2);
        zza(jArr5, jArr4, jArr3);
        zzb(jArr11, jArr5);
        zza(jArr6, jArr11, jArr4);
        zzb(jArr11, jArr6);
        zzb(jArr12, jArr11);
        zzb(jArr11, jArr12);
        zzb(jArr12, jArr11);
        zzb(jArr11, jArr12);
        zza(jArr7, jArr11, jArr6);
        zzb(jArr11, jArr7);
        zzb(jArr12, jArr11);
        for (int i4 = 2; i4 < 10; i4 += 2) {
            zzb(jArr11, jArr12);
            zzb(jArr12, jArr11);
        }
        zza(jArr8, jArr12, jArr7);
        zzb(jArr11, jArr8);
        zzb(jArr12, jArr11);
        for (int i5 = 2; i5 < 20; i5 += 2) {
            zzb(jArr11, jArr12);
            zzb(jArr12, jArr11);
        }
        zza(jArr11, jArr12, jArr8);
        zzb(jArr12, jArr11);
        zzb(jArr11, jArr12);
        for (int i6 = 2; i6 < 10; i6 += 2) {
            zzb(jArr12, jArr11);
            zzb(jArr11, jArr12);
        }
        zza(jArr9, jArr11, jArr7);
        zzb(jArr11, jArr9);
        zzb(jArr12, jArr11);
        for (int i7 = 2; i7 < 50; i7 += 2) {
            zzb(jArr11, jArr12);
            zzb(jArr12, jArr11);
        }
        zza(jArr10, jArr12, jArr9);
        zzb(jArr12, jArr10);
        zzb(jArr11, jArr12);
        for (int i8 = 2; i8 < 100; i8 += 2) {
            zzb(jArr12, jArr11);
            zzb(jArr11, jArr12);
        }
        zza(jArr12, jArr11, jArr10);
        zzb(jArr11, jArr12);
        zzb(jArr12, jArr11);
        for (int i9 = 2; i9 < 50; i9 += 2) {
            zzb(jArr11, jArr12);
            zzb(jArr12, jArr11);
        }
        zza(jArr11, jArr12, jArr9);
        zzb(jArr12, jArr11);
        zzb(jArr11, jArr12);
        zzb(jArr12, jArr11);
        zzb(jArr11, jArr12);
        zzb(jArr12, jArr11);
        zza(jArr, jArr12, jArr5);
    }

    public static void zzb(long[] jArr, long[] jArr2, long[] jArr3) {
        jArr[0] = jArr2[0] * jArr3[0];
        long j4 = jArr2[0];
        long j5 = jArr3[1] * j4;
        long j6 = jArr2[1];
        long j7 = jArr3[0];
        jArr[1] = (j6 * j7) + j5;
        long j8 = jArr2[1];
        long j9 = jArr3[1];
        jArr[2] = (jArr2[2] * j7) + (jArr3[2] * j4) + (j8 * 2 * j9);
        long j10 = jArr3[2];
        long j11 = jArr2[2];
        jArr[3] = (jArr2[3] * j7) + (jArr3[3] * j4) + (j11 * j9) + (j8 * j10);
        long j12 = jArr3[3];
        long j13 = jArr2[3];
        jArr[4] = (jArr2[4] * j7) + (jArr3[4] * j4) + (((j13 * j9) + (j8 * j12)) * 2) + (j11 * j10);
        long j14 = jArr3[4];
        long j15 = (j8 * j14) + (j13 * j10) + (j11 * j12);
        long j16 = jArr2[4];
        jArr[5] = (jArr2[5] * j7) + (jArr3[5] * j4) + (j16 * j9) + j15;
        long j17 = jArr3[5];
        long j18 = jArr2[5];
        jArr[6] = (jArr2[6] * j7) + (jArr3[6] * j4) + (j16 * j10) + (j11 * j14) + (((j18 * j9) + (j8 * j17) + (j13 * j12)) * 2);
        long j19 = (j18 * j10) + (j11 * j17) + (j16 * j12) + (j13 * j14);
        long j20 = jArr3[6];
        long j21 = (j8 * j20) + j19;
        long j22 = jArr2[6];
        jArr[7] = (jArr2[7] * j7) + (jArr3[7] * j4) + (j22 * j9) + j21;
        long j23 = jArr3[7];
        long j24 = (j8 * j23) + (j18 * j12) + (j13 * j17);
        long j25 = jArr2[7];
        long j26 = (((j25 * j9) + j24) * 2) + (j16 * j14);
        jArr[8] = (jArr2[8] * j7) + (jArr3[8] * j4) + (j22 * j10) + (j11 * j20) + j26;
        long j27 = (j25 * j10) + (j11 * j23) + (j22 * j12) + (j13 * j20) + (j18 * j14) + (j16 * j17);
        long j28 = jArr3[8];
        long j29 = (j8 * j28) + j27;
        long j30 = jArr2[8];
        jArr[9] = (jArr2[9] * j7) + (j4 * jArr3[9]) + (j30 * j9) + j29;
        long j31 = (j25 * j12) + (j13 * j23) + (j18 * j17);
        long j32 = jArr3[9];
        long j33 = jArr2[9];
        long j34 = j16 * j20;
        jArr[10] = (j30 * j10) + (j11 * j28) + (j22 * j14) + j34 + (((j9 * j33) + (j8 * j32) + j31) * 2);
        long j35 = j11 * j32;
        long j36 = j10 * j33;
        jArr[11] = j36 + j35 + (j30 * j12) + (j13 * j28) + (j25 * j14) + (j16 * j23) + (j22 * j17) + (j18 * j20);
        long j37 = j13 * j32;
        long j38 = j12 * j33;
        long j39 = j30 * j14;
        jArr[12] = j39 + (j16 * j28) + ((j38 + j37 + (j25 * j17) + (j18 * j23)) * 2) + (j22 * j20);
        long j40 = j16 * j32;
        long j41 = j14 * j33;
        jArr[13] = j41 + j40 + (j30 * j17) + (j18 * j28) + (j25 * j20) + (j22 * j23);
        long j42 = j17 * j33;
        long j43 = j30 * j20;
        jArr[14] = j43 + (j22 * j28) + ((j42 + (j18 * j32) + (j25 * j23)) * 2);
        long j44 = j22 * j32;
        long j45 = j20 * j33;
        jArr[15] = j45 + j44 + (j30 * j23) + (j25 * j28);
        jArr[16] = (((j23 * j33) + (j25 * j32)) * 2) + (j30 * j28);
        jArr[17] = (j28 * j33) + (j30 * j32);
        jArr[18] = j33 * 2 * j32;
    }

    public static void zzc(long[] jArr, long[] jArr2) {
        zzc(jArr, jArr2, jArr);
    }

    public static void zzd(long[] jArr, long[] jArr2) {
        zzd(jArr, jArr, jArr2);
    }

    private static void zze(long[] jArr, long[] jArr2) {
        if (jArr.length != 19) {
            long[] jArr3 = new long[19];
            System.arraycopy(jArr, 0, jArr3, 0, jArr.length);
            jArr = jArr3;
        }
        zzb(jArr);
        zza(jArr);
        System.arraycopy(jArr, 0, jArr2, 0, 10);
    }

    public static void zzc(long[] jArr, long[] jArr2, long[] jArr3) {
        for (int i4 = 0; i4 < 10; i4++) {
            jArr[i4] = jArr2[i4] - jArr3[i4];
        }
    }

    public static void zzd(long[] jArr, long[] jArr2, long[] jArr3) {
        for (int i4 = 0; i4 < 10; i4++) {
            jArr[i4] = jArr2[i4] + jArr3[i4];
        }
    }

    public static byte[] zzc(long[] jArr) {
        int i4;
        long[] jArrCopyOf = Arrays.copyOf(jArr, 10);
        int i5 = 0;
        int i6 = 0;
        while (true) {
            if (i6 >= 2) {
                break;
            }
            int i7 = 0;
            while (i7 < 9) {
                long j4 = jArrCopyOf[i7];
                int i8 = zzd[i7 & 1];
                int i9 = -((int) (((j4 >> 31) & j4) >> i8));
                jArrCopyOf[i7] = j4 + ((long) (i9 << i8));
                i7++;
                jArrCopyOf[i7] = jArrCopyOf[i7] - ((long) i9);
            }
            long j5 = jArrCopyOf[9];
            int i10 = -((int) (((j5 >> 31) & j5) >> 25));
            jArrCopyOf[9] = j5 + ((long) (i10 << 25));
            jArrCopyOf[0] = jArrCopyOf[0] - (((long) i10) * 19);
            i6++;
        }
        long j6 = jArrCopyOf[0];
        int i11 = -((int) (((j6 >> 31) & j6) >> 26));
        jArrCopyOf[0] = j6 + ((long) (i11 << 26));
        jArrCopyOf[1] = jArrCopyOf[1] - ((long) i11);
        int i12 = 0;
        while (i12 < 2) {
            int i13 = i5;
            while (i13 < 9) {
                long j7 = jArrCopyOf[i13];
                int i14 = i13 & 1;
                int i15 = i5;
                int i16 = (int) (j7 >> zzd[i14]);
                jArrCopyOf[i13] = j7 & ((long) zzc[i14]);
                i13++;
                jArrCopyOf[i13] = jArrCopyOf[i13] + ((long) i16);
                i5 = i15;
                i12 = i12;
            }
            i12++;
        }
        int i17 = i5;
        long j8 = jArrCopyOf[9];
        jArrCopyOf[9] = j8 & 33554431;
        long j9 = (((long) ((int) (j8 >> 25))) * 19) + jArrCopyOf[i17];
        jArrCopyOf[i17] = j9;
        int i18 = ~((((int) j9) - 67108845) >> 31);
        for (int i19 = 1; i19 < 10; i19++) {
            int i20 = ~(((int) jArrCopyOf[i19]) ^ zzc[i19 & 1]);
            int i21 = i20 & (i20 << 16);
            int i22 = i21 & (i21 << 8);
            int i23 = i22 & (i22 << 4);
            int i24 = i23 & (i23 << 2);
            i18 &= (i24 & (i24 << 1)) >> 31;
        }
        jArrCopyOf[i17] = jArrCopyOf[i17] - ((long) (67108845 & i18));
        long j10 = 33554431 & i18;
        jArrCopyOf[1] = jArrCopyOf[1] - j10;
        for (i4 = 2; i4 < 10; i4 += 2) {
            jArrCopyOf[i4] = jArrCopyOf[i4] - ((long) (67108863 & i18));
            int i25 = i4 + 1;
            jArrCopyOf[i25] = jArrCopyOf[i25] - j10;
        }
        for (int i26 = i17; i26 < 10; i26++) {
            jArrCopyOf[i26] = jArrCopyOf[i26] << zzb[i26];
        }
        byte[] bArr = new byte[32];
        for (int i27 = i17; i27 < 10; i27++) {
            int i28 = zza[i27];
            long j11 = bArr[i28];
            long j12 = jArrCopyOf[i27];
            bArr[i28] = (byte) (j11 | (j12 & 255));
            bArr[i28 + 1] = (byte) (((long) bArr[r5]) | ((j12 >> 8) & 255));
            bArr[i28 + 2] = (byte) (((long) bArr[r5]) | ((j12 >> 16) & 255));
            bArr[i28 + 3] = (byte) (((long) bArr[r4]) | ((j12 >> 24) & 255));
        }
        return bArr;
    }

    public static void zzb(long[] jArr) {
        long j4 = jArr[8];
        long j5 = jArr[18];
        long j6 = j4 + (j5 << 4);
        jArr[8] = j6;
        long j7 = j6 + (j5 << 1);
        jArr[8] = j7;
        jArr[8] = j7 + j5;
        long j8 = jArr[7];
        long j9 = jArr[17];
        long j10 = j8 + (j9 << 4);
        jArr[7] = j10;
        long j11 = j10 + (j9 << 1);
        jArr[7] = j11;
        jArr[7] = j11 + j9;
        long j12 = jArr[6];
        long j13 = jArr[16];
        long j14 = j12 + (j13 << 4);
        jArr[6] = j14;
        long j15 = j14 + (j13 << 1);
        jArr[6] = j15;
        jArr[6] = j15 + j13;
        long j16 = jArr[5];
        long j17 = jArr[15];
        long j18 = j16 + (j17 << 4);
        jArr[5] = j18;
        long j19 = j18 + (j17 << 1);
        jArr[5] = j19;
        jArr[5] = j19 + j17;
        long j20 = jArr[4];
        long j21 = jArr[14];
        long j22 = j20 + (j21 << 4);
        jArr[4] = j22;
        long j23 = j22 + (j21 << 1);
        jArr[4] = j23;
        jArr[4] = j23 + j21;
        long j24 = jArr[3];
        long j25 = jArr[13];
        long j26 = j24 + (j25 << 4);
        jArr[3] = j26;
        long j27 = j26 + (j25 << 1);
        jArr[3] = j27;
        jArr[3] = j27 + j25;
        long j28 = jArr[2];
        long j29 = jArr[12];
        long j30 = j28 + (j29 << 4);
        jArr[2] = j30;
        long j31 = j30 + (j29 << 1);
        jArr[2] = j31;
        jArr[2] = j31 + j29;
        long j32 = jArr[1];
        long j33 = jArr[11];
        long j34 = j32 + (j33 << 4);
        jArr[1] = j34;
        long j35 = j34 + (j33 << 1);
        jArr[1] = j35;
        jArr[1] = j35 + j33;
        long j36 = jArr[0];
        long j37 = jArr[10];
        long j38 = j36 + (j37 << 4);
        jArr[0] = j38;
        long j39 = j38 + (j37 << 1);
        jArr[0] = j39;
        jArr[0] = j39 + j37;
    }

    public static void zzb(long[] jArr, long[] jArr2) {
        long j4 = jArr2[0];
        long j5 = jArr2[1];
        long j6 = jArr2[2];
        long j7 = jArr2[3];
        long j8 = jArr2[4];
        long j9 = jArr2[5];
        long j10 = jArr2[6];
        long j11 = jArr2[7];
        long j12 = jArr2[8];
        long j13 = jArr2[9];
        zze(new long[]{j4 * j4, j4 * 2 * j5, ((j4 * j6) + (j5 * j5)) * 2, ((j4 * j7) + (j5 * j6)) * 2, (j4 * 2 * j8) + (j5 * 4 * j7) + (j6 * j6), ((j4 * j9) + (j5 * j8) + (j6 * j7)) * 2, ((j5 * 2 * j9) + (j4 * j10) + (j6 * j8) + (j7 * j7)) * 2, ((j4 * j11) + (j5 * j10) + (j6 * j9) + (j7 * j8)) * 2, (((((j7 * j9) + (j5 * j11)) * 2) + (j4 * j12) + (j6 * j10)) * 2) + (j8 * j8), ((j4 * j13) + (j5 * j12) + (j6 * j11) + (j7 * j10) + (j8 * j9)) * 2, ((((j5 * j13) + (j7 * j11)) * 2) + (j6 * j12) + (j8 * j10) + (j9 * j9)) * 2, ((j6 * j13) + (j7 * j12) + (j8 * j11) + (j9 * j10)) * 2, (((((j7 * j13) + (j9 * j11)) * 2) + (j8 * j12)) * 2) + (j10 * j10), ((j8 * j13) + (j9 * j12) + (j10 * j11)) * 2, ((j9 * 2 * j13) + (j10 * j12) + (j11 * j11)) * 2, ((j10 * j13) + (j11 * j12)) * 2, (j11 * 4 * j13) + (j12 * j12), j12 * 2 * j13, 2 * j13 * j13}, jArr);
    }

    public static void zza(long[] jArr, long[] jArr2, long[] jArr3) {
        long[] jArr4 = new long[19];
        zzb(jArr4, jArr2, jArr3);
        zze(jArr4, jArr);
    }

    public static void zza(long[] jArr) {
        jArr[10] = 0;
        int i4 = 0;
        while (i4 < 10) {
            long j4 = jArr[i4];
            long j5 = j4 / 67108864;
            jArr[i4] = j4 - (j5 << 26);
            int i5 = i4 + 1;
            long j6 = jArr[i5] + j5;
            jArr[i5] = j6;
            long j7 = j6 / 33554432;
            jArr[i5] = j6 - (j7 << 25);
            i4 += 2;
            jArr[i4] = jArr[i4] + j7;
        }
        long j8 = jArr[0];
        long j9 = jArr[10];
        long j10 = j8 + (j9 << 4);
        jArr[0] = j10;
        long j11 = j10 + (j9 << 1);
        jArr[0] = j11;
        long j12 = j11 + j9;
        jArr[0] = j12;
        jArr[10] = 0;
        long j13 = j12 / 67108864;
        jArr[0] = j12 - (j13 << 26);
        jArr[1] = jArr[1] + j13;
    }

    public static void zza(long[] jArr, long[] jArr2, long j4) {
        for (int i4 = 0; i4 < 10; i4++) {
            jArr[i4] = jArr2[i4] * j4;
        }
    }

    public static long[] zza(byte[] bArr) {
        long[] jArr = new long[10];
        for (int i4 = 0; i4 < 10; i4++) {
            int i5 = zza[i4];
            jArr[i4] = ((((((long) (bArr[i5] & 255)) | (((long) (bArr[i5 + 1] & 255)) << 8)) | (((long) (bArr[i5 + 2] & 255)) << 16)) | (((long) (bArr[i5 + 3] & 255)) << 24)) >> zzb[i4]) & ((long) zzc[i4 & 1]);
        }
        return jArr;
    }
}
