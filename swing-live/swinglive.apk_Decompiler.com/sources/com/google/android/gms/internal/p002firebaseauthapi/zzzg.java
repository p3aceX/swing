package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzzg implements zzadm<zzafm> {
    final /* synthetic */ String zza;
    final /* synthetic */ zzacf zzb;
    final /* synthetic */ zzyl zzc;

    public zzzg(zzyl zzylVar, String str, zzacf zzacfVar) {
        this.zza = str;
        this.zzb = zzacfVar;
        this.zzc = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zzb.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzafm zzafmVar) {
        zzafm zzafmVar2 = zzafmVar;
        this.zzc.zza.zza(new zzaez(zzafmVar2.zzc()), new zzzj(this, this, zzafmVar2));
    }
}
