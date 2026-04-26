package A1;

import A3.j;
import I3.p;
import Q3.D;
import Q3.F;
import e1.AbstractC0367g;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class b extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f69a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f70b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ d f71c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public b(d dVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f71c = dVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        b bVar = new b(this.f71c, interfaceC0762c);
        bVar.f70b = obj;
        return bVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((b) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        D d5 = (D) this.f70b;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f69a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            d dVar = this.f71c;
            F.d(d5, new a(dVar, null));
            this.f70b = null;
            this.f69a = 1;
            if (dVar.a(this) == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return i.f6729a;
    }
}
