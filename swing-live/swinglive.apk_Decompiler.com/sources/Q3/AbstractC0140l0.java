package Q3;

import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: renamed from: Q3.l0, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0140l0 extends V3.k implements Q, InterfaceC0124d0 {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public q0 f1637d;

    @Override // Q3.Q
    public final void a() {
        q0 q0VarL = l();
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = q0.f1656a;
            Object obj = atomicReferenceFieldUpdater.get(q0VarL);
            if (obj instanceof AbstractC0140l0) {
                if (obj != this) {
                    return;
                }
                T t4 = F.f1584j;
                while (!atomicReferenceFieldUpdater.compareAndSet(q0VarL, obj, t4)) {
                    if (atomicReferenceFieldUpdater.get(q0VarL) != obj) {
                        break;
                    }
                }
                return;
            }
            if (!(obj instanceof InterfaceC0124d0) || ((InterfaceC0124d0) obj).d() == null) {
                return;
            }
            while (true) {
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = V3.k.f2233a;
                Object obj2 = atomicReferenceFieldUpdater2.get(this);
                if (obj2 instanceof V3.p) {
                    V3.k kVar = ((V3.p) obj2).f2245a;
                    return;
                }
                if (obj2 == this) {
                    return;
                }
                J3.i.c(obj2, "null cannot be cast to non-null type kotlinx.coroutines.internal.LockFreeLinkedListNode");
                V3.k kVar2 = (V3.k) obj2;
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater3 = V3.k.f2235c;
                V3.p pVar = (V3.p) atomicReferenceFieldUpdater3.get(kVar2);
                if (pVar == null) {
                    pVar = new V3.p(kVar2);
                    atomicReferenceFieldUpdater3.set(kVar2, pVar);
                }
                while (!atomicReferenceFieldUpdater2.compareAndSet(this, obj2, pVar)) {
                    if (atomicReferenceFieldUpdater2.get(this) != obj2) {
                        break;
                    }
                }
                kVar2.g();
                return;
            }
        }
    }

    @Override // Q3.InterfaceC0124d0
    public final boolean b() {
        return true;
    }

    @Override // Q3.InterfaceC0124d0
    public final s0 d() {
        return null;
    }

    public InterfaceC0132h0 getParent() {
        return l();
    }

    public final q0 l() {
        q0 q0Var = this.f1637d;
        if (q0Var != null) {
            return q0Var;
        }
        J3.i.g("job");
        throw null;
    }

    public abstract boolean m();

    public abstract void n(Throwable th);

    @Override // V3.k
    public final String toString() {
        return getClass().getSimpleName() + '@' + F.l(this) + "[job@" + F.l(l()) + ']';
    }
}
