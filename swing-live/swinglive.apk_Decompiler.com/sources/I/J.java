package I;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class J extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f571a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Q f572b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public J(Q q4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f572b = q4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new J(this.f572b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((J) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:21:0x0044, code lost:
    
        if (r6 == r0) goto L22;
     */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r6) throws java.lang.Throwable {
        /*
            r5 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r5.f571a
            r2 = 2
            r3 = 1
            I.Q r4 = r5.f572b
            if (r1 == 0) goto L20
            if (r1 == r3) goto L1a
            if (r1 != r2) goto L12
            e1.AbstractC0367g.M(r6)
            goto L47
        L12:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r0)
            throw r6
        L1a:
            e1.AbstractC0367g.M(r6)     // Catch: java.lang.Throwable -> L1e
            goto L3d
        L1e:
            r6 = move-exception
            goto L4a
        L20:
            e1.AbstractC0367g.M(r6)
            u1.c r6 = r4.f603n
            I.m0 r6 = r6.v()
            boolean r6 = r6 instanceof I.c0
            if (r6 == 0) goto L34
            u1.c r6 = r4.f603n
            I.m0 r6 = r6.v()
            return r6
        L34:
            r5.f571a = r3     // Catch: java.lang.Throwable -> L1e
            java.lang.Object r6 = r4.g(r5)     // Catch: java.lang.Throwable -> L1e
            if (r6 != r0) goto L3d
            goto L46
        L3d:
            r5.f571a = r2
            r6 = 0
            java.lang.Object r6 = I.Q.d(r4, r6, r5)
            if (r6 != r0) goto L47
        L46:
            return r0
        L47:
            I.m0 r6 = (I.m0) r6
            return r6
        L4a:
            I.e0 r0 = new I.e0
            r1 = -1
            r0.<init>(r1, r6)
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: I.J.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
