package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public final class zzz {
    public static int zza(int i4, int i5) {
        String strZza;
        if (i4 >= 0 && i4 < i5) {
            return i4;
        }
        if (i4 < 0) {
            strZza = zzah.zza("%s (%s) must not be negative", "index", Integer.valueOf(i4));
        } else {
            if (i5 < 0) {
                throw new IllegalArgumentException(S.d(i5, "negative size: "));
            }
            strZza = zzah.zza("%s (%s) must be less than size (%s)", "index", Integer.valueOf(i4), Integer.valueOf(i5));
        }
        throw new IndexOutOfBoundsException(strZza);
    }

    public static int zzb(int i4, int i5) {
        if (i4 < 0 || i4 > i5) {
            throw new IndexOutOfBoundsException(zzb(i4, i5, "index"));
        }
        return i4;
    }

    private static String zzb(int i4, int i5, String str) {
        if (i4 < 0) {
            return zzah.zza("%s (%s) must not be negative", str, Integer.valueOf(i4));
        }
        if (i5 >= 0) {
            return zzah.zza("%s (%s) must not be greater than size (%s)", str, Integer.valueOf(i4), Integer.valueOf(i5));
        }
        throw new IllegalArgumentException(S.d(i5, "negative size: "));
    }

    public static int zza(int i4, int i5, String str) {
        if (i4 < 0 || i4 > i5) {
            throw new IndexOutOfBoundsException(zzb(i4, i5, str));
        }
        return i4;
    }

    public static <T> T zza(T t4) {
        t4.getClass();
        return t4;
    }

    public static void zza(int i4, int i5, int i6) {
        String strZzb;
        if (i4 < 0 || i5 < i4 || i5 > i6) {
            if (i4 < 0 || i4 > i6) {
                strZzb = zzb(i4, i6, "start index");
            } else if (i5 >= 0 && i5 <= i6) {
                strZzb = zzah.zza("end index (%s) must not be less than start index (%s)", Integer.valueOf(i5), Integer.valueOf(i4));
            } else {
                strZzb = zzb(i5, i6, "end index");
            }
            throw new IndexOutOfBoundsException(strZzb);
        }
    }
}
