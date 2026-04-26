package Q3;

import a.AbstractC0184a;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class r0 extends y0 {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final InterfaceC0762c f1658d;

    public r0(InterfaceC0767h interfaceC0767h, I3.p pVar) {
        super(interfaceC0767h, true, false);
        this.f1658d = e1.k.l(pVar, this, this);
    }

    @Override // Q3.q0
    public final void V() throws Throwable {
        try {
            V3.b.h(w3.i.f6729a, e1.k.w(this.f1658d));
        } catch (Throwable th) {
            AbstractC0184a.B(this, th);
            throw null;
        }
    }
}
