package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzzf implements zzadm<zzafm> {
    final /* synthetic */ zzacf zza;
    final /* synthetic */ zzyl zzb;
    private final /* synthetic */ zzags zzc;

    public zzzf(zzyl zzylVar, zzags zzagsVar, zzacf zzacfVar) {
        this.zzc = zzagsVar;
        this.zza = zzacfVar;
        this.zzb = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zza.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzafm zzafmVar) {
        this.zzc.zzb(true);
        this.zzc.zza(zzafmVar.zzc());
        this.zzb.zza.zza(this.zzc, new zzze(this, this));
    }
}
