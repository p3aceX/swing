package V3;

import Q3.AbstractC0117a;
import Q3.F;
import Q3.L;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public class r extends AbstractC0117a implements A3.d {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final InterfaceC0762c f2246d;

    public r(InterfaceC0762c interfaceC0762c, InterfaceC0767h interfaceC0767h) {
        super(interfaceC0767h, true, true);
        this.f2246d = interfaceC0762c;
    }

    @Override // Q3.q0
    public final boolean N() {
        return true;
    }

    @Override // A3.d
    public final A3.d getCallerFrame() {
        InterfaceC0762c interfaceC0762c = this.f2246d;
        if (interfaceC0762c instanceof A3.d) {
            return (A3.d) interfaceC0762c;
        }
        return null;
    }

    @Override // Q3.q0
    public void r(Object obj) throws L {
        b.h(F.u(obj), e1.k.w(this.f2246d));
    }

    @Override // Q3.q0
    public void t(Object obj) {
        this.f2246d.resumeWith(F.u(obj));
    }

    public void f0() {
    }
}
