package Q3;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: renamed from: Q3.g0, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0130g0 extends AbstractC0140l0 {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f1629f = AtomicIntegerFieldUpdater.newUpdater(C0130g0.class, "_invoked$volatile");
    private volatile /* synthetic */ int _invoked$volatile;
    public final C0138k0 e;

    public C0130g0(C0138k0 c0138k0) {
        this.e = c0138k0;
    }

    @Override // Q3.AbstractC0140l0
    public final boolean m() {
        return true;
    }

    @Override // Q3.AbstractC0140l0
    public final void n(Throwable th) {
        if (f1629f.compareAndSet(this, 0, 1)) {
            this.e.invoke(th);
        }
    }
}
