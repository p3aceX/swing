package n3;

import Q3.InterfaceC0137k;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final AtomicReferenceFieldUpdater[] f5917a;
    private volatile InterfaceC0137k acceptHandlerReference;
    private volatile InterfaceC0137k connectHandlerReference;
    private volatile InterfaceC0137k readHandlerReference;
    private volatile InterfaceC0137k writeHandlerReference;

    static {
        J3.c cVar;
        p.f5925b.getClass();
        p[] pVarArr = p.f5926c;
        ArrayList arrayList = new ArrayList(pVarArr.length);
        for (p pVar : pVarArr) {
            int iOrdinal = pVar.ordinal();
            if (iOrdinal == 0) {
                cVar = g.f5912n;
            } else if (iOrdinal == 1) {
                cVar = h.f5913n;
            } else if (iOrdinal == 2) {
                cVar = i.f5914n;
            } else {
                if (iOrdinal != 3) {
                    throw new A0.b();
                }
                cVar = j.f5915n;
            }
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdaterNewUpdater = AtomicReferenceFieldUpdater.newUpdater(l.class, InterfaceC0137k.class, cVar.f820d);
            J3.i.c(atomicReferenceFieldUpdaterNewUpdater, "null cannot be cast to non-null type java.util.concurrent.atomic.AtomicReferenceFieldUpdater<io.ktor.network.selector.InterestSuspensionsMap, kotlinx.coroutines.CancellableContinuation<kotlin.Unit>?>");
            arrayList.add(atomicReferenceFieldUpdaterNewUpdater);
        }
        f5917a = (AtomicReferenceFieldUpdater[]) arrayList.toArray(new AtomicReferenceFieldUpdater[0]);
    }

    public final String toString() {
        return "R " + this.readHandlerReference + " W " + this.writeHandlerReference + " C " + this.connectHandlerReference + " A " + this.acceptHandlerReference;
    }
}
