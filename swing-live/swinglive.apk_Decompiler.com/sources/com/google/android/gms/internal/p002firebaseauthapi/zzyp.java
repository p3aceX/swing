package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;
import j1.C0459d;

/* JADX INFO: loaded from: classes.dex */
final class zzyp implements zzadm<zzafm> {
    private final /* synthetic */ C0459d zza;
    private final /* synthetic */ String zzb;
    private final /* synthetic */ zzacf zzc;
    private final /* synthetic */ zzyl zzd;

    public zzyp(zzyl zzylVar, C0459d c0459d, String str, zzacf zzacfVar) {
        this.zza = c0459d;
        this.zzb = str;
        this.zzc = zzacfVar;
        this.zzd = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zzc.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzafm zzafmVar) {
        this.zzd.zza(new zzaeo(this.zza, zzafmVar.zzc(), this.zzb), this.zzc);
    }
}
