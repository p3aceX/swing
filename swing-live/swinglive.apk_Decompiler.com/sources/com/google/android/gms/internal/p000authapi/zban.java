package com.google.android.gms.internal.p000authapi;

import H0.a;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.AbstractBinderC0260h;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class zban extends AbstractBinderC0260h {
    final /* synthetic */ TaskCompletionSource zba;

    public zban(zbaq zbaqVar, TaskCompletionSource taskCompletionSource) {
        this.zba = taskCompletionSource;
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0261i
    public final void onResult(Status status) {
        a.d0(status, null, this.zba);
    }
}
