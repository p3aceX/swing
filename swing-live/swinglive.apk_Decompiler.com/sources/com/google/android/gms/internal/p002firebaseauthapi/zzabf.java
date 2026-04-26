package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.q;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzabf extends zzacw<Object, s> {
    private final zzye zzy;

    public zzabf(q qVar, String str) {
        super(2);
        F.h(qVar, "credential cannot be null");
        qVar.f5208d = false;
        this.zzy = new zzye(qVar, str);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "reauthenticateWithPhoneCredentialWithData";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        e eVarZza = zzaag.zza(this.zzc, this.zzk);
        if (!((e) this.zzd).f5513b.f5505a.equalsIgnoreCase(eVarZza.f5513b.f5505a)) {
            zza(new Status(17024, null));
        } else {
            ((s) this.zze).a(this.zzj, eVarZza);
            zzb(new x(eVarZza));
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzb);
    }
}
