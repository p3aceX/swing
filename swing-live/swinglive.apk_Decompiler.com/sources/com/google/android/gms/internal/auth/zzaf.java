package com.google.android.gms.internal.auth;

import com.google.android.gms.common.api.Status;

/* JADX INFO: loaded from: classes.dex */
final class zzaf extends zzah {
    final /* synthetic */ zzag zza;

    public zzaf(zzag zzagVar) {
        this.zza = zzagVar;
    }

    @Override // com.google.android.gms.internal.auth.zzah, r0.InterfaceC0650c
    public final void zzc(boolean z4) {
        this.zza.setResult(new zzak(z4 ? Status.f3372f : zzal.zza));
    }
}
