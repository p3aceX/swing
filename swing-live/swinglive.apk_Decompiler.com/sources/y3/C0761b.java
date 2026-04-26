package y3;

import I3.p;
import Q3.C0151x;
import java.io.Serializable;

/* JADX INFO: renamed from: y3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0761b implements InterfaceC0767h, Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final InterfaceC0767h f6942a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final InterfaceC0765f f6943b;

    public C0761b(InterfaceC0765f interfaceC0765f, InterfaceC0767h interfaceC0767h) {
        J3.i.e(interfaceC0767h, "left");
        J3.i.e(interfaceC0765f, "element");
        this.f6942a = interfaceC0767h;
        this.f6943b = interfaceC0765f;
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h c(InterfaceC0766g interfaceC0766g) {
        J3.i.e(interfaceC0766g, "key");
        InterfaceC0765f interfaceC0765f = this.f6943b;
        InterfaceC0765f interfaceC0765fI = interfaceC0765f.i(interfaceC0766g);
        InterfaceC0767h interfaceC0767h = this.f6942a;
        if (interfaceC0765fI != null) {
            return interfaceC0767h;
        }
        InterfaceC0767h interfaceC0767hC = interfaceC0767h.c(interfaceC0766g);
        return interfaceC0767hC == interfaceC0767h ? this : interfaceC0767hC == C0768i.f6945a ? interfaceC0765f : new C0761b(interfaceC0765f, interfaceC0767hC);
    }

    public final boolean equals(Object obj) {
        boolean zA;
        if (this == obj) {
            return true;
        }
        if (obj instanceof C0761b) {
            C0761b c0761b = (C0761b) obj;
            c0761b.getClass();
            int i4 = 2;
            C0761b c0761b2 = c0761b;
            int i5 = 2;
            while (true) {
                InterfaceC0767h interfaceC0767h = c0761b2.f6942a;
                c0761b2 = interfaceC0767h instanceof C0761b ? (C0761b) interfaceC0767h : null;
                if (c0761b2 == null) {
                    break;
                }
                i5++;
            }
            C0761b c0761b3 = this;
            while (true) {
                InterfaceC0767h interfaceC0767h2 = c0761b3.f6942a;
                c0761b3 = interfaceC0767h2 instanceof C0761b ? (C0761b) interfaceC0767h2 : null;
                if (c0761b3 == null) {
                    break;
                }
                i4++;
            }
            if (i5 == i4) {
                C0761b c0761b4 = this;
                while (true) {
                    InterfaceC0765f interfaceC0765f = c0761b4.f6943b;
                    if (!J3.i.a(c0761b.i(interfaceC0765f.getKey()), interfaceC0765f)) {
                        zA = false;
                        break;
                    }
                    InterfaceC0767h interfaceC0767h3 = c0761b4.f6942a;
                    if (!(interfaceC0767h3 instanceof C0761b)) {
                        J3.i.c(interfaceC0767h3, "null cannot be cast to non-null type kotlin.coroutines.CoroutineContext.Element");
                        InterfaceC0765f interfaceC0765f2 = (InterfaceC0765f) interfaceC0767h3;
                        zA = J3.i.a(c0761b.i(interfaceC0765f2.getKey()), interfaceC0765f2);
                        break;
                    }
                    c0761b4 = (C0761b) interfaceC0767h3;
                }
                if (zA) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override // y3.InterfaceC0767h
    public final Object h(Object obj, p pVar) {
        return pVar.invoke(this.f6942a.h(obj, pVar), this.f6943b);
    }

    public final int hashCode() {
        return this.f6943b.hashCode() + this.f6942a.hashCode();
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0765f i(InterfaceC0766g interfaceC0766g) {
        J3.i.e(interfaceC0766g, "key");
        C0761b c0761b = this;
        while (true) {
            InterfaceC0765f interfaceC0765fI = c0761b.f6943b.i(interfaceC0766g);
            if (interfaceC0765fI != null) {
                return interfaceC0765fI;
            }
            InterfaceC0767h interfaceC0767h = c0761b.f6942a;
            if (!(interfaceC0767h instanceof C0761b)) {
                return interfaceC0767h.i(interfaceC0766g);
            }
            c0761b = (C0761b) interfaceC0767h;
        }
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h s(InterfaceC0767h interfaceC0767h) {
        J3.i.e(interfaceC0767h, "context");
        return interfaceC0767h == C0768i.f6945a ? this : (InterfaceC0767h) interfaceC0767h.h(this, new C0151x(10));
    }

    public final String toString() {
        return "[" + ((String) h("", new C0151x(9))) + ']';
    }
}
