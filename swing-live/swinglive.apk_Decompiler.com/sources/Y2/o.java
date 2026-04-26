package y2;

import Q3.D;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class o extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ N2.j f6929a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f6930b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public o(N2.j jVar, int i4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6929a = jVar;
        this.f6930b = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new o(this.f6929a, this.f6930b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        o oVar = (o) create((D) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        oVar.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        this.f6929a.c(new Integer(this.f6930b));
        return w3.i.f6729a;
    }
}
