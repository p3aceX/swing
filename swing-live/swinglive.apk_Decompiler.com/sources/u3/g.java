package U3;

import S3.u;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class g extends e {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final T3.d f2118d;

    public g(T3.d dVar, InterfaceC0767h interfaceC0767h, int i4, S3.c cVar) {
        super(interfaceC0767h, i4, cVar);
        this.f2118d = dVar;
    }

    @Override // U3.e
    public final Object a(u uVar, InterfaceC0762c interfaceC0762c) {
        Object objB = this.f2118d.b(new o(uVar), interfaceC0762c);
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        w3.i iVar = w3.i.f6729a;
        if (objB != enumC0789a) {
            objB = iVar;
        }
        return objB == enumC0789a ? objB : iVar;
    }

    /* JADX WARN: Removed duplicated region for block: B:24:0x0071  */
    @Override // U3.e, T3.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(T3.e r6, y3.InterfaceC0762c r7) throws java.lang.Throwable {
        /*
            r5 = this;
            w3.i r0 = w3.i.f6729a
            int r1 = r5.f2113b
            r2 = -3
            if (r1 != r2) goto L71
            y3.h r1 = r7.getContext()
            java.lang.Boolean r2 = java.lang.Boolean.FALSE
            Q3.x r3 = new Q3.x
            r4 = 0
            r3.<init>(r4)
            y3.h r4 = r5.f2112a
            java.lang.Object r2 = r4.h(r2, r3)
            java.lang.Boolean r2 = (java.lang.Boolean) r2
            boolean r2 = r2.booleanValue()
            if (r2 != 0) goto L26
            y3.h r2 = r1.s(r4)
            goto L2b
        L26:
            r2 = 0
            y3.h r2 = Q3.F.j(r1, r4, r2)
        L2b:
            boolean r3 = J3.i.a(r2, r1)
            if (r3 == 0) goto L40
            T3.d r1 = r5.f2118d
            java.lang.Object r6 = r1.b(r6, r7)
            z3.a r7 = z3.EnumC0789a.f6999a
            if (r6 != r7) goto L3c
            goto L3d
        L3c:
            r6 = r0
        L3d:
            if (r6 != r7) goto L7a
            return r6
        L40:
            y3.d r3 = y3.C0763d.f6944a
            y3.f r4 = r2.i(r3)
            y3.f r1 = r1.i(r3)
            boolean r1 = J3.i.a(r4, r1)
            if (r1 == 0) goto L71
            y3.h r1 = r7.getContext()
            boolean r3 = r6 instanceof U3.o
            if (r3 != 0) goto L5e
            T3.l r3 = new T3.l
            r3.<init>(r6, r1)
            r6 = r3
        L5e:
            U3.f r1 = new U3.f
            r3 = 0
            r1.<init>(r5, r3)
            java.lang.Object r3 = V3.b.m(r2)
            java.lang.Object r6 = U3.k.b(r2, r6, r3, r1, r7)
            z3.a r7 = z3.EnumC0789a.f6999a
            if (r6 != r7) goto L7a
            return r6
        L71:
            java.lang.Object r6 = super.b(r6, r7)
            z3.a r7 = z3.EnumC0789a.f6999a
            if (r6 != r7) goto L7a
            return r6
        L7a:
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: U3.g.b(T3.e, y3.c):java.lang.Object");
    }

    @Override // U3.e
    public final e c(InterfaceC0767h interfaceC0767h, int i4, S3.c cVar) {
        return new g(this.f2118d, interfaceC0767h, i4, cVar);
    }

    @Override // U3.e
    public final String toString() {
        return this.f2118d + " -> " + super.toString();
    }
}
