package I;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: I.x, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0062x extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f737a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ I f738b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0062x(I i4, InterfaceC0762c interfaceC0762c) {
        super(1, interfaceC0762c);
        this.f738b = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new C0062x(this.f738b, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        return ((C0062x) create((InterfaceC0762c) obj)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f737a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return obj;
        }
        AbstractC0367g.M(obj);
        this.f737a = 1;
        Object objInvoke = this.f738b.invoke(this);
        return objInvoke == enumC0789a ? enumC0789a : objInvoke;
    }
}
