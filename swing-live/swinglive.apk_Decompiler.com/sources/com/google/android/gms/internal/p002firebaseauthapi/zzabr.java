package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import k1.g;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzabr extends zzacw<Void, s> {
    private final String zzaa;
    private final long zzab;
    private final boolean zzac;
    private final boolean zzad;
    private final String zzae;
    private final String zzaf;
    private final boolean zzag;
    private final String zzy;
    private final String zzz;

    public zzabr(g gVar, String str, String str2, long j4, boolean z4, boolean z5, String str3, String str4, boolean z6) {
        super(8);
        F.g(gVar);
        F.d(str);
        String str5 = gVar.f5526a;
        F.d(str5);
        this.zzy = str5;
        this.zzz = str;
        this.zzaa = str2;
        this.zzab = j4;
        this.zzac = z4;
        this.zzad = z5;
        this.zzae = str3;
        this.zzaf = str4;
        this.zzag = z6;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "startMfaEnrollment";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zza(this.zzy, this.zzz, this.zzaa, this.zzab, this.zzac, this.zzad, this.zzae, this.zzaf, this.zzag, this.zzb);
    }
}
