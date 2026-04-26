package e2;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: e2.F, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0374F extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4026a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L f4027b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0374F(L l2, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4027b = l2;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0374F(this.f4027b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0374F) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4026a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f4026a = 1;
            if (L.a(this.f4027b, true, this) == enumC0789a) {
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
