package com.google.android.gms.internal.p000authapi;

import H0.a;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import u0.l;

/* JADX INFO: loaded from: classes.dex */
final class zbaf extends zbu {
    final /* synthetic */ TaskCompletionSource zba;

    public zbaf(zbag zbagVar, TaskCompletionSource taskCompletionSource) {
        this.zba = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.p000authapi.zbv
    public final void zbb(Status status, l lVar) {
        a.d0(status, lVar, this.zba);
    }
}
