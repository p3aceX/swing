package m1;

import java.util.concurrent.Delayed;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import o.AbstractFutureC0576h;
import o.C0569a;

/* JADX INFO: loaded from: classes.dex */
public final class j extends AbstractFutureC0576h implements ScheduledFuture {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final ScheduledFuture f5789n;

    public j(i iVar) {
        this.f5789n = iVar.a(new C0553h(this));
    }

    @Override // o.AbstractFutureC0576h
    public final void b() {
        ScheduledFuture scheduledFuture = this.f5789n;
        Object obj = this.f5954a;
        scheduledFuture.cancel((obj instanceof C0569a) && ((C0569a) obj).f5939a);
    }

    @Override // java.lang.Comparable
    public final int compareTo(Delayed delayed) {
        return this.f5789n.compareTo(delayed);
    }

    @Override // java.util.concurrent.Delayed
    public final long getDelay(TimeUnit timeUnit) {
        return this.f5789n.getDelay(timeUnit);
    }
}
