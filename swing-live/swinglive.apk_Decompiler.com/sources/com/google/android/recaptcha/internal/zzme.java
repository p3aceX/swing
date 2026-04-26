package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzme {
    public static final zzib zza;
    public static final zzib zzb;
    public static final zzib zzc;

    static {
        zzia zziaVarZzi = zzib.zzi();
        zziaVarZzi.zze(-315576000000L);
        zziaVarZzi.zzd(-999999999);
        zza = (zzib) zziaVarZzi.zzj();
        zzia zziaVarZzi2 = zzib.zzi();
        zziaVarZzi2.zze(315576000000L);
        zziaVarZzi2.zzd(999999999);
        zzb = (zzib) zziaVarZzi2.zzj();
        zzia zziaVarZzi3 = zzib.zzi();
        zziaVarZzi3.zze(0L);
        zziaVarZzi3.zzd(0);
        zzc = (zzib) zziaVarZzi3.zzj();
    }

    public static zzib zza(long j4) {
        int i4 = (int) (j4 % 1000000000);
        long jZza = j4 / 1000000000;
        if (i4 <= -1000000000 || i4 >= 1000000000) {
            jZza = zzgb.zza(jZza, i4 / 1000000000);
            i4 %= 1000000000;
        }
        if (jZza > 0 && i4 < 0) {
            i4 += 1000000000;
            jZza--;
        }
        if (jZza < 0 && i4 > 0) {
            i4 -= 1000000000;
            jZza++;
        }
        zzia zziaVarZzi = zzib.zzi();
        zziaVarZzi.zze(jZza);
        zziaVarZzi.zzd(i4);
        zzib zzibVar = (zzib) zziaVarZzi.zzj();
        long jZzg = zzibVar.zzg();
        int iZzf = zzibVar.zzf();
        if (jZzg >= -315576000000L && jZzg <= 315576000000L && iZzf >= -999999999 && iZzf < 1000000000 && ((jZzg >= 0 && iZzf >= 0) || (jZzg <= 0 && iZzf <= 0))) {
            return zzibVar;
        }
        throw new IllegalArgumentException("Duration is not valid. See proto definition for valid values. Seconds (" + jZzg + ") must be in range [-315,576,000,000, +315,576,000,000]. Nanos (" + iZzf + ") must be in range [-999,999,999, +999,999,999]. Nanos must have the same sign as seconds");
    }
}
