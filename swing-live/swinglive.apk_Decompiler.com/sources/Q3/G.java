package Q3;

import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.LockSupport;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class G extends Y implements Runnable {
    private static volatile Thread _thread;
    private static volatile int debugStatus;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final G f1585p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final long f1586q;

    static {
        Long l2;
        G g4 = new G();
        f1585p = g4;
        g4.H(false);
        TimeUnit timeUnit = TimeUnit.MILLISECONDS;
        try {
            l2 = Long.getLong("kotlinx.coroutines.DefaultExecutor.keepAlive", 1000L);
        } catch (SecurityException unused) {
            l2 = 1000L;
        }
        f1586q = timeUnit.toNanos(l2.longValue());
    }

    @Override // Q3.Z
    public final Thread G() {
        Thread thread;
        Thread thread2 = _thread;
        if (thread2 != null) {
            return thread2;
        }
        synchronized (this) {
            thread = _thread;
            if (thread == null) {
                thread = new Thread(this, "kotlinx.coroutines.DefaultExecutor");
                _thread = thread;
                thread.setContextClassLoader(f1585p.getClass().getClassLoader());
                thread.setDaemon(true);
                thread.start();
            }
        }
        return thread;
    }

    @Override // Q3.Z
    public final void K(long j4, W w4) {
        throw new RejectedExecutionException("DefaultExecutor was shut down. This error indicates that Dispatchers.shutdown() was invoked prior to completion of exiting coroutines, leaving coroutines in incomplete state. Please refer to Dispatchers.shutdown documentation for more details");
    }

    @Override // Q3.Y
    public final void L(Runnable runnable) {
        if (debugStatus == 4) {
            throw new RejectedExecutionException("DefaultExecutor was shut down. This error indicates that Dispatchers.shutdown() was invoked prior to completion of exiting coroutines, leaving coroutines in incomplete state. Please refer to Dispatchers.shutdown documentation for more details");
        }
        super.L(runnable);
    }

    public final synchronized void Q() {
        int i4 = debugStatus;
        if (i4 == 2 || i4 == 3) {
            debugStatus = 3;
            Y.f1606m.set(this, null);
            Y.f1607n.set(this, null);
            notifyAll();
        }
    }

    @Override // Q3.Y, Q3.K
    public final Q n(long j4, F0 f02, InterfaceC0767h interfaceC0767h) {
        long j5 = j4 > 0 ? j4 >= 9223372036854L ? Long.MAX_VALUE : 1000000 * j4 : 0L;
        if (j5 >= 4611686018427387903L) {
            return u0.f1664a;
        }
        long jNanoTime = System.nanoTime();
        V v = new V(j5 + jNanoTime, f02);
        P(jNanoTime, v);
        return v;
    }

    @Override // java.lang.Runnable
    public final void run() {
        boolean zO;
        B0.f1566a.set(this);
        try {
            synchronized (this) {
                int i4 = debugStatus;
                if (i4 == 2 || i4 == 3) {
                    if (zO) {
                        return;
                    } else {
                        return;
                    }
                }
                debugStatus = 1;
                notifyAll();
                long j4 = Long.MAX_VALUE;
                while (true) {
                    Thread.interrupted();
                    long jI = I();
                    if (jI == Long.MAX_VALUE) {
                        long jNanoTime = System.nanoTime();
                        if (j4 == Long.MAX_VALUE) {
                            j4 = f1586q + jNanoTime;
                        }
                        long j5 = j4 - jNanoTime;
                        if (j5 <= 0) {
                            _thread = null;
                            Q();
                            if (O()) {
                                return;
                            }
                            G();
                            return;
                        }
                        if (jI > j5) {
                            jI = j5;
                        }
                    } else {
                        j4 = Long.MAX_VALUE;
                    }
                    if (jI > 0) {
                        int i5 = debugStatus;
                        if (i5 == 2 || i5 == 3) {
                            _thread = null;
                            Q();
                            if (O()) {
                                return;
                            }
                            G();
                            return;
                        }
                        LockSupport.parkNanos(this, jI);
                    }
                }
            }
        } finally {
            _thread = null;
            Q();
            if (!O()) {
                G();
            }
        }
    }

    @Override // Q3.Y, Q3.Z
    public final void shutdown() {
        debugStatus = 4;
        super.shutdown();
    }

    @Override // Q3.A
    public final String toString() {
        return "DefaultExecutor";
    }
}
