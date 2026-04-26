package com.google.android.gms.internal.auth;

import android.content.Context;
import com.google.android.gms.common.api.o;
import w0.C0699a;

/* JADX INFO: loaded from: classes.dex */
final class zzbq extends zzbi {
    final /* synthetic */ C0699a zza;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzbq(zzbt zzbtVar, o oVar, C0699a c0699a) {
        super(oVar);
        this.zza = c0699a;
    }

    @Override // com.google.android.gms.internal.auth.zzbi
    public final void zza(Context context, zzbh zzbhVar) {
        zzbhVar.zze(new zzbp(this), this.zza);
    }
}
