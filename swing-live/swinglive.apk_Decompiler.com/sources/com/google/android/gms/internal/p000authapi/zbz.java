package com.google.android.gms.internal.p000authapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import u0.C0687a;

/* JADX INFO: loaded from: classes.dex */
final class zbz extends zbi {
    final /* synthetic */ TaskCompletionSource zba;

    public zbz(zbaa zbaaVar, TaskCompletionSource taskCompletionSource) {
        this.zba = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.p000authapi.zbj
    public final void zbb(Status status, C0687a c0687a) {
        if (status.b()) {
            this.zba.setResult(c0687a);
        } else {
            this.zba.setException(F.k(status));
        }
    }
}
