package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzacd extends zzacw<Void, s> {
    private final zzyd zzy;

    public zzacd(zzafz zzafzVar) {
        super(8);
        F.g(zzafzVar);
        this.zzy = new zzyd(zzafzVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "verifyPhoneNumber";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzb);
    }
}
