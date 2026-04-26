package y2;

import Q3.D;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class r extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6937a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Y0.n f6938b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ String f6939c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ N2.j f6940d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public r(Y0.n nVar, String str, N2.j jVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6938b = nVar;
        this.f6939c = str;
        this.f6940d = jVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new r(this.f6938b, this.f6939c, this.f6940d, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((r) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:38:0x00fb A[RETURN] */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r17) {
        /*
            Method dump skipped, instruction units count: 255
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: y2.r.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
