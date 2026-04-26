package r2;

import Q3.D;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class m extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6372a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ r f6373b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public m(r rVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6373b = rVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new m(this.f6373b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((m) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6372a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f6372a = 1;
            if (r.a(this.f6373b, true, this) == enumC0789a) {
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
