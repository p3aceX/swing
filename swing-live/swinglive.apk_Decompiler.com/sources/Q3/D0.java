package Q3;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class D0 extends AbstractC0140l0 {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f1569m = AtomicIntegerFieldUpdater.newUpdater(D0.class, "_state$volatile");
    private volatile /* synthetic */ int _state$volatile;
    public final Thread e = Thread.currentThread();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Q f1570f;

    public static void p(int i4) {
        throw new IllegalStateException(("Illegal state " + i4).toString());
    }

    @Override // Q3.AbstractC0140l0
    public final boolean m() {
        return true;
    }

    @Override // Q3.AbstractC0140l0
    public final void n(Throwable th) {
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater;
        int i4;
        do {
            atomicIntegerFieldUpdater = f1569m;
            i4 = atomicIntegerFieldUpdater.get(this);
            if (i4 != 0) {
                if (i4 == 1 || i4 == 2 || i4 == 3) {
                    return;
                }
                p(i4);
                throw null;
            }
        } while (!atomicIntegerFieldUpdater.compareAndSet(this, i4, 2));
        this.e.interrupt();
        atomicIntegerFieldUpdater.set(this, 3);
    }

    public final void o() {
        while (true) {
            AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f1569m;
            int i4 = atomicIntegerFieldUpdater.get(this);
            if (i4 != 0) {
                if (i4 != 2) {
                    if (i4 == 3) {
                        Thread.interrupted();
                        return;
                    } else {
                        p(i4);
                        throw null;
                    }
                }
            } else if (atomicIntegerFieldUpdater.compareAndSet(this, i4, 1)) {
                Q q4 = this.f1570f;
                if (q4 != null) {
                    q4.a();
                    return;
                }
                return;
            }
        }
    }
}
