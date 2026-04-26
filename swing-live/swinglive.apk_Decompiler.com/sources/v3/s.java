package V3;

import Q3.v0;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public abstract class s extends c implements v0 {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2247d = AtomicIntegerFieldUpdater.newUpdater(s.class, "cleanedAndPointers$volatile");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f2248c;
    private volatile /* synthetic */ int cleanedAndPointers$volatile;

    public s(long j4, s sVar, int i4) {
        super(sVar);
        this.f2248c = j4;
        this.cleanedAndPointers$volatile = i4 << 16;
    }

    @Override // V3.c
    public final boolean d() {
        return f2247d.get(this) == g() && c() != null;
    }

    public final boolean f() {
        return f2247d.addAndGet(this, -65536) == g() && c() != null;
    }

    public abstract int g();

    public abstract void h(int i4, InterfaceC0767h interfaceC0767h);

    public final void i() {
        if (f2247d.incrementAndGet(this) == g()) {
            e();
        }
    }

    public final boolean j() {
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater;
        int i4;
        do {
            atomicIntegerFieldUpdater = f2247d;
            i4 = atomicIntegerFieldUpdater.get(this);
            if (i4 == g() && c() != null) {
                return false;
            }
        } while (!atomicIntegerFieldUpdater.compareAndSet(this, i4, 65536 + i4));
        return true;
    }
}
