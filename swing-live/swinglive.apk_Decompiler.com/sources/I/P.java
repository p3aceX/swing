package I;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class P extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public J3.p f591a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f592b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f593c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ J3.p f594d;
    public final /* synthetic */ Q e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ Object f595f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ boolean f596m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public P(J3.p pVar, Q q4, Object obj, boolean z4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f594d = pVar;
        this.e = q4;
        this.f595f = obj;
        this.f596m = z4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        P p4 = new P(this.f594d, this.e, this.f595f, this.f596m, interfaceC0762c);
        p4.f593c = obj;
        return p4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((P) create((b0) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:15:0x0062, code lost:
    
        if (r6.b(r3, r7) == r0) goto L16;
     */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r8) {
        /*
            r7 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r7.f592b
            J3.p r2 = r7.f594d
            java.lang.Object r3 = r7.f595f
            I.Q r4 = r7.e
            r5 = 2
            r6 = 1
            if (r1 == 0) goto L28
            if (r1 == r6) goto L1e
            if (r1 != r5) goto L16
            e1.AbstractC0367g.M(r8)
            goto L65
        L16:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r0)
            throw r8
        L1e:
            J3.p r1 = r7.f591a
            java.lang.Object r6 = r7.f593c
            I.b0 r6 = (I.b0) r6
            e1.AbstractC0367g.M(r8)
            goto L4f
        L28:
            e1.AbstractC0367g.M(r8)
            java.lang.Object r8 = r7.f593c
            I.b0 r8 = (I.b0) r8
            I.l0 r1 = r4.f()
            r7.f593c = r8
            r7.f591a = r2
            r7.f592b = r6
            z0.j r1 = r1.f694b
            java.lang.Object r1 = r1.f6969b
            java.util.concurrent.atomic.AtomicInteger r1 = (java.util.concurrent.atomic.AtomicInteger) r1
            int r1 = r1.incrementAndGet()
            java.lang.Integer r6 = new java.lang.Integer
            r6.<init>(r1)
            if (r6 != r0) goto L4b
            goto L64
        L4b:
            r1 = r6
            r6 = r8
            r8 = r1
            r1 = r2
        L4f:
            java.lang.Number r8 = (java.lang.Number) r8
            int r8 = r8.intValue()
            r1.f830a = r8
            r8 = 0
            r7.f593c = r8
            r7.f591a = r8
            r7.f592b = r5
            java.lang.Object r8 = r6.b(r3, r7)
            if (r8 != r0) goto L65
        L64:
            return r0
        L65:
            boolean r8 = r7.f596m
            if (r8 == 0) goto L7d
            u1.c r8 = r4.f603n
            I.d r0 = new I.d
            if (r3 == 0) goto L74
            int r1 = r3.hashCode()
            goto L75
        L74:
            r1 = 0
        L75:
            int r2 = r2.f830a
            r0.<init>(r3, r1, r2)
            r8.A(r0)
        L7d:
            w3.i r8 = w3.i.f6729a
            return r8
        */
        throw new UnsupportedOperationException("Method not decompiled: I.P.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
