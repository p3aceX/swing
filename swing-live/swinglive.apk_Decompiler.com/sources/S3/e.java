package S3;

import Q3.C0141m;
import Q3.F;
import Q3.InterfaceC0137k;
import Q3.K0;
import Q3.L;
import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.CancellationException;
import java.util.concurrent.atomic.AtomicLongFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceArray;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0762c;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public class e implements i {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicLongFieldUpdater f1820b = AtomicLongFieldUpdater.newUpdater(e.class, "sendersAndCloseStatus$volatile");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ AtomicLongFieldUpdater f1821c = AtomicLongFieldUpdater.newUpdater(e.class, "receivers$volatile");

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ AtomicLongFieldUpdater f1822d = AtomicLongFieldUpdater.newUpdater(e.class, "bufferEnd$volatile");
    public static final /* synthetic */ AtomicLongFieldUpdater e = AtomicLongFieldUpdater.newUpdater(e.class, "completedExpandBuffersAndPauseFlag$volatile");

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1823f = AtomicReferenceFieldUpdater.newUpdater(e.class, Object.class, "sendSegment$volatile");

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1824m = AtomicReferenceFieldUpdater.newUpdater(e.class, Object.class, "receiveSegment$volatile");

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1825n = AtomicReferenceFieldUpdater.newUpdater(e.class, Object.class, "bufferEndSegment$volatile");

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1826o = AtomicReferenceFieldUpdater.newUpdater(e.class, Object.class, "_closeCause$volatile");

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1827p = AtomicReferenceFieldUpdater.newUpdater(e.class, Object.class, "closeHandler$volatile");
    private volatile /* synthetic */ Object _closeCause$volatile;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1828a;
    private volatile /* synthetic */ long bufferEnd$volatile;
    private volatile /* synthetic */ Object bufferEndSegment$volatile;
    private volatile /* synthetic */ Object closeHandler$volatile;
    private volatile /* synthetic */ long completedExpandBuffersAndPauseFlag$volatile;
    private volatile /* synthetic */ Object receiveSegment$volatile;
    private volatile /* synthetic */ long receivers$volatile;
    private volatile /* synthetic */ Object sendSegment$volatile;
    private volatile /* synthetic */ long sendersAndCloseStatus$volatile;

    public e(int i4) {
        this.f1828a = i4;
        if (i4 < 0) {
            throw new IllegalArgumentException(B1.a.l("Invalid channel capacity: ", i4, ", should be >=0").toString());
        }
        n nVar = g.f1830a;
        this.bufferEnd$volatile = i4 != 0 ? i4 != Integer.MAX_VALUE ? i4 : Long.MAX_VALUE : 0L;
        this.completedExpandBuffersAndPauseFlag$volatile = f1822d.get(this);
        n nVar2 = new n(0L, null, this, 3);
        this.sendSegment$volatile = nVar2;
        this.receiveSegment$volatile = nVar2;
        if (v()) {
            nVar2 = g.f1830a;
            J3.i.c(nVar2, "null cannot be cast to non-null type kotlinx.coroutines.channels.ChannelSegment<E of kotlinx.coroutines.channels.BufferedChannel>");
        }
        this.bufferEndSegment$volatile = nVar2;
        this._closeCause$volatile = g.f1847s;
    }

    public static boolean C(Object obj) {
        if (!(obj instanceof InterfaceC0137k)) {
            throw new IllegalStateException(("Unexpected waiter: " + obj).toString());
        }
        J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.CancellableContinuation<kotlin.Unit>");
        InterfaceC0137k interfaceC0137k = (InterfaceC0137k) obj;
        n nVar = g.f1830a;
        C0779j c0779jE = interfaceC0137k.e(w3.i.f6729a, null);
        if (c0779jE == null) {
            return false;
        }
        interfaceC0137k.o(c0779jE);
        return true;
    }

    public static final n b(e eVar, long j4, n nVar) {
        Object objB;
        e eVar2;
        eVar.getClass();
        n nVar2 = g.f1830a;
        f fVar = f.f1829o;
        loop0: while (true) {
            objB = V3.b.b(nVar, j4, fVar);
            if (!V3.b.e(objB)) {
                V3.s sVarC = V3.b.c(objB);
                while (true) {
                    AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1823f;
                    V3.s sVar = (V3.s) atomicReferenceFieldUpdater.get(eVar);
                    if (sVar.f2248c >= sVarC.f2248c) {
                        break loop0;
                    }
                    if (!sVarC.j()) {
                        break;
                    }
                    while (!atomicReferenceFieldUpdater.compareAndSet(eVar, sVar, sVarC)) {
                        if (atomicReferenceFieldUpdater.get(eVar) != sVar) {
                            if (sVarC.f()) {
                                sVarC.e();
                            }
                        }
                    }
                    if (sVar.f()) {
                        sVar.e();
                    }
                }
            } else {
                break;
            }
        }
        boolean zE = V3.b.e(objB);
        AtomicLongFieldUpdater atomicLongFieldUpdater = f1821c;
        if (zE) {
            eVar.t();
            if (nVar.f2248c * ((long) g.f1831b) < atomicLongFieldUpdater.get(eVar)) {
                nVar.b();
                return null;
            }
        } else {
            n nVar3 = (n) V3.b.c(objB);
            long j5 = nVar3.f2248c;
            if (j5 <= j4) {
                return nVar3;
            }
            long j6 = ((long) g.f1831b) * j5;
            while (true) {
                AtomicLongFieldUpdater atomicLongFieldUpdater2 = f1820b;
                long j7 = atomicLongFieldUpdater2.get(eVar);
                long j8 = 1152921504606846975L & j7;
                if (j8 >= j6) {
                    eVar2 = eVar;
                    break;
                }
                eVar2 = eVar;
                if (atomicLongFieldUpdater2.compareAndSet(eVar2, j7, j8 + (((long) ((int) (j7 >> 60))) << 60))) {
                    break;
                }
                eVar = eVar2;
            }
            if (j5 * ((long) g.f1831b) < atomicLongFieldUpdater.get(eVar2)) {
                nVar3.b();
            }
        }
        return null;
    }

    public static final void c(e eVar, Object obj, C0141m c0141m) throws IllegalAccessException, L, InvocationTargetException {
        eVar.getClass();
        c0141m.resumeWith(AbstractC0367g.h(eVar.p()));
    }

    public static final int d(e eVar, n nVar, int i4, Object obj, long j4, Object obj2, boolean z4) {
        eVar.getClass();
        nVar.n(i4, obj);
        if (z4) {
            return eVar.E(nVar, i4, obj, j4, obj2, z4);
        }
        Object objL = nVar.l(i4);
        if (objL == null) {
            if (eVar.e(j4)) {
                if (nVar.k(i4, null, g.f1833d)) {
                    return 1;
                }
            } else {
                if (obj2 == null) {
                    return 3;
                }
                if (nVar.k(i4, null, obj2)) {
                    return 2;
                }
            }
        } else if (objL instanceof K0) {
            nVar.n(i4, null);
            if (eVar.B(objL, obj)) {
                nVar.o(i4, g.f1837i);
                return 0;
            }
            C0779j c0779j = g.f1839k;
            if (nVar.f1854f.getAndSet((i4 * 2) + 1, c0779j) == c0779j) {
                return 5;
            }
            nVar.m(i4, true);
            return 5;
        }
        return eVar.E(nVar, i4, obj, j4, obj2, z4);
    }

    public static void r(e eVar) {
        eVar.getClass();
        AtomicLongFieldUpdater atomicLongFieldUpdater = e;
        if ((atomicLongFieldUpdater.addAndGet(eVar, 1L) & 4611686018427387904L) != 0) {
            while ((atomicLongFieldUpdater.get(eVar) & 4611686018427387904L) != 0) {
            }
        }
    }

    public final Object A() {
        n nVar;
        AtomicLongFieldUpdater atomicLongFieldUpdater = f1821c;
        long j4 = atomicLongFieldUpdater.get(this);
        AtomicLongFieldUpdater atomicLongFieldUpdater2 = f1820b;
        long j5 = atomicLongFieldUpdater2.get(this);
        if (s(j5, true)) {
            return new k(n());
        }
        long j6 = j5 & 1152921504606846975L;
        l lVar = m.f1853a;
        if (j4 >= j6) {
            return lVar;
        }
        Object obj = g.f1839k;
        n nVar2 = (n) f1824m.get(this);
        while (!s(atomicLongFieldUpdater2.get(this), true)) {
            long andIncrement = atomicLongFieldUpdater.getAndIncrement(this);
            long j7 = g.f1831b;
            long j8 = andIncrement / j7;
            int i4 = (int) (andIncrement % j7);
            if (nVar2.f2248c != j8) {
                n nVarL = l(j8, nVar2);
                if (nVarL == null) {
                    continue;
                } else {
                    nVar = nVarL;
                }
            } else {
                nVar = nVar2;
            }
            Object objD = D(nVar, i4, andIncrement, obj);
            n nVar3 = nVar;
            if (objD == g.f1841m) {
                K0 k02 = obj instanceof K0 ? (K0) obj : null;
                if (k02 != null) {
                    k02.a(nVar3, i4);
                }
                F(andIncrement);
                nVar3.i();
                return lVar;
            }
            if (objD != g.f1843o) {
                if (objD == g.f1842n) {
                    throw new IllegalStateException("unexpected");
                }
                nVar3.b();
                return objD;
            }
            if (andIncrement < q()) {
                nVar3.b();
            }
            nVar2 = nVar3;
        }
        return new k(n());
    }

    public final boolean B(Object obj, Object obj2) throws L {
        if (!(obj instanceof d)) {
            if (!(obj instanceof InterfaceC0137k)) {
                throw new IllegalStateException(("Unexpected receiver type: " + obj).toString());
            }
            J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.CancellableContinuation<E of kotlinx.coroutines.channels.BufferedChannel>");
            InterfaceC0137k interfaceC0137k = (InterfaceC0137k) obj;
            n nVar = g.f1830a;
            C0779j c0779jE = interfaceC0137k.e(obj2, null);
            if (c0779jE == null) {
                return false;
            }
            interfaceC0137k.o(c0779jE);
            return true;
        }
        J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.channels.BufferedChannel.BufferedChannelIterator<E of kotlinx.coroutines.channels.BufferedChannel>");
        d dVar = (d) obj;
        C0141m c0141m = dVar.f1818b;
        J3.i.b(c0141m);
        dVar.f1818b = null;
        dVar.f1817a = obj2;
        Boolean bool = Boolean.TRUE;
        dVar.f1819c.getClass();
        n nVar2 = g.f1830a;
        C0779j c0779jE2 = c0141m.e(bool, null);
        if (c0779jE2 == null) {
            return false;
        }
        c0141m.o(c0779jE2);
        return true;
    }

    public final Object D(n nVar, int i4, long j4, Object obj) {
        Object objL = nVar.l(i4);
        AtomicReferenceArray atomicReferenceArray = nVar.f1854f;
        AtomicLongFieldUpdater atomicLongFieldUpdater = f1820b;
        if (objL == null) {
            if (j4 >= (atomicLongFieldUpdater.get(this) & 1152921504606846975L)) {
                if (obj == null) {
                    return g.f1842n;
                }
                if (nVar.k(i4, objL, obj)) {
                    i();
                    return g.f1841m;
                }
            }
        } else if (objL == g.f1833d && nVar.k(i4, objL, g.f1837i)) {
            i();
            Object obj2 = atomicReferenceArray.get(i4 * 2);
            nVar.n(i4, null);
            return obj2;
        }
        while (true) {
            Object objL2 = nVar.l(i4);
            if (objL2 == null || objL2 == g.e) {
                if (j4 < (atomicLongFieldUpdater.get(this) & 1152921504606846975L)) {
                    if (nVar.k(i4, objL2, g.f1836h)) {
                        i();
                        return g.f1843o;
                    }
                } else {
                    if (obj == null) {
                        return g.f1842n;
                    }
                    if (nVar.k(i4, objL2, obj)) {
                        i();
                        return g.f1841m;
                    }
                }
            } else if (objL2 != g.f1833d) {
                C0779j c0779j = g.f1838j;
                if (objL2 == c0779j) {
                    return g.f1843o;
                }
                if (objL2 == g.f1836h) {
                    return g.f1843o;
                }
                if (objL2 == g.f1840l) {
                    i();
                    return g.f1843o;
                }
                if (objL2 != g.f1835g && nVar.k(i4, objL2, g.f1834f)) {
                    boolean z4 = objL2 instanceof x;
                    if (z4) {
                        objL2 = ((x) objL2).f1860a;
                    }
                    if (C(objL2)) {
                        nVar.o(i4, g.f1837i);
                        i();
                        Object obj3 = atomicReferenceArray.get(i4 * 2);
                        nVar.n(i4, null);
                        return obj3;
                    }
                    nVar.o(i4, c0779j);
                    nVar.i();
                    if (z4) {
                        i();
                    }
                    return g.f1843o;
                }
            } else if (nVar.k(i4, objL2, g.f1837i)) {
                i();
                Object obj4 = atomicReferenceArray.get(i4 * 2);
                nVar.n(i4, null);
                return obj4;
            }
        }
    }

    public final int E(n nVar, int i4, Object obj, long j4, Object obj2, boolean z4) {
        while (true) {
            Object objL = nVar.l(i4);
            if (objL == null) {
                if (!e(j4) || z4) {
                    if (z4) {
                        if (nVar.k(i4, null, g.f1838j)) {
                            nVar.i();
                            return 4;
                        }
                    } else {
                        if (obj2 == null) {
                            return 3;
                        }
                        if (nVar.k(i4, null, obj2)) {
                            return 2;
                        }
                    }
                } else if (nVar.k(i4, null, g.f1833d)) {
                    break;
                }
            } else {
                if (objL != g.e) {
                    C0779j c0779j = g.f1839k;
                    if (objL == c0779j) {
                        nVar.n(i4, null);
                        return 5;
                    }
                    if (objL == g.f1836h) {
                        nVar.n(i4, null);
                        return 5;
                    }
                    if (objL == g.f1840l) {
                        nVar.n(i4, null);
                        t();
                        return 4;
                    }
                    nVar.n(i4, null);
                    if (objL instanceof x) {
                        objL = ((x) objL).f1860a;
                    }
                    if (B(objL, obj)) {
                        nVar.o(i4, g.f1837i);
                        return 0;
                    }
                    if (nVar.f1854f.getAndSet((i4 * 2) + 1, c0779j) != c0779j) {
                        nVar.m(i4, true);
                    }
                    return 5;
                }
                if (nVar.k(i4, objL, g.f1833d)) {
                    break;
                }
            }
        }
        return 1;
    }

    public final void F(long j4) {
        AtomicLongFieldUpdater atomicLongFieldUpdater;
        e eVar = this;
        if (eVar.v()) {
            return;
        }
        while (true) {
            atomicLongFieldUpdater = f1822d;
            if (atomicLongFieldUpdater.get(eVar) > j4) {
                break;
            } else {
                eVar = this;
            }
        }
        int i4 = g.f1832c;
        int i5 = 0;
        while (true) {
            AtomicLongFieldUpdater atomicLongFieldUpdater2 = e;
            if (i5 < i4) {
                long j5 = atomicLongFieldUpdater.get(eVar);
                if (j5 == (4611686018427387903L & atomicLongFieldUpdater2.get(eVar)) && j5 == atomicLongFieldUpdater.get(eVar)) {
                    return;
                } else {
                    i5++;
                }
            } else {
                while (true) {
                    long j6 = atomicLongFieldUpdater2.get(eVar);
                    if (atomicLongFieldUpdater2.compareAndSet(eVar, j6, (j6 & 4611686018427387903L) + 4611686018427387904L)) {
                        break;
                    } else {
                        eVar = this;
                    }
                }
                while (true) {
                    long j7 = atomicLongFieldUpdater.get(eVar);
                    long j8 = atomicLongFieldUpdater2.get(eVar);
                    long j9 = j8 & 4611686018427387903L;
                    boolean z4 = (j8 & 4611686018427387904L) != 0;
                    if (j7 == j9 && j7 == atomicLongFieldUpdater.get(eVar)) {
                        break;
                    }
                    if (!z4) {
                        atomicLongFieldUpdater2.compareAndSet(this, j8, 4611686018427387904L + j9);
                    }
                    eVar = this;
                }
                while (true) {
                    long j10 = atomicLongFieldUpdater2.get(eVar);
                    if (atomicLongFieldUpdater2.compareAndSet(eVar, j10, j10 & 4611686018427387903L)) {
                        return;
                    } else {
                        eVar = this;
                    }
                }
            }
        }
    }

    @Override // S3.v
    public final void a(CancellationException cancellationException) {
        if (cancellationException == null) {
            cancellationException = new CancellationException("Channel was cancelled");
        }
        f(cancellationException, true);
    }

    public final boolean e(long j4) {
        return j4 < f1822d.get(this) || j4 < f1821c.get(this) + ((long) this.f1828a);
    }

    public final boolean f(Throwable th, boolean z4) {
        e eVar;
        boolean z5;
        long j4;
        long j5;
        long j6;
        Object obj;
        long j7;
        long j8;
        AtomicLongFieldUpdater atomicLongFieldUpdater = f1820b;
        if (!z4) {
            eVar = this;
            break;
        }
        do {
            j8 = atomicLongFieldUpdater.get(this);
            if (((int) (j8 >> 60)) != 0) {
                eVar = this;
                break;
            }
            n nVar = g.f1830a;
            eVar = this;
        } while (!atomicLongFieldUpdater.compareAndSet(eVar, j8, (j8 & 1152921504606846975L) + (((long) 1) << 60)));
        C0779j c0779j = g.f1847s;
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1826o;
            if (atomicReferenceFieldUpdater.compareAndSet(this, c0779j, th)) {
                z5 = true;
                break;
            }
            if (atomicReferenceFieldUpdater.get(this) != c0779j) {
                z5 = false;
                break;
            }
        }
        if (z4) {
            do {
                j7 = atomicLongFieldUpdater.get(this);
            } while (!atomicLongFieldUpdater.compareAndSet(eVar, j7, (((long) 3) << 60) + (j7 & 1152921504606846975L)));
        } else {
            do {
                j4 = atomicLongFieldUpdater.get(this);
                int i4 = (int) (j4 >> 60);
                if (i4 == 0) {
                    j5 = j4 & 1152921504606846975L;
                    j6 = 2;
                } else {
                    if (i4 != 1) {
                        break;
                    }
                    j5 = j4 & 1152921504606846975L;
                    j6 = 3;
                }
            } while (!atomicLongFieldUpdater.compareAndSet(eVar, j4, (j6 << 60) + j5));
        }
        t();
        if (z5) {
            loop3: while (true) {
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = f1827p;
                obj = atomicReferenceFieldUpdater2.get(this);
                C0779j c0779j2 = obj == null ? g.f1845q : g.f1846r;
                while (!atomicReferenceFieldUpdater2.compareAndSet(this, obj, c0779j2)) {
                    if (atomicReferenceFieldUpdater2.get(this) != obj) {
                        break;
                    }
                }
            }
            if (obj != null) {
                J3.u.a(1, obj);
                ((I3.l) obj).invoke(n());
                return z5;
            }
        }
        return z5;
    }

    /* JADX WARN: Code restructure failed: missing block: B:37:0x008f, code lost:
    
        r1 = (S3.n) ((V3.c) V3.c.f2219b.get(r1));
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final S3.n g(long r13) throws java.lang.IllegalAccessException, Q3.L, java.lang.reflect.InvocationTargetException {
        /*
            Method dump skipped, instruction units count: 308
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.e.g(long):S3.n");
    }

    public final void h(long j4) {
        n nVar = (n) f1824m.get(this);
        while (true) {
            AtomicLongFieldUpdater atomicLongFieldUpdater = f1821c;
            long j5 = atomicLongFieldUpdater.get(this);
            if (j4 < Math.max(((long) this.f1828a) + j5, f1822d.get(this))) {
                return;
            }
            if (atomicLongFieldUpdater.compareAndSet(this, j5, 1 + j5)) {
                long j6 = g.f1831b;
                long j7 = j5 / j6;
                int i4 = (int) (j5 % j6);
                if (nVar.f2248c != j7) {
                    n nVarL = l(j7, nVar);
                    if (nVarL != null) {
                        nVar = nVarL;
                    }
                }
                n nVar2 = nVar;
                if (D(nVar2, i4, j5, null) != g.f1843o || j5 < q()) {
                    nVar2.b();
                }
                nVar = nVar2;
            }
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:102:0x018e, code lost:
    
        r(r15);
     */
    /* JADX WARN: Code restructure failed: missing block: B:103:0x0191, code lost:
    
        return;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void i() {
        /*
            Method dump skipped, instruction units count: 402
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.e.i():void");
    }

    @Override // S3.w
    public final boolean j(Throwable th) {
        return f(th, false);
    }

    /* JADX WARN: Removed duplicated region for block: B:22:0x0068  */
    /* JADX WARN: Removed duplicated region for block: B:57:0x00be A[SYNTHETIC] */
    @Override // S3.w
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object k(java.lang.Object r16) throws java.lang.IllegalAccessException, Q3.L, java.lang.reflect.InvocationTargetException {
        /*
            r15 = this;
            java.util.concurrent.atomic.AtomicLongFieldUpdater r8 = S3.e.f1820b
            long r1 = r8.get(r15)
            r9 = 0
            boolean r3 = r15.s(r1, r9)
            r10 = 1
            r11 = 1152921504606846975(0xfffffffffffffff, double:1.2882297539194265E-231)
            if (r3 == 0) goto L15
            r1 = r9
            goto L1b
        L15:
            long r1 = r1 & r11
            boolean r1 = r15.e(r1)
            r1 = r1 ^ r10
        L1b:
            S3.l r13 = S3.m.f1853a
            if (r1 == 0) goto L20
            return r13
        L20:
            z0.j r6 = S3.g.f1838j
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r1 = S3.e.f1823f
            java.lang.Object r1 = r1.get(r15)
            S3.n r1 = (S3.n) r1
        L2a:
            long r2 = r8.getAndIncrement(r15)
            long r4 = r2 & r11
            boolean r7 = r15.s(r2, r9)
            int r14 = S3.g.f1831b
            long r2 = (long) r14
            long r11 = r4 / r2
            long r2 = r4 % r2
            int r2 = (int) r2
            long r9 = r1.f2248c
            int r3 = (r9 > r11 ? 1 : (r9 == r11 ? 0 : -1))
            if (r3 == 0) goto L5d
            S3.n r3 = b(r15, r11, r1)
            if (r3 != 0) goto L5c
            if (r7 == 0) goto L54
            java.lang.Throwable r1 = r15.p()
            S3.k r2 = new S3.k
            r2.<init>(r1)
            return r2
        L54:
            r9 = 0
            r10 = 1
        L56:
            r11 = 1152921504606846975(0xfffffffffffffff, double:1.2882297539194265E-231)
            goto L2a
        L5c:
            r1 = r3
        L5d:
            r0 = r15
            r3 = r16
            int r9 = d(r0, r1, r2, r3, r4, r6, r7)
            w3.i r3 = w3.i.f6729a
            if (r9 == 0) goto Lbe
            r10 = 1
            if (r9 == r10) goto Lbd
            r3 = 2
            if (r9 == r3) goto L9c
            r2 = 3
            if (r9 == r2) goto L94
            r2 = 4
            if (r9 == r2) goto L7d
            r2 = 5
            if (r9 == r2) goto L78
            goto L7b
        L78:
            r1.b()
        L7b:
            r9 = 0
            goto L56
        L7d:
            java.util.concurrent.atomic.AtomicLongFieldUpdater r2 = S3.e.f1821c
            long r2 = r2.get(r15)
            int r2 = (r4 > r2 ? 1 : (r4 == r2 ? 0 : -1))
            if (r2 >= 0) goto L8a
            r1.b()
        L8a:
            java.lang.Throwable r1 = r15.p()
            S3.k r2 = new S3.k
            r2.<init>(r1)
            return r2
        L94:
            java.lang.IllegalStateException r1 = new java.lang.IllegalStateException
            java.lang.String r2 = "unexpected"
            r1.<init>(r2)
            throw r1
        L9c:
            if (r7 == 0) goto Lab
            r1.i()
            java.lang.Throwable r1 = r15.p()
            S3.k r2 = new S3.k
            r2.<init>(r1)
            return r2
        Lab:
            boolean r3 = r6 instanceof Q3.K0
            if (r3 == 0) goto Lb2
            Q3.K0 r6 = (Q3.K0) r6
            goto Lb3
        Lb2:
            r6 = 0
        Lb3:
            if (r6 == 0) goto Lb9
            int r2 = r2 + r14
            r6.a(r1, r2)
        Lb9:
            r1.i()
            return r13
        Lbd:
            return r3
        Lbe:
            r1.b()
            return r3
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.e.k(java.lang.Object):java.lang.Object");
    }

    public final n l(long j4, n nVar) {
        Object objB;
        AtomicLongFieldUpdater atomicLongFieldUpdater;
        long j5;
        n nVar2 = g.f1830a;
        f fVar = f.f1829o;
        loop0: while (true) {
            objB = V3.b.b(nVar, j4, fVar);
            if (!V3.b.e(objB)) {
                V3.s sVarC = V3.b.c(objB);
                while (true) {
                    AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1824m;
                    V3.s sVar = (V3.s) atomicReferenceFieldUpdater.get(this);
                    if (sVar.f2248c >= sVarC.f2248c) {
                        break loop0;
                    }
                    if (!sVarC.j()) {
                        break;
                    }
                    while (!atomicReferenceFieldUpdater.compareAndSet(this, sVar, sVarC)) {
                        if (atomicReferenceFieldUpdater.get(this) != sVar) {
                            if (sVarC.f()) {
                                sVarC.e();
                            }
                        }
                    }
                    if (sVar.f()) {
                        sVar.e();
                    }
                }
            } else {
                break;
            }
        }
        if (V3.b.e(objB)) {
            t();
            if (nVar.f2248c * ((long) g.f1831b) < q()) {
                nVar.b();
                return null;
            }
        } else {
            n nVar3 = (n) V3.b.c(objB);
            boolean zV = v();
            long j6 = nVar3.f2248c;
            if (!zV && j4 <= f1822d.get(this) / ((long) g.f1831b)) {
                while (true) {
                    AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = f1825n;
                    V3.s sVar2 = (V3.s) atomicReferenceFieldUpdater2.get(this);
                    if (sVar2.f2248c >= j6 || !nVar3.j()) {
                        break;
                    }
                    while (!atomicReferenceFieldUpdater2.compareAndSet(this, sVar2, nVar3)) {
                        if (atomicReferenceFieldUpdater2.get(this) != sVar2) {
                            if (nVar3.f()) {
                                nVar3.e();
                            }
                        }
                    }
                    if (sVar2.f()) {
                        sVar2.e();
                    }
                }
            }
            if (j6 <= j4) {
                return nVar3;
            }
            long j7 = j6 * ((long) g.f1831b);
            do {
                atomicLongFieldUpdater = f1821c;
                j5 = atomicLongFieldUpdater.get(this);
                if (j5 >= j7) {
                    break;
                }
            } while (!atomicLongFieldUpdater.compareAndSet(this, j5, j7));
            if (j6 * ((long) g.f1831b) < q()) {
                nVar3.b();
            }
        }
        return null;
    }

    /* JADX WARN: Code restructure failed: missing block: B:103:0x0189, code lost:
    
        return r10;
     */
    /* JADX WARN: Code restructure failed: missing block: B:45:0x00c6, code lost:
    
        c(r1, r4, r7);
     */
    /* JADX WARN: Removed duplicated region for block: B:93:0x0170  */
    /* JADX WARN: Removed duplicated region for block: B:95:0x0173 A[RETURN] */
    @Override // S3.w
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object m(java.lang.Object r24, y3.InterfaceC0762c r25) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 399
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.e.m(java.lang.Object, y3.c):java.lang.Object");
    }

    public final Throwable n() {
        return (Throwable) f1826o.get(this);
    }

    public final Throwable o() {
        Throwable thN = n();
        return thN == null ? new o("Channel was closed") : thN;
    }

    public final Throwable p() {
        Throwable thN = n();
        return thN == null ? new p("Channel was closed") : thN;
    }

    public final long q() {
        return f1820b.get(this) & 1152921504606846975L;
    }

    /* JADX WARN: Code restructure failed: missing block: B:53:0x00a2, code lost:
    
        r0 = (S3.n) ((V3.c) V3.c.f2219b.get(r0));
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean s(long r15, boolean r17) throws java.lang.IllegalAccessException, Q3.L, java.lang.reflect.InvocationTargetException {
        /*
            Method dump skipped, instruction units count: 368
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.e.s(long, boolean):boolean");
    }

    public final boolean t() {
        return s(f1820b.get(this), false);
    }

    /* JADX WARN: Code restructure failed: missing block: B:72:0x0194, code lost:
    
        r16 = r7;
        r3 = (S3.n) r3.c();
     */
    /* JADX WARN: Code restructure failed: missing block: B:73:0x019d, code lost:
    
        if (r3 != null) goto L83;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.String toString() {
        /*
            Method dump skipped, instruction units count: 475
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.e.toString():java.lang.String");
    }

    public boolean u() {
        return false;
    }

    public final boolean v() {
        long j4 = f1822d.get(this);
        return j4 == 0 || j4 == Long.MAX_VALUE;
    }

    /* JADX WARN: Code restructure failed: missing block: B:39:0x0011, code lost:
    
        continue;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void w(long r5, S3.n r7) {
        /*
            r4 = this;
        L0:
            long r0 = r7.f2248c
            int r0 = (r0 > r5 ? 1 : (r0 == r5 ? 0 : -1))
            if (r0 >= 0) goto L11
            V3.c r0 = r7.c()
            S3.n r0 = (S3.n) r0
            if (r0 != 0) goto Lf
            goto L11
        Lf:
            r7 = r0
            goto L0
        L11:
            boolean r5 = r7.d()
            if (r5 == 0) goto L22
            V3.c r5 = r7.c()
            S3.n r5 = (S3.n) r5
            if (r5 != 0) goto L20
            goto L22
        L20:
            r7 = r5
            goto L11
        L22:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r5 = S3.e.f1825n
            java.lang.Object r6 = r5.get(r4)
            V3.s r6 = (V3.s) r6
            long r0 = r6.f2248c
            long r2 = r7.f2248c
            int r0 = (r0 > r2 ? 1 : (r0 == r2 ? 0 : -1))
            if (r0 < 0) goto L33
            goto L49
        L33:
            boolean r0 = r7.j()
            if (r0 != 0) goto L3a
            goto L11
        L3a:
            boolean r0 = r5.compareAndSet(r4, r6, r7)
            if (r0 == 0) goto L4a
            boolean r5 = r6.f()
            if (r5 == 0) goto L49
            r6.e()
        L49:
            return
        L4a:
            java.lang.Object r0 = r5.get(r4)
            if (r0 == r6) goto L3a
            boolean r5 = r7.f()
            if (r5 == 0) goto L22
            r7.e()
            goto L22
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.e.w(long, S3.n):void");
    }

    public final Object x(Object obj, InterfaceC0762c interfaceC0762c) throws IllegalAccessException, L, InvocationTargetException {
        C0141m c0141m = new C0141m(1, e1.k.w(interfaceC0762c));
        c0141m.r();
        c0141m.resumeWith(AbstractC0367g.h(p()));
        Object objQ = c0141m.q();
        return objQ == EnumC0789a.f6999a ? objQ : w3.i.f6729a;
    }

    public final Object y(A3.c cVar) {
        n nVarL;
        e eVar = this;
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1824m;
        n nVar = (n) atomicReferenceFieldUpdater.get(eVar);
        while (true) {
            AtomicLongFieldUpdater atomicLongFieldUpdater = f1820b;
            if (eVar.s(atomicLongFieldUpdater.get(eVar), true)) {
                Throwable thO = o();
                int i4 = V3.t.f2249a;
                throw thO;
            }
            AtomicLongFieldUpdater atomicLongFieldUpdater2 = f1821c;
            long andIncrement = atomicLongFieldUpdater2.getAndIncrement(eVar);
            long j4 = g.f1831b;
            long j5 = andIncrement / j4;
            int i5 = (int) (andIncrement % j4);
            if (nVar.f2248c != j5) {
                n nVarL2 = eVar.l(j5, nVar);
                if (nVarL2 == null) {
                    continue;
                } else {
                    nVar = nVarL2;
                }
            }
            Object objD = eVar.D(nVar, i5, andIncrement, null);
            C0779j c0779j = g.f1841m;
            if (objD == c0779j) {
                throw new IllegalStateException("unexpected");
            }
            C0779j c0779j2 = g.f1843o;
            if (objD != c0779j2) {
                if (objD != g.f1842n) {
                    nVar.b();
                    return objD;
                }
                C0141m c0141mN = F.n(e1.k.w(cVar));
                e eVar2 = this;
                try {
                    Object objD2 = eVar2.D(nVar, i5, andIncrement, c0141mN);
                    if (objD2 == c0779j) {
                        c0141mN.a(nVar, i5);
                    } else if (objD2 == c0779j2) {
                        if (andIncrement < eVar2.q()) {
                            nVar.b();
                        }
                        n nVar2 = (n) atomicReferenceFieldUpdater.get(eVar2);
                        while (true) {
                            if (eVar2.s(atomicLongFieldUpdater.get(eVar2), true)) {
                                c0141mN.resumeWith(AbstractC0367g.h(eVar2.o()));
                                break;
                            }
                            long andIncrement2 = atomicLongFieldUpdater2.getAndIncrement(eVar2);
                            long j6 = g.f1831b;
                            long j7 = andIncrement2 / j6;
                            int i6 = (int) (andIncrement2 % j6);
                            if (nVar2.f2248c != j7) {
                                nVarL = eVar2.l(j7, nVar2);
                                if (nVarL == null) {
                                }
                            } else {
                                nVarL = nVar2;
                            }
                            Object objD3 = eVar2.D(nVarL, i6, andIncrement2, c0141mN);
                            if (objD3 == g.f1841m) {
                                c0141mN.a(nVarL, i6);
                                break;
                            }
                            if (objD3 == g.f1843o) {
                                if (andIncrement2 < q()) {
                                    nVarL.b();
                                }
                                eVar2 = this;
                                nVar2 = nVarL;
                            } else {
                                if (objD3 == g.f1842n) {
                                    throw new IllegalStateException("unexpected");
                                }
                                nVarL.b();
                                c0141mN.z(objD3, null);
                            }
                        }
                    } else {
                        nVar.b();
                        c0141mN.z(objD2, null);
                    }
                    Object objQ = c0141mN.q();
                    EnumC0789a enumC0789a = EnumC0789a.f6999a;
                    return objQ;
                } catch (Throwable th) {
                    c0141mN.y();
                    throw th;
                }
            }
            if (andIncrement < q()) {
                nVar.b();
            }
            eVar = this;
        }
    }

    public final void z(K0 k02, boolean z4) throws IllegalAccessException, L, InvocationTargetException {
        if (k02 instanceof InterfaceC0137k) {
            ((InterfaceC0762c) k02).resumeWith(AbstractC0367g.h(z4 ? o() : p()));
            return;
        }
        if (!(k02 instanceof d)) {
            throw new IllegalStateException(("Unexpected waiter: " + k02).toString());
        }
        d dVar = (d) k02;
        C0141m c0141m = dVar.f1818b;
        J3.i.b(c0141m);
        dVar.f1818b = null;
        dVar.f1817a = g.f1840l;
        Throwable thN = dVar.f1819c.n();
        if (thN == null) {
            c0141m.resumeWith(Boolean.FALSE);
        } else {
            c0141m.resumeWith(AbstractC0367g.h(thN));
        }
    }
}
