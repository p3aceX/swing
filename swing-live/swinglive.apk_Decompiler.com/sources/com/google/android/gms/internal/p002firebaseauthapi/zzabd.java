package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import k1.e;
import k1.s;
import k1.x;

/* JADX INFO: loaded from: classes.dex */
final class zzabd extends zzacw<Object, s> {
    private final String zzaa;
    private final String zzab;
    private final String zzy;
    private final String zzz;

    public zzabd(String str, String str2, String str3, String str4) {
        super(2);
        F.e(str, "email cannot be null or empty");
        F.e(str2, "password cannot be null or empty");
        this.zzy = str;
        this.zzz = str2;
        this.zzaa = str3;
        this.zzab = str4;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "reauthenticateWithEmailPasswordWithData";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        e eVarZza = zzaag.zza(this.zzc, this.zzk);
        if (!((e) this.zzd).f5513b.f5505a.equalsIgnoreCase(eVarZza.f5513b.f5505a)) {
            zza(new Status(17024, null));
        } else {
            ((s) this.zze).a(this.zzj, eVarZza);
            zzb(new x(eVarZza));
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zzb(this.zzy, this.zzz, this.zzaa, this.zzab, this.zzb);
    }
}
