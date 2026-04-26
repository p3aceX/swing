package com.google.android.gms.internal.fido;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public final class zzam {
    public static int zza(int i4, int i5, String str) {
        String strZza;
        if (i4 >= 0 && i4 < i5) {
            return i4;
        }
        if (i4 < 0) {
            strZza = zzan.zza("%s (%s) must not be negative", "index", Integer.valueOf(i4));
        } else {
            if (i5 < 0) {
                throw new IllegalArgumentException(S.d(i5, "negative size: "));
            }
            strZza = zzan.zza("%s (%s) must be less than size (%s)", "index", Integer.valueOf(i4), Integer.valueOf(i5));
        }
        throw new IndexOutOfBoundsException(strZza);
    }

    public static int zzb(int i4, int i5, String str) {
        if (i4 < 0 || i4 > i5) {
            throw new IndexOutOfBoundsException(zzf(i4, i5, "index"));
        }
        return i4;
    }

    public static void zzc(boolean z4) {
        if (!z4) {
            throw new IllegalArgumentException();
        }
    }

    public static void zzd(boolean z4, String str, char c5) {
        if (!z4) {
            throw new IllegalArgumentException(zzan.zza(str, Character.valueOf(c5)));
        }
    }

    public static void zze(int i4, int i5, int i6) {
        if (i4 < 0 || i5 < i4 || i5 > i6) {
            throw new IndexOutOfBoundsException((i4 < 0 || i4 > i6) ? zzf(i4, i6, "start index") : (i5 < 0 || i5 > i6) ? zzf(i5, i6, "end index") : zzan.zza("end index (%s) must not be less than start index (%s)", Integer.valueOf(i5), Integer.valueOf(i4)));
        }
    }

    private static String zzf(int i4, int i5, String str) {
        if (i4 < 0) {
            return zzan.zza("%s (%s) must not be negative", str, Integer.valueOf(i4));
        }
        if (i5 >= 0) {
            return zzan.zza("%s (%s) must not be greater than size (%s)", str, Integer.valueOf(i4), Integer.valueOf(i5));
        }
        throw new IllegalArgumentException(S.d(i5, "negative size: "));
    }
}
