package I;

import e1.AbstractC0367g;
import java.util.List;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: I.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0044e extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f647a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f648b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ List f649c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0044e(List list, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f649c = list;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0044e c0044e = new C0044e(this.f649c, interfaceC0762c);
        c0044e.f648b = obj;
        return c0044e;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0044e) create((C0051l) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f647a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            C0051l c0051l = (C0051l) this.f648b;
            this.f647a = 1;
            if (H0.a.b(this.f649c, c0051l, this) == enumC0789a) {
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
