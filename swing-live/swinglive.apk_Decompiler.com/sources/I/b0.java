package I;

/* JADX INFO: loaded from: classes.dex */
public final class b0 extends T {
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(java.lang.Object r7, A3.c r8) throws java.lang.IllegalAccessException, java.io.IOException, java.lang.reflect.InvocationTargetException {
        /*
            r6 = this;
            boolean r0 = r8 instanceof I.a0
            if (r0 == 0) goto L13
            r0 = r8
            I.a0 r0 = (I.a0) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            I.a0 r0 = new I.a0
            r0.<init>(r6, r8)
        L18:
            java.lang.Object r8 = r0.f638c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            w3.i r3 = w3.i.f6729a
            r4 = 1
            if (r2 == 0) goto L37
            if (r2 != r4) goto L2f
            java.io.FileOutputStream r7 = r0.f637b
            java.io.FileOutputStream r0 = r0.f636a
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Throwable -> L2d
            goto L5e
        L2d:
            r7 = move-exception
            goto L6e
        L2f:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L37:
            e1.AbstractC0367g.M(r8)
            java.util.concurrent.atomic.AtomicBoolean r8 = r6.f613b
            boolean r8 = r8.get()
            if (r8 != 0) goto L74
            java.io.FileOutputStream r8 = new java.io.FileOutputStream
            java.io.File r2 = r6.f612a
            r8.<init>(r2)
            L.g r2 = L.g.f868a     // Catch: java.lang.Throwable -> L6c
            I.o0 r5 = new I.o0     // Catch: java.lang.Throwable -> L6c
            r5.<init>(r8)     // Catch: java.lang.Throwable -> L6c
            r0.f636a = r8     // Catch: java.lang.Throwable -> L6c
            r0.f637b = r8     // Catch: java.lang.Throwable -> L6c
            r0.e = r4     // Catch: java.lang.Throwable -> L6c
            r2.b(r7, r5)     // Catch: java.lang.Throwable -> L6c
            if (r3 != r1) goto L5c
            return r1
        L5c:
            r7 = r8
            r0 = r7
        L5e:
            java.io.FileDescriptor r7 = r7.getFD()     // Catch: java.lang.Throwable -> L2d
            r7.sync()     // Catch: java.lang.Throwable -> L2d
            r7 = 0
            H0.a.d(r0, r7)
            return r3
        L6a:
            r0 = r8
            goto L6e
        L6c:
            r7 = move-exception
            goto L6a
        L6e:
            throw r7     // Catch: java.lang.Throwable -> L6f
        L6f:
            r8 = move-exception
            H0.a.d(r0, r7)
            throw r8
        L74:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "This scope has already been closed."
            r7.<init>(r8)
            throw r7
        */
        throw new UnsupportedOperationException("Method not decompiled: I.b0.b(java.lang.Object, A3.c):java.lang.Object");
    }
}
