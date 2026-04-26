package y3;

import I3.p;
import e1.AbstractC0367g;

/* JADX INFO: renamed from: y3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0760a implements InterfaceC0765f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final InterfaceC0766g f6941a;

    public AbstractC0760a(InterfaceC0766g interfaceC0766g) {
        this.f6941a = interfaceC0766g;
    }

    @Override // y3.InterfaceC0767h
    public /* bridge */ InterfaceC0767h c(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.y(this, interfaceC0766g);
    }

    @Override // y3.InterfaceC0765f
    public final InterfaceC0766g getKey() {
        return this.f6941a;
    }

    @Override // y3.InterfaceC0767h
    public final Object h(Object obj, p pVar) {
        return pVar.invoke(obj, this);
    }

    @Override // y3.InterfaceC0767h
    public /* bridge */ InterfaceC0765f i(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.u(this, interfaceC0766g);
    }

    @Override // y3.InterfaceC0767h
    public final /* bridge */ InterfaceC0767h s(InterfaceC0767h interfaceC0767h) {
        return AbstractC0367g.A(this, interfaceC0767h);
    }
}
