package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzamk {
    private static boolean zza(byte b5) {
        return b5 > -65;
    }

    public static /* synthetic */ void zza(byte b5, byte b6, byte b7, byte b8, char[] cArr, int i4) throws zzajj {
        if (!zza(b6)) {
            if ((((b6 + 112) + (b5 << 28)) >> 30) == 0 && !zza(b7) && !zza(b8)) {
                int i5 = ((b5 & 7) << 18) | ((b6 & 63) << 12) | ((b7 & 63) << 6) | (b8 & 63);
                cArr[i4] = (char) ((i5 >>> 10) + 55232);
                cArr[i4 + 1] = (char) ((i5 & 1023) + 56320);
                return;
            }
        }
        throw zzajj.zzd();
    }

    public static /* synthetic */ void zza(byte b5, char[] cArr, int i4) {
        cArr[i4] = (char) b5;
    }

    public static /* synthetic */ void zza(byte b5, byte b6, byte b7, char[] cArr, int i4) throws zzajj {
        if (!zza(b6) && ((b5 != -32 || b6 >= -96) && ((b5 != -19 || b6 < -96) && !zza(b7)))) {
            cArr[i4] = (char) (((b5 & 15) << 12) | ((b6 & 63) << 6) | (b7 & 63));
            return;
        }
        throw zzajj.zzd();
    }

    public static /* synthetic */ void zza(byte b5, byte b6, char[] cArr, int i4) throws zzajj {
        if (b5 >= -62 && !zza(b6)) {
            cArr[i4] = (char) (((b5 & 31) << 6) | (b6 & 63));
            return;
        }
        throw zzajj.zzd();
    }
}
