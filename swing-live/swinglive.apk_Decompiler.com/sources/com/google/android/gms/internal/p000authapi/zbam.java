package com.google.android.gms.internal.p000authapi;

import H0.a;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import u0.g;

/* JADX INFO: loaded from: classes.dex */
final class zbam extends zbl {
    final /* synthetic */ TaskCompletionSource zba;

    public zbam(zbaq zbaqVar, TaskCompletionSource taskCompletionSource) {
        this.zba = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.p000authapi.zbm
    public final void zbb(Status status, g gVar) {
        a.d0(status, gVar, this.zba);
    }
}
