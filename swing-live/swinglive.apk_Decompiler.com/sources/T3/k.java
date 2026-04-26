package T3;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class k extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public l f2044a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f2045b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f2046c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ l f2047d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public k(l lVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f2047d = lVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f2046c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f2047d.c(null, this);
    }
}
