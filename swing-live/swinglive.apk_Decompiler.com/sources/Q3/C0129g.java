package Q3;

import java.util.concurrent.locks.LockSupport;
import y3.InterfaceC0767h;

/* JADX INFO: renamed from: Q3.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0129g extends AbstractC0117a {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Thread f1628d;
    public final Z e;

    public C0129g(InterfaceC0767h interfaceC0767h, Thread thread, Z z4) {
        super(interfaceC0767h, true, true);
        this.f1628d = thread;
        this.e = z4;
    }

    @Override // Q3.q0
    public final void r(Object obj) {
        Thread threadCurrentThread = Thread.currentThread();
        Thread thread = this.f1628d;
        if (J3.i.a(threadCurrentThread, thread)) {
            return;
        }
        LockSupport.unpark(thread);
    }
}
