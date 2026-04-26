package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.C0456a;

/* JADX INFO: loaded from: classes.dex */
final class zzacb extends zzacw<Void, Void> {
    private final zzyg zzy;

    public zzacb(String str, String str2, C0456a c0456a) {
        super(6);
        F.d(str);
        F.d(str2);
        F.g(c0456a);
        this.zzy = new zzyg(str, str2, c0456a);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "verifyBeforeUpdateEmail";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        zzb(null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzb);
    }
}
