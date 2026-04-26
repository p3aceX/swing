package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import j1.s;
import j1.u;

/* JADX INFO: loaded from: classes.dex */
final class zzabt extends zzacw<Void, s> {
    private final zzyh zzy;

    public zzabt(u uVar, String str, String str2, long j4, boolean z4, boolean z5, String str3, String str4, boolean z6) {
        super(8);
        F.g(uVar);
        F.d(str);
        this.zzy = new zzyh(uVar, str, str2, j4, z4, z5, str3, str4, z6);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "startMfaSignInWithPhoneNumber";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzb);
    }
}
