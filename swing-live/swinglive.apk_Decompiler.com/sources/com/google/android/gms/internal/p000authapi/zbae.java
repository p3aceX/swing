package com.google.android.gms.internal.p000authapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import u0.j;

/* JADX INFO: loaded from: classes.dex */
final class zbae extends zbs {
    final /* synthetic */ TaskCompletionSource zba;

    public zbae(zbag zbagVar, TaskCompletionSource taskCompletionSource) {
        this.zba = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.p000authapi.zbt
    public final void zbb(Status status, j jVar) {
        if (status.b()) {
            this.zba.setResult(jVar);
        } else {
            this.zba.setException(F.k(status));
        }
    }
}
