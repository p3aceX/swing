package I;

import Q3.C0146s;
import e1.AbstractC0367g;
import y3.C0768i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class B extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f537a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Q f538b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public B(Q q4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f538b = q4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new B(this.f538b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((B) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Throwable {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f537a;
        w3.i iVar = w3.i.f6729a;
        Q q4 = this.f538b;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f537a = 1;
            Object objC0 = ((C0146s) q4.f604o.f707c).c0(this);
            if (objC0 != enumC0789a) {
                objC0 = iVar;
            }
            if (objC0 != enumC0789a) {
            }
        }
        if (i4 != 1) {
            if (i4 != 2) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return iVar;
        }
        AbstractC0367g.M(obj);
        T3.d dVar = q4.f().f695c;
        S3.c cVar = S3.c.f1814b;
        T3.d dVarA = dVar instanceof U3.i ? U3.k.a((U3.i) dVar, null, 0, cVar, 1) : new U3.g(dVar, C0768i.f6945a, 0, cVar);
        A a5 = new A(q4, 0);
        this.f537a = 2;
        return dVarA.b(a5, this) == enumC0789a ? enumC0789a : iVar;
    }
}
