package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzabn extends zzacw<Object, s> {
    private final zzagt zzy;

    public zzabn(String str, String str2) {
        super(2);
        F.e(str, "token cannot be null or empty");
        this.zzy = new zzagt(str, str2);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "signInWithCustomToken";
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
