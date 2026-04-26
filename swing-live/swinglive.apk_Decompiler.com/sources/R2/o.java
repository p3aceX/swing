package r2;

import Q3.D;
import e1.AbstractC0367g;
import m1.C0553h;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class o extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6378a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ r f6379b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public o(r rVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6379b = rVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new o(this.f6379b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((o) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6378a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            r rVar = this.f6379b;
            i iVar = rVar.f6390c;
            C0553h c0553h = rVar.e;
            this.f6378a = 1;
            if (iVar.h(c0553h, this) == enumC0789a) {
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
