package U3;

import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class p implements InterfaceC0762c, A3.d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final InterfaceC0762c f2130a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final InterfaceC0767h f2131b;

    public p(InterfaceC0762c interfaceC0762c, InterfaceC0767h interfaceC0767h) {
        this.f2130a = interfaceC0762c;
        this.f2131b = interfaceC0767h;
    }

    @Override // A3.d
    public final A3.d getCallerFrame() {
        InterfaceC0762c interfaceC0762c = this.f2130a;
        if (interfaceC0762c instanceof A3.d) {
            return (A3.d) interfaceC0762c;
        }
        return null;
    }

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        return this.f2131b;
    }

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) {
        this.f2130a.resumeWith(obj);
    }
}
