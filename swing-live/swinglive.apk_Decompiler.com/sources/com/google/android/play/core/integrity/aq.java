package com.google.android.play.core.integrity;

import android.content.Context;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class aq extends Q0.w {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final /* synthetic */ Context f3662a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    final /* synthetic */ ax f3663b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public aq(ax axVar, TaskCompletionSource taskCompletionSource, Context context) {
        super(taskCompletionSource);
        this.f3663b = axVar;
        this.f3662a = context;
    }

    @Override // Q0.w
    public final void b() {
        this.f3663b.f3679d.trySetResult(Boolean.valueOf(Q0.e.a(this.f3662a)));
    }
}
