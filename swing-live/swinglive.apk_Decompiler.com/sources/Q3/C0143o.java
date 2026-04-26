package Q3;

import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import z0.C0779j;

/* JADX INFO: renamed from: Q3.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0143o extends AbstractC0140l0 {
    public final /* synthetic */ int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0141m f1647f;

    public /* synthetic */ C0143o(C0141m c0141m, int i4) {
        this.e = i4;
        this.f1647f = c0141m;
    }

    @Override // Q3.AbstractC0140l0
    public final boolean m() {
        switch (this.e) {
            case 0:
                return true;
            default:
                return false;
        }
    }

    @Override // Q3.AbstractC0140l0
    public final void n(Throwable th) throws IllegalAccessException, L, InvocationTargetException {
        switch (this.e) {
            case 0:
                q0 q0VarL = l();
                C0141m c0141m = this.f1647f;
                Throwable thP = c0141m.p(q0VarL);
                if (c0141m.v()) {
                    V3.g gVar = (V3.g) c0141m.f1641d;
                    while (true) {
                        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = V3.g.f2223n;
                        Object obj = atomicReferenceFieldUpdater.get(gVar);
                        C0779j c0779j = V3.b.f2214c;
                        if (J3.i.a(obj, c0779j)) {
                            while (!atomicReferenceFieldUpdater.compareAndSet(gVar, c0779j, thP)) {
                                if (atomicReferenceFieldUpdater.get(gVar) != c0779j) {
                                }
                                break;
                            }
                        } else if (!(obj instanceof Throwable)) {
                            while (!atomicReferenceFieldUpdater.compareAndSet(gVar, obj, null)) {
                                if (atomicReferenceFieldUpdater.get(gVar) != obj) {
                                }
                            }
                        }
                    }
                }
                c0141m.l(thP);
                if (!c0141m.v()) {
                    c0141m.m();
                }
                break;
            default:
                this.f1647f.resumeWith(w3.i.f6729a);
                break;
        }
    }
}
