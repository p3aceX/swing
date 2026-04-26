package l3;

import I.C0059u;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class z extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5745a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5746b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0059u f5747c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public z(C0059u c0059u, InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        this.f5747c = c0059u;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5745a = obj;
        this.f5746b |= Integer.MIN_VALUE;
        return this.f5747c.c(null, this);
    }
}
