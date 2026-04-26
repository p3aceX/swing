package I;

import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class L extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f576a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f577b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Q f578c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ InterfaceC0767h f579d;
    public final /* synthetic */ A3.j e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public L(Q q4, InterfaceC0767h interfaceC0767h, I3.p pVar, InterfaceC0762c interfaceC0762c) {
        super(1, interfaceC0762c);
        this.f578c = q4;
        this.f579d = interfaceC0767h;
        this.e = (A3.j) pVar;
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new L(this.f578c, this.f579d, this.e, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        return ((L) create((InterfaceC0762c) obj)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x0053  */
    /* JADX WARN: Removed duplicated region for block: B:22:0x0058  */
    /* JADX WARN: Removed duplicated region for block: B:25:0x005d  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x0071  */
    /* JADX WARN: Type inference failed for: r6v0, types: [A3.j, I3.p] */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r9) throws java.lang.Throwable {
        /*
            r8 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r8.f577b
            I.Q r2 = r8.f578c
            r3 = 3
            r4 = 2
            r5 = 1
            if (r1 == 0) goto L2b
            if (r1 == r5) goto L27
            if (r1 == r4) goto L1f
            if (r1 != r3) goto L17
            java.lang.Object r0 = r8.f576a
            e1.AbstractC0367g.M(r9)
            return r0
        L17:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r0)
            throw r9
        L1f:
            java.lang.Object r1 = r8.f576a
            I.d r1 = (I.C0043d) r1
            e1.AbstractC0367g.M(r9)
            goto L4f
        L27:
            e1.AbstractC0367g.M(r9)
            goto L37
        L2b:
            e1.AbstractC0367g.M(r9)
            r8.f577b = r5
            java.lang.Object r9 = I.Q.e(r2, r5, r8)
            if (r9 != r0) goto L37
            goto L6f
        L37:
            r1 = r9
            I.d r1 = (I.C0043d) r1
            I.K r9 = new I.K
            A3.j r6 = r8.e
            r7 = 0
            r9.<init>(r6, r1, r7)
            r8.f576a = r1
            r8.f577b = r4
            y3.h r4 = r8.f579d
            java.lang.Object r9 = Q3.F.B(r4, r9, r8)
            if (r9 != r0) goto L4f
            goto L6f
        L4f:
            java.lang.Object r4 = r1.f641b
            if (r4 == 0) goto L58
            int r4 = r4.hashCode()
            goto L59
        L58:
            r4 = 0
        L59:
            int r6 = r1.f642c
            if (r4 != r6) goto L71
            java.lang.Object r1 = r1.f641b
            boolean r1 = J3.i.a(r1, r9)
            if (r1 != 0) goto L70
            r8.f576a = r9
            r8.f577b = r3
            java.lang.Object r1 = r2.i(r9, r5, r8)
            if (r1 != r0) goto L70
        L6f:
            return r0
        L70:
            return r9
        L71:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r0 = "Data in DataStore was mutated but DataStore is only compatible with Immutable types."
            r9.<init>(r0)
            throw r9
        */
        throw new UnsupportedOperationException("Method not decompiled: I.L.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
