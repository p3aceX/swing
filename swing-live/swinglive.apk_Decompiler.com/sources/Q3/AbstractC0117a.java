package Q3;

import a.AbstractC0184a;
import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: renamed from: Q3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0117a extends q0 implements InterfaceC0762c, D {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final InterfaceC0767h f1612c;

    public AbstractC0117a(InterfaceC0767h interfaceC0767h, boolean z4, boolean z5) {
        super(z5);
        if (z4) {
            L((InterfaceC0132h0) interfaceC0767h.i(B.f1565b));
        }
        this.f1612c = interfaceC0767h.s(this);
    }

    @Override // Q3.q0
    public final String A() {
        return getClass().getSimpleName().concat(" was cancelled");
    }

    @Override // Q3.q0
    public final void K(A0.b bVar) throws IllegalAccessException, InvocationTargetException {
        F.o(bVar, this.f1612c);
    }

    @Override // Q3.q0
    public final void U(Object obj) {
        if (!(obj instanceof C0149v)) {
            d0(obj);
        } else {
            C0149v c0149v = (C0149v) obj;
            c0(c0149v.f1666a, C0149v.f1665b.get(c0149v) == 1);
        }
    }

    public final void e0(E e, AbstractC0117a abstractC0117a, I3.p pVar) {
        Object objInvoke;
        int iOrdinal = e.ordinal();
        w3.i iVar = w3.i.f6729a;
        if (iOrdinal == 0) {
            try {
                V3.b.h(iVar, e1.k.w(e1.k.l(pVar, abstractC0117a, this)));
                return;
            } catch (Throwable th) {
                AbstractC0184a.B(this, th);
                throw null;
            }
        }
        if (iOrdinal != 1) {
            if (iOrdinal == 2) {
                J3.i.e(pVar, "<this>");
                e1.k.w(e1.k.l(pVar, abstractC0117a, this)).resumeWith(iVar);
                return;
            }
            if (iOrdinal != 3) {
                throw new A0.b();
            }
            try {
                InterfaceC0767h interfaceC0767h = this.f1612c;
                Object objN = V3.b.n(interfaceC0767h, null);
                try {
                    if (pVar instanceof A3.a) {
                        J3.u.a(2, pVar);
                        objInvoke = pVar.invoke(abstractC0117a, this);
                    } else {
                        objInvoke = e1.k.J(pVar, abstractC0117a, this);
                    }
                    V3.b.g(interfaceC0767h, objN);
                    if (objInvoke != EnumC0789a.f6999a) {
                        resumeWith(objInvoke);
                    }
                } catch (Throwable th2) {
                    V3.b.g(interfaceC0767h, objN);
                    throw th2;
                }
            } catch (Throwable th3) {
                th = th3;
                if (th instanceof L) {
                    th = ((L) th).f1593a;
                }
                resumeWith(AbstractC0367g.h(th));
            }
        }
    }

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        return this.f1612c;
    }

    @Override // Q3.D
    public final InterfaceC0767h n() {
        return this.f1612c;
    }

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) {
        Throwable thA = w3.e.a(obj);
        if (thA != null) {
            obj = new C0149v(thA, false);
        }
        Object objP = P(obj);
        if (objP == F.e) {
            return;
        }
        t(objP);
    }

    public void d0(Object obj) {
    }

    public void c0(Throwable th, boolean z4) {
    }
}
