package Q3;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import java.util.concurrent.locks.LockSupport;
import x3.C0725e;
import y3.InterfaceC0767h;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class Y extends Z implements K {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1606m = AtomicReferenceFieldUpdater.newUpdater(Y.class, Object.class, "_queue$volatile");

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1607n = AtomicReferenceFieldUpdater.newUpdater(Y.class, Object.class, "_delayed$volatile");

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f1608o = AtomicIntegerFieldUpdater.newUpdater(Y.class, "_isCompleted$volatile");
    private volatile /* synthetic */ Object _delayed$volatile;
    private volatile /* synthetic */ int _isCompleted$volatile;
    private volatile /* synthetic */ Object _queue$volatile;

    @Override // Q3.A
    public final void A(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        L(runnable);
    }

    /* JADX WARN: Code restructure failed: missing block: B:8:0x0018, code lost:
    
        r7 = null;
     */
    @Override // Q3.Z
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final long I() {
        /*
            r10 = this;
            boolean r0 = r10.J()
            r1 = 0
            if (r0 == 0) goto La
            goto Lb1
        La:
            r10.M()
        Ld:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r0 = Q3.Y.f1606m
            java.lang.Object r3 = r0.get(r10)
            z0.j r4 = Q3.F.f1578c
            r5 = 0
            if (r3 != 0) goto L1a
        L18:
            r7 = r5
            goto L4a
        L1a:
            boolean r6 = r3 instanceof V3.n
            if (r6 == 0) goto L3e
            r6 = r3
            V3.n r6 = (V3.n) r6
            java.lang.Object r7 = r6.d()
            z0.j r8 = V3.n.f2239g
            if (r7 == r8) goto L2c
            java.lang.Runnable r7 = (java.lang.Runnable) r7
            goto L4a
        L2c:
            V3.n r6 = r6.c()
        L30:
            boolean r4 = r0.compareAndSet(r10, r3, r6)
            if (r4 == 0) goto L37
            goto Ld
        L37:
            java.lang.Object r4 = r0.get(r10)
            if (r4 == r3) goto L30
            goto Ld
        L3e:
            if (r3 != r4) goto L41
            goto L18
        L41:
            boolean r6 = r0.compareAndSet(r10, r3, r5)
            if (r6 == 0) goto Lb7
            r7 = r3
            java.lang.Runnable r7 = (java.lang.Runnable) r7
        L4a:
            if (r7 == 0) goto L50
            r7.run()
            return r1
        L50:
            x3.e r3 = r10.e
            r6 = 9223372036854775807(0x7fffffffffffffff, double:NaN)
            if (r3 != 0) goto L5b
        L59:
            r8 = r6
            goto L63
        L5b:
            boolean r3 = r3.isEmpty()
            if (r3 == 0) goto L62
            goto L59
        L62:
            r8 = r1
        L63:
            int r3 = (r8 > r1 ? 1 : (r8 == r1 ? 0 : -1))
            if (r3 != 0) goto L68
            goto Lb1
        L68:
            java.lang.Object r0 = r0.get(r10)
            if (r0 == 0) goto L90
            boolean r3 = r0 instanceof V3.n
            if (r3 == 0) goto L8d
            V3.n r0 = (V3.n) r0
            java.util.concurrent.atomic.AtomicLongFieldUpdater r3 = V3.n.f2238f
            long r3 = r3.get(r0)
            r8 = 1073741823(0x3fffffff, double:5.304989472E-315)
            long r8 = r8 & r3
            int r0 = (int) r8
            r8 = 1152921503533105152(0xfffffffc0000000, double:1.2882296003504729E-231)
            long r3 = r3 & r8
            r8 = 30
            long r3 = r3 >> r8
            int r3 = (int) r3
            if (r0 != r3) goto L8c
            goto L90
        L8c:
            return r1
        L8d:
            if (r0 != r4) goto Lb1
            goto Lb6
        L90:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r0 = Q3.Y.f1607n
            java.lang.Object r0 = r0.get(r10)
            Q3.X r0 = (Q3.X) r0
            if (r0 == 0) goto Lb6
            monitor-enter(r0)
            Q3.W[] r3 = r0.f2252a     // Catch: java.lang.Throwable -> Lb3
            if (r3 == 0) goto La2
            r4 = 0
            r5 = r3[r4]     // Catch: java.lang.Throwable -> Lb3
        La2:
            monitor-exit(r0)
            if (r5 != 0) goto La6
            goto Lb6
        La6:
            long r3 = r5.f1603a
            long r5 = java.lang.System.nanoTime()
            long r3 = r3 - r5
            int r0 = (r3 > r1 ? 1 : (r3 == r1 ? 0 : -1))
            if (r0 >= 0) goto Lb2
        Lb1:
            return r1
        Lb2:
            return r3
        Lb3:
            r1 = move-exception
            monitor-exit(r0)
            throw r1
        Lb6:
            return r6
        Lb7:
            java.lang.Object r6 = r0.get(r10)
            if (r6 == r3) goto L41
            goto Ld
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.Y.I():long");
    }

    public void L(Runnable runnable) {
        M();
        if (!N(runnable)) {
            G.f1585p.L(runnable);
            return;
        }
        Thread threadG = G();
        if (Thread.currentThread() != threadG) {
            LockSupport.unpark(threadG);
        }
    }

    public final void M() {
        W wB;
        X x4 = (X) f1607n.get(this);
        if (x4 == null || V3.v.f2251b.get(x4) == 0) {
            return;
        }
        long jNanoTime = System.nanoTime();
        do {
            synchronized (x4) {
                try {
                    W[] wArr = x4.f2252a;
                    W w4 = wArr != null ? wArr[0] : null;
                    if (w4 != null) {
                        wB = ((jNanoTime - w4.f1603a) > 0L ? 1 : ((jNanoTime - w4.f1603a) == 0L ? 0 : -1)) >= 0 ? N(w4) : false ? x4.b(0) : null;
                    }
                } catch (Throwable th) {
                    throw th;
                }
            }
        } while (wB != null);
    }

    /* JADX WARN: Code restructure failed: missing block: B:32:0x0050, code lost:
    
        return false;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean N(java.lang.Runnable r7) {
        /*
            r6 = this;
        L0:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r0 = Q3.Y.f1606m
            java.lang.Object r1 = r0.get(r6)
            java.util.concurrent.atomic.AtomicIntegerFieldUpdater r2 = Q3.Y.f1608o
            int r2 = r2.get(r6)
            r3 = 0
            r4 = 1
            if (r2 != r4) goto L12
            r2 = r4
            goto L13
        L12:
            r2 = r3
        L13:
            if (r2 == 0) goto L16
            goto L50
        L16:
            if (r1 != 0) goto L27
        L18:
            r1 = 0
            boolean r1 = r0.compareAndSet(r6, r1, r7)
            if (r1 == 0) goto L20
            goto L67
        L20:
            java.lang.Object r1 = r0.get(r6)
            if (r1 == 0) goto L18
            goto L0
        L27:
            boolean r2 = r1 instanceof V3.n
            if (r2 == 0) goto L4c
            r2 = r1
            V3.n r2 = (V3.n) r2
            int r5 = r2.a(r7)
            if (r5 == 0) goto L67
            if (r5 == r4) goto L3a
            r0 = 2
            if (r5 == r0) goto L50
            goto L0
        L3a:
            V3.n r2 = r2.c()
        L3e:
            boolean r3 = r0.compareAndSet(r6, r1, r2)
            if (r3 == 0) goto L45
            goto L0
        L45:
            java.lang.Object r3 = r0.get(r6)
            if (r3 == r1) goto L3e
            goto L0
        L4c:
            z0.j r2 = Q3.F.f1578c
            if (r1 != r2) goto L51
        L50:
            return r3
        L51:
            V3.n r2 = new V3.n
            r3 = 8
            r2.<init>(r3, r4)
            r3 = r1
            java.lang.Runnable r3 = (java.lang.Runnable) r3
            r2.a(r3)
            r2.a(r7)
        L61:
            boolean r3 = r0.compareAndSet(r6, r1, r2)
            if (r3 == 0) goto L68
        L67:
            return r4
        L68:
            java.lang.Object r3 = r0.get(r6)
            if (r3 == r1) goto L61
            goto L0
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.Y.N(java.lang.Runnable):boolean");
    }

    public final boolean O() {
        X x4;
        C0725e c0725e = this.e;
        if (!(c0725e != null ? c0725e.isEmpty() : true) || ((x4 = (X) f1607n.get(this)) != null && V3.v.f2251b.get(x4) != 0)) {
            return false;
        }
        Object obj = f1606m.get(this);
        if (obj != null) {
            if (obj instanceof V3.n) {
                long j4 = V3.n.f2238f.get((V3.n) obj);
                return ((int) (1073741823 & j4)) == ((int) ((j4 & 1152921503533105152L) >> 30));
            }
            if (obj != F.f1578c) {
                return false;
            }
        }
        return true;
    }

    public final void P(long j4, W w4) {
        int iB;
        Thread threadG;
        boolean z4 = f1608o.get(this) == 1;
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1607n;
        if (z4) {
            iB = 1;
        } else {
            X x4 = (X) atomicReferenceFieldUpdater.get(this);
            if (x4 == null) {
                X x5 = new X();
                x5.f1605c = j4;
                while (!atomicReferenceFieldUpdater.compareAndSet(this, null, x5) && atomicReferenceFieldUpdater.get(this) == null) {
                }
                Object obj = atomicReferenceFieldUpdater.get(this);
                J3.i.b(obj);
                x4 = (X) obj;
            }
            iB = w4.b(j4, x4, this);
        }
        if (iB != 0) {
            if (iB == 1) {
                K(j4, w4);
                return;
            } else {
                if (iB != 2) {
                    throw new IllegalStateException("unexpected result");
                }
                return;
            }
        }
        X x6 = (X) atomicReferenceFieldUpdater.get(this);
        if (x6 != null) {
            synchronized (x6) {
                W[] wArr = x6.f2252a;
                w = wArr != null ? wArr[0] : null;
            }
        }
        if (w != w4 || Thread.currentThread() == (threadG = G())) {
            return;
        }
        LockSupport.unpark(threadG);
    }

    public Q n(long j4, F0 f02, InterfaceC0767h interfaceC0767h) {
        return H.f1590a.n(j4, f02, interfaceC0767h);
    }

    @Override // Q3.K
    public final void o(long j4, C0141m c0141m) {
        long j5 = j4 > 0 ? j4 >= 9223372036854L ? Long.MAX_VALUE : 1000000 * j4 : 0L;
        if (j5 < 4611686018427387903L) {
            long jNanoTime = System.nanoTime();
            U u4 = new U(this, j5 + jNanoTime, c0141m);
            P(jNanoTime, u4);
            c0141m.u(new C0133i(u4, 2));
        }
    }

    @Override // Q3.Z
    public void shutdown() {
        W wB;
        B0.f1566a.set(null);
        f1608o.set(this, 1);
        loop0: while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1606m;
            Object obj = atomicReferenceFieldUpdater.get(this);
            C0779j c0779j = F.f1578c;
            if (obj != null) {
                if (!(obj instanceof V3.n)) {
                    if (obj != c0779j) {
                        V3.n nVar = new V3.n(8, true);
                        nVar.a((Runnable) obj);
                        while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, nVar)) {
                            if (atomicReferenceFieldUpdater.get(this) != obj) {
                                break;
                            }
                        }
                        break loop0;
                    }
                    break;
                }
                ((V3.n) obj).b();
                break;
            }
            while (!atomicReferenceFieldUpdater.compareAndSet(this, null, c0779j)) {
                if (atomicReferenceFieldUpdater.get(this) != null) {
                    break;
                }
            }
            break loop0;
        }
        while (I() <= 0) {
        }
        long jNanoTime = System.nanoTime();
        while (true) {
            X x4 = (X) f1607n.get(this);
            if (x4 == null) {
                return;
            }
            synchronized (x4) {
                wB = V3.v.f2251b.get(x4) > 0 ? x4.b(0) : null;
            }
            if (wB == null) {
                return;
            } else {
                K(jNanoTime, wB);
            }
        }
    }
}
