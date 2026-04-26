package com.google.android.gms.internal.p001authapiphone;

import H0.a;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.AbstractBinderC0260h;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class zzo extends AbstractBinderC0260h {
    final /* synthetic */ TaskCompletionSource zza;

    public zzo(zzr zzrVar, TaskCompletionSource taskCompletionSource) {
        this.zza = taskCompletionSource;
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0261i
    public final void onResult(Status status) {
        if (status.f3378b == 6) {
            this.zza.trySetException(F.k(status));
        } else {
            a.d0(status, null, this.zza);
        }
    }
}
