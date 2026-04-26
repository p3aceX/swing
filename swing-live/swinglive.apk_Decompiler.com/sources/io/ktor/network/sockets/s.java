package io.ktor.network.sockets;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class s extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public S3.t f4930a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4931b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4932c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ t f4933d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public s(t tVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4933d = tVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        s sVar = new s(this.f4933d, interfaceC0762c);
        sVar.f4932c = obj;
        return sVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((s) create((S3.u) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:16:0x0039  */
    /* JADX WARN: Removed duplicated region for block: B:17:0x003a A[Catch: ClosedChannelException | IOException -> 0x0048, ClosedChannelException | IOException -> 0x0048, PHI: r2 r7
      0x003a: PHI (r2v1 S3.t) = (r2v3 S3.t), (r2v4 S3.t) binds: [B:15:0x0037, B:11:0x001e] A[DONT_GENERATE, DONT_INLINE]
      0x003a: PHI (r7v2 java.lang.Object) = (r7v5 java.lang.Object), (r7v0 java.lang.Object) binds: [B:15:0x0037, B:11:0x001e] A[DONT_GENERATE, DONT_INLINE], TRY_LEAVE, TryCatch #0 {ClosedChannelException | IOException -> 0x0048, blocks: (B:6:0x0010, B:14:0x0025, B:14:0x0025, B:17:0x003a, B:17:0x003a, B:11:0x001e, B:11:0x001e), top: B:22:0x000a }] */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:18:0x0045 -> B:14:0x0025). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r7) {
        /*
            r6 = this;
            java.lang.Object r0 = r6.f4932c
            S3.u r0 = (S3.u) r0
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r6.f4931b
            r3 = 2
            r4 = 1
            if (r2 == 0) goto L22
            if (r2 == r4) goto L1c
            if (r2 != r3) goto L14
            e1.AbstractC0367g.M(r7)     // Catch: java.lang.Throwable -> L48
            goto L25
        L14:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r0)
            throw r7
        L1c:
            S3.t r2 = r6.f4930a
            e1.AbstractC0367g.M(r7)     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            goto L3a
        L22:
            e1.AbstractC0367g.M(r7)
        L25:
            r2 = r0
            S3.t r2 = (S3.t) r2     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            r2.getClass()     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            io.ktor.network.sockets.t r7 = r6.f4933d     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            r6.f4932c = r0     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            r6.f4930a = r2     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            r6.f4931b = r4     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            java.lang.Object r7 = io.ktor.network.sockets.t.l(r7, r6)     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            if (r7 != r1) goto L3a
            goto L47
        L3a:
            r6.f4932c = r0     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            r5 = 0
            r6.f4930a = r5     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            r6.f4931b = r3     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            java.lang.Object r7 = r2.m(r7, r6)     // Catch: java.lang.Throwable -> L48 java.lang.Throwable -> L48
            if (r7 != r1) goto L25
        L47:
            return r1
        L48:
            w3.i r7 = w3.i.f6729a
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.s.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
