package com.google.android.gms.internal.auth;

import android.content.Context;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.b;
import com.google.android.gms.common.api.internal.AbstractC0256d;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.api.s;
import s0.AbstractC0661b;

/* JADX INFO: loaded from: classes.dex */
abstract class zzbj extends AbstractC0256d {
    public zzbj(o oVar) {
        super(AbstractC0661b.f6472a, oVar);
    }

    @Override // com.google.android.gms.common.api.internal.BasePendingResult
    public final /* synthetic */ s createFailedResult(Status status) {
        return new zzbv(status);
    }

    @Override // com.google.android.gms.common.api.internal.AbstractC0256d
    public final /* bridge */ /* synthetic */ void doExecute(b bVar) {
        zzbe zzbeVar = (zzbe) bVar;
        zza(zzbeVar.getContext(), (zzbh) zzbeVar.getService());
    }

    public final /* bridge */ /* synthetic */ void setResult(Object obj) {
        setResult((s) obj);
    }

    public abstract void zza(Context context, zzbh zzbhVar);
}
