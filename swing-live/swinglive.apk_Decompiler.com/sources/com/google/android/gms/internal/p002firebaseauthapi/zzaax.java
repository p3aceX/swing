package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.C0459d;
import j1.l;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzaax extends zzacw<Object, s> {
    private final C0459d zzy;

    public zzaax(C0459d c0459d) {
        super(2);
        F.h(c0459d, "credential cannot be null");
        this.zzy = c0459d;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "linkEmailAuthCredential";
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
        C0459d c0459d = this.zzy;
        l lVar = this.zzd;
        c0459d.getClass();
        c0459d.f5196d = ((e) lVar).f5512a.zzf();
        c0459d.e = true;
        zzaceVar.zza(new zzyf(c0459d, null), this.zzb);
    }
}
