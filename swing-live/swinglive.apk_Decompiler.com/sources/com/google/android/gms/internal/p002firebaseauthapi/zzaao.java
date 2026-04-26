package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.l;
import j1.o;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzaao extends zzacw<Object, s> {
    private final String zzaa;
    private final o zzy;
    private final String zzz;

    public zzaao(o oVar, String str, String str2) {
        super(2);
        F.g(oVar);
        throw null;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "finalizeMfaSignIn";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        e eVarZza = zzaag.zza(this.zzc, this.zzk);
        l lVar = this.zzd;
        if (lVar != null && !((e) lVar).f5513b.f5505a.equalsIgnoreCase(eVarZza.f5513b.f5505a)) {
            zza(new Status(17024, null));
        } else {
            ((s) this.zze).a(this.zzj, eVarZza);
            zzb(new x(eVarZza));
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzz, (o) null, this.zzaa, this.zzb);
    }
}
