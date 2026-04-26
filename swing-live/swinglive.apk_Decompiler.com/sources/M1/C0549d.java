package m1;

import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

/* JADX INFO: renamed from: m1.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0549d implements i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5774a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ ScheduledExecutorServiceC0552g f5775b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Runnable f5776c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ long f5777d;
    public final /* synthetic */ long e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ TimeUnit f5778f;

    public /* synthetic */ C0549d(ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g, Runnable runnable, long j4, long j5, TimeUnit timeUnit, int i4) {
        this.f5774a = i4;
        this.f5775b = scheduledExecutorServiceC0552g;
        this.f5776c = runnable;
        this.f5777d = j4;
        this.e = j5;
        this.f5778f = timeUnit;
    }

    @Override // m1.i
    public final ScheduledFuture a(C0553h c0553h) {
        switch (this.f5774a) {
            case 0:
                ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g = this.f5775b;
                return scheduledExecutorServiceC0552g.f5787b.scheduleAtFixedRate(new RunnableC0550e(scheduledExecutorServiceC0552g, this.f5776c, c0553h, 0), this.f5777d, this.e, this.f5778f);
            default:
                ScheduledExecutorServiceC0552g scheduledExecutorServiceC0552g2 = this.f5775b;
                return scheduledExecutorServiceC0552g2.f5787b.scheduleWithFixedDelay(new RunnableC0550e(scheduledExecutorServiceC0552g2, this.f5776c, c0553h, 2), this.f5777d, this.e, this.f5778f);
        }
    }
}
