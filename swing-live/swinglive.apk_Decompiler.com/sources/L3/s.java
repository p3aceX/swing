package l3;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class s extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5718a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5719b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0536m f5720c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public s(C0536m c0536m, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f5720c = c0536m;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5718a = obj;
        this.f5719b |= Integer.MIN_VALUE;
        return this.f5720c.c(null, this);
    }
}
