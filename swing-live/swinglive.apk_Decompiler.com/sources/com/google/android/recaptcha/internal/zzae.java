package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzae extends Exception {
    private final Throwable zza;
    private final zzpg zzb;
    private final int zzc;
    private final int zzd;

    public zzae(int i4, int i5, Throwable th) {
        this.zzc = i4;
        this.zzd = i5;
        this.zza = th;
        zzpg zzpgVarZzf = zzph.zzf();
        zzpgVarZzf.zze(i5);
        zzpgVarZzf.zzp(i4);
        this.zzb = zzpgVarZzf;
    }

    @Override // java.lang.Throwable
    public final Throwable getCause() {
        return this.zza;
    }

    public final zzpg zza() {
        return this.zzb;
    }

    public final int zzb() {
        return this.zzd;
    }
}
