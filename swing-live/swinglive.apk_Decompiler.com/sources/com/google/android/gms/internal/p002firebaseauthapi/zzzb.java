package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzzb implements zzadm<zzafm> {
    private final /* synthetic */ String zza;
    private final /* synthetic */ String zzb;
    private final /* synthetic */ String zzc;
    private final /* synthetic */ String zzd;
    private final /* synthetic */ zzacf zze;
    private final /* synthetic */ zzyl zzf;

    public zzzb(zzyl zzylVar, String str, String str2, String str3, String str4, zzacf zzacfVar) {
        this.zza = str;
        this.zzb = str2;
        this.zzc = str3;
        this.zzd = str4;
        this.zze = zzacfVar;
        this.zzf = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zze.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzafm zzafmVar) {
        zzyl.zza(this.zzf, this.zze, new zzagd(this.zza, this.zzb, null, this.zzc, this.zzd, zzafmVar.zzc()), this);
    }
}
