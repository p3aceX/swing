package o;

import e1.k;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: renamed from: o.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0573e extends k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicReferenceFieldUpdater f5944a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AtomicReferenceFieldUpdater f5945b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AtomicReferenceFieldUpdater f5946c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final AtomicReferenceFieldUpdater f5947d;
    public final AtomicReferenceFieldUpdater e;

    public C0573e(AtomicReferenceFieldUpdater atomicReferenceFieldUpdater, AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2, AtomicReferenceFieldUpdater atomicReferenceFieldUpdater3, AtomicReferenceFieldUpdater atomicReferenceFieldUpdater4, AtomicReferenceFieldUpdater atomicReferenceFieldUpdater5) {
        this.f5944a = atomicReferenceFieldUpdater;
        this.f5945b = atomicReferenceFieldUpdater2;
        this.f5946c = atomicReferenceFieldUpdater3;
        this.f5947d = atomicReferenceFieldUpdater4;
        this.e = atomicReferenceFieldUpdater5;
    }

    @Override // e1.k
    public final void B(C0575g c0575g, C0575g c0575g2) {
        this.f5945b.lazySet(c0575g, c0575g2);
    }

    @Override // e1.k
    public final void C(C0575g c0575g, Thread thread) {
        this.f5944a.lazySet(c0575g, thread);
    }

    @Override // e1.k
    public final boolean d(AbstractFutureC0576h abstractFutureC0576h, C0572d c0572d) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        C0572d c0572d2 = C0572d.f5942b;
        do {
            atomicReferenceFieldUpdater = this.f5947d;
            if (atomicReferenceFieldUpdater.compareAndSet(abstractFutureC0576h, c0572d, c0572d2)) {
                return true;
            }
        } while (atomicReferenceFieldUpdater.get(abstractFutureC0576h) == c0572d);
        return false;
    }

    @Override // e1.k
    public final boolean e(AbstractFutureC0576h abstractFutureC0576h, Object obj, Object obj2) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        do {
            atomicReferenceFieldUpdater = this.e;
            if (atomicReferenceFieldUpdater.compareAndSet(abstractFutureC0576h, obj, obj2)) {
                return true;
            }
        } while (atomicReferenceFieldUpdater.get(abstractFutureC0576h) == obj);
        return false;
    }

    @Override // e1.k
    public final boolean f(AbstractFutureC0576h abstractFutureC0576h, C0575g c0575g, C0575g c0575g2) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        do {
            atomicReferenceFieldUpdater = this.f5946c;
            if (atomicReferenceFieldUpdater.compareAndSet(abstractFutureC0576h, c0575g, c0575g2)) {
                return true;
            }
        } while (atomicReferenceFieldUpdater.get(abstractFutureC0576h) == c0575g);
        return false;
    }
}
