package Q3;

import y3.InterfaceC0762c;

/* JADX INFO: renamed from: Q3.f0, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0128f0 extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f1626a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ I3.a f1627b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0128f0(I3.a aVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f1627b = aVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0128f0 c0128f0 = new C0128f0(this.f1627b, interfaceC0762c);
        c0128f0.f1626a = obj;
        return c0128f0;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0128f0) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:17:0x0041, code lost:
    
        return r0.a();
     */
    /* JADX WARN: Code restructure failed: missing block: B:20:0x0044, code lost:
    
        r5 = move-exception;
     */
    /* JADX WARN: Code restructure failed: missing block: B:21:0x0045, code lost:
    
        r1.o();
     */
    /* JADX WARN: Code restructure failed: missing block: B:22:0x0048, code lost:
    
        throw r5;
     */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r5) throws java.lang.Throwable {
        /*
            r4 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            e1.AbstractC0367g.M(r5)
            java.lang.Object r5 = r4.f1626a
            Q3.D r5 = (Q3.D) r5
            y3.h r5 = r5.n()
            I3.a r0 = r4.f1627b
            Q3.D0 r1 = new Q3.D0     // Catch: java.lang.InterruptedException -> L42
            r1.<init>()     // Catch: java.lang.InterruptedException -> L42
            Q3.h0 r5 = Q3.F.m(r5)     // Catch: java.lang.InterruptedException -> L42
            r2 = 1
            Q3.Q r5 = Q3.F.p(r5, r2, r1)     // Catch: java.lang.InterruptedException -> L42
            r1.f1570f = r5     // Catch: java.lang.InterruptedException -> L42
        L1f:
            java.util.concurrent.atomic.AtomicIntegerFieldUpdater r5 = Q3.D0.f1569m     // Catch: java.lang.InterruptedException -> L42
            int r2 = r5.get(r1)     // Catch: java.lang.InterruptedException -> L42
            if (r2 == 0) goto L33
            r5 = 2
            if (r2 == r5) goto L3a
            r5 = 3
            if (r2 != r5) goto L2e
            goto L3a
        L2e:
            Q3.D0.p(r2)     // Catch: java.lang.InterruptedException -> L42
            r5 = 0
            throw r5     // Catch: java.lang.InterruptedException -> L42
        L33:
            r3 = 0
            boolean r5 = r5.compareAndSet(r1, r2, r3)     // Catch: java.lang.InterruptedException -> L42
            if (r5 == 0) goto L1f
        L3a:
            java.lang.Object r5 = r0.a()     // Catch: java.lang.Throwable -> L44
            r1.o()     // Catch: java.lang.InterruptedException -> L42
            return r5
        L42:
            r5 = move-exception
            goto L49
        L44:
            r5 = move-exception
            r1.o()     // Catch: java.lang.InterruptedException -> L42
            throw r5     // Catch: java.lang.InterruptedException -> L42
        L49:
            java.util.concurrent.CancellationException r0 = new java.util.concurrent.CancellationException
            java.lang.String r1 = "Blocking call was interrupted due to parent cancellation"
            r0.<init>(r1)
            java.lang.Throwable r5 = r0.initCause(r5)
            throw r5
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.C0128f0.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
