package I;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class K extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f573a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ A3.j f574b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0043d f575c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public K(I3.p pVar, C0043d c0043d, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f574b = (A3.j) pVar;
        this.f575c = c0043d;
    }

    /* JADX WARN: Type inference failed for: r0v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new K(this.f574b, this.f575c, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((K) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Type inference failed for: r1v1, types: [A3.j, I3.p] */
    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f573a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return obj;
        }
        AbstractC0367g.M(obj);
        Object obj2 = this.f575c.f641b;
        this.f573a = 1;
        Object objInvoke = this.f574b.invoke(obj2, this);
        return objInvoke == enumC0789a ? enumC0789a : objInvoke;
    }
}
