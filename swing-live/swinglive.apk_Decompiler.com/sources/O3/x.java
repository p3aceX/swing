package o3;

import io.ktor.utils.io.C0449m;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class x extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6164a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0588D f6165b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0449m f6166c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public x(C0449m c0449m, C0588D c0588d, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6165b = c0588d;
        this.f6166c = c0449m;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new x(this.f6166c, this.f6165b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((x) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:22:0x005f, code lost:
    
        if (r3.i(r8) == r0) goto L23;
     */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r9) {
        /*
            r8 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r8.f6164a
            w3.i r2 = w3.i.f6729a
            io.ktor.utils.io.m r3 = r8.f6166c
            r4 = 2
            o3.D r5 = r8.f6165b
            r6 = 1
            if (r1 == 0) goto L24
            if (r1 == r6) goto L20
            if (r1 != r4) goto L18
            e1.AbstractC0367g.M(r9)     // Catch: java.lang.Throwable -> L16
            goto L62
        L16:
            r9 = move-exception
            goto L6a
        L18:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r0)
            throw r9
        L20:
            e1.AbstractC0367g.M(r9)     // Catch: java.lang.Throwable -> L16
            goto L59
        L24:
            e1.AbstractC0367g.M(r9)
            o3.M r9 = o3.M.e     // Catch: java.lang.Throwable -> L16
            Z3.a r1 = new Z3.a     // Catch: java.lang.Throwable -> L16
            r1.<init>()     // Catch: java.lang.Throwable -> L16
            X.N r7 = o3.EnumC0606n.f6121b     // Catch: java.lang.Throwable -> L16
            byte r7 = (byte) r6     // Catch: java.lang.Throwable -> L16
            r1.n(r7)     // Catch: java.lang.Throwable -> L16
            X.N r7 = o3.EnumC0607o.f6125b     // Catch: java.lang.Throwable -> L16
            r7 = 0
            byte r7 = (byte) r7     // Catch: java.lang.Throwable -> L16
            r1.n(r7)     // Catch: java.lang.Throwable -> L16
            o3.K r7 = new o3.K     // Catch: java.lang.Throwable -> L16
            r7.<init>(r9, r1)     // Catch: java.lang.Throwable -> L16
            boolean r9 = r5.f5993o     // Catch: java.lang.Throwable -> L16
            if (r9 == 0) goto L50
            w3.f r9 = r5.f5991m     // Catch: java.lang.Throwable -> L16
            java.lang.Object r9 = r9.a()     // Catch: java.lang.Throwable -> L16
            p3.f r9 = (p3.InterfaceC0623f) r9     // Catch: java.lang.Throwable -> L16
            o3.K r7 = r9.b(r7)     // Catch: java.lang.Throwable -> L16
        L50:
            r8.f6164a = r6     // Catch: java.lang.Throwable -> L16
            java.lang.Object r9 = e1.k.M(r3, r7, r8)     // Catch: java.lang.Throwable -> L16
            if (r9 != r0) goto L59
            goto L61
        L59:
            r8.f6164a = r4     // Catch: java.lang.Throwable -> L16
            java.lang.Object r9 = r3.i(r8)     // Catch: java.lang.Throwable -> L16
            if (r9 != r0) goto L62
        L61:
            return r0
        L62:
            Q3.t r9 = r5.f5988c
            Q3.j0 r9 = (Q3.C0136j0) r9
            r9.O(r2)
            return r2
        L6a:
            Q3.t r0 = r5.f5988c
            Q3.j0 r0 = (Q3.C0136j0) r0
            r0.O(r2)
            throw r9
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.x.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
