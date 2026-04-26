package e2;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class P extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public J3.p f4071a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Q f4072b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public J3.p f4073c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4074d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ Q f4075f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public P(Q q4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4075f = q4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        P p4 = new P(this.f4075f, interfaceC0762c);
        p4.e = obj;
        return p4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((P) create((Z1.a) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:20:0x0068  */
    /* JADX WARN: Removed duplicated region for block: B:30:0x00ab  */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r8) {
        /*
            Method dump skipped, instruction units count: 213
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.P.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
