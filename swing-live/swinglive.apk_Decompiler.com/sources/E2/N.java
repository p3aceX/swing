package e2;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class N extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4064a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4065b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ P f4066c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public N(P p4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4066c = p4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        N n4 = new N(this.f4066c, interfaceC0762c);
        n4.f4065b = obj;
        return n4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((N) create((Z1.a) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Z1.a aVar = (Z1.a) this.f4065b;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4064a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f4065b = null;
            this.f4064a = 1;
            if (this.f4066c.invoke(aVar, this) == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return w3.i.f6729a;
    }
}
