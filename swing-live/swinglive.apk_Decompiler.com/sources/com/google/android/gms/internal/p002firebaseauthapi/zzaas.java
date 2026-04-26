package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.C0459d;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzaas extends zzacw<Object, s> {
    private final C0459d zzy;
    private final String zzz;

    public zzaas(C0459d c0459d, String str) {
        super(2);
        F.h(c0459d, "credential cannot be null");
        this.zzy = c0459d;
        F.e(c0459d.f5193a, "email cannot be null");
        F.e(c0459d.f5194b, "password cannot be null");
        this.zzz = str;
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
        String str = c0459d.f5193a;
        String str2 = c0459d.f5194b;
        F.d(str2);
        zzaceVar.zza(str, str2, ((e) this.zzd).f5512a.zzf(), this.zzd.b(), this.zzz, this.zzb);
    }
}
