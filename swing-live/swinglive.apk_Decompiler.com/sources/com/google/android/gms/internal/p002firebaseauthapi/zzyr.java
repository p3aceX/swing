package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzyr implements zzadm<zzafc> {
    private final /* synthetic */ zzadj zza;
    private final /* synthetic */ zzacf zzb;
    private final /* synthetic */ zzafm zzc;
    private final /* synthetic */ zzagb zzd;
    private final /* synthetic */ zzyl zze;

    public zzyr(zzyl zzylVar, zzadj zzadjVar, zzacf zzacfVar, zzafm zzafmVar, zzagb zzagbVar) {
        this.zza = zzadjVar;
        this.zzb = zzacfVar;
        this.zzc = zzafmVar;
        this.zzd = zzagbVar;
        this.zze = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zza.zza(str);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final /* synthetic */ void zza(zzafc zzafcVar) {
        List<zzafb> listZza = zzafcVar.zza();
        if (listZza == null || listZza.isEmpty()) {
            this.zza.zza("No users");
        } else {
            zzyl.zza(this.zze, this.zzb, this.zzc, listZza.get(0), this.zzd, this.zza);
        }
    }
}
