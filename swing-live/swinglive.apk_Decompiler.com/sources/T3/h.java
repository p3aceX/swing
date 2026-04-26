package T3;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class h extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f2033a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2034b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ i f2035c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f2036d;
    public e e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(i iVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f2035c = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f2033a = obj;
        this.f2034b |= Integer.MIN_VALUE;
        return this.f2035c.b(null, this);
    }
}
