package I;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class D extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Q f543a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public m0 f544b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f545c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f546d;
    public final /* synthetic */ Q e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f547f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public D(Q q4, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.e = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f546d = obj;
        this.f547f |= Integer.MIN_VALUE;
        return Q.d(this.e, false, this);
    }
}
