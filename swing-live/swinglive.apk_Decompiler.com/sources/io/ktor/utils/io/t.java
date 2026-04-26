package io.ktor.utils.io;

import Q3.C0136j0;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class t extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0136j0 f5012a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Throwable f5013b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5014c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f5015d;
    public final /* synthetic */ A3.j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ C0449m f5016f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public t(I3.p pVar, C0449m c0449m, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.e = (A3.j) pVar;
        this.f5016f = c0449m;
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        t tVar = new t(this.e, this.f5016f, interfaceC0762c);
        tVar.f5015d = obj;
        return tVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((t) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:37:0x00c0 A[RETURN] */
    /* JADX WARN: Type inference failed for: r13v7, types: [A3.j, I3.p] */
    /* JADX WARN: Type inference failed for: r2v0, types: [int] */
    /* JADX WARN: Type inference failed for: r2v1, types: [Q3.q0] */
    /* JADX WARN: Type inference failed for: r2v3, types: [Q3.q0] */
    /* JADX WARN: Type inference failed for: r2v5 */
    /* JADX WARN: Type inference failed for: r2v6 */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r13) throws java.lang.Throwable {
        /*
            r12 = this;
            java.lang.Object r0 = r12.f5015d
            Q3.D r0 = (Q3.D) r0
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r12.f5014c
            io.ktor.utils.io.m r3 = r12.f5016f
            w3.i r4 = w3.i.f6729a
            r5 = 4
            r6 = 3
            r7 = 2
            r8 = 1
            r9 = 0
            if (r2 == 0) goto L37
            if (r2 == r8) goto L2f
            if (r2 == r7) goto L2a
            if (r2 == r6) goto L2a
            if (r2 == r5) goto L23
            java.lang.IllegalStateException r13 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r13.<init>(r0)
            throw r13
        L23:
            java.lang.Throwable r0 = r12.f5013b
            e1.AbstractC0367g.M(r13)
            goto Lc1
        L2a:
            e1.AbstractC0367g.M(r13)
            goto Lad
        L2f:
            Q3.j0 r2 = r12.f5012a
            e1.AbstractC0367g.M(r13)     // Catch: java.lang.Throwable -> L35
            goto L63
        L35:
            r13 = move-exception
            goto L90
        L37:
            e1.AbstractC0367g.M(r13)
            y3.h r13 = r0.n()
            Q3.h0 r13 = Q3.F.m(r13)
            Q3.j0 r2 = new Q3.j0
            r2.<init>(r13)
            A3.j r13 = r12.e     // Catch: java.lang.Throwable -> L35
            io.ktor.utils.io.K r10 = new io.ktor.utils.io.K     // Catch: java.lang.Throwable -> L35
            y3.h r11 = r0.n()     // Catch: java.lang.Throwable -> L35
            y3.h r11 = r11.s(r2)     // Catch: java.lang.Throwable -> L35
            r10.<init>(r3, r11)     // Catch: java.lang.Throwable -> L35
            r12.f5015d = r0     // Catch: java.lang.Throwable -> L35
            r12.f5012a = r2     // Catch: java.lang.Throwable -> L35
            r12.f5014c = r8     // Catch: java.lang.Throwable -> L35
            java.lang.Object r13 = r13.invoke(r10, r12)     // Catch: java.lang.Throwable -> L35
            if (r13 != r1) goto L63
            goto Lc0
        L63:
            r2.O(r4)     // Catch: java.lang.Throwable -> L35
            y3.h r13 = r0.n()     // Catch: java.lang.Throwable -> L35
            Q3.h0 r13 = Q3.F.m(r13)     // Catch: java.lang.Throwable -> L35
            boolean r13 = r13.isCancelled()     // Catch: java.lang.Throwable -> L35
            if (r13 == 0) goto L83
            y3.h r13 = r0.n()     // Catch: java.lang.Throwable -> L35
            Q3.h0 r13 = Q3.F.m(r13)     // Catch: java.lang.Throwable -> L35
            java.util.concurrent.CancellationException r13 = r13.f()     // Catch: java.lang.Throwable -> L35
            r3.t(r13)     // Catch: java.lang.Throwable -> L35
        L83:
            r12.f5015d = r9
            r12.f5012a = r9
            r12.f5014c = r7
            java.lang.Object r13 = r2.y(r12)
            if (r13 != r1) goto Lad
            goto Lc0
        L90:
            java.lang.String r0 = "Exception thrown while reading from channel"
            java.util.concurrent.CancellationException r7 = new java.util.concurrent.CancellationException     // Catch: java.lang.Throwable -> Lb0
            r7.<init>(r0)     // Catch: java.lang.Throwable -> Lb0
            r7.initCause(r13)     // Catch: java.lang.Throwable -> Lb0
            r2.v(r7)     // Catch: java.lang.Throwable -> Lb0
            r3.t(r13)     // Catch: java.lang.Throwable -> Lb0
            r12.f5015d = r9
            r12.f5012a = r9
            r12.f5014c = r6
            java.lang.Object r13 = r2.y(r12)
            if (r13 != r1) goto Lad
            goto Lc0
        Lad:
            return r4
        Lae:
            r0 = r13
            goto Lb2
        Lb0:
            r13 = move-exception
            goto Lae
        Lb2:
            r12.f5015d = r9
            r12.f5012a = r9
            r12.f5013b = r0
            r12.f5014c = r5
            java.lang.Object r13 = r2.y(r12)
            if (r13 != r1) goto Lc1
        Lc0:
            return r1
        Lc1:
            throw r0
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.t.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
