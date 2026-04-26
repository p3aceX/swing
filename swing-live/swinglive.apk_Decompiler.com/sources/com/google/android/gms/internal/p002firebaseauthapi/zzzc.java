package com.google.android.gms.internal.p002firebaseauthapi;

import android.text.TextUtils;
import com.google.android.gms.common.api.Status;
import j1.q;

/* JADX INFO: loaded from: classes.dex */
final class zzzc implements zzadm<zzaha> {
    private final /* synthetic */ zzadm zza;
    private final /* synthetic */ zzzd zzb;

    public zzzc(zzzd zzzdVar, zzadm zzadmVar) {
        this.zza = zzadmVar;
        this.zzb = zzzdVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zza.zza(str);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final void zza(zzaha zzahaVar) {
        zzaha zzahaVar2 = zzahaVar;
        if (TextUtils.isEmpty(zzahaVar2.zze())) {
            this.zzb.zzb.zza(new zzafm(zzahaVar2.zzd(), zzahaVar2.zzb(), Long.valueOf(zzahaVar2.zza()), "Bearer"), null, "phone", Boolean.valueOf(zzahaVar2.zzf()), null, this.zzb.zza, this.zza);
        } else {
            this.zzb.zza.zza(new Status(17025, null), new q(null, null, zzahaVar2.zzc(), zzahaVar2.zze(), true));
        }
    }
}
