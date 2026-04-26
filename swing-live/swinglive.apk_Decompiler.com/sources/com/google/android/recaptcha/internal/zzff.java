package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzff {
    public static void zza(boolean z4) {
        if (!z4) {
            throw new IllegalArgumentException();
        }
    }

    public static void zzb(boolean z4, Object obj) {
        if (!z4) {
            throw new IllegalArgumentException((String) obj);
        }
    }

    public static void zzc(boolean z4, String str, char c5) {
        if (!z4) {
            throw new IllegalArgumentException(zzfi.zza(str, Character.valueOf(c5)));
        }
    }

    public static void zzd(int i4, int i5, int i6) {
        if (i4 < 0 || i5 < i4 || i5 > i6) {
            throw new IndexOutOfBoundsException((i4 < 0 || i4 > i6) ? zzf(i4, i6, "start index") : (i5 < 0 || i5 > i6) ? zzf(i5, i6, "end index") : zzfi.zza("end index (%s) must not be less than start index (%s)", Integer.valueOf(i5), Integer.valueOf(i4)));
        }
    }

    public static void zze(boolean z4, Object obj) {
        if (!z4) {
            throw new IllegalStateException((String) obj);
        }
    }

    private static String zzf(int i4, int i5, String str) {
        return i4 < 0 ? zzfi.zza("%s (%s) must not be negative", str, Integer.valueOf(i4)) : zzfi.zza("%s (%s) must not be greater than size (%s)", str, Integer.valueOf(i4), Integer.valueOf(i5));
    }
}
