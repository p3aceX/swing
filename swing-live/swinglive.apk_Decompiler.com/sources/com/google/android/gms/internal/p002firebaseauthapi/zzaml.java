package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzaml {
    private static final zzamn zza;

    static {
        if (zzamh.zzc()) {
            zzamh.zzd();
        }
        zza = new zzamm();
    }

    public static /* synthetic */ int zza(byte[] bArr, int i4, int i5) {
        byte b5 = bArr[i4 - 1];
        int i6 = i5 - i4;
        if (i6 == 0) {
            if (b5 > -12) {
                return -1;
            }
            return b5;
        }
        if (i6 == 1) {
            byte b6 = bArr[i4];
            if (b5 > -12 || b6 > -65) {
                return -1;
            }
            return (b6 << 8) ^ b5;
        }
        if (i6 != 2) {
            throw new AssertionError();
        }
        byte b7 = bArr[i4];
        byte b8 = bArr[i4 + 1];
        if (b5 > -12 || b7 > -65 || b8 > -65) {
            return -1;
        }
        return (b8 << 16) ^ ((b7 << 8) ^ b5);
    }

    public static String zzb(byte[] bArr, int i4, int i5) {
        return zza.zza(bArr, i4, i5);
    }

    public static boolean zzc(byte[] bArr, int i4, int i5) {
        return zza.zzb(bArr, i4, i5);
    }

    public static int zza(String str, byte[] bArr, int i4, int i5) {
        return zza.zza(str, bArr, i4, i5);
    }

    public static int zza(String str) {
        int length = str.length();
        int i4 = 0;
        int i5 = 0;
        while (i5 < length && str.charAt(i5) < 128) {
            i5++;
        }
        int i6 = length;
        while (true) {
            if (i5 >= length) {
                break;
            }
            char cCharAt = str.charAt(i5);
            if (cCharAt < 2048) {
                i6 += (127 - cCharAt) >>> 31;
                i5++;
            } else {
                int length2 = str.length();
                while (i5 < length2) {
                    char cCharAt2 = str.charAt(i5);
                    if (cCharAt2 < 2048) {
                        i4 += (127 - cCharAt2) >>> 31;
                    } else {
                        i4 += 2;
                        if (55296 <= cCharAt2 && cCharAt2 <= 57343) {
                            if (Character.codePointAt(str, i5) < 65536) {
                                throw new zzamp(i5, length2);
                            }
                            i5++;
                        }
                    }
                    i5++;
                }
                i6 += i4;
            }
        }
        if (i6 >= length) {
            return i6;
        }
        throw new IllegalArgumentException("UTF-8 length does not fit in int: " + (((long) i6) + 4294967296L));
    }

    public static boolean zza(byte[] bArr) {
        return zza.zzb(bArr, 0, bArr.length);
    }
}
