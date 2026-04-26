package U3;

import S3.u;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2109a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f2110b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ e f2111c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public d(e eVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f2111c = eVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        d dVar = new d(this.f2111c, interfaceC0762c);
        dVar.f2110b = obj;
        return dVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((d) create((u) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f2109a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            u uVar = (u) this.f2110b;
            this.f2109a = 1;
            if (this.f2111c.a(uVar, this) == enumC0789a) {
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
