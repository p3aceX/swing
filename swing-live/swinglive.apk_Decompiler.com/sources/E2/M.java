package e2;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class M extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4061a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4062b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ P f4063c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public M(P p4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4063c = p4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        M m4 = new M(this.f4063c, interfaceC0762c);
        m4.f4062b = obj;
        return m4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((M) create((Z1.a) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Z1.a aVar = (Z1.a) this.f4062b;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4061a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f4062b = null;
            this.f4061a = 1;
            if (this.f4063c.invoke(aVar, this) == enumC0789a) {
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
