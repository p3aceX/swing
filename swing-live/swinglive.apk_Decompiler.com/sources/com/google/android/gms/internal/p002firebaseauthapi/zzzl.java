package com.google.android.gms.internal.p002firebaseauthapi;

import android.text.TextUtils;
import e1.k;

/* JADX INFO: loaded from: classes.dex */
final class zzzl implements zzadm<zzahc> {
    private final /* synthetic */ zzzi zza;

    public zzzl(zzzi zzziVar) {
        this.zza = zzziVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zza.zza.zza(k.O(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzahc zzahcVar) {
        zzahc zzahcVar2 = zzahcVar;
        if (!TextUtils.isEmpty(zzahcVar2.zza()) && !TextUtils.isEmpty(zzahcVar2.zzb())) {
            zzafm zzafmVar = new zzafm(zzahcVar2.zzb(), zzahcVar2.zza(), Long.valueOf(zzafo.zza(zzahcVar2.zza())), "Bearer");
            zzzi zzziVar = this.zza;
            zzziVar.zzb.zza(zzafmVar, null, null, Boolean.FALSE, null, zzziVar.zza, this);
            return;
        }
        this.zza.zza.zza(k.O("INTERNAL_SUCCESS_SIGN_OUT"));
    }
}
