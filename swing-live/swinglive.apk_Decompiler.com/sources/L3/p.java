package l3;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class p extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5708a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5709b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ T3.l f5710c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public p(T3.l lVar, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f5710c = lVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5708a = obj;
        this.f5709b |= Integer.MIN_VALUE;
        return this.f5710c.c(null, this);
    }
}
