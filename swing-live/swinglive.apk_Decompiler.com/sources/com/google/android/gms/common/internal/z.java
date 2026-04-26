package com.google.android.gms.common.internal;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.concurrent.TimeUnit;

/* JADX INFO: loaded from: classes.dex */
public final class z implements com.google.android.gms.common.api.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ com.google.android.gms.common.api.q f3614a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ TaskCompletionSource f3615b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ InterfaceC0295s f3616c;

    public z(com.google.android.gms.common.api.q qVar, TaskCompletionSource taskCompletionSource, InterfaceC0295s interfaceC0295s) {
        this.f3614a = qVar;
        this.f3615b = taskCompletionSource;
        this.f3616c = interfaceC0295s;
    }

    @Override // com.google.android.gms.common.api.p
    public final void a(Status status) {
        boolean zB = status.b();
        TaskCompletionSource taskCompletionSource = this.f3615b;
        if (!zB) {
            taskCompletionSource.setException(F.k(status));
            return;
        }
        taskCompletionSource.setResult(this.f3616c.b(this.f3614a.await(0L, TimeUnit.MILLISECONDS)));
    }
}
