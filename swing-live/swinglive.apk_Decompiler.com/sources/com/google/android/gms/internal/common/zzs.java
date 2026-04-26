package com.google.android.gms.internal.common;

import com.google.crypto.tink.shaded.protobuf.S;
import org.jspecify.nullness.NullMarked;

/* JADX INFO: loaded from: classes.dex */
@NullMarked
public final class zzs {
    public static int zza(int i4, int i5, String str) {
        String strZza;
        if (i4 >= 0 && i4 < i5) {
            return i4;
        }
        if (i4 < 0) {
            strZza = zzy.zza("%s (%s) must not be negative", "index", Integer.valueOf(i4));
        } else {
            if (i5 < 0) {
                throw new IllegalArgumentException(S.d(i5, "negative size: "));
            }
            strZza = zzy.zza("%s (%s) must be less than size (%s)", "index", Integer.valueOf(i4), Integer.valueOf(i5));
        }
        throw new IndexOutOfBoundsException(strZza);
    }

    public static int zzb(int i4, int i5, String str) {
        if (i4 < 0 || i4 > i5) {
            throw new IndexOutOfBoundsException(zzd(i4, i5, "index"));
        }
        return i4;
    }

    public static void zzc(int i4, int i5, int i6) {
        if (i4 < 0 || i5 < i4 || i5 > i6) {
            throw new IndexOutOfBoundsException((i4 < 0 || i4 > i6) ? zzd(i4, i6, "start index") : (i5 < 0 || i5 > i6) ? zzd(i5, i6, "end index") : zzy.zza("end index (%s) must not be less than start index (%s)", Integer.valueOf(i5), Integer.valueOf(i4)));
        }
    }

    private static String zzd(int i4, int i5, String str) {
        if (i4 < 0) {
            return zzy.zza("%s (%s) must not be negative", str, Integer.valueOf(i4));
        }
        if (i5 >= 0) {
            return zzy.zza("%s (%s) must not be greater than size (%s)", str, Integer.valueOf(i4), Integer.valueOf(i5));
        }
        throw new IllegalArgumentException(S.d(i5, "negative size: "));
    }
}
