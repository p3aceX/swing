package I;

import Q3.C0146s;
import e1.AbstractC0367g;
import java.util.concurrent.atomic.AtomicInteger;
import y3.InterfaceC0762c;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class M extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f580a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f581b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Q f582c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ A3.j f583d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public M(Q q4, I3.p pVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f582c = q4;
        this.f583d = (A3.j) pVar;
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        M m4 = new M(this.f582c, this.f583d, interfaceC0762c);
        m4.f581b = obj;
        return m4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((M) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Type inference failed for: r6v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Throwable {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f580a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
            return obj;
        }
        AbstractC0367g.M(obj);
        Q3.D d5 = (Q3.D) this.f581b;
        C0146s c0146sA = Q3.F.a();
        Q q4 = this.f582c;
        d0 d0Var = new d0(this.f583d, c0146sA, q4.f603n.v(), d5.n());
        C0053n c0053n = q4.f607r;
        Object objK = ((S3.e) c0053n.f708d).k(d0Var);
        if (objK instanceof S3.k) {
            S3.k kVar = (S3.k) objK;
            if (kVar == null) {
                kVar = null;
            }
            Throwable th = kVar != null ? kVar.f1852a : null;
            if (th == null) {
                throw new S3.p("Channel was closed normally");
            }
            throw th;
        }
        if (objK instanceof S3.l) {
            throw new IllegalStateException("Check failed.");
        }
        if (((AtomicInteger) ((C0779j) c0053n.e).f6969b).getAndIncrement() == 0) {
            Q3.F.s((Q3.D) c0053n.f706b, null, new h0(c0053n, null), 3);
        }
        this.f580a = 1;
        Object objC0 = c0146sA.c0(this);
        return objC0 == enumC0789a ? enumC0789a : objC0;
    }
}
