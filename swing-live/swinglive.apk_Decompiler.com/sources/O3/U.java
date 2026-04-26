package o3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class U extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6055a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f6056b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ V f6057c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public U(V v, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6057c = v;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        U u4 = new U(this.f6057c, interfaceC0762c);
        u4.f6056b = obj;
        return u4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((U) create((io.ktor.utils.io.K) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        io.ktor.utils.io.K k4 = (io.ktor.utils.io.K) this.f6056b;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6055a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            io.ktor.utils.io.o oVar = k4.f4963a;
            this.f6056b = null;
            this.f6055a = 1;
            if (V.d(this.f6057c, oVar, this) == enumC0789a) {
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
