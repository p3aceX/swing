package com.google.android.recaptcha.internal;

import Q3.F;
import java.util.TimerTask;

/* JADX INFO: loaded from: classes.dex */
public final class zzbj extends TimerTask {
    final /* synthetic */ zzbm zza;

    public zzbj(zzbm zzbmVar) {
        this.zza = zzbmVar;
    }

    @Override // java.util.TimerTask, java.lang.Runnable
    public final void run() {
        zzbm zzbmVar = this.zza;
        F.s(zzbmVar.zzd, null, new zzbk(zzbmVar, null), 3);
    }
}
