package Q3;

import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.CancellationException;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public abstract class N extends X3.i {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f1595c;

    public N(int i4) {
        super(0L, false);
        this.f1595c = i4;
    }

    public abstract InterfaceC0762c c();

    public Throwable d(Object obj) {
        C0149v c0149v = obj instanceof C0149v ? (C0149v) obj : null;
        if (c0149v != null) {
            return c0149v.f1666a;
        }
        return null;
    }

    public final void g(Throwable th) throws IllegalAccessException, InvocationTargetException {
        F.o(new H3.a("Fatal exception in coroutines machinery for " + this + ". Please read KDoc to 'handleFatalException' method and report this incident to maintainers", th), c().getContext());
    }

    public abstract Object h();

    @Override // java.lang.Runnable
    public final void run() throws IllegalAccessException, InvocationTargetException {
        try {
            InterfaceC0762c interfaceC0762cC = c();
            J3.i.c(interfaceC0762cC, "null cannot be cast to non-null type kotlinx.coroutines.internal.DispatchedContinuation<T of kotlinx.coroutines.DispatchedTask>");
            V3.g gVar = (V3.g) interfaceC0762cC;
            A3.c cVar = gVar.e;
            Object obj = gVar.f2226m;
            InterfaceC0767h context = cVar.getContext();
            Object objN = V3.b.n(context, obj);
            InterfaceC0132h0 interfaceC0132h0 = null;
            I0 i0A = objN != V3.b.f2215d ? F.A(cVar, context, objN) : null;
            try {
                InterfaceC0767h context2 = cVar.getContext();
                Object objH = h();
                Throwable thD = d(objH);
                if (thD == null) {
                    int i4 = this.f1595c;
                    boolean z4 = true;
                    if (i4 != 1 && i4 != 2) {
                        z4 = false;
                    }
                    if (z4) {
                        interfaceC0132h0 = (InterfaceC0132h0) context2.i(B.f1565b);
                    }
                }
                if (interfaceC0132h0 != null && !interfaceC0132h0.b()) {
                    CancellationException cancellationExceptionF = interfaceC0132h0.f();
                    b(cancellationExceptionF);
                    cVar.resumeWith(AbstractC0367g.h(cancellationExceptionF));
                } else if (thD != null) {
                    cVar.resumeWith(AbstractC0367g.h(thD));
                } else {
                    cVar.resumeWith(f(objH));
                }
                if (i0A == null || i0A.g0()) {
                    V3.b.g(context, objN);
                }
            } catch (Throwable th) {
                if (i0A == null || i0A.g0()) {
                    V3.b.g(context, objN);
                }
                throw th;
            }
        } catch (L e) {
            F.o(e.f1593a, c().getContext());
        } catch (Throwable th2) {
            g(th2);
        }
    }

    public void b(CancellationException cancellationException) {
    }

    public Object f(Object obj) {
        return obj;
    }
}
