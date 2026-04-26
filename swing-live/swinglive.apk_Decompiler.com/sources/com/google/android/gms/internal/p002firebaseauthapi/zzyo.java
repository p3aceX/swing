package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzyo implements zzadm<zzaen> {
    private final /* synthetic */ zzacf zza;
    private final /* synthetic */ zzyl zzb;

    public zzyo(zzyl zzylVar, zzacf zzacfVar) {
        this.zza = zzacfVar;
        this.zzb = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zza.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzaen zzaenVar) {
        zzaen zzaenVar2 = zzaenVar;
        if (zzaenVar2.zzf()) {
            this.zza.zza(new zzyi(zzaenVar2.zzc(), zzaenVar2.zze(), null));
        } else {
            this.zzb.zza(new zzafm(zzaenVar2.zzd(), zzaenVar2.zzb(), Long.valueOf(zzaenVar2.zza()), "Bearer"), null, null, Boolean.valueOf(zzaenVar2.zzg()), null, this.zza, this);
        }
    }
}
