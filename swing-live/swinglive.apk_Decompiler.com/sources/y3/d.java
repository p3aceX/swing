package Y3;

import Q3.C0141m;
import Q3.F;
import Q3.L;
import e1.k;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class d extends h implements a {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2529g = AtomicReferenceFieldUpdater.newUpdater(d.class, Object.class, "owner$volatile");
    private volatile /* synthetic */ Object owner$volatile = e.f2530a;

    public final Object c(A3.c cVar) throws IllegalAccessException, L, InvocationTargetException {
        boolean zD = d();
        w3.i iVar = w3.i.f6729a;
        if (!zD) {
            C0141m c0141mN = F.n(k.w(cVar));
            try {
                a(new c(this, c0141mN));
                Object objQ = c0141mN.q();
                EnumC0789a enumC0789a = EnumC0789a.f6999a;
                if (objQ != enumC0789a) {
                    objQ = iVar;
                }
                if (objQ == enumC0789a) {
                    return objQ;
                }
            } catch (Throwable th) {
                c0141mN.y();
                throw th;
            }
        }
        return iVar;
    }

    public final boolean d() {
        int i4;
        char c5;
        while (true) {
            AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = h.f2536f;
            int i5 = atomicIntegerFieldUpdater.get(this);
            if (i5 > 1) {
                do {
                    i4 = atomicIntegerFieldUpdater.get(this);
                    if (i4 > 1) {
                    }
                } while (!atomicIntegerFieldUpdater.compareAndSet(this, i4, 1));
            } else {
                if (i5 <= 0) {
                    c5 = 1;
                    break;
                }
                if (atomicIntegerFieldUpdater.compareAndSet(this, i5, i5 - 1)) {
                    f2529g.set(this, null);
                    c5 = 0;
                    break;
                }
            }
        }
        if (c5 == 0) {
            return true;
        }
        if (c5 == 1) {
            return false;
        }
        if (c5 != 2) {
            throw new IllegalStateException("unexpected");
        }
        throw new IllegalStateException("This mutex is already locked by the specified owner: null".toString());
    }

    public final void e(Object obj) {
        while (Math.max(h.f2536f.get(this), 0) == 0) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f2529g;
            Object obj2 = atomicReferenceFieldUpdater.get(this);
            C0779j c0779j = e.f2530a;
            if (obj2 != c0779j) {
                if (obj2 == obj || obj == null) {
                    while (!atomicReferenceFieldUpdater.compareAndSet(this, obj2, c0779j)) {
                        if (atomicReferenceFieldUpdater.get(this) != obj2) {
                            break;
                        }
                    }
                    b();
                    return;
                }
                throw new IllegalStateException(("This mutex is locked by " + obj2 + ", but " + obj + " is expected").toString());
            }
        }
        throw new IllegalStateException("This mutex is not locked");
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("Mutex@");
        sb.append(F.l(this));
        sb.append("[isLocked=");
        sb.append(Math.max(h.f2536f.get(this), 0) == 0);
        sb.append(",owner=");
        sb.append(f2529g.get(this));
        sb.append(']');
        return sb.toString();
    }
}
