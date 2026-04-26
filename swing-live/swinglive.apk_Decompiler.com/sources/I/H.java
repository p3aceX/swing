package I;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class H extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f563a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f564b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ boolean f565c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f566d;
    public final /* synthetic */ int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public H(Q q4, int i4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f566d = q4;
        this.e = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        H h4 = new H(this.f566d, this.e, interfaceC0762c);
        h4.f565c = ((Boolean) obj).booleanValue();
        return h4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        Boolean bool = (Boolean) obj;
        bool.booleanValue();
        return ((H) create(bool, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:22:0x0055  */
    /* JADX WARN: Removed duplicated region for block: B:23:0x005a  */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r7) {
        /*
            r6 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r6.f564b
            I.Q r2 = r6.f566d
            r3 = 2
            r4 = 1
            if (r1 == 0) goto L22
            if (r1 == r4) goto L1c
            if (r1 != r3) goto L14
            java.lang.Object r0 = r6.f563a
            e1.AbstractC0367g.M(r7)
            goto L45
        L14:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r0)
            throw r7
        L1c:
            boolean r1 = r6.f565c
            e1.AbstractC0367g.M(r7)
            goto L32
        L22:
            e1.AbstractC0367g.M(r7)
            boolean r1 = r6.f565c
            r6.f565c = r1
            r6.f564b = r4
            java.lang.Object r7 = r2.h(r6)
            if (r7 != r0) goto L32
            goto L42
        L32:
            if (r1 == 0) goto L4c
            I.l0 r1 = r2.f()
            r6.f563a = r7
            r6.f564b = r3
            java.lang.Integer r1 = r1.a()
            if (r1 != r0) goto L43
        L42:
            return r0
        L43:
            r0 = r7
            r7 = r1
        L45:
            java.lang.Number r7 = (java.lang.Number) r7
            int r7 = r7.intValue()
            goto L51
        L4c:
            int r0 = r6.e
            r5 = r0
            r0 = r7
            r7 = r5
        L51:
            I.d r1 = new I.d
            if (r0 == 0) goto L5a
            int r2 = r0.hashCode()
            goto L5b
        L5a:
            r2 = 0
        L5b:
            r1.<init>(r0, r2, r7)
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: I.H.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
