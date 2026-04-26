package S3;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class q extends e {

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final c f1855q;

    public q(int i4, c cVar) {
        super(i4);
        this.f1855q = cVar;
        if (cVar != c.f1813a) {
            if (i4 < 1) {
                throw new IllegalArgumentException(B1.a.l("Buffered channel capacity must be at least 1, but ", i4, " was specified").toString());
            }
        } else {
            throw new IllegalArgumentException(("This implementation does not support suspension for senders, use " + J3.s.a(e.class).b() + " instead").toString());
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:52:0x00bb, code lost:
    
        return r8;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object G(boolean r17, java.lang.Object r18) throws java.lang.IllegalAccessException, Q3.L, java.lang.reflect.InvocationTargetException {
        /*
            r16 = this;
            r0 = r16
            S3.c r1 = S3.c.f1815c
            w3.i r8 = w3.i.f6729a
            S3.c r2 = r0.f1855q
            if (r2 != r1) goto L1b
            r3 = r18
            java.lang.Object r1 = super.k(r3)
            boolean r2 = r1 instanceof S3.l
            if (r2 == 0) goto L1a
            boolean r2 = r1 instanceof S3.k
            if (r2 == 0) goto L19
            goto L1a
        L19:
            return r8
        L1a:
            return r1
        L1b:
            r3 = r18
            z0.j r6 = S3.g.f1833d
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r1 = S3.e.f1823f
            java.lang.Object r1 = r1.get(r0)
            S3.n r1 = (S3.n) r1
        L27:
            java.util.concurrent.atomic.AtomicLongFieldUpdater r2 = S3.e.f1820b
            long r4 = r2.getAndIncrement(r0)
            r9 = 1152921504606846975(0xfffffffffffffff, double:1.2882297539194265E-231)
            long r9 = r9 & r4
            r2 = 0
            boolean r7 = r0.s(r4, r2)
            int r11 = S3.g.f1831b
            long r12 = (long) r11
            long r4 = r9 / r12
            long r14 = r9 % r12
            int r2 = (int) r14
            long r14 = r1.f2248c
            int r14 = (r14 > r4 ? 1 : (r14 == r4 ? 0 : -1))
            if (r14 == 0) goto L59
            S3.n r4 = S3.e.b(r0, r4, r1)
            if (r4 != 0) goto L58
            if (r7 == 0) goto L27
            java.lang.Throwable r1 = r0.p()
            S3.k r2 = new S3.k
            r2.<init>(r1)
            return r2
        L58:
            r1 = r4
        L59:
            r4 = r9
            int r9 = S3.e.d(r0, r1, r2, r3, r4, r6, r7)
            if (r9 == 0) goto Lbc
            r3 = 1
            if (r9 == r3) goto Lbb
            r3 = 2
            if (r9 == r3) goto L95
            r2 = 3
            if (r9 == r2) goto L8d
            r2 = 4
            if (r9 == r2) goto L76
            r2 = 5
            if (r9 == r2) goto L70
            goto L73
        L70:
            r1.b()
        L73:
            r3 = r18
            goto L27
        L76:
            java.util.concurrent.atomic.AtomicLongFieldUpdater r2 = S3.e.f1821c
            long r2 = r2.get(r0)
            int r2 = (r4 > r2 ? 1 : (r4 == r2 ? 0 : -1))
            if (r2 >= 0) goto L83
            r1.b()
        L83:
            java.lang.Throwable r1 = r0.p()
            S3.k r2 = new S3.k
            r2.<init>(r1)
            return r2
        L8d:
            java.lang.IllegalStateException r1 = new java.lang.IllegalStateException
            java.lang.String r2 = "unexpected"
            r1.<init>(r2)
            throw r1
        L95:
            if (r7 == 0) goto La4
            r1.i()
            java.lang.Throwable r1 = r0.p()
            S3.k r2 = new S3.k
            r2.<init>(r1)
            return r2
        La4:
            boolean r3 = r6 instanceof Q3.K0
            if (r3 == 0) goto Lab
            Q3.K0 r6 = (Q3.K0) r6
            goto Lac
        Lab:
            r6 = 0
        Lac:
            if (r6 == 0) goto Lb3
            int r3 = r2 + r11
            r6.a(r1, r3)
        Lb3:
            long r3 = r1.f2248c
            long r3 = r3 * r12
            long r1 = (long) r2
            long r3 = r3 + r1
            r0.h(r3)
        Lbb:
            return r8
        Lbc:
            r1.b()
            return r8
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.q.G(boolean, java.lang.Object):java.lang.Object");
    }

    @Override // S3.e, S3.w
    public final Object k(Object obj) {
        return G(false, obj);
    }

    @Override // S3.e, S3.w
    public final Object m(Object obj, InterfaceC0762c interfaceC0762c) throws Throwable {
        if (G(true, obj) instanceof k) {
            throw p();
        }
        return w3.i.f6729a;
    }

    @Override // S3.e
    public final boolean u() {
        return this.f1855q == c.f1814b;
    }
}
