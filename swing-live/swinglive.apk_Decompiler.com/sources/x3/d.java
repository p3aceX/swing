package X3;

import Q3.A;
import Q3.AbstractC0118a0;
import V3.u;
import java.util.concurrent.Executor;
import y3.C0768i;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class d extends AbstractC0118a0 implements Executor {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final d f2437c = new d();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final A f2438d;

    static {
        l lVar = l.f2450c;
        int i4 = u.f2250a;
        if (64 >= i4) {
            i4 = 64;
        }
        f2438d = lVar.D(V3.b.l(i4, 12, "kotlinx.coroutines.io.parallelism"));
    }

    @Override // Q3.A
    public final void A(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        f2438d.A(interfaceC0767h, runnable);
    }

    @Override // Q3.A
    public final void B(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        f2438d.B(interfaceC0767h, runnable);
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
        throw new IllegalStateException("Cannot be invoked on Dispatchers.IO");
    }

    @Override // java.util.concurrent.Executor
    public final void execute(Runnable runnable) {
        A(C0768i.f6945a, runnable);
    }

    @Override // Q3.A
    public final String toString() {
        return "Dispatchers.IO";
    }
}
