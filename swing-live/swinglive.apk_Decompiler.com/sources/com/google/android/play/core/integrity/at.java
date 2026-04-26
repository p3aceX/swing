package com.google.android.play.core.integrity;

import android.os.Bundle;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
class at extends Q0.o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final TaskCompletionSource f3671a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    final /* synthetic */ ax f3672b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public at(ax axVar, TaskCompletionSource taskCompletionSource) {
        super("com.google.android.play.core.integrity.protocol.IExpressIntegrityServiceCallback");
        this.f3672b = axVar;
        this.f3671a = taskCompletionSource;
    }

    @Override // Q0.p
    public final void b(Bundle bundle) {
        this.f3672b.f3676a.c(this.f3671a);
    }

    @Override // Q0.p
    public void c(Bundle bundle) {
        this.f3672b.f3676a.c(this.f3671a);
    }

    @Override // Q0.p
    public final void d(Bundle bundle) {
        this.f3672b.f3676a.c(this.f3671a);
    }

    @Override // Q0.p
    public void e(Bundle bundle) {
        this.f3672b.f3676a.c(this.f3671a);
    }
}
