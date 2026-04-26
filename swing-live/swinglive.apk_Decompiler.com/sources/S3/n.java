package S3;

import java.util.concurrent.atomic.AtomicReferenceArray;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class n extends V3.s {
    public final e e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ AtomicReferenceArray f1854f;

    public n(long j4, n nVar, e eVar, int i4) {
        super(j4, nVar, i4);
        this.e = eVar;
        this.f1854f = new AtomicReferenceArray(g.f1831b * 2);
    }

    @Override // V3.s
    public final int g() {
        return g.f1831b;
    }

    /* JADX WARN: Code restructure failed: missing block: B:34:0x0059, code lost:
    
        n(r5, null);
     */
    /* JADX WARN: Code restructure failed: missing block: B:35:0x005c, code lost:
    
        if (r0 == false) goto L60;
     */
    /* JADX WARN: Code restructure failed: missing block: B:36:0x005e, code lost:
    
        J3.i.b(r2);
     */
    /* JADX WARN: Code restructure failed: missing block: B:37:0x0061, code lost:
    
        return;
     */
    /* JADX WARN: Code restructure failed: missing block: B:60:?, code lost:
    
        return;
     */
    @Override // V3.s
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void h(int r5, y3.InterfaceC0767h r6) {
        /*
            r4 = this;
            int r6 = S3.g.f1831b
            if (r5 < r6) goto L6
            r0 = 1
            goto L7
        L6:
            r0 = 0
        L7:
            if (r0 == 0) goto La
            int r5 = r5 - r6
        La:
            java.util.concurrent.atomic.AtomicReferenceArray r6 = r4.f1854f
            int r1 = r5 * 2
            r6.get(r1)
        L11:
            java.lang.Object r6 = r4.l(r5)
            boolean r1 = r6 instanceof Q3.K0
            S3.e r2 = r4.e
            r3 = 0
            if (r1 != 0) goto L62
            boolean r1 = r6 instanceof S3.x
            if (r1 == 0) goto L21
            goto L62
        L21:
            z0.j r1 = S3.g.f1838j
            if (r6 == r1) goto L59
            z0.j r1 = S3.g.f1839k
            if (r6 != r1) goto L2a
            goto L59
        L2a:
            z0.j r1 = S3.g.f1835g
            if (r6 == r1) goto L11
            z0.j r1 = S3.g.f1834f
            if (r6 != r1) goto L33
            goto L11
        L33:
            z0.j r5 = S3.g.f1837i
            if (r6 == r5) goto L7c
            z0.j r5 = S3.g.f1833d
            if (r6 != r5) goto L3c
            goto L7c
        L3c:
            z0.j r5 = S3.g.f1840l
            if (r6 != r5) goto L41
            goto L7c
        L41:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.StringBuilder r0 = new java.lang.StringBuilder
            java.lang.String r1 = "unexpected state: "
            r0.<init>(r1)
            r0.append(r6)
            java.lang.String r6 = r0.toString()
            java.lang.String r6 = r6.toString()
            r5.<init>(r6)
            throw r5
        L59:
            r4.n(r5, r3)
            if (r0 == 0) goto L7c
            J3.i.b(r2)
            return
        L62:
            if (r0 == 0) goto L67
            z0.j r1 = S3.g.f1838j
            goto L69
        L67:
            z0.j r1 = S3.g.f1839k
        L69:
            boolean r6 = r4.k(r5, r6, r1)
            if (r6 == 0) goto L11
            r4.n(r5, r3)
            r6 = r0 ^ 1
            r4.m(r5, r6)
            if (r0 == 0) goto L7c
            J3.i.b(r2)
        L7c:
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.n.h(int, y3.h):void");
    }

    public final boolean k(int i4, Object obj, Object obj2) {
        AtomicReferenceArray atomicReferenceArray = this.f1854f;
        int i5 = (i4 * 2) + 1;
        while (!atomicReferenceArray.compareAndSet(i5, obj, obj2)) {
            if (atomicReferenceArray.get(i5) != obj) {
                return false;
            }
        }
        return true;
    }

    public final Object l(int i4) {
        return this.f1854f.get((i4 * 2) + 1);
    }

    public final void m(int i4, boolean z4) {
        if (z4) {
            e eVar = this.e;
            J3.i.b(eVar);
            eVar.F((this.f2248c * ((long) g.f1831b)) + ((long) i4));
        }
        i();
    }

    public final void n(int i4, Object obj) {
        this.f1854f.set(i4 * 2, obj);
    }

    public final void o(int i4, C0779j c0779j) {
        this.f1854f.set((i4 * 2) + 1, c0779j);
    }
}
