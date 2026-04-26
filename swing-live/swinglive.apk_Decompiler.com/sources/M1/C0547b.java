package m1;

import O.RunnableC0093d;
import java.util.concurrent.Callable;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

/* JADX INFO: renamed from: m1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0547b implements i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5767a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ ScheduledExecutorServiceC0552g f5768b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ long f5769c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ TimeUnit f5770d;
    public final /* synthetic */ Object e;

    public /* synthetic */ C0547b(ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g, Object obj, long j4, TimeUnit timeUnit, int i4) {
        this.f5767a = i4;
        this.f5768b = scheduledExecutorServiceC0552g;
        this.e = obj;
        this.f5769c = j4;
        this.f5770d = timeUnit;
    }

    @Override // m1.i
    public final ScheduledFuture a(final C0553h c0553h) {
        switch (this.f5767a) {
            case 0:
                ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g = this.f5768b;
                return scheduledExecutorServiceC0552g.f5787b.schedule(new RunnableC0550e(scheduledExecutorServiceC0552g, (Runnable) this.e, c0553h, 1), this.f5769c, this.f5770d);
            default:
                final ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g2 = this.f5768b;
                final Callable callable = (Callable) this.e;
                return scheduledExecutorServiceC0552g2.f5787b.schedule(new Callable() { // from class: m1.f
                    @Override // java.util.concurrent.Callable
                    public final Object call() {
                        ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g3 = scheduledExecutorServiceC0552g2;
                        int i4 = 11;
                        return scheduledExecutorServiceC0552g3.f5786a.submit(new RunnableC0093d(i4, callable, c0553h));
                    }
                }, this.f5769c, this.f5770d);
        }
    }
}
