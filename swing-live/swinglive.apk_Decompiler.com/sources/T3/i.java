package T3;

import I.C0057s;

/* JADX INFO: loaded from: classes.dex */
public final class i implements d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ B.k f2037a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0057s f2038b;

    public i(B.k kVar, C0057s c0057s) {
        this.f2037a = kVar;
        this.f2038b = c0057s;
    }

    /* JADX WARN: Removed duplicated region for block: B:35:0x007b  */
    /* JADX WARN: Removed duplicated region for block: B:56:? A[RETURN, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // T3.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(T3.e r9, y3.InterfaceC0762c r10) throws java.lang.Throwable {
        /*
            r8 = this;
            boolean r0 = r10 instanceof T3.h
            if (r0 == 0) goto L13
            r0 = r10
            T3.h r0 = (T3.h) r0
            int r1 = r0.f2034b
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f2034b = r1
            goto L18
        L13:
            T3.h r0 = new T3.h
            r0.<init>(r8, r10)
        L18:
            java.lang.Object r10 = r0.f2033a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f2034b
            r3 = 3
            r4 = 2
            r5 = 1
            r6 = 0
            if (r2 == 0) goto L50
            if (r2 == r5) goto L44
            if (r2 == r4) goto L3c
            if (r2 != r3) goto L34
            java.lang.Object r9 = r0.f2036d
            U3.l r9 = (U3.l) r9
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L32
            goto L7c
        L32:
            r10 = move-exception
            goto L86
        L34:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r10 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r10)
            throw r9
        L3c:
            java.lang.Object r9 = r0.f2036d
            java.lang.Throwable r9 = (java.lang.Throwable) r9
            e1.AbstractC0367g.M(r10)
            goto La0
        L44:
            T3.e r9 = r0.e
            java.lang.Object r2 = r0.f2036d
            T3.i r2 = (T3.i) r2
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L4e
            goto L63
        L4e:
            r9 = move-exception
            goto L8c
        L50:
            e1.AbstractC0367g.M(r10)
            B.k r10 = r8.f2037a     // Catch: java.lang.Throwable -> L8a
            r0.f2036d = r8     // Catch: java.lang.Throwable -> L8a
            r0.e = r9     // Catch: java.lang.Throwable -> L8a
            r0.f2034b = r5     // Catch: java.lang.Throwable -> L8a
            java.lang.Object r10 = r10.b(r9, r0)     // Catch: java.lang.Throwable -> L8a
            if (r10 != r1) goto L62
            goto L9f
        L62:
            r2 = r8
        L63:
            U3.l r10 = new U3.l
            y3.h r4 = r0.getContext()
            r10.<init>(r9, r4)
            I.s r9 = r2.f2038b     // Catch: java.lang.Throwable -> L82
            r0.f2036d = r10     // Catch: java.lang.Throwable -> L82
            r0.e = r6     // Catch: java.lang.Throwable -> L82
            r0.f2034b = r3     // Catch: java.lang.Throwable -> L82
            java.lang.Object r9 = r9.b(r10, r6, r0)     // Catch: java.lang.Throwable -> L82
            if (r9 != r1) goto L7b
            goto L9f
        L7b:
            r9 = r10
        L7c:
            r9.releaseIntercepted()
            w3.i r9 = w3.i.f6729a
            return r9
        L82:
            r9 = move-exception
            r7 = r10
            r10 = r9
            r9 = r7
        L86:
            r9.releaseIntercepted()
            throw r10
        L8a:
            r9 = move-exception
            r2 = r8
        L8c:
            T3.t r10 = new T3.t
            r10.<init>(r9)
            I.s r2 = r2.f2038b
            r0.f2036d = r9
            r0.e = r6
            r0.f2034b = r4
            java.lang.Object r10 = T3.r.a(r10, r2, r9, r0)
            if (r10 != r1) goto La0
        L9f:
            return r1
        La0:
            throw r9
        */
        throw new UnsupportedOperationException("Method not decompiled: T3.i.b(T3.e, y3.c):java.lang.Object");
    }
}
