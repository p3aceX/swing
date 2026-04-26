package I;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class E extends A3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Throwable f548a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f549b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Q f550c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public E(Q q4, InterfaceC0762c interfaceC0762c) {
        super(1, interfaceC0762c);
        this.f550c = q4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        return new E(this.f550c, interfaceC0762c);
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        return ((E) create((InterfaceC0762c) obj)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Throwable th;
        m0 e0Var;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f549b;
        Q q4 = this.f550c;
        try {
        } catch (Throwable th2) {
            l0 l0VarF = q4.f();
            this.f548a = th2;
            this.f549b = 2;
            Integer numA = l0VarF.a();
            if (numA != enumC0789a) {
                th = th2;
                obj = numA;
            }
            return enumC0789a;
        }
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f549b = 1;
            obj = Q.e(q4, true, this);
            if (obj == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                if (i4 != 2) {
                    throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                }
                th = this.f548a;
                AbstractC0367g.M(obj);
                e0Var = new e0(((Number) obj).intValue(), th);
                return new w3.c(e0Var, Boolean.TRUE);
            }
            AbstractC0367g.M(obj);
        }
        e0Var = (m0) obj;
        return new w3.c(e0Var, Boolean.TRUE);
    }
}
