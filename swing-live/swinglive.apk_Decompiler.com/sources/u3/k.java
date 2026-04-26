package U3;

import J3.u;
import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public abstract class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0779j f2122a = new C0779j("NULL", 20);

    public static /* synthetic */ T3.d a(i iVar, R3.d dVar, int i4, S3.c cVar, int i5) {
        InterfaceC0767h interfaceC0767h = dVar;
        if ((i5 & 1) != 0) {
            interfaceC0767h = C0768i.f6945a;
        }
        if ((i5 & 2) != 0) {
            i4 = -3;
        }
        if ((i5 & 4) != 0) {
            cVar = S3.c.f1813a;
        }
        return iVar.d(interfaceC0767h, i4, cVar);
    }

    public static final Object b(InterfaceC0767h interfaceC0767h, Object obj, Object obj2, I3.p pVar, InterfaceC0762c interfaceC0762c) {
        Object objInvoke;
        Object objN = V3.b.n(interfaceC0767h, obj2);
        try {
            p pVar2 = new p(interfaceC0762c, interfaceC0767h);
            if (pVar == null) {
                objInvoke = e1.k.J(pVar, obj, pVar2);
            } else {
                u.a(2, pVar);
                objInvoke = pVar.invoke(obj, pVar2);
            }
            V3.b.g(interfaceC0767h, objN);
            if (objInvoke == EnumC0789a.f6999a) {
                J3.i.e(interfaceC0762c, "frame");
            }
            return objInvoke;
        } catch (Throwable th) {
            V3.b.g(interfaceC0767h, objN);
            throw th;
        }
    }
}
