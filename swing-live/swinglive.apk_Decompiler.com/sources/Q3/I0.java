package Q3;

import y3.C0763d;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class I0 extends V3.r {
    public final ThreadLocal e;
    private volatile boolean threadLocalIsSet;

    /* JADX WARN: Illegal instructions before constructor call */
    public I0(InterfaceC0762c interfaceC0762c, InterfaceC0767h interfaceC0767h) {
        J0 j02 = J0.f1592a;
        super(interfaceC0762c, interfaceC0767h.i(j02) == null ? interfaceC0767h.s(j02) : interfaceC0767h);
        this.e = new ThreadLocal();
        if (interfaceC0762c.getContext().i(C0763d.f6944a) instanceof A) {
            return;
        }
        Object objN = V3.b.n(interfaceC0767h, null);
        V3.b.g(interfaceC0767h, objN);
        i0(interfaceC0767h, objN);
    }

    @Override // V3.r
    public final void f0() {
        h0();
    }

    public final boolean g0() {
        boolean z4 = this.threadLocalIsSet && this.e.get() == null;
        this.e.remove();
        return !z4;
    }

    public final void h0() {
        if (this.threadLocalIsSet) {
            w3.c cVar = (w3.c) this.e.get();
            if (cVar != null) {
                V3.b.g((InterfaceC0767h) cVar.f6718a, cVar.f6719b);
            }
            this.e.remove();
        }
    }

    public final void i0(InterfaceC0767h interfaceC0767h, Object obj) {
        this.threadLocalIsSet = true;
        this.e.set(new w3.c(interfaceC0767h, obj));
    }

    @Override // V3.r, Q3.q0
    public final void t(Object obj) {
        h0();
        Object objU = F.u(obj);
        InterfaceC0762c interfaceC0762c = this.f2246d;
        InterfaceC0767h context = interfaceC0762c.getContext();
        Object objN = V3.b.n(context, null);
        I0 i0A = objN != V3.b.f2215d ? F.A(interfaceC0762c, context, objN) : null;
        try {
            interfaceC0762c.resumeWith(objU);
            if (i0A == null || i0A.g0()) {
                V3.b.g(context, objN);
            }
        } catch (Throwable th) {
            if (i0A == null || i0A.g0()) {
                V3.b.g(context, objN);
            }
            throw th;
        }
    }
}
