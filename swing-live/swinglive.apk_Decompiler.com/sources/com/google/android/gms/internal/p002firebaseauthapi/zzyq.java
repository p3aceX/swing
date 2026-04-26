package com.google.android.gms.internal.p002firebaseauthapi;

import android.text.TextUtils;
import android.util.Base64;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzyq implements zzadm<zzage> {
    private final /* synthetic */ zzagb zza;
    private final /* synthetic */ zzafb zzb;
    private final /* synthetic */ zzacf zzc;
    private final /* synthetic */ zzafm zzd;
    private final /* synthetic */ zzadj zze;
    private final /* synthetic */ zzyl zzf;

    public zzyq(zzyl zzylVar, zzagb zzagbVar, zzafb zzafbVar, zzacf zzacfVar, zzafm zzafmVar, zzadj zzadjVar) {
        this.zza = zzagbVar;
        this.zzb = zzafbVar;
        this.zzc = zzacfVar;
        this.zzd = zzafmVar;
        this.zze = zzadjVar;
        this.zzf = zzylVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadj
    public final void zza(String str) {
        this.zze.zza(str);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadm
    public final void zza(zzage zzageVar) {
        zzage zzageVar2 = zzageVar;
        if (this.zza.zzi("EMAIL")) {
            this.zzb.zzb(null);
        } else if (this.zza.zzc() != null) {
            this.zzb.zzb(this.zza.zzc());
        }
        if (this.zza.zzi("DISPLAY_NAME")) {
            this.zzb.zza((String) null);
        } else if (this.zza.zzb() != null) {
            this.zzb.zza(this.zza.zzb());
        }
        if (this.zza.zzi("PHOTO_URL")) {
            this.zzb.zzd(null);
        } else if (this.zza.zze() != null) {
            this.zzb.zzd(this.zza.zze());
        }
        if (!TextUtils.isEmpty(this.zza.zzd())) {
            zzafb zzafbVar = this.zzb;
            byte[] bytes = "redacted".getBytes();
            zzafbVar.zzc(bytes != null ? Base64.encodeToString(bytes, 0) : null);
        }
        List<zzafr> listZze = zzageVar2.zze();
        if (listZze == null) {
            listZze = new ArrayList<>();
        }
        this.zzb.zza(listZze);
        zzacf zzacfVar = this.zzc;
        zzafm zzafmVar = this.zzd;
        F.g(zzafmVar);
        String strZzc = zzageVar2.zzc();
        String strZzd = zzageVar2.zzd();
        if (!TextUtils.isEmpty(strZzc) && !TextUtils.isEmpty(strZzd)) {
            zzafmVar = new zzafm(strZzd, strZzc, Long.valueOf(zzageVar2.zza()), zzafmVar.zze());
        }
        zzacfVar.zza(zzafmVar, this.zzb);
    }
}
