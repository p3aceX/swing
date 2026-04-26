package X3;

import Q3.A;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class l extends A {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final l f2450c = new l();

    @Override // Q3.A
    public final void A(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        e.f2439d.f2441c.b(runnable, true, false);
    }

    @Override // Q3.A
    public final void B(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        e.f2439d.f2441c.b(runnable, true, true);
    }

    @Override // Q3.A
    public final A D(int i4) {
        V3.b.a(i4);
        return i4 >= k.f2448d ? this : super.D(i4);
    }

    @Override // Q3.A
    public final String toString() {
        return "Dispatchers.IO";
    }
}
