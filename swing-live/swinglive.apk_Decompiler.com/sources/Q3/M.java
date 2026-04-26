package Q3;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class M extends V3.r {
    public static final /* synthetic */ AtomicIntegerFieldUpdater e = AtomicIntegerFieldUpdater.newUpdater(M.class, "_decision$volatile");
    private volatile /* synthetic */ int _decision$volatile;

    @Override // V3.r, Q3.q0
    public final void r(Object obj) throws L {
        t(obj);
    }

    @Override // V3.r, Q3.q0
    public final void t(Object obj) throws L {
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater;
        do {
            atomicIntegerFieldUpdater = e;
            int i4 = atomicIntegerFieldUpdater.get(this);
            if (i4 != 0) {
                if (i4 != 1) {
                    throw new IllegalStateException("Already resumed");
                }
                V3.b.h(F.u(obj), e1.k.w(this.f2246d));
                return;
            }
        } while (!atomicIntegerFieldUpdater.compareAndSet(this, 0, 2));
    }
}
