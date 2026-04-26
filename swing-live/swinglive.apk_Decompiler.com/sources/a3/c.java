package A3;

import Q3.A;
import Q3.C0141m;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.C0763d;
import y3.InterfaceC0762c;
import y3.InterfaceC0764e;
import y3.InterfaceC0765f;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public abstract class c extends a {
    private final InterfaceC0767h _context;
    private transient InterfaceC0762c intercepted;

    public c(InterfaceC0762c interfaceC0762c, InterfaceC0767h interfaceC0767h) {
        super(interfaceC0762c);
        this._context = interfaceC0767h;
    }

    @Override // y3.InterfaceC0762c
    public InterfaceC0767h getContext() {
        InterfaceC0767h interfaceC0767h = this._context;
        J3.i.b(interfaceC0767h);
        return interfaceC0767h;
    }

    public final InterfaceC0762c intercepted() {
        InterfaceC0762c interfaceC0762c = this.intercepted;
        if (interfaceC0762c != null) {
            return interfaceC0762c;
        }
        InterfaceC0764e interfaceC0764e = (InterfaceC0764e) getContext().i(C0763d.f6944a);
        InterfaceC0762c gVar = interfaceC0764e != null ? new V3.g((A) interfaceC0764e, this) : this;
        this.intercepted = gVar;
        return gVar;
    }

    @Override // A3.a
    public void releaseIntercepted() {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        InterfaceC0762c interfaceC0762c = this.intercepted;
        if (interfaceC0762c != null && interfaceC0762c != this) {
            InterfaceC0765f interfaceC0765fI = getContext().i(C0763d.f6944a);
            J3.i.b(interfaceC0765fI);
            V3.g gVar = (V3.g) interfaceC0762c;
            do {
                atomicReferenceFieldUpdater = V3.g.f2223n;
            } while (atomicReferenceFieldUpdater.get(gVar) == V3.b.f2214c);
            Object obj = atomicReferenceFieldUpdater.get(gVar);
            C0141m c0141m = obj instanceof C0141m ? (C0141m) obj : null;
            if (c0141m != null) {
                c0141m.m();
            }
        }
        this.intercepted = b.f86a;
    }

    public c(InterfaceC0762c interfaceC0762c) {
        this(interfaceC0762c, interfaceC0762c != null ? interfaceC0762c.getContext() : null);
    }
}
