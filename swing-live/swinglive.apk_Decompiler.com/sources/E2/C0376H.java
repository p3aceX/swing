package e2;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: e2.H, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0376H extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4032a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L f4033b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0376H(L l2, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4033b = l2;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new C0376H(this.f4033b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0376H) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4032a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            L l2 = this.f4033b;
            AbstractC0367g abstractC0367g = l2.f4050c;
            if (abstractC0367g == null) {
                return null;
            }
            r rVar = l2.f4053g;
            this.f4032a = 1;
            if (rVar.h(abstractC0367g, this) == enumC0789a) {
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
