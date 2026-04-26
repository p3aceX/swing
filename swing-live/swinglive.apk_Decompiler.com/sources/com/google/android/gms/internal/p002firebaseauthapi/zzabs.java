package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzabs extends zzacw<Void, s> {
    private final String zzaa;
    private final String zzy;
    private final String zzz;

    public zzabs(String str, String str2, String str3) {
        super(2);
        F.d(str);
        this.zzy = str;
        F.d(str2);
        this.zzz = str2;
        this.zzaa = str3;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "unenrollMfa";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        ((s) this.zze).a(this.zzj, zzaag.zza(this.zzc, this.zzk));
        zzb(null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzz, this.zzaa, this.zzb);
    }
}
