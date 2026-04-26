package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.q;
import k1.e;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzabz extends zzacw<Void, s> {
    private final q zzy;

    public zzabz(q qVar) {
        super(2);
        F.g(qVar);
        this.zzy = qVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "updatePhoneNumber";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        ((s) this.zze).a(this.zzj, zzaag.zza(this.zzc, this.zzk));
        zzb(null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(new zzxy(((e) this.zzd).f5512a.zzf(), this.zzy), this.zzb);
    }
}
