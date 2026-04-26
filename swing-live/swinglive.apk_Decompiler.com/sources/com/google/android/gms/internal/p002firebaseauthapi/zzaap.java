package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.o;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzaap extends zzacw<Void, s> {
    private final String zzaa;
    private final String zzab;
    private final o zzy;
    private final String zzz;

    public zzaap(o oVar, String str, String str2, String str3) {
        super(2);
        F.g(oVar);
        throw null;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "finalizeMfaEnrollment";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        ((s) this.zze).a(this.zzj, zzaag.zza(this.zzc, this.zzk));
        zzb(null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza((o) null, this.zzz, this.zzaa, this.zzab, this.zzb);
    }
}
