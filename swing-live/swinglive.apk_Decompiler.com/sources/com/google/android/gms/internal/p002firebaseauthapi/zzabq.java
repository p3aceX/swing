package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import k1.g;

/* JADX INFO: loaded from: classes.dex */
final class zzabq extends zzacw<zzagi, Void> {
    private final zzagl zzy;

    public zzabq(g gVar, String str) {
        super(12);
        F.g(gVar);
        String str2 = gVar.f5526a;
        F.d(str2);
        this.zzy = zzagl.zza(str2, str);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "startMfaEnrollment";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        zzb(this.zzv);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzb);
    }
}
