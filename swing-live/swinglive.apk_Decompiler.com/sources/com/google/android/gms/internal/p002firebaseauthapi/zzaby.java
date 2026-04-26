package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.C0451A;
import k1.e;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzaby extends zzacw<Void, s> {
    private final C0451A zzy;

    public zzaby(C0451A c0451a) {
        super(2);
        F.h(c0451a, "request cannot be null");
        this.zzy = c0451a;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "updateProfile";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        ((s) this.zze).a(this.zzj, zzaag.zza(this.zzc, this.zzk));
        zzb(null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(((e) this.zzd).f5512a.zzf(), this.zzy, this.zzb);
    }
}
