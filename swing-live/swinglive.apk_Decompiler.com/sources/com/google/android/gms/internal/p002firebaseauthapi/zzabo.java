package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.q;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzabo extends zzacw<Object, s> {
    private final zzye zzy;

    public zzabo(q qVar, String str) {
        super(2);
        F.g(qVar);
        this.zzy = new zzye(qVar, str);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "signInWithPhoneNumber";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        e eVarZza = zzaag.zza(this.zzc, this.zzk);
        ((s) this.zze).a(this.zzj, eVarZza);
        zzb(new x(eVarZza));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzb);
    }
}
