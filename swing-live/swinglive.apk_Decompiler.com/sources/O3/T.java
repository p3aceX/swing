package o3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class T extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6052a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f6053b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ V f6054c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public T(V v, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6054c = v;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        T t4 = new T(this.f6054c, interfaceC0762c);
        t4.f6053b = obj;
        return t4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((T) create((io.ktor.utils.io.M) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        io.ktor.utils.io.M m4 = (io.ktor.utils.io.M) this.f6053b;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6052a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            io.ktor.utils.io.v vVar = m4.f4966a;
            this.f6053b = null;
            this.f6052a = 1;
            if (V.b(this.f6054c, vVar, this) == enumC0789a) {
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
