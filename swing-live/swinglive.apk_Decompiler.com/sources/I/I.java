package I;

import java.io.Serializable;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class I extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Serializable f567a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f568b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ J3.r f569c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f570d;
    public final /* synthetic */ J3.p e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public I(J3.r rVar, Q q4, J3.p pVar, InterfaceC0762c interfaceC0762c) {
        super(1, interfaceC0762c);
        this.f569c = rVar;
        this.f570d = q4;
        this.e = pVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new I(this.f569c, this.f570d, this.e, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        return ((I) create((InterfaceC0762c) obj)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:28:0x006a, code lost:
    
        if (r9 != r0) goto L30;
     */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r9) {
        /*
            r8 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r8.f568b
            J3.p r2 = r8.e
            J3.r r3 = r8.f569c
            r4 = 3
            r5 = 2
            I.Q r6 = r8.f570d
            r7 = 1
            if (r1 == 0) goto L36
            if (r1 == r7) goto L2e
            if (r1 == r5) goto L26
            if (r1 != r4) goto L1e
            java.io.Serializable r0 = r8.f567a
            r2 = r0
            J3.p r2 = (J3.p) r2
            e1.AbstractC0367g.M(r9)
            goto L6d
        L1e:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r0)
            throw r9
        L26:
            java.io.Serializable r1 = r8.f567a
            J3.p r1 = (J3.p) r1
            e1.AbstractC0367g.M(r9)     // Catch: I.C0042c -> L60
            goto L57
        L2e:
            java.io.Serializable r1 = r8.f567a
            J3.r r1 = (J3.r) r1
            e1.AbstractC0367g.M(r9)     // Catch: I.C0042c -> L60
            goto L45
        L36:
            e1.AbstractC0367g.M(r9)
            r8.f567a = r3     // Catch: I.C0042c -> L60
            r8.f568b = r7     // Catch: I.C0042c -> L60
            java.lang.Object r9 = r6.h(r8)     // Catch: I.C0042c -> L60
            if (r9 != r0) goto L44
            goto L6c
        L44:
            r1 = r3
        L45:
            r1.f832a = r9     // Catch: I.C0042c -> L60
            I.l0 r9 = r6.f()     // Catch: I.C0042c -> L60
            r8.f567a = r2     // Catch: I.C0042c -> L60
            r8.f568b = r5     // Catch: I.C0042c -> L60
            java.lang.Integer r9 = r9.a()     // Catch: I.C0042c -> L60
            if (r9 != r0) goto L56
            goto L6c
        L56:
            r1 = r2
        L57:
            java.lang.Number r9 = (java.lang.Number) r9     // Catch: I.C0042c -> L60
            int r9 = r9.intValue()     // Catch: I.C0042c -> L60
            r1.f830a = r9     // Catch: I.C0042c -> L60
            goto L75
        L60:
            java.lang.Object r9 = r3.f832a
            r8.f567a = r2
            r8.f568b = r4
            java.lang.Object r9 = r6.i(r9, r7, r8)
            if (r9 != r0) goto L6d
        L6c:
            return r0
        L6d:
            java.lang.Number r9 = (java.lang.Number) r9
            int r9 = r9.intValue()
            r2.f830a = r9
        L75:
            w3.i r9 = w3.i.f6729a
            return r9
        */
        throw new UnsupportedOperationException("Method not decompiled: I.I.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
