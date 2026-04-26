package U3;

import Q3.C0151x;
import Q3.F;
import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class l extends A3.c implements T3.e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final T3.e f2123a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final InterfaceC0767h f2124b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f2125c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public InterfaceC0767h f2126d;
    public InterfaceC0762c e;

    public l(T3.e eVar, InterfaceC0767h interfaceC0767h) {
        super(j.f2121a, C0768i.f6945a);
        this.f2123a = eVar;
        this.f2124b = interfaceC0767h;
        this.f2125c = ((Number) interfaceC0767h.h(0, new C0151x(3))).intValue();
    }

    @Override // T3.e
    public final Object c(Object obj, InterfaceC0762c interfaceC0762c) {
        try {
            Object objF = f(interfaceC0762c, obj);
            return objF == EnumC0789a.f6999a ? objF : w3.i.f6729a;
        } catch (Throwable th) {
            this.f2126d = new h(th, interfaceC0762c.getContext());
            throw th;
        }
    }

    public final Object f(InterfaceC0762c interfaceC0762c, Object obj) {
        InterfaceC0767h context = interfaceC0762c.getContext();
        F.i(context);
        InterfaceC0767h interfaceC0767h = this.f2126d;
        if (interfaceC0767h != context) {
            if (interfaceC0767h instanceof h) {
                throw new IllegalStateException(P3.f.p0("\n            Flow exception transparency is violated:\n                Previous 'emit' call has thrown exception " + ((h) interfaceC0767h).f2120b + ", but then emission attempt of value '" + obj + "' has been detected.\n                Emissions from 'catch' blocks are prohibited in order to avoid unspecified behaviour, 'Flow.catch' operator can be used instead.\n                For a more detailed explanation, please refer to Flow documentation.\n            ").toString());
            }
            if (((Number) context.h(0, new P3.l(this, 2))).intValue() != this.f2125c) {
                throw new IllegalStateException(("Flow invariant is violated:\n\t\tFlow was collected in " + this.f2124b + ",\n\t\tbut emission happened in " + context + ".\n\t\tPlease refer to 'flow' documentation or use 'flowOn' instead").toString());
            }
            this.f2126d = context;
        }
        this.e = interfaceC0762c;
        m mVar = n.f2128a;
        T3.e eVar = this.f2123a;
        J3.i.c(eVar, "null cannot be cast to non-null type kotlinx.coroutines.flow.FlowCollector<kotlin.Any?>");
        mVar.getClass();
        Object objC = eVar.c(obj, this);
        if (!J3.i.a(objC, EnumC0789a.f6999a)) {
            this.e = null;
        }
        return objC;
    }

    @Override // A3.a, A3.d
    public final A3.d getCallerFrame() {
        InterfaceC0762c interfaceC0762c = this.e;
        if (interfaceC0762c instanceof A3.d) {
            return (A3.d) interfaceC0762c;
        }
        return null;
    }

    @Override // A3.c, y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        InterfaceC0767h interfaceC0767h = this.f2126d;
        return interfaceC0767h == null ? C0768i.f6945a : interfaceC0767h;
    }

    @Override // A3.a
    public final StackTraceElement getStackTraceElement() {
        return null;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Throwable thA = w3.e.a(obj);
        if (thA != null) {
            this.f2126d = new h(thA, getContext());
        }
        InterfaceC0762c interfaceC0762c = this.e;
        if (interfaceC0762c != null) {
            interfaceC0762c.resumeWith(obj);
        }
        return EnumC0789a.f6999a;
    }
}
