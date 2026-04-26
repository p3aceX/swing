package com.google.android.gms.internal.p002firebaseauthapi;

import a.AbstractC0184a;
import com.google.android.gms.common.api.Status;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
final class zzady extends zzacf {
    private final String zza;
    private final /* synthetic */ zzadt zzb;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzady(zzadt zzadtVar, zzacf zzacfVar, String str) {
        super(zzacfVar);
        this.zzb = zzadtVar;
        this.zza = str;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacf
    public final void zza(Status status) {
        zzadt.zza.c("SMS verification code request failed: " + AbstractC0184a.L(status.f3378b) + " " + status.f3379c, new Object[0]);
        zzaea zzaeaVar = (zzaea) this.zzb.zzd.get(this.zza);
        if (zzaeaVar == null) {
            return;
        }
        Iterator<zzacf> it = zzaeaVar.zzb.iterator();
        while (it.hasNext()) {
            it.next().zza(status);
        }
        this.zzb.zzc(this.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacf
    public final void zzb(String str) {
        zzadt.zza.a("onCodeSent", new Object[0]);
        zzaea zzaeaVar = (zzaea) this.zzb.zzd.get(this.zza);
        if (zzaeaVar == null) {
            return;
        }
        Iterator<zzacf> it = zzaeaVar.zzb.iterator();
        while (it.hasNext()) {
            it.next().zzb(str);
        }
        zzaeaVar.zzg = true;
        zzaeaVar.zzd = str;
        if (zzaeaVar.zza <= 0) {
            this.zzb.zzb(this.zza);
        } else if (!zzaeaVar.zzc) {
            this.zzb.zze(this.zza);
        } else {
            if (zzah.zzc(zzaeaVar.zze)) {
                return;
            }
            zzadt.zza(this.zzb, this.zza);
        }
    }
}
