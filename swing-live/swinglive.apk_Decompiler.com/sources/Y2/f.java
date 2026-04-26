package y2;

import Q3.D;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class f extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6877a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ g f6878b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public f(g gVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6878b = gVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new f(this.f6878b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((f) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:11:0x0022  */
    /* JADX WARN: Removed duplicated region for block: B:15:0x0037  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:12:0x002a -> B:14:0x002d). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r7) {
        /*
            r6 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r6.f6877a
            y2.g r2 = r6.f6878b
            r3 = 1
            if (r1 == 0) goto L17
            if (r1 != r3) goto Lf
            e1.AbstractC0367g.M(r7)
            goto L2d
        Lf:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r0)
            throw r7
        L17:
            e1.AbstractC0367g.M(r7)
        L1a:
            java.util.concurrent.atomic.AtomicBoolean r7 = r2.f6892j
            boolean r7 = r7.get()
            if (r7 == 0) goto L37
            r6.f6877a = r3
            r4 = 1000(0x3e8, double:4.94E-321)
            java.lang.Object r7 = Q3.F.h(r4, r6)
            if (r7 != r0) goto L2d
            return r0
        L2d:
            M1.b r7 = r2.f6886c
            y2.l r1 = r2.d()
            r7.invoke(r1)
            goto L1a
        L37:
            w3.i r7 = w3.i.f6729a
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: y2.f.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
