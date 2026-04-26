package T3;

import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class c extends U3.e {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final i0.i f2024d;
    public final i0.i e;

    public c(i0.i iVar, InterfaceC0767h interfaceC0767h, int i4, S3.c cVar) {
        super(interfaceC0767h, i4, cVar);
        this.f2024d = iVar;
        this.e = iVar;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r6v0, types: [S3.u, java.lang.Object] */
    /* JADX WARN: Type inference failed for: r6v1 */
    /* JADX WARN: Type inference failed for: r6v7, types: [S3.u] */
    @Override // U3.e
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object a(S3.u r6, y3.InterfaceC0762c r7) {
        /*
            r5 = this;
            boolean r0 = r7 instanceof T3.b
            if (r0 == 0) goto L13
            r0 = r7
            T3.b r0 = (T3.b) r0
            int r1 = r0.f2023d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f2023d = r1
            goto L1a
        L13:
            T3.b r0 = new T3.b
            A3.c r7 = (A3.c) r7
            r0.<init>(r5, r7)
        L1a:
            java.lang.Object r7 = r0.f2021b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f2023d
            w3.i r3 = w3.i.f6729a
            r4 = 1
            if (r2 == 0) goto L35
            if (r2 != r4) goto L2d
            S3.u r6 = r0.f2020a
            e1.AbstractC0367g.M(r7)
            goto L49
        L2d:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L35:
            e1.AbstractC0367g.M(r7)
            r0.f2020a = r6
            r0.f2023d = r4
            i0.i r7 = r5.f2024d
            java.lang.Object r7 = r7.invoke(r6, r0)
            if (r7 != r1) goto L45
            goto L46
        L45:
            r7 = r3
        L46:
            if (r7 != r1) goto L49
            return r1
        L49:
            S3.j r6 = (S3.j) r6
            S3.e r6 = r6.f1851d
            boolean r6 = r6.t()
            if (r6 == 0) goto L54
            return r3
        L54:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "'awaitClose { yourCallbackOrListener.cancel() }' should be used in the end of callbackFlow block.\nOtherwise, a callback/listener may leak in case of external cancellation.\nSee callbackFlow API documentation for the details."
            r6.<init>(r7)
            throw r6
        */
        throw new UnsupportedOperationException("Method not decompiled: T3.c.a(S3.u, y3.c):java.lang.Object");
    }

    @Override // U3.e
    public final U3.e c(InterfaceC0767h interfaceC0767h, int i4, S3.c cVar) {
        return new c(this.e, interfaceC0767h, i4, cVar);
    }

    @Override // U3.e
    public final String toString() {
        return "block[" + this.f2024d + "] -> " + super.toString();
    }
}
