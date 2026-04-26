package Q3;

import z3.EnumC0789a;

/* JADX INFO: renamed from: Q3.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0146s extends q0 implements r {
    public final Object c0(A3.j jVar) throws Throwable {
        Object objZ;
        int i4 = 2;
        while (true) {
            Object obj = q0.f1656a.get(this);
            if (obj instanceof InterfaceC0124d0) {
                if (Y(obj) >= 0) {
                    m0 m0Var = new m0(e1.k.w(jVar), this);
                    m0Var.r();
                    m0Var.u(new C0133i(F.p(this, true, new S(m0Var, i4)), i4));
                    objZ = m0Var.q();
                    EnumC0789a enumC0789a = EnumC0789a.f6999a;
                    break;
                }
            } else {
                if (obj instanceof C0149v) {
                    throw ((C0149v) obj).f1666a;
                }
                objZ = F.z(obj);
            }
        }
        EnumC0789a enumC0789a2 = EnumC0789a.f6999a;
        return objZ;
    }

    public final boolean d0(Throwable th) {
        return O(new C0149v(th, false));
    }
}
