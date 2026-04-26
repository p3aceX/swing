package U3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class f extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2115a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f2116b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ g f2117c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public f(g gVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f2117c = gVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        f fVar = new f(this.f2117c, interfaceC0762c);
        fVar.f2116b = obj;
        return fVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((f) create((T3.e) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f2115a;
        w3.i iVar = w3.i.f6729a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            T3.e eVar = (T3.e) this.f2116b;
            this.f2115a = 1;
            Object objB = this.f2117c.f2118d.b(eVar, this);
            if (objB != enumC0789a) {
                objB = iVar;
            }
            if (objB == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return iVar;
    }
}
