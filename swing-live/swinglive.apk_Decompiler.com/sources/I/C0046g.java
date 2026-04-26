package I;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: I.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0046g extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f659a;

    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new C0046g(1, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        C0046g c0046g = (C0046g) create((InterfaceC0762c) obj);
        w3.i iVar = w3.i.f6729a;
        c0046g.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f659a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f659a = 1;
            throw null;
        }
        if (i4 != 1) {
            throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
        }
        AbstractC0367g.M(obj);
        return w3.i.f6729a;
    }
}
