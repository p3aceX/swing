package X3;

import Q3.F;
import V3.q;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.Closeable;
import java.util.ArrayList;
import java.util.concurrent.Executor;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicLongFieldUpdater;
import java.util.concurrent.locks.LockSupport;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class c implements Executor, Closeable {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicLongFieldUpdater f2427n = AtomicLongFieldUpdater.newUpdater(c.class, "parkedWorkersStack$volatile");

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ AtomicLongFieldUpdater f2428o = AtomicLongFieldUpdater.newUpdater(c.class, "controlState$volatile");

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2429p = AtomicIntegerFieldUpdater.newUpdater(c.class, "_isTerminated$volatile");

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final C0779j f2430q = new C0779j("NOT_IN_STACK", 20);
    private volatile /* synthetic */ int _isTerminated$volatile;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f2431a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f2432b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f2433c;
    private volatile /* synthetic */ long controlState$volatile;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f2434d;
    public final f e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final f f2435f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final q f2436m;
    private volatile /* synthetic */ long parkedWorkersStack$volatile;

    public c(int i4, int i5, long j4, String str) {
        this.f2431a = i4;
        this.f2432b = i5;
        this.f2433c = j4;
        this.f2434d = str;
        if (i4 < 1) {
            throw new IllegalArgumentException(B1.a.l("Core pool size ", i4, " should be at least 1").toString());
        }
        if (i5 < i4) {
            throw new IllegalArgumentException(B1.a.k("Max pool size ", i5, i4, " should be greater than or equals to core pool size ").toString());
        }
        if (i5 > 2097150) {
            throw new IllegalArgumentException(B1.a.l("Max pool size ", i5, " should not exceed maximal supported number of threads 2097150").toString());
        }
        if (j4 <= 0) {
            throw new IllegalArgumentException(("Idle worker keep alive time " + j4 + " must be positive").toString());
        }
        this.e = new f();
        this.f2435f = new f();
        this.f2436m = new q((i4 + 1) * 2);
        this.controlState$volatile = ((long) i4) << 42;
    }

    public static /* synthetic */ void c(c cVar, Runnable runnable, int i4) {
        cVar.b(runnable, false, (i4 & 4) == 0);
    }

    public final int a() {
        synchronized (this.f2436m) {
            try {
                if (f2429p.get(this) == 1) {
                    return -1;
                }
                AtomicLongFieldUpdater atomicLongFieldUpdater = f2428o;
                long j4 = atomicLongFieldUpdater.get(this);
                int i4 = (int) (j4 & 2097151);
                int i5 = i4 - ((int) ((j4 & 4398044413952L) >> 21));
                if (i5 < 0) {
                    i5 = 0;
                }
                if (i5 >= this.f2431a) {
                    return 0;
                }
                if (i4 >= this.f2432b) {
                    return 0;
                }
                int i6 = ((int) (atomicLongFieldUpdater.get(this) & 2097151)) + 1;
                if (i6 <= 0 || this.f2436m.b(i6) != null) {
                    throw new IllegalArgumentException("Failed requirement.");
                }
                a aVar = new a(this, i6);
                this.f2436m.c(i6, aVar);
                if (i6 != ((int) (2097151 & atomicLongFieldUpdater.incrementAndGet(this)))) {
                    throw new IllegalArgumentException("Failed requirement.");
                }
                int i7 = i5 + 1;
                aVar.start();
                return i7;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void b(Runnable runnable, boolean z4, boolean z5) {
        i jVar;
        b bVar;
        k.f2449f.getClass();
        long jNanoTime = System.nanoTime();
        if (runnable instanceof i) {
            jVar = (i) runnable;
            jVar.f2442a = jNanoTime;
            jVar.f2443b = z4;
        } else {
            jVar = new j(runnable, jNanoTime, z4);
        }
        boolean z6 = jVar.f2443b;
        AtomicLongFieldUpdater atomicLongFieldUpdater = f2428o;
        long jAddAndGet = z6 ? atomicLongFieldUpdater.addAndGet(this, 2097152L) : 0L;
        Thread threadCurrentThread = Thread.currentThread();
        a aVar = threadCurrentThread instanceof a ? (a) threadCurrentThread : null;
        if (aVar == null || !J3.i.a(aVar.f2421n, this)) {
            aVar = null;
        }
        if (aVar != null && (bVar = aVar.f2417c) != b.e && (jVar.f2443b || bVar != b.f2423b)) {
            aVar.f2420m = true;
            m mVar = aVar.f2415a;
            if (z5) {
                jVar = mVar.a(jVar);
            } else {
                mVar.getClass();
                i iVar = (i) m.f2451b.getAndSet(mVar, jVar);
                jVar = iVar == null ? null : mVar.a(iVar);
            }
        }
        if (jVar != null) {
            if (!(jVar.f2443b ? this.f2435f.a(jVar) : this.e.a(jVar))) {
                throw new RejectedExecutionException(S.h(new StringBuilder(), this.f2434d, " was terminated"));
            }
        }
        if (z6) {
            if (g() || f(jAddAndGet)) {
                return;
            }
            g();
            return;
        }
        if (g() || f(atomicLongFieldUpdater.get(this))) {
            return;
        }
        g();
    }

    /* JADX WARN: Removed duplicated region for block: B:39:0x008a  */
    @Override // java.io.Closeable, java.lang.AutoCloseable
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void close() throws java.lang.InterruptedException {
        /*
            r8 = this;
            java.util.concurrent.atomic.AtomicIntegerFieldUpdater r0 = X3.c.f2429p
            r1 = 0
            r2 = 1
            boolean r0 = r0.compareAndSet(r8, r1, r2)
            if (r0 != 0) goto Lb
            return
        Lb:
            java.lang.Thread r0 = java.lang.Thread.currentThread()
            boolean r1 = r0 instanceof X3.a
            r3 = 0
            if (r1 == 0) goto L17
            X3.a r0 = (X3.a) r0
            goto L18
        L17:
            r0 = r3
        L18:
            if (r0 == 0) goto L23
            X3.c r1 = r0.f2421n
            boolean r1 = J3.i.a(r1, r8)
            if (r1 == 0) goto L23
            goto L24
        L23:
            r0 = r3
        L24:
            V3.q r1 = r8.f2436m
            monitor-enter(r1)
            java.util.concurrent.atomic.AtomicLongFieldUpdater r4 = X3.c.f2428o     // Catch: java.lang.Throwable -> Lc3
            long r4 = r4.get(r8)     // Catch: java.lang.Throwable -> Lc3
            r6 = 2097151(0x1fffff, double:1.0361303E-317)
            long r4 = r4 & r6
            int r4 = (int) r4
            monitor-exit(r1)
            if (r2 > r4) goto L78
            r1 = r2
        L36:
            V3.q r5 = r8.f2436m
            java.lang.Object r5 = r5.b(r1)
            J3.i.b(r5)
            X3.a r5 = (X3.a) r5
            if (r5 == r0) goto L73
        L43:
            java.lang.Thread$State r6 = r5.getState()
            java.lang.Thread$State r7 = java.lang.Thread.State.TERMINATED
            if (r6 == r7) goto L54
            java.util.concurrent.locks.LockSupport.unpark(r5)
            r6 = 10000(0x2710, double:4.9407E-320)
            r5.join(r6)
            goto L43
        L54:
            X3.m r5 = r5.f2415a
            X3.f r6 = r8.f2435f
            r5.getClass()
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r7 = X3.m.f2451b
            java.lang.Object r7 = r7.getAndSet(r5, r3)
            X3.i r7 = (X3.i) r7
            if (r7 == 0) goto L68
            r6.a(r7)
        L68:
            X3.i r7 = r5.b()
            if (r7 != 0) goto L6f
            goto L73
        L6f:
            r6.a(r7)
            goto L68
        L73:
            if (r1 == r4) goto L78
            int r1 = r1 + 1
            goto L36
        L78:
            X3.f r1 = r8.f2435f
            r1.b()
            X3.f r1 = r8.e
            r1.b()
        L82:
            if (r0 == 0) goto L8a
            X3.i r1 = r0.a(r2)
            if (r1 != 0) goto Lb2
        L8a:
            X3.f r1 = r8.e
            java.lang.Object r1 = r1.d()
            X3.i r1 = (X3.i) r1
            if (r1 != 0) goto Lb2
            X3.f r1 = r8.f2435f
            java.lang.Object r1 = r1.d()
            X3.i r1 = (X3.i) r1
            if (r1 != 0) goto Lb2
            if (r0 == 0) goto La5
            X3.b r1 = X3.b.e
            r0.h(r1)
        La5:
            java.util.concurrent.atomic.AtomicLongFieldUpdater r0 = X3.c.f2427n
            r1 = 0
            r0.set(r8, r1)
            java.util.concurrent.atomic.AtomicLongFieldUpdater r0 = X3.c.f2428o
            r0.set(r8, r1)
            return
        Lb2:
            r1.run()     // Catch: java.lang.Throwable -> Lb6
            goto L82
        Lb6:
            r1 = move-exception
            java.lang.Thread r3 = java.lang.Thread.currentThread()
            java.lang.Thread$UncaughtExceptionHandler r4 = r3.getUncaughtExceptionHandler()
            r4.uncaughtException(r3, r1)
            goto L82
        Lc3:
            r0 = move-exception
            monitor-exit(r1)
            throw r0
        */
        throw new UnsupportedOperationException("Method not decompiled: X3.c.close():void");
    }

    public final void d(a aVar, int i4, int i5) {
        while (true) {
            long j4 = f2427n.get(this);
            int i6 = (int) (2097151 & j4);
            long j5 = (2097152 + j4) & (-2097152);
            if (i6 == i4) {
                if (i5 == 0) {
                    Object objC = aVar.c();
                    while (true) {
                        if (objC == f2430q) {
                            i6 = -1;
                            break;
                        }
                        if (objC == null) {
                            i6 = 0;
                            break;
                        }
                        a aVar2 = (a) objC;
                        int iB = aVar2.b();
                        if (iB != 0) {
                            i6 = iB;
                            break;
                        }
                        objC = aVar2.c();
                    }
                } else {
                    i6 = i5;
                }
            }
            if (i6 >= 0) {
                if (f2427n.compareAndSet(this, j4, ((long) i6) | j5)) {
                    return;
                }
            }
        }
    }

    @Override // java.util.concurrent.Executor
    public final void execute(Runnable runnable) {
        c(this, runnable, 6);
    }

    public final boolean f(long j4) {
        int i4 = ((int) (2097151 & j4)) - ((int) ((j4 & 4398044413952L) >> 21));
        if (i4 < 0) {
            i4 = 0;
        }
        int i5 = this.f2431a;
        if (i4 < i5) {
            int iA = a();
            if (iA == 1 && i5 > 1) {
                a();
            }
            if (iA > 0) {
                return true;
            }
        }
        return false;
    }

    public final boolean g() {
        C0779j c0779j;
        int iB;
        while (true) {
            AtomicLongFieldUpdater atomicLongFieldUpdater = f2427n;
            long j4 = atomicLongFieldUpdater.get(this);
            a aVar = (a) this.f2436m.b((int) (2097151 & j4));
            if (aVar == null) {
                aVar = null;
            } else {
                long j5 = (2097152 + j4) & (-2097152);
                Object objC = aVar.c();
                while (true) {
                    c0779j = f2430q;
                    if (objC == c0779j) {
                        iB = -1;
                        break;
                    }
                    if (objC == null) {
                        iB = 0;
                        break;
                    }
                    a aVar2 = (a) objC;
                    iB = aVar2.b();
                    if (iB != 0) {
                        break;
                    }
                    objC = aVar2.c();
                }
                if (iB >= 0 && atomicLongFieldUpdater.compareAndSet(this, j4, j5 | ((long) iB))) {
                    aVar.g(c0779j);
                }
            }
            if (aVar == null) {
                return false;
            }
            if (a.f2414o.compareAndSet(aVar, -1, 0)) {
                LockSupport.unpark(aVar);
                return true;
            }
        }
    }

    public final String toString() {
        ArrayList arrayList = new ArrayList();
        q qVar = this.f2436m;
        int iA = qVar.a();
        int i4 = 0;
        int i5 = 0;
        int i6 = 0;
        int i7 = 0;
        int i8 = 0;
        for (int i9 = 1; i9 < iA; i9++) {
            a aVar = (a) qVar.b(i9);
            if (aVar != null) {
                m mVar = aVar.f2415a;
                mVar.getClass();
                int i10 = m.f2451b.get(mVar) != null ? (m.f2452c.get(mVar) - m.f2453d.get(mVar)) + 1 : m.f2452c.get(mVar) - m.f2453d.get(mVar);
                int iOrdinal = aVar.f2417c.ordinal();
                if (iOrdinal == 0) {
                    i4++;
                    StringBuilder sb = new StringBuilder();
                    sb.append(i10);
                    sb.append('c');
                    arrayList.add(sb.toString());
                } else if (iOrdinal == 1) {
                    i5++;
                    StringBuilder sb2 = new StringBuilder();
                    sb2.append(i10);
                    sb2.append('b');
                    arrayList.add(sb2.toString());
                } else if (iOrdinal == 2) {
                    i6++;
                } else if (iOrdinal == 3) {
                    i7++;
                    if (i10 > 0) {
                        StringBuilder sb3 = new StringBuilder();
                        sb3.append(i10);
                        sb3.append('d');
                        arrayList.add(sb3.toString());
                    }
                } else {
                    if (iOrdinal != 4) {
                        throw new A0.b();
                    }
                    i8++;
                }
            }
        }
        long j4 = f2428o.get(this);
        StringBuilder sb4 = new StringBuilder();
        sb4.append(this.f2434d);
        sb4.append('@');
        sb4.append(F.l(this));
        sb4.append("[Pool Size {core = ");
        int i11 = this.f2431a;
        sb4.append(i11);
        sb4.append(", max = ");
        sb4.append(this.f2432b);
        sb4.append("}, Worker States {CPU = ");
        sb4.append(i4);
        sb4.append(", blocking = ");
        sb4.append(i5);
        sb4.append(", parked = ");
        sb4.append(i6);
        sb4.append(", dormant = ");
        sb4.append(i7);
        sb4.append(", terminated = ");
        sb4.append(i8);
        sb4.append("}, running workers queues = ");
        sb4.append(arrayList);
        sb4.append(", global CPU queue size = ");
        sb4.append(this.e.c());
        sb4.append(", global blocking queue size = ");
        sb4.append(this.f2435f.c());
        sb4.append(", Control State {created workers= ");
        sb4.append((int) (2097151 & j4));
        sb4.append(", blocking tasks = ");
        sb4.append((int) ((4398044413952L & j4) >> 21));
        sb4.append(", CPUs acquired = ");
        sb4.append(i11 - ((int) ((j4 & 9223367638808264704L) >> 42)));
        sb4.append("}]");
        return sb4.toString();
    }
}
