package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.List;
import k1.s;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
final class zzaam extends zzacw<Object, s> {
    private final String zzy;
    private final String zzz;

    public zzaam(String str, String str2) {
        super(3);
        F.e(str, "email cannot be null or empty");
        this.zzy = str;
        this.zzz = str2;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "fetchSignInMethodsForEmail";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        List<String> listZza;
        if (this.zzl.zza() == null) {
            listZza = zzaq.zzh();
        } else {
            listZza = this.zzl.zza();
            F.g(listZza);
        }
        zzb(new C0690c(listZza, 28));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zze(this.zzy, this.zzz, this.zzb);
    }
}
