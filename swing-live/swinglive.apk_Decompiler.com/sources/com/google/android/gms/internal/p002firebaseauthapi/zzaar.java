package com.google.android.gms.internal.p002firebaseauthapi;

import B.k;
import android.text.TextUtils;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import k1.l;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzaar extends zzacw<k, s> {
    private final String zzy;

    public zzaar(String str) {
        super(1);
        F.e(str, "refresh token cannot be null");
        this.zzy = str;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "getAccessToken";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        if (TextUtils.isEmpty(this.zzj.zzd())) {
            this.zzj.zzc(this.zzy);
        }
        ((s) this.zze).a(this.zzj, this.zzd);
        zzb(l.a(this.zzj.zzc()));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zzb(this.zzy, this.zzb);
    }
}
