package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import e1.AbstractC0367g;
import j1.AbstractC0458c;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzaaz extends zzacw<Object, s> {
    private final zzags zzy;

    public zzaaz(AbstractC0458c abstractC0458c, String str) {
        super(2);
        F.h(abstractC0458c, "credential cannot be null");
        this.zzy = AbstractC0367g.Z(abstractC0458c, str).zza(false);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "reauthenticateWithCredentialWithData";
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
