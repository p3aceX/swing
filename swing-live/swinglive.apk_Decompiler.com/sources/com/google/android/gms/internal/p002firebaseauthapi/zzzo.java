package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzzo implements zzadm<zzaer> {
    private final /* synthetic */ zzacf zza;
    private final /* synthetic */ zzyl zzb;

    public zzzo(zzyl zzylVar, zzacf zzacfVar) {
        this.zza = zzacfVar;
        this.zzb = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zza.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzaer zzaerVar) {
        zzaer zzaerVar2 = zzaerVar;
        this.zzb.zza(new zzafm(zzaerVar2.zzb(), zzaerVar2.zza(), Long.valueOf(zzafo.zza(zzaerVar2.zza())), "Bearer"), null, null, Boolean.FALSE, null, this.zza, this);
    }
}
