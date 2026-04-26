package l3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class B extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5627a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L.d f5628b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ boolean f5629c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public B(L.d dVar, boolean z4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5628b = dVar;
        this.f5629c = z4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        B b5 = new B(this.f5628b, this.f5629c, interfaceC0762c);
        b5.f5627a = obj;
        return b5;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        B b5 = (B) create((L.b) obj, (InterfaceC0762c) obj2);
        w3.i iVar = w3.i.f6729a;
        b5.invokeSuspend(iVar);
        return iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        ((L.b) this.f5627a).d(this.f5628b, Boolean.valueOf(this.f5629c));
        return w3.i.f6729a;
    }
}
