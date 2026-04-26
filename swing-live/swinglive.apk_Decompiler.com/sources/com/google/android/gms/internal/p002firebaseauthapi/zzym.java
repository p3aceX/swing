package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzym implements zzadm<zzagy> {
    private final /* synthetic */ zzacf zza;
    private final /* synthetic */ zzyl zzb;

    public zzym(zzyl zzylVar, zzacf zzacfVar) {
        this.zza = zzacfVar;
        this.zzb = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zza.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzagy zzagyVar) {
        zzagy zzagyVar2 = zzagyVar;
        if (zzagyVar2.zzf()) {
            this.zza.zza(new zzyi(zzagyVar2.zzc(), zzagyVar2.zze(), null));
        } else {
            this.zzb.zza(new zzafm(zzagyVar2.zzd(), zzagyVar2.zzb(), Long.valueOf(zzagyVar2.zza()), "Bearer"), null, null, Boolean.FALSE, null, this.zza, this);
        }
    }
}
