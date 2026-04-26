package com.google.android.recaptcha.internal;

import J3.i;
import P3.m;
import java.util.Iterator;
import java.util.Set;
import x3.AbstractC0728h;

/* JADX INFO: loaded from: classes.dex */
public final class zzcb {
    public static final zzcb zza = new zzcb();
    private static Set zzb;
    private static Set zzc;
    private static Long zzd;
    private static int zze;

    private zzcb() {
    }

    public static final void zza(zznz zznzVar) {
        zzb = AbstractC0728h.m0(zznzVar.zzf().zzi());
        zzc = AbstractC0728h.m0(zznzVar.zzg().zzi());
    }

    public static final boolean zzb(String str) {
        Set set = zzb;
        if (set == null || zzc == null) {
            if (zzd == null) {
                zzd = Long.valueOf(System.currentTimeMillis());
            }
            zze++;
            return true;
        }
        if (set.isEmpty()) {
            return true;
        }
        Set set2 = zzc;
        i.c(set2, "null cannot be cast to non-null type kotlin.collections.Set<kotlin.String>");
        if (zzc(str, set2)) {
            return false;
        }
        return zzc(str, set);
    }

    private static final boolean zzc(String str, Set set) {
        Iterator it = m.E0(str, new char[]{'.'}).iterator();
        String strConcat = "";
        while (it.hasNext()) {
            String strConcat2 = strConcat.concat(String.valueOf((String) it.next()));
            if (set.contains(strConcat2)) {
                return true;
            }
            strConcat = strConcat2.concat(".");
        }
        return false;
    }
}
