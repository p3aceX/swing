package Q3;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class p0 extends A3.i implements I3.p {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public s0 f1652b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public V3.k f1653c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1654d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ q0 f1655f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public p0(q0 q0Var, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f1655f = q0Var;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        p0 p0Var = new p0(this.f1655f, interfaceC0762c);
        p0Var.e = obj;
        return p0Var;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((p0) create((O3.d) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x0067  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:22:0x0069 -> B:25:0x007e). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r6) {
        /*
            r5 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r5.f1654d
            r2 = 2
            r3 = 1
            if (r1 == 0) goto L24
            if (r1 == r3) goto L20
            if (r1 != r2) goto L18
            V3.k r1 = r5.f1653c
            Q3.s0 r3 = r5.f1652b
            java.lang.Object r4 = r5.e
            O3.d r4 = (O3.d) r4
            e1.AbstractC0367g.M(r6)
            goto L7e
        L18:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r0)
            throw r6
        L20:
            e1.AbstractC0367g.M(r6)
            goto L83
        L24:
            e1.AbstractC0367g.M(r6)
            java.lang.Object r6 = r5.e
            O3.d r6 = (O3.d) r6
            Q3.q0 r1 = r5.f1655f
            r1.getClass()
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r4 = Q3.q0.f1656a
            java.lang.Object r1 = r4.get(r1)
            boolean r4 = r1 instanceof Q3.C0145q
            if (r4 == 0) goto L44
            Q3.q r1 = (Q3.C0145q) r1
            Q3.q0 r1 = r1.e
            r5.f1654d = r3
            r6.b(r1, r5)
            return r0
        L44:
            boolean r3 = r1 instanceof Q3.InterfaceC0124d0
            if (r3 == 0) goto L83
            Q3.d0 r1 = (Q3.InterfaceC0124d0) r1
            Q3.s0 r1 = r1.d()
            if (r1 == 0) goto L83
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r3 = V3.k.f2233a
            java.lang.Object r3 = r3.get(r1)
            java.lang.String r4 = "null cannot be cast to non-null type kotlinx.coroutines.internal.LockFreeLinkedListNode"
            J3.i.c(r3, r4)
            V3.k r3 = (V3.k) r3
            r4 = r3
            r3 = r1
            r1 = r4
            r4 = r6
        L61:
            boolean r6 = r1.equals(r3)
            if (r6 != 0) goto L83
            boolean r6 = r1 instanceof Q3.C0145q
            if (r6 == 0) goto L7e
            r6 = r1
            Q3.q r6 = (Q3.C0145q) r6
            r5.e = r4
            r5.f1652b = r3
            r5.f1653c = r1
            r5.f1654d = r2
            Q3.q0 r6 = r6.e
            r4.b(r6, r5)
            z3.a r6 = z3.EnumC0789a.f6999a
            return r0
        L7e:
            V3.k r1 = r1.i()
            goto L61
        L83:
            w3.i r6 = w3.i.f6729a
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.p0.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
