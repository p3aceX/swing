package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.C0456a;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzabj extends zzacw<Void, s> {
    private final zzya zzy;
    private final String zzz;

    public zzabj(String str, C0456a c0456a, String str2, String str3, String str4) {
        super(4);
        F.e(str, "email cannot be null or empty");
        this.zzy = new zzya(str, c0456a, str2, str3);
        this.zzz = str4;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return this.zzz;
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
