package I;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: I.q, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0056q extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f716a;

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0056q c0056q = new C0056q(2, interfaceC0762c);
        c0056q.f716a = obj;
        return c0056q;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0056q) create((m0) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        return Boolean.valueOf(!(((m0) this.f716a) instanceof c0));
    }
}
