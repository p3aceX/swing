package T3;

import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class r {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0779j f2072a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0779j f2073b;

    static {
        int i4 = 20;
        f2072a = new C0779j("NONE", i4);
        f2073b = new C0779j("PENDING", i4);
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object a(T3.t r4, I.C0057s r5, java.lang.Throwable r6, A3.c r7) throws java.lang.IllegalAccessException, java.lang.reflect.InvocationTargetException {
        /*
            boolean r0 = r7 instanceof T3.g
            if (r0 == 0) goto L13
            r0 = r7
            T3.g r0 = (T3.g) r0
            int r1 = r0.f2032c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f2032c = r1
            goto L18
        L13:
            T3.g r0 = new T3.g
            r0.<init>(r7)
        L18:
            java.lang.Object r7 = r0.f2031b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f2032c
            r3 = 1
            if (r2 == 0) goto L33
            if (r2 != r3) goto L2b
            java.lang.Throwable r6 = r0.f2030a
            e1.AbstractC0367g.M(r7)     // Catch: java.lang.Throwable -> L29
            goto L41
        L29:
            r4 = move-exception
            goto L44
        L2b:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "call to 'resume' before 'invoke' with coroutine"
            r4.<init>(r5)
            throw r4
        L33:
            e1.AbstractC0367g.M(r7)
            r0.f2030a = r6     // Catch: java.lang.Throwable -> L29
            r0.f2032c = r3     // Catch: java.lang.Throwable -> L29
            java.lang.Object r4 = r5.b(r4, r6, r0)     // Catch: java.lang.Throwable -> L29
            if (r4 != r1) goto L41
            return r1
        L41:
            w3.i r4 = w3.i.f6729a
            return r4
        L44:
            if (r6 == 0) goto L4b
            if (r6 == r4) goto L4b
            e1.k.b(r4, r6)
        L4b:
            throw r4
        */
        throw new UnsupportedOperationException("Method not decompiled: T3.r.a(T3.t, I.s, java.lang.Throwable, A3.c):java.lang.Object");
    }

    /* JADX WARN: Code restructure failed: missing block: B:32:0x008b, code lost:
    
        if (r2.c(r10, r0) == r1) goto L33;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:27:0x006d  */
    /* JADX WARN: Removed duplicated region for block: B:28:0x006e  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x0079 A[Catch: all -> 0x0036, TRY_LEAVE, TryCatch #0 {all -> 0x0036, blocks: (B:13:0x002f, B:25:0x005d, B:29:0x0071, B:31:0x0079, B:20:0x0048, B:24:0x0053), top: B:50:0x0021 }] */
    /* JADX WARN: Removed duplicated region for block: B:34:0x008e  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r8v0, types: [S3.j, S3.t] */
    /* JADX WARN: Type inference failed for: r8v1, types: [S3.v] */
    /* JADX WARN: Type inference failed for: r8v10 */
    /* JADX WARN: Type inference failed for: r8v11 */
    /* JADX WARN: Type inference failed for: r8v12 */
    /* JADX WARN: Type inference failed for: r8v13 */
    /* JADX WARN: Type inference failed for: r8v2, types: [S3.v] */
    /* JADX WARN: Type inference failed for: r8v3, types: [S3.v] */
    /* JADX WARN: Type inference failed for: r8v4 */
    /* JADX WARN: Type inference failed for: r8v8 */
    /* JADX WARN: Type inference failed for: r8v9 */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:32:0x008b -> B:14:0x0032). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object b(T3.e r7, S3.t r8, boolean r9, A3.c r10) throws java.lang.Throwable {
        /*
            boolean r0 = r10 instanceof T3.f
            if (r0 == 0) goto L13
            r0 = r10
            T3.f r0 = (T3.f) r0
            int r1 = r0.f2029f
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f2029f = r1
            goto L18
        L13:
            T3.f r0 = new T3.f
            r0.<init>(r10)
        L18:
            java.lang.Object r10 = r0.e
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f2029f
            r3 = 0
            r4 = 2
            r5 = 1
            if (r2 == 0) goto L4c
            if (r2 == r5) goto L40
            if (r2 != r4) goto L38
            boolean r9 = r0.f2028d
            S3.d r7 = r0.f2027c
            S3.v r8 = r0.f2026b
            T3.e r2 = r0.f2025a
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L36
        L32:
            r6 = r2
            r2 = r7
            r7 = r6
            goto L5d
        L36:
            r7 = move-exception
            goto L96
        L38:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L40:
            boolean r9 = r0.f2028d
            S3.d r7 = r0.f2027c
            S3.v r8 = r0.f2026b
            T3.e r2 = r0.f2025a
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L36
            goto L71
        L4c:
            e1.AbstractC0367g.M(r10)
            boolean r10 = r7 instanceof T3.t
            if (r10 != 0) goto Lb1
            S3.e r10 = r8.f1851d     // Catch: java.lang.Throwable -> L36
            r10.getClass()     // Catch: java.lang.Throwable -> L36
            S3.d r2 = new S3.d     // Catch: java.lang.Throwable -> L36
            r2.<init>(r10)     // Catch: java.lang.Throwable -> L36
        L5d:
            r0.f2025a = r7     // Catch: java.lang.Throwable -> L36
            r0.f2026b = r8     // Catch: java.lang.Throwable -> L36
            r0.f2027c = r2     // Catch: java.lang.Throwable -> L36
            r0.f2028d = r9     // Catch: java.lang.Throwable -> L36
            r0.f2029f = r5     // Catch: java.lang.Throwable -> L36
            java.lang.Object r10 = r2.b(r0)     // Catch: java.lang.Throwable -> L36
            if (r10 != r1) goto L6e
            goto L8d
        L6e:
            r6 = r2
            r2 = r7
            r7 = r6
        L71:
            java.lang.Boolean r10 = (java.lang.Boolean) r10     // Catch: java.lang.Throwable -> L36
            boolean r10 = r10.booleanValue()     // Catch: java.lang.Throwable -> L36
            if (r10 == 0) goto L8e
            java.lang.Object r10 = r7.c()     // Catch: java.lang.Throwable -> L36
            r0.f2025a = r2     // Catch: java.lang.Throwable -> L36
            r0.f2026b = r8     // Catch: java.lang.Throwable -> L36
            r0.f2027c = r7     // Catch: java.lang.Throwable -> L36
            r0.f2028d = r9     // Catch: java.lang.Throwable -> L36
            r0.f2029f = r4     // Catch: java.lang.Throwable -> L36
            java.lang.Object r10 = r2.c(r10, r0)     // Catch: java.lang.Throwable -> L36
            if (r10 != r1) goto L32
        L8d:
            return r1
        L8e:
            if (r9 == 0) goto L93
            r8.a(r3)
        L93:
            w3.i r7 = w3.i.f6729a
            return r7
        L96:
            throw r7     // Catch: java.lang.Throwable -> L97
        L97:
            r10 = move-exception
            if (r9 == 0) goto Lb0
            boolean r9 = r7 instanceof java.util.concurrent.CancellationException
            if (r9 == 0) goto La1
            r3 = r7
            java.util.concurrent.CancellationException r3 = (java.util.concurrent.CancellationException) r3
        La1:
            if (r3 != 0) goto Lad
            java.util.concurrent.CancellationException r3 = new java.util.concurrent.CancellationException
            java.lang.String r9 = "Channel was consumed, consumer had failed"
            r3.<init>(r9)
            r3.initCause(r7)
        Lad:
            r8.a(r3)
        Lb0:
            throw r10
        Lb1:
            T3.t r7 = (T3.t) r7
            java.lang.Throwable r7 = r7.f2075a
            throw r7
        */
        throw new UnsupportedOperationException("Method not decompiled: T3.r.b(T3.e, S3.t, boolean, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:27:0x005a  */
    /* JADX WARN: Removed duplicated region for block: B:30:0x0064  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object c(T3.d r5, A3.c r6) {
        /*
            boolean r0 = r6 instanceof T3.o
            if (r0 == 0) goto L13
            r0 = r6
            T3.o r0 = (T3.o) r0
            int r1 = r0.f2063d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f2063d = r1
            goto L18
        L13:
            T3.o r0 = new T3.o
            r0.<init>(r6)
        L18:
            java.lang.Object r6 = r0.f2062c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f2063d
            r3 = 1
            if (r2 == 0) goto L35
            if (r2 != r3) goto L2d
            I.A r5 = r0.f2061b
            J3.r r1 = r0.f2060a
            e1.AbstractC0367g.M(r6)     // Catch: U3.a -> L2b
            goto L61
        L2b:
            r6 = move-exception
            goto L56
        L2d:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r6 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r6)
            throw r5
        L35:
            e1.AbstractC0367g.M(r6)
            J3.r r6 = new J3.r
            r6.<init>()
            I.A r2 = new I.A
            r4 = 1
            r2.<init>(r6, r4)
            r0.f2060a = r6     // Catch: U3.a -> L52
            r0.f2061b = r2     // Catch: U3.a -> L52
            r0.f2063d = r3     // Catch: U3.a -> L52
            java.lang.Object r5 = r5.b(r2, r0)     // Catch: U3.a -> L52
            if (r5 != r1) goto L50
            return r1
        L50:
            r1 = r6
            goto L61
        L52:
            r5 = move-exception
            r1 = r6
            r6 = r5
            r5 = r2
        L56:
            T3.e r2 = r6.f2101a
            if (r2 != r5) goto L64
            y3.h r5 = r0.getContext()
            Q3.F.i(r5)
        L61:
            java.lang.Object r5 = r1.f832a
            return r5
        L64:
            throw r6
        */
        throw new UnsupportedOperationException("Method not decompiled: T3.r.c(T3.d, A3.c):java.lang.Object");
    }
}
