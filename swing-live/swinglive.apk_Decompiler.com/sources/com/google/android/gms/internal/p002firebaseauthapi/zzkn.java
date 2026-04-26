package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzkn implements zzbs {
    private final zzch<zzbs> zza;
    private final zzrp zzb;

    public zzkn(zzch<zzbs> zzchVar) {
        this.zza = zzchVar;
        if (zzchVar.zzf()) {
            this.zzb = zzno.zza().zzb().zza(zzng.zza(zzchVar), "hybrid_encrypt", "encrypt");
        } else {
            this.zzb = zzng.zza;
        }
    }
}
