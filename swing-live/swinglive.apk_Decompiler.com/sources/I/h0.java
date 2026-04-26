package I;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class h0 extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public N f667a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f668b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0053n f669c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h0(C0053n c0053n, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f669c = c0053n;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new h0(this.f669c, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((h0) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:16:0x0059, code lost:
    
        if (r1.invoke(r7, r6) != r0) goto L18;
     */
    /* JADX WARN: Removed duplicated region for block: B:15:0x0050 A[PHI: r1 r7
      0x0050: PHI (r1v1 I.N) = (r1v3 I.N), (r1v4 I.N) binds: [B:13:0x004d, B:9:0x001a] A[DONT_GENERATE, DONT_INLINE]
      0x0050: PHI (r7v7 java.lang.Object) = (r7v15 java.lang.Object), (r7v0 java.lang.Object) binds: [B:13:0x004d, B:9:0x001a] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:16:0x0059 -> B:18:0x005c). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r7) {
        /*
            r6 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r6.f668b
            r2 = 2
            r3 = 1
            I.n r4 = r6.f669c
            if (r1 == 0) goto L20
            if (r1 == r3) goto L1a
            if (r1 != r2) goto L12
            e1.AbstractC0367g.M(r7)
            goto L5c
        L12:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r0)
            throw r7
        L1a:
            I.N r1 = r6.f667a
            e1.AbstractC0367g.M(r7)
            goto L50
        L20:
            e1.AbstractC0367g.M(r7)
            java.lang.Object r7 = r4.e
            z0.j r7 = (z0.C0779j) r7
            java.lang.Object r7 = r7.f6969b
            java.util.concurrent.atomic.AtomicInteger r7 = (java.util.concurrent.atomic.AtomicInteger) r7
            int r7 = r7.get()
            if (r7 <= 0) goto L6d
        L31:
            java.lang.Object r7 = r4.f706b
            Q3.D r7 = (Q3.D) r7
            y3.h r7 = r7.n()
            Q3.F.i(r7)
            java.lang.Object r7 = r4.f707c
            r1 = r7
            I.N r1 = (I.N) r1
            java.lang.Object r7 = r4.f708d
            S3.e r7 = (S3.e) r7
            r6.f667a = r1
            r6.f668b = r3
            java.lang.Object r7 = r7.y(r6)
            if (r7 != r0) goto L50
            goto L5b
        L50:
            r5 = 0
            r6.f667a = r5
            r6.f668b = r2
            java.lang.Object r7 = r1.invoke(r7, r6)
            if (r7 != r0) goto L5c
        L5b:
            return r0
        L5c:
            java.lang.Object r7 = r4.e
            z0.j r7 = (z0.C0779j) r7
            java.lang.Object r7 = r7.f6969b
            java.util.concurrent.atomic.AtomicInteger r7 = (java.util.concurrent.atomic.AtomicInteger) r7
            int r7 = r7.decrementAndGet()
            if (r7 != 0) goto L31
            w3.i r7 = w3.i.f6729a
            return r7
        L6d:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r0 = "Check failed."
            r7.<init>(r0)
            throw r7
        */
        throw new UnsupportedOperationException("Method not decompiled: I.h0.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
