package Q3;

import java.util.concurrent.ScheduledFuture;

/* JADX INFO: loaded from: classes.dex */
public final class P implements Q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ScheduledFuture f1597a;

    public P(ScheduledFuture scheduledFuture) {
        this.f1597a = scheduledFuture;
    }

    @Override // Q3.Q
    public final void a() {
        this.f1597a.cancel(false);
    }

    public final String toString() {
        return "DisposableFutureHandle[" + this.f1597a + ']';
    }
}
