package l3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class E extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5638a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L.d f5639b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ double f5640c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public E(L.d dVar, double d5, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5639b = dVar;
        this.f5640c = d5;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        E e = new E(this.f5639b, this.f5640c, interfaceC0762c);
        e.f5638a = obj;
        return e;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        E e = (E) create((L.b) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        e.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        ((L.b) this.f5638a).d(this.f5639b, new Double(this.f5640c));
        return w3.i.f6729a;
    }
}
