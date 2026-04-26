package I;

import y3.InterfaceC0762c;

/* JADX INFO: renamed from: I.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0060v extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0043d f729a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f730b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f731c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f732d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0060v(Q q4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f732d = q4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0060v c0060v = new C0060v(this.f732d, interfaceC0762c);
        c0060v.f731c = obj;
        return c0060v;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0060v) create((T3.e) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:31:0x00c3  */
    /* JADX WARN: Removed duplicated region for block: B:38:0x00cf  */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r13) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 225
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: I.C0060v.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
