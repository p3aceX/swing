package com.google.android.gms.internal.auth;

/* JADX INFO: loaded from: classes.dex */
final class zzhn {
    public static final /* synthetic */ int zza = 0;
    private static final zzhl zzb;

    static {
        if (zzhj.zzu() && zzhj.zzv()) {
            int i4 = zzds.zza;
        }
        zzb = new zzhm();
    }

    public static /* bridge */ /* synthetic */ int zza(byte[] bArr, int i4, int i5) {
        int i6 = i5 - i4;
        byte b5 = bArr[i4 - 1];
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

    public static boolean zzb(byte[] bArr) {
        return zzb.zzb(bArr, 0, bArr.length);
    }

    public static boolean zzc(byte[] bArr, int i4, int i5) {
        return zzb.zzb(bArr, i4, i5);
    }
}
