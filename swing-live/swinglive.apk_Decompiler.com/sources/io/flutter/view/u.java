package io.flutter.view;

import android.view.Choreographer;

/* JADX INFO: loaded from: classes.dex */
public final class u implements Choreographer.FrameCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public long f4823a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ v f4824b;

    public u(v vVar, long j4) {
        this.f4824b = vVar;
        this.f4823a = j4;
    }

    @Override // android.view.Choreographer.FrameCallback
    public final void doFrame(long j4) {
        long jNanoTime = System.nanoTime() - j4;
        long j5 = jNanoTime < 0 ? 0L : jNanoTime;
        v vVar = this.f4824b;
        vVar.f4827b.onVsync(j5, vVar.f4826a, this.f4823a);
        vVar.f4828c = this;
    }
}
