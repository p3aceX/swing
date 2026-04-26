package V3;

import java.util.concurrent.atomic.AtomicLongFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceArray;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class n {
    public static final /* synthetic */ AtomicReferenceFieldUpdater e = AtomicReferenceFieldUpdater.newUpdater(n.class, Object.class, "_next$volatile");

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ AtomicLongFieldUpdater f2238f = AtomicLongFieldUpdater.newUpdater(n.class, "_state$volatile");

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final C0779j f2239g = new C0779j("REMOVE_FROZEN", 20);
    private volatile /* synthetic */ Object _next$volatile;
    private volatile /* synthetic */ long _state$volatile;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f2240a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f2241b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f2242c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ AtomicReferenceArray f2243d;

    public n(int i4, boolean z4) {
        this.f2240a = i4;
        this.f2241b = z4;
        int i5 = i4 - 1;
        this.f2242c = i5;
        this.f2243d = new AtomicReferenceArray(i4);
        if (i5 > 1073741823) {
            throw new IllegalStateException("Check failed.");
        }
        if ((i4 & i5) != 0) {
            throw new IllegalStateException("Check failed.");
        }
    }

    public final int a(Runnable runnable) {
        while (true) {
            AtomicLongFieldUpdater atomicLongFieldUpdater = f2238f;
            long j4 = atomicLongFieldUpdater.get(this);
            if ((3458764513820540928L & j4) != 0) {
                return (2305843009213693952L & j4) != 0 ? 2 : 1;
            }
            int i4 = (int) (1073741823 & j4);
            int i5 = (int) ((1152921503533105152L & j4) >> 30);
            int i6 = this.f2242c;
            if (((i5 + 2) & i6) == (i4 & i6)) {
                return 1;
            }
            AtomicReferenceArray atomicReferenceArray = this.f2243d;
            if (!this.f2241b && atomicReferenceArray.get(i5 & i6) != null) {
                int i7 = this.f2240a;
                if (i7 < 1024 || ((i5 - i4) & 1073741823) > (i7 >> 1)) {
                    return 1;
                }
            } else if (atomicLongFieldUpdater.compareAndSet(this, j4, ((-1152921503533105153L) & j4) | (((long) ((i5 + 1) & 1073741823)) << 30))) {
                atomicReferenceArray.set(i5 & i6, runnable);
                n nVarC = this;
                while ((atomicLongFieldUpdater.get(nVarC) & 1152921504606846976L) != 0) {
                    nVarC = nVarC.c();
                    AtomicReferenceArray atomicReferenceArray2 = nVarC.f2243d;
                    int i8 = nVarC.f2242c & i5;
                    Object obj = atomicReferenceArray2.get(i8);
                    if ((obj instanceof m) && ((m) obj).f2237a == i5) {
                        atomicReferenceArray2.set(i8, runnable);
                    } else {
                        nVarC = null;
                    }
                    if (nVarC == null) {
                        return 0;
                    }
                }
                return 0;
            }
        }
    }

    public final boolean b() {
        AtomicLongFieldUpdater atomicLongFieldUpdater;
        long j4;
        do {
            atomicLongFieldUpdater = f2238f;
            j4 = atomicLongFieldUpdater.get(this);
            if ((j4 & 2305843009213693952L) != 0) {
                return true;
            }
            if ((1152921504606846976L & j4) != 0) {
                return false;
            }
        } while (!atomicLongFieldUpdater.compareAndSet(this, j4, 2305843009213693952L | j4));
        return true;
    }

    public final n c() {
        AtomicLongFieldUpdater atomicLongFieldUpdater;
        long j4;
        n nVar;
        while (true) {
            atomicLongFieldUpdater = f2238f;
            j4 = atomicLongFieldUpdater.get(this);
            if ((j4 & 1152921504606846976L) != 0) {
                nVar = this;
                break;
            }
            long j5 = 1152921504606846976L | j4;
            nVar = this;
            if (atomicLongFieldUpdater.compareAndSet(nVar, j4, j5)) {
                j4 = j5;
                break;
            }
        }
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = e;
            n nVar2 = (n) atomicReferenceFieldUpdater.get(this);
            if (nVar2 != null) {
                return nVar2;
            }
            n nVar3 = new n(nVar.f2240a * 2, nVar.f2241b);
            int i4 = (int) (1073741823 & j4);
            int i5 = (int) ((1152921503533105152L & j4) >> 30);
            while (true) {
                int i6 = nVar.f2242c;
                int i7 = i4 & i6;
                if (i7 == (i6 & i5)) {
                    break;
                }
                Object mVar = nVar.f2243d.get(i7);
                if (mVar == null) {
                    mVar = new m(i4);
                }
                nVar3.f2243d.set(nVar3.f2242c & i4, mVar);
                i4++;
            }
            atomicLongFieldUpdater.set(nVar3, (-1152921504606846977L) & j4);
            while (!atomicReferenceFieldUpdater.compareAndSet(this, null, nVar3) && atomicReferenceFieldUpdater.get(this) == null) {
            }
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:16:0x0040, code lost:
    
        return null;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object d() {
        /*
            r30 = this;
            r1 = r30
        L2:
            java.util.concurrent.atomic.AtomicLongFieldUpdater r0 = V3.n.f2238f
            long r2 = r0.get(r1)
            r6 = 1152921504606846976(0x1000000000000000, double:1.2882297539194267E-231)
            long r4 = r2 & r6
            r8 = 0
            int r4 = (r4 > r8 ? 1 : (r4 == r8 ? 0 : -1))
            if (r4 == 0) goto L15
            z0.j r0 = V3.n.f2239g
            return r0
        L15:
            r10 = 1073741823(0x3fffffff, double:5.304989472E-315)
            long r4 = r2 & r10
            int r4 = (int) r4
            r12 = 1152921503533105152(0xfffffffc0000000, double:1.2882296003504729E-231)
            long r12 = r12 & r2
            r5 = 30
            long r12 = r12 >> r5
            int r5 = (int) r12
            int r12 = r1.f2242c
            r5 = r5 & r12
            r12 = r12 & r4
            r13 = 0
            if (r5 != r12) goto L2d
            goto L40
        L2d:
            java.util.concurrent.atomic.AtomicReferenceArray r14 = r1.f2243d
            java.lang.Object r15 = r14.get(r12)
            boolean r5 = r1.f2241b
            if (r15 != 0) goto L3a
            if (r5 == 0) goto L2
            goto L40
        L3a:
            r16 = r6
            boolean r6 = r15 instanceof V3.m
            if (r6 == 0) goto L41
        L40:
            return r13
        L41:
            int r4 = r4 + 1
            r6 = 1073741823(0x3fffffff, float:1.9999999)
            r4 = r4 & r6
            r6 = -1073741824(0xffffffffc0000000, double:NaN)
            long r18 = r2 & r6
            r20 = r6
            long r6 = (long) r4
            long r18 = r18 | r6
            r28 = r18
            r18 = r5
            r4 = r28
            boolean r0 = r0.compareAndSet(r1, r2, r4)
            if (r0 == 0) goto L61
            r14.set(r12, r13)
            return r15
        L61:
            r1 = r30
            if (r18 == 0) goto L2
        L65:
            java.util.concurrent.atomic.AtomicLongFieldUpdater r0 = V3.n.f2238f
            long r24 = r0.get(r1)
            long r2 = r24 & r10
            int r2 = (int) r2
            long r3 = r24 & r16
            int r3 = (r3 > r8 ? 1 : (r3 == r8 ? 0 : -1))
            if (r3 == 0) goto L7a
            V3.n r0 = r1.c()
            r1 = r0
            goto L93
        L7a:
            long r3 = r24 & r20
            long r26 = r3 | r6
            r22 = r0
            r23 = r1
            boolean r0 = r22.compareAndSet(r23, r24, r26)
            r1 = r23
            if (r0 == 0) goto L65
            java.util.concurrent.atomic.AtomicReferenceArray r0 = r1.f2243d
            int r1 = r1.f2242c
            r1 = r1 & r2
            r0.set(r1, r13)
            r1 = r13
        L93:
            if (r1 != 0) goto L65
            return r15
        */
        throw new UnsupportedOperationException("Method not decompiled: V3.n.d():java.lang.Object");
    }
}
