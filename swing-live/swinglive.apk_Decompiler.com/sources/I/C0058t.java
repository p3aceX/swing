package I;

import y3.InterfaceC0762c;

/* JADX INFO: renamed from: I.t, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0058t extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f724a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f725b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0059u f726c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0058t(C0059u c0059u, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f726c = c0059u;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f724a = obj;
        this.f725b |= Integer.MIN_VALUE;
        return this.f726c.c(null, this);
    }
}
