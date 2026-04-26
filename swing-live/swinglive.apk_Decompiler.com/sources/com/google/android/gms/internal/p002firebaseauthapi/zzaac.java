package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzaac implements zzadm<zzafm> {
    private final /* synthetic */ String zza;
    private final /* synthetic */ zzacf zzb;
    private final /* synthetic */ zzyl zzc;

    public zzaac(zzyl zzylVar, String str, zzacf zzacfVar) {
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
        String strZzc = zzafmVar2.zzc();
        zzagb zzagbVar = new zzagb();
        zzagbVar.zzd(strZzc).zzf(this.zza);
        zzyl.zza(this.zzc, this.zzb, zzafmVar2, zzagbVar, this);
    }
}
