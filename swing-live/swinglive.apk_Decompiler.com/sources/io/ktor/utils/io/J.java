package io.ktor.utils.io;

import Q3.InterfaceC0132h0;
import Q3.y0;

/* JADX INFO: loaded from: classes.dex */
public final class J implements A {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final com.google.android.gms.common.internal.r f4961a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final y0 f4962b;

    public J(com.google.android.gms.common.internal.r rVar, y0 y0Var) {
        this.f4961a = rVar;
        this.f4962b = y0Var;
    }

    @Override // io.ktor.utils.io.A
    public final InterfaceC0132h0 a() {
        return this.f4962b;
    }

    /* JADX WARN: Code restructure failed: missing block: B:27:0x008c, code lost:
    
        if (r7.f4961a.i(r0) == r1) goto L28;
     */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(A3.c r8) {
        /*
            r7 = this;
            boolean r0 = r8 instanceof io.ktor.utils.io.I
            if (r0 == 0) goto L13
            r0 = r8
            io.ktor.utils.io.I r0 = (io.ktor.utils.io.I) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            io.ktor.utils.io.I r0 = new io.ktor.utils.io.I
            r0.<init>(r7, r8)
        L18:
            java.lang.Object r8 = r0.f4959c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            r3 = 0
            r4 = 2
            r5 = 1
            if (r2 == 0) goto L3b
            if (r2 == r5) goto L33
            if (r2 != r4) goto L2b
            e1.AbstractC0367g.M(r8)
            goto L8f
        L2b:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r0)
            throw r8
        L33:
            int r2 = r0.f4958b
            java.util.Iterator r6 = r0.f4957a
            e1.AbstractC0367g.M(r8)
            goto L66
        L3b:
            e1.AbstractC0367g.M(r8)
            Q3.y0 r8 = r7.f4962b
            O3.c r2 = r8.p()
            O3.f r2 = (O3.f) r2
            java.util.Iterator r2 = r2.iterator()
        L4a:
            boolean r6 = r2.hasNext()
            if (r6 == 0) goto L5a
            java.lang.Object r6 = r2.next()
            Q3.h0 r6 = (Q3.InterfaceC0132h0) r6
            r6.a(r3)
            goto L4a
        L5a:
            O3.c r8 = r8.p()
            O3.f r8 = (O3.f) r8
            java.util.Iterator r8 = r8.iterator()
            r2 = 0
            r6 = r8
        L66:
            boolean r8 = r6.hasNext()
            if (r8 == 0) goto L82
            java.lang.Object r8 = r6.next()
            Q3.h0 r8 = (Q3.InterfaceC0132h0) r8
            r8.a(r3)
            r0.f4957a = r6
            r0.f4958b = r2
            r0.e = r5
            java.lang.Object r8 = r8.y(r0)
            if (r8 != r1) goto L66
            goto L8e
        L82:
            r0.f4957a = r3
            r0.e = r4
            com.google.android.gms.common.internal.r r8 = r7.f4961a
            java.lang.Object r8 = r8.i(r0)
            if (r8 != r1) goto L8f
        L8e:
            return r1
        L8f:
            w3.i r8 = w3.i.f6729a
            return r8
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.J.b(A3.c):java.lang.Object");
    }
}
