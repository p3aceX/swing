package V3;

import Q3.A;
import Q3.C0141m;
import Q3.F0;
import Q3.H;
import Q3.K;
import Q3.Q;
import Q3.x0;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class h extends A implements K {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2227n = AtomicIntegerFieldUpdater.newUpdater(h.class, "runningWorkers$volatile");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ K f2228c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final A f2229d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final l f2230f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final Object f2231m;
    private volatile /* synthetic */ int runningWorkers$volatile;

    /* JADX WARN: Multi-variable type inference failed */
    public h(A a5, int i4) {
        K k4 = a5 instanceof K ? (K) a5 : null;
        this.f2228c = k4 == null ? H.f1590a : k4;
        this.f2229d = a5;
        this.e = i4;
        this.f2230f = new l();
        this.f2231m = new Object();
    }

    @Override // Q3.A
    public final void A(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        Runnable runnableE;
        this.f2230f.a(runnable);
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f2227n;
        if (atomicIntegerFieldUpdater.get(this) >= this.e || !F() || (runnableE = E()) == null) {
            return;
        }
        try {
            b.i(this.f2229d, this, new x0(this, runnableE, 2, false));
        } catch (Throwable th) {
            atomicIntegerFieldUpdater.decrementAndGet(this);
            throw th;
        }
    }

    @Override // Q3.A
    public final void B(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        Runnable runnableE;
        this.f2230f.a(runnable);
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f2227n;
        if (atomicIntegerFieldUpdater.get(this) >= this.e || !F() || (runnableE = E()) == null) {
            return;
        }
        try {
            this.f2229d.B(this, new x0(this, runnableE, 2, false));
        } catch (Throwable th) {
            atomicIntegerFieldUpdater.decrementAndGet(this);
            throw th;
        }
    }

    public final Runnable E() {
        while (true) {
            Runnable runnable = (Runnable) this.f2230f.d();
            if (runnable != null) {
                return runnable;
            }
            synchronized (this.f2231m) {
                AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f2227n;
                atomicIntegerFieldUpdater.decrementAndGet(this);
                if (this.f2230f.c() == 0) {
                    return null;
                }
                atomicIntegerFieldUpdater.incrementAndGet(this);
            }
        }
    }

    public final boolean F() {
        synchronized (this.f2231m) {
            AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f2227n;
            if (atomicIntegerFieldUpdater.get(this) >= this.e) {
                return false;
            }
            atomicIntegerFieldUpdater.incrementAndGet(this);
            return true;
        }
    }

    @Override // Q3.K
    public final Q n(long j4, F0 f02, InterfaceC0767h interfaceC0767h) {
        return this.f2228c.n(j4, f02, interfaceC0767h);
    }

    @Override // Q3.K
    public final void o(long j4, C0141m c0141m) {
        this.f2228c.o(j4, c0141m);
    }

    @Override // Q3.A
    public final String toString() {
        return this.f2229d + ".limitedParallelism(" + this.e + ')';
    }
}
