package com.google.android.play.core.integrity;

import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
abstract class aw extends Q0.w {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    final /* synthetic */ ax f3675f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public aw(ax axVar, TaskCompletionSource taskCompletionSource) {
        super(taskCompletionSource);
        this.f3675f = axVar;
    }

    @Override // Q0.w
    public final void a(Exception exc) {
        if (!(exc instanceof Q0.d)) {
            super.a(exc);
        } else if (ax.g(this.f3675f)) {
            super.a(new StandardIntegrityException(-2, exc));
        } else {
            super.a(new StandardIntegrityException(-9, exc));
        }
    }
}
