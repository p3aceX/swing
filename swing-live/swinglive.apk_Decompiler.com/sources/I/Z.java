package I;

import java.io.File;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: loaded from: classes.dex */
public final class Z implements InterfaceC0041b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final File f632a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final l0 f633b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final V f634c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final AtomicBoolean f635d;
    public final Y3.d e;

    public Z(File file, l0 l0Var, V v) {
        J3.i.e(l0Var, "coordinator");
        this.f632a = file;
        this.f633b = l0Var;
        this.f634c = v;
        this.f635d = new AtomicBoolean(false);
        this.e = new Y3.d();
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:30:0x0070  */
    /* JADX WARN: Removed duplicated region for block: B:33:0x0078 A[Catch: all -> 0x0079, TRY_ENTER, TRY_LEAVE, TryCatch #1 {all -> 0x0079, blocks: (B:33:0x0078, B:42:0x0089, B:41:0x0086, B:38:0x0081), top: B:52:0x0020, inners: #0 }] */
    /* JADX WARN: Removed duplicated region for block: B:46:0x0091  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r0v10 */
    /* JADX WARN: Type inference failed for: r0v11 */
    /* JADX WARN: Type inference failed for: r0v12, types: [I.Z] */
    /* JADX WARN: Type inference failed for: r0v13, types: [I.Z] */
    /* JADX WARN: Type inference failed for: r0v16 */
    /* JADX WARN: Type inference failed for: r0v17 */
    /* JADX WARN: Type inference failed for: r0v18 */
    /* JADX WARN: Type inference failed for: r0v2, types: [I.X, java.lang.Object] */
    /* JADX WARN: Type inference failed for: r0v3 */
    /* JADX WARN: Type inference failed for: r0v4, types: [I.Z] */
    /* JADX WARN: Type inference failed for: r0v6 */
    /* JADX WARN: Type inference failed for: r0v8 */
    /* JADX WARN: Type inference failed for: r7v0, types: [I.s] */
    /* JADX WARN: Type inference failed for: r7v1 */
    /* JADX WARN: Type inference failed for: r7v10 */
    /* JADX WARN: Type inference failed for: r7v11 */
    /* JADX WARN: Type inference failed for: r7v12 */
    /* JADX WARN: Type inference failed for: r7v15, types: [boolean] */
    /* JADX WARN: Type inference failed for: r7v16 */
    /* JADX WARN: Type inference failed for: r7v2 */
    /* JADX WARN: Type inference failed for: r7v6 */
    /* JADX WARN: Type inference failed for: r7v8 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object a(I.C0057s r7, A3.c r8) throws java.lang.Throwable {
        /*
            r6 = this;
            boolean r0 = r8 instanceof I.X
            if (r0 == 0) goto L13
            r0 = r8
            I.X r0 = (I.X) r0
            int r1 = r0.f625f
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f625f = r1
            goto L18
        L13:
            I.X r0 = new I.X
            r0.<init>(r6, r8)
        L18:
            java.lang.Object r8 = r0.f624d
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f625f
            r3 = 0
            r4 = 1
            if (r2 == 0) goto L38
            if (r2 != r4) goto L30
            boolean r7 = r0.f623c
            I.T r1 = r0.f622b
            I.Z r0 = r0.f621a
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Throwable -> L2e
            goto L68
        L2e:
            r8 = move-exception
            goto L81
        L30:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L38:
            e1.AbstractC0367g.M(r8)
            java.util.concurrent.atomic.AtomicBoolean r8 = r6.f635d
            boolean r8 = r8.get()
            if (r8 != 0) goto L97
            Y3.d r8 = r6.e
            boolean r8 = r8.d()
            I.T r2 = new I.T     // Catch: java.lang.Throwable -> L8a
            java.io.File r5 = r6.f632a     // Catch: java.lang.Throwable -> L8a
            r2.<init>(r5)     // Catch: java.lang.Throwable -> L8a
            java.lang.Boolean r5 = java.lang.Boolean.valueOf(r8)     // Catch: java.lang.Throwable -> L7b
            r0.f621a = r6     // Catch: java.lang.Throwable -> L7b
            r0.f622b = r2     // Catch: java.lang.Throwable -> L7b
            r0.f623c = r8     // Catch: java.lang.Throwable -> L7b
            r0.f625f = r4     // Catch: java.lang.Throwable -> L7b
            java.lang.Object r7 = r7.b(r2, r5, r0)     // Catch: java.lang.Throwable -> L7b
            if (r7 != r1) goto L63
            return r1
        L63:
            r0 = r8
            r8 = r7
            r7 = r0
            r0 = r6
            r1 = r2
        L68:
            r1.close()     // Catch: java.lang.Throwable -> L6d
            r1 = r3
            goto L6e
        L6d:
            r1 = move-exception
        L6e:
            if (r1 != 0) goto L78
            if (r7 == 0) goto L77
            Y3.d r7 = r0.e
            r7.e(r3)
        L77:
            return r8
        L78:
            throw r1     // Catch: java.lang.Throwable -> L79
        L79:
            r8 = move-exception
            goto L8f
        L7b:
            r7 = move-exception
            r0 = r8
            r8 = r7
            r7 = r0
            r0 = r6
            r1 = r2
        L81:
            r1.close()     // Catch: java.lang.Throwable -> L85
            goto L89
        L85:
            r1 = move-exception
            e1.k.b(r8, r1)     // Catch: java.lang.Throwable -> L79
        L89:
            throw r8     // Catch: java.lang.Throwable -> L79
        L8a:
            r7 = move-exception
            r0 = r8
            r8 = r7
            r7 = r0
            r0 = r6
        L8f:
            if (r7 == 0) goto L96
            Y3.d r7 = r0.e
            r7.e(r3)
        L96:
            throw r8
        L97:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "StorageConnection has already been disposed."
            r7.<init>(r8)
            throw r7
        */
        throw new UnsupportedOperationException("Method not decompiled: I.Z.a(I.s, A3.c):java.lang.Object");
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:43:0x00db A[Catch: all -> 0x0116, IOException -> 0x0118, TRY_ENTER, TryCatch #0 {IOException -> 0x0118, blocks: (B:43:0x00db, B:45:0x00e1, B:47:0x00e9, B:51:0x00f5, B:52:0x0115, B:48:0x00ee, B:59:0x0123, B:66:0x0130, B:65:0x012d), top: B:76:0x0023 }] */
    /* JADX WARN: Removed duplicated region for block: B:59:0x0123 A[Catch: all -> 0x0116, IOException -> 0x0118, TRY_ENTER, TRY_LEAVE, TryCatch #0 {IOException -> 0x0118, blocks: (B:43:0x00db, B:45:0x00e1, B:47:0x00e9, B:51:0x00f5, B:52:0x0115, B:48:0x00ee, B:59:0x0123, B:66:0x0130, B:65:0x012d), top: B:76:0x0023 }] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0015  */
    /* JADX WARN: Type inference failed for: r3v0, types: [int] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(I.P r11, A3.c r12) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 330
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: I.Z.b(I.P, A3.c):java.lang.Object");
    }

    @Override // I.InterfaceC0041b
    public final void close() {
        this.f635d.set(true);
        this.f634c.a();
    }
}
