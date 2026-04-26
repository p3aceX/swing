package V3;

import Q3.F;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2233a = AtomicReferenceFieldUpdater.newUpdater(k.class, Object.class, "_next$volatile");

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2234b = AtomicReferenceFieldUpdater.newUpdater(k.class, Object.class, "_prev$volatile");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2235c = AtomicReferenceFieldUpdater.newUpdater(k.class, Object.class, "_removedRef$volatile");
    private volatile /* synthetic */ Object _next$volatile = this;
    private volatile /* synthetic */ Object _prev$volatile = this;
    private volatile /* synthetic */ Object _removedRef$volatile;

    public final boolean f(k kVar, int i4) {
        while (true) {
            k kVarG = g();
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f2234b;
            if (kVarG == null) {
                Object obj = atomicReferenceFieldUpdater.get(this);
                while (true) {
                    kVarG = (k) obj;
                    if (!kVarG.k()) {
                        break;
                    }
                    obj = atomicReferenceFieldUpdater.get(kVarG);
                }
            }
            if (kVarG instanceof i) {
                return (((i) kVarG).f2232d & i4) == 0 && kVarG.f(kVar, i4);
            }
            atomicReferenceFieldUpdater.set(kVar, kVarG);
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = f2233a;
            atomicReferenceFieldUpdater2.set(kVar, this);
            while (!atomicReferenceFieldUpdater2.compareAndSet(kVarG, this, kVar)) {
                if (atomicReferenceFieldUpdater2.get(kVarG) != this) {
                    break;
                }
            }
            kVar.h(this);
            return true;
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:20:0x0031, code lost:
    
        r6 = ((V3.p) r6).f2245a;
     */
    /* JADX WARN: Code restructure failed: missing block: B:22:0x0039, code lost:
    
        if (r5.compareAndSet(r4, r3, r6) == false) goto L24;
     */
    /* JADX WARN: Code restructure failed: missing block: B:25:0x0041, code lost:
    
        if (r5.get(r4) == r3) goto L43;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final V3.k g() {
        /*
            r9 = this;
        L0:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r0 = V3.k.f2234b
            java.lang.Object r1 = r0.get(r9)
            V3.k r1 = (V3.k) r1
            r2 = 0
            r3 = r1
        La:
            r4 = r2
        Lb:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r5 = V3.k.f2233a
            java.lang.Object r6 = r5.get(r3)
            if (r6 != r9) goto L24
            if (r1 != r3) goto L16
            return r3
        L16:
            boolean r2 = r0.compareAndSet(r9, r1, r3)
            if (r2 == 0) goto L1d
            return r3
        L1d:
            java.lang.Object r2 = r0.get(r9)
            if (r2 == r1) goto L16
            goto L0
        L24:
            boolean r7 = r9.k()
            if (r7 == 0) goto L2b
            return r2
        L2b:
            boolean r7 = r6 instanceof V3.p
            if (r7 == 0) goto L4b
            if (r4 == 0) goto L44
            V3.p r6 = (V3.p) r6
            V3.k r6 = r6.f2245a
        L35:
            boolean r7 = r5.compareAndSet(r4, r3, r6)
            if (r7 == 0) goto L3d
            r3 = r4
            goto La
        L3d:
            java.lang.Object r7 = r5.get(r4)
            if (r7 == r3) goto L35
            goto L0
        L44:
            java.lang.Object r3 = r0.get(r3)
            V3.k r3 = (V3.k) r3
            goto Lb
        L4b:
            java.lang.String r4 = "null cannot be cast to non-null type kotlinx.coroutines.internal.LockFreeLinkedListNode"
            J3.i.c(r6, r4)
            r4 = r6
            V3.k r4 = (V3.k) r4
            r8 = r4
            r4 = r3
            r3 = r8
            goto Lb
        */
        throw new UnsupportedOperationException("Method not decompiled: V3.k.g():V3.k");
    }

    public final void h(k kVar) {
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f2234b;
            k kVar2 = (k) atomicReferenceFieldUpdater.get(kVar);
            if (f2233a.get(this) != kVar) {
                return;
            }
            while (!atomicReferenceFieldUpdater.compareAndSet(kVar, kVar2, this)) {
                if (atomicReferenceFieldUpdater.get(kVar) != kVar2) {
                    break;
                }
            }
            if (k()) {
                kVar.g();
                return;
            }
            return;
        }
    }

    public final k i() {
        k kVar;
        Object obj = f2233a.get(this);
        p pVar = obj instanceof p ? (p) obj : null;
        if (pVar != null && (kVar = pVar.f2245a) != null) {
            return kVar;
        }
        J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.internal.LockFreeLinkedListNode");
        return (k) obj;
    }

    public boolean k() {
        return f2233a.get(this) instanceof p;
    }

    public String toString() {
        return new j(this, F.class, "classSimpleName", "getClassSimpleName(Ljava/lang/Object;)Ljava/lang/String;", 1) + '@' + F.l(this);
    }
}
