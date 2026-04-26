package b;

import O.AbstractActivityC0114z;
import android.os.Looper;
import android.os.SystemClock;
import android.view.View;
import android.view.ViewTreeObserver;
import java.util.concurrent.Executor;

/* JADX INFO: renamed from: b.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ExecutorC0233j implements Executor, ViewTreeObserver.OnDrawListener, Runnable {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Runnable f3226b;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ AbstractActivityC0114z f3228d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f3225a = SystemClock.uptimeMillis() + 10000;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f3227c = false;

    public ExecutorC0233j(AbstractActivityC0114z abstractActivityC0114z) {
        this.f3228d = abstractActivityC0114z;
    }

    public final void a(View view) {
        if (this.f3227c) {
            return;
        }
        this.f3227c = true;
        view.getViewTreeObserver().addOnDrawListener(this);
    }

    @Override // java.util.concurrent.Executor
    public final void execute(Runnable runnable) {
        this.f3226b = runnable;
        View decorView = this.f3228d.getWindow().getDecorView();
        if (!this.f3227c) {
            decorView.postOnAnimation(new F1.a(this, 14));
        } else if (Looper.myLooper() == Looper.getMainLooper()) {
            decorView.invalidate();
        } else {
            decorView.postInvalidate();
        }
    }

    @Override // android.view.ViewTreeObserver.OnDrawListener
    public final void onDraw() {
        boolean z4;
        Runnable runnable = this.f3226b;
        if (runnable == null) {
            if (SystemClock.uptimeMillis() > this.f3225a) {
                this.f3227c = false;
                this.f3228d.getWindow().getDecorView().post(this);
                return;
            }
            return;
        }
        runnable.run();
        this.f3226b = null;
        Y.f fVar = this.f3228d.f3235o;
        synchronized (fVar.f2463b) {
            z4 = fVar.f2462a;
        }
        if (z4) {
            this.f3227c = false;
            this.f3228d.getWindow().getDecorView().post(this);
        }
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.f3228d.getWindow().getDecorView().getViewTreeObserver().removeOnDrawListener(this);
    }
}
