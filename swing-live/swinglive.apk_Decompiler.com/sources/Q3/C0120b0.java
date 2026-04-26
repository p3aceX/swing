package Q3;

import java.lang.reflect.Method;
import java.util.concurrent.CancellationException;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import y3.InterfaceC0767h;

/* JADX INFO: renamed from: Q3.b0, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0120b0 extends AbstractC0118a0 implements K {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Executor f1614c;

    public C0120b0(Executor executor) {
        Method method;
        this.f1614c = executor;
        Method method2 = V3.a.f2211a;
        try {
            ScheduledThreadPoolExecutor scheduledThreadPoolExecutor = executor instanceof ScheduledThreadPoolExecutor ? (ScheduledThreadPoolExecutor) executor : null;
            if (scheduledThreadPoolExecutor != null && (method = V3.a.f2211a) != null) {
                method.invoke(scheduledThreadPoolExecutor, Boolean.TRUE);
            }
        } catch (Throwable unused) {
        }
    }

    @Override // Q3.A
    public final void A(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        try {
            this.f1614c.execute(runnable);
        } catch (RejectedExecutionException e) {
            CancellationException cancellationException = new CancellationException("The task was rejected");
            cancellationException.initCause(e);
            InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) interfaceC0767h.i(B.f1565b);
            if (interfaceC0132h0 != null) {
                interfaceC0132h0.a(cancellationException);
            }
            X3.e eVar = O.f1596a;
            X3.d.f2437c.A(interfaceC0767h, runnable);
        }
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
        Executor executor = this.f1614c;
        ExecutorService executorService = executor instanceof ExecutorService ? (ExecutorService) executor : null;
        if (executorService != null) {
            executorService.shutdown();
        }
    }

    public final boolean equals(Object obj) {
        return (obj instanceof C0120b0) && ((C0120b0) obj).f1614c == this.f1614c;
    }

    public final int hashCode() {
        return System.identityHashCode(this.f1614c);
    }

    @Override // Q3.K
    public final Q n(long j4, F0 f02, InterfaceC0767h interfaceC0767h) {
        Executor executor = this.f1614c;
        ScheduledFuture<?> scheduledFutureSchedule = null;
        ScheduledExecutorService scheduledExecutorService = executor instanceof ScheduledExecutorService ? (ScheduledExecutorService) executor : null;
        if (scheduledExecutorService != null) {
            try {
                scheduledFutureSchedule = scheduledExecutorService.schedule(f02, j4, TimeUnit.MILLISECONDS);
            } catch (RejectedExecutionException e) {
                CancellationException cancellationException = new CancellationException("The task was rejected");
                cancellationException.initCause(e);
                InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) interfaceC0767h.i(B.f1565b);
                if (interfaceC0132h0 != null) {
                    interfaceC0132h0.a(cancellationException);
                }
            }
        }
        return scheduledFutureSchedule != null ? new P(scheduledFutureSchedule) : G.f1585p.n(j4, f02, interfaceC0767h);
    }

    @Override // Q3.K
    public final void o(long j4, C0141m c0141m) {
        Executor executor = this.f1614c;
        ScheduledFuture<?> scheduledFutureSchedule = null;
        ScheduledExecutorService scheduledExecutorService = executor instanceof ScheduledExecutorService ? (ScheduledExecutorService) executor : null;
        if (scheduledExecutorService != null) {
            try {
                scheduledFutureSchedule = scheduledExecutorService.schedule(new x0(0, this, c0141m), j4, TimeUnit.MILLISECONDS);
            } catch (RejectedExecutionException e) {
                CancellationException cancellationException = new CancellationException("The task was rejected");
                cancellationException.initCause(e);
                InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) c0141m.e.i(B.f1565b);
                if (interfaceC0132h0 != null) {
                    interfaceC0132h0.a(cancellationException);
                }
            }
        }
        if (scheduledFutureSchedule != null) {
            c0141m.u(new C0133i(scheduledFutureSchedule, 0));
        } else {
            G.f1585p.o(j4, c0141m);
        }
    }

    @Override // Q3.A
    public final String toString() {
        return this.f1614c.toString();
    }
}
