package T3;

import l3.C0536m;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class n extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0536m f2056a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f2057b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2058c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ C0536m f2059d;
    public Object e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public n(C0536m c0536m, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f2059d = c0536m;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f2057b = obj;
        this.f2058c |= Integer.MIN_VALUE;
        return this.f2059d.c(null, this);
    }
}
