package I;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class r extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f719a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ m0 f720b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public r(m0 m0Var, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f720b = m0Var;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        r rVar = new r(this.f720b, interfaceC0762c);
        rVar.f719a = obj;
        return rVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((r) create((m0) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        m0 m0Var = (m0) this.f719a;
        return Boolean.valueOf((m0Var instanceof C0043d) && m0Var.f704a <= this.f720b.f704a);
    }
}
