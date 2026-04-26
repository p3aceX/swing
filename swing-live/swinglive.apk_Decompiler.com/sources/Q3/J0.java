package Q3;

import e1.AbstractC0367g;
import y3.InterfaceC0765f;
import y3.InterfaceC0766g;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class J0 implements InterfaceC0765f, InterfaceC0766g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final J0 f1592a = new J0();

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h c(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.y(this, interfaceC0766g);
    }

    @Override // y3.InterfaceC0767h
    public final Object h(Object obj, I3.p pVar) {
        return pVar.invoke(obj, this);
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0765f i(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.u(this, interfaceC0766g);
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h s(InterfaceC0767h interfaceC0767h) {
        return AbstractC0367g.A(this, interfaceC0767h);
    }

    @Override // y3.InterfaceC0765f
    public final InterfaceC0766g getKey() {
        return this;
    }
}
