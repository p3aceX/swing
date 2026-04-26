package U3;

import Q3.D;
import Q3.E;
import Q3.F;
import S3.t;
import T3.r;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2105a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f2106b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ T3.e f2107c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ e f2108d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(T3.e eVar, e eVar2, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f2107c = eVar;
        this.f2108d = eVar2;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        c cVar = new c(this.f2107c, this.f2108d, interfaceC0762c);
        cVar.f2106b = obj;
        return cVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((c) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Throwable {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f2105a;
        w3.i iVar = w3.i.f6729a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return iVar;
        }
        AbstractC0367g.M(obj);
        D d5 = (D) this.f2106b;
        e eVar = this.f2108d;
        int i5 = eVar.f2113b;
        if (i5 == -3) {
            i5 = -2;
        }
        E e = E.f1573c;
        I3.p dVar = new d(eVar, null);
        t tVar = new t(F.t(d5, eVar.f2112a), S3.m.a(i5, eVar.f2114c, 4), true, true);
        tVar.e0(e, tVar, dVar);
        this.f2105a = 1;
        Object objB = r.b(this.f2107c, tVar, true, this);
        if (objB != enumC0789a) {
            objB = iVar;
        }
        return objB == enumC0789a ? enumC0789a : iVar;
    }
}
