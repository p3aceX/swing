package com.google.android.recaptcha.internal;

import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public final class zzmg {
    public static final zzlj zza;
    public static final zzlj zzb;
    public static final zzlj zzc;
    private static final ThreadLocal zzd;
    private static final Method zze;
    private static final Method zzf;
    private static final Method zzg;

    static {
        zzli zzliVarZzi = zzlj.zzi();
        zzliVarZzi.zze(-62135596800L);
        zzliVarZzi.zzd(0);
        zza = (zzlj) zzliVarZzi.zzj();
        zzli zzliVarZzi2 = zzlj.zzi();
        zzliVarZzi2.zze(253402300799L);
        zzliVarZzi2.zzd(999999999);
        zzb = (zzlj) zzliVarZzi2.zzj();
        zzli zzliVarZzi3 = zzlj.zzi();
        zzliVarZzi3.zze(0L);
        zzliVarZzi3.zzd(0);
        zzc = (zzlj) zzliVarZzi3.zzj();
        zzd = new zzmf();
        zze = zzd("now");
        zzf = zzd("getEpochSecond");
        zzg = zzd("getNano");
    }

    public static zzlj zza(zzlj zzljVar) {
        long jZzg = zzljVar.zzg();
        int iZzf = zzljVar.zzf();
        if (jZzg >= -62135596800L && jZzg <= 253402300799L && iZzf >= 0 && iZzf < 1000000000) {
            return zzljVar;
        }
        throw new IllegalArgumentException("Timestamp is not valid. See proto definition for valid values. Seconds (" + jZzg + ") must be in range [-62,135,596,800, +253,402,300,799]. Nanos (" + iZzf + ") must be in range [0, +999,999,999].");
    }

    public static zzlj zzb(long j4) {
        int i4 = (int) ((j4 % 1000) * 1000000);
        long jZza = j4 / 1000;
        if (i4 <= -1000000000 || i4 >= 1000000000) {
            jZza = zzgb.zza(jZza, i4 / 1000000000);
            i4 %= 1000000000;
        }
        if (i4 < 0) {
            i4 += 1000000000;
            jZza = zzgb.zzb(jZza, 1L);
        }
        zzli zzliVarZzi = zzlj.zzi();
        zzliVarZzi.zze(jZza);
        zzliVarZzi.zzd(i4);
        zzlj zzljVar = (zzlj) zzliVarZzi.zzj();
        zza(zzljVar);
        return zzljVar;
    }

    public static String zzc(zzlj zzljVar) {
        zza(zzljVar);
        long jZzg = zzljVar.zzg();
        int iZzf = zzljVar.zzf();
        StringBuilder sb = new StringBuilder();
        sb.append(((SimpleDateFormat) zzd.get()).format(new Date(jZzg * 1000)));
        if (iZzf != 0) {
            sb.append(".");
            sb.append(iZzf % 1000000 == 0 ? String.format(Locale.ENGLISH, "%1$03d", Integer.valueOf(iZzf / 1000000)) : iZzf % 1000 == 0 ? String.format(Locale.ENGLISH, "%1$06d", Integer.valueOf(iZzf / 1000)) : String.format(Locale.ENGLISH, "%1$09d", Integer.valueOf(iZzf)));
        }
        sb.append("Z");
        return sb.toString();
    }

    private static Method zzd(String str) {
        try {
            return Class.forName("java.time.Instant").getMethod(str, new Class[0]);
        } catch (Exception unused) {
            return null;
        }
    }
}
