package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public final class zzbv {
    private final zzvd zza = null;
    private final zzci zzb;

    private zzbv(zzci zzciVar) {
        this.zzb = zzciVar;
    }

    public static zzbv zza(zzci zzciVar) {
        return new zzbv(zzciVar);
    }

    public final zzvd zza() {
        zzci zzciVar = this.zzb;
        return zzciVar instanceof zzne ? ((zzne) zzciVar).zzb().zza() : ((zzos) zznv.zza().zza(this.zzb, zzos.class)).zza();
    }
}
