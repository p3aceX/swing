package S3;

import Q3.AbstractC0117a;
import Q3.C0134i0;
import java.util.concurrent.CancellationException;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class j extends AbstractC0117a implements i {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final e f1851d;

    public j(InterfaceC0767h interfaceC0767h, e eVar, boolean z4, boolean z5) {
        super(interfaceC0767h, z4, z5);
        this.f1851d = eVar;
    }

    @Override // Q3.q0, Q3.InterfaceC0132h0
    public final void a(CancellationException cancellationException) {
        if (isCancelled()) {
            return;
        }
        if (cancellationException == null) {
            cancellationException = new C0134i0(A(), null, this);
        }
        v(cancellationException);
    }

    public final void f0(I3.l lVar) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        e eVar = this.f1851d;
        eVar.getClass();
        do {
            atomicReferenceFieldUpdater = e.f1827p;
            if (atomicReferenceFieldUpdater.compareAndSet(eVar, null, lVar)) {
                return;
            }
        } while (atomicReferenceFieldUpdater.get(eVar) == null);
        while (true) {
            Object obj = atomicReferenceFieldUpdater.get(eVar);
            C0779j c0779j = g.f1845q;
            if (obj != c0779j) {
                if (obj == g.f1846r) {
                    throw new IllegalStateException("Another handler was already registered and successfully invoked");
                }
                throw new IllegalStateException(("Another handler is already registered: " + obj).toString());
            }
            C0779j c0779j2 = g.f1846r;
            while (!atomicReferenceFieldUpdater.compareAndSet(eVar, c0779j, c0779j2)) {
                if (atomicReferenceFieldUpdater.get(eVar) != c0779j) {
                    break;
                }
            }
            lVar.invoke(eVar.n());
            return;
        }
    }

    @Override // S3.w
    public boolean j(Throwable th) {
        return this.f1851d.f(th, false);
    }

    @Override // S3.w
    public Object k(Object obj) {
        return this.f1851d.k(obj);
    }

    @Override // S3.w
    public Object m(Object obj, InterfaceC0762c interfaceC0762c) {
        return this.f1851d.m(obj, interfaceC0762c);
    }

    @Override // Q3.q0
    public final void v(CancellationException cancellationException) {
        this.f1851d.f(cancellationException, true);
        u(cancellationException);
    }
}
