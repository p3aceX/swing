package com.google.android.gms.internal.p002firebaseauthapi;

import e1.k;
import j1.C0451A;

/* JADX INFO: loaded from: classes.dex */
final class zzaaa implements zzadm<zzafm> {
    private final /* synthetic */ C0451A zza;
    private final /* synthetic */ zzacf zzb;
    private final /* synthetic */ zzyl zzc;

    public zzaaa(zzyl zzylVar, C0451A c0451a, zzacf zzacfVar) {
        this.zza = c0451a;
        this.zzb = zzacfVar;
        this.zzc = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zzb.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final void zza(zzafm zzafmVar) {
        zzafm zzafmVar2 = zzafmVar;
        zzagb zzagbVar = new zzagb();
        zzagbVar.zzd(zzafmVar2.zzc());
        C0451A c0451a = this.zza;
        if (c0451a.f5158c || c0451a.f5156a != null) {
            zzagbVar.zzb(c0451a.f5156a);
        }
        C0451A c0451a2 = this.zza;
        if (c0451a2.f5159d || c0451a2.e != null) {
            zzagbVar.zzg(c0451a2.f5157b);
        }
        zzyl.zza(this.zzc, this.zzb, zzafmVar2, zzagbVar, this);
    }
}
