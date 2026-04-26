package y2;

import Q3.D;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class q extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ N2.j f6935a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f6936b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public q(N2.j jVar, int i4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6935a = jVar;
        this.f6936b = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new q(this.f6935a, this.f6936b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        q qVar = (q) create((D) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        qVar.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        this.f6935a.c(new Integer(this.f6936b));
        return w3.i.f6729a;
    }
}
