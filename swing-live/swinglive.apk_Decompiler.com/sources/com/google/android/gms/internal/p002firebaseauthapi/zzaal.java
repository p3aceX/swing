package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzaal extends zzacw<Void, s> {
    private final zzxx zzy;

    public zzaal(String str, String str2, String str3) {
        super(4);
        F.e(str, "code cannot be null or empty");
        F.e(str2, "new password cannot be null or empty");
        this.zzy = new zzxx(str, str2, str3);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "confirmPasswordReset";
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
