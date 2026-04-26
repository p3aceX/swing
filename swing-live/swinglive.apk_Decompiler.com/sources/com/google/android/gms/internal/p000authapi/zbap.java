package com.google.android.gms.internal.p000authapi;

import H0.a;
import android.app.PendingIntent;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class zbap extends zbo {
    final /* synthetic */ TaskCompletionSource zba;

    public zbap(zbaq zbaqVar, TaskCompletionSource taskCompletionSource) {
        this.zba = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.p000authapi.zbp
    public final void zbb(Status status, PendingIntent pendingIntent) {
        a.d0(status, pendingIntent, this.zba);
    }
}
