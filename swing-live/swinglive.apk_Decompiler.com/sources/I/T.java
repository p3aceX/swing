package I;

import java.io.File;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: loaded from: classes.dex */
public class T implements InterfaceC0041b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final File f612a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AtomicBoolean f613b = new AtomicBoolean(false);

    public T(File file) {
        this.f612a = file;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r2v0, types: [int] */
    /* JADX WARN: Type inference failed for: r2v1 */
    /* JADX WARN: Type inference failed for: r2v4 */
    /* JADX WARN: Type inference failed for: r2v7 */
    /* JADX WARN: Type inference failed for: r2v9, types: [I.T] */
    /* JADX WARN: Type inference failed for: r9v0, types: [I.T, java.lang.Object] */
    /* JADX WARN: Type inference failed for: r9v1 */
    /* JADX WARN: Type inference failed for: r9v2, types: [I.T] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static java.lang.Object a(I.T r9, A3.c r10) throws java.lang.IllegalAccessException, java.io.IOException, java.lang.reflect.InvocationTargetException {
        /*
            boolean r0 = r10 instanceof I.S
            if (r0 == 0) goto L13
            r0 = r10
            I.S r0 = (I.S) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            I.S r0 = new I.S
            r0.<init>(r9, r10)
        L18:
            java.lang.Object r10 = r0.f610c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            L.g r3 = L.g.f868a
            r4 = 2
            r5 = 1
            r6 = 0
            if (r2 == 0) goto L49
            if (r2 == r5) goto L3d
            if (r2 != r4) goto L35
            java.lang.Object r9 = r0.f608a
            java.io.Closeable r9 = (java.io.Closeable) r9
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L32
            goto L9e
        L32:
            r10 = move-exception
            goto La8
        L35:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r10 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r10)
            throw r9
        L3d:
            java.io.FileInputStream r9 = r0.f609b
            java.lang.Object r2 = r0.f608a
            I.T r2 = (I.T) r2
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L47
            goto L6c
        L47:
            r10 = move-exception
            goto L79
        L49:
            e1.AbstractC0367g.M(r10)
            java.util.concurrent.atomic.AtomicBoolean r10 = r9.f613b
            boolean r10 = r10.get()
            if (r10 != 0) goto Lb4
            java.io.FileInputStream r10 = new java.io.FileInputStream     // Catch: java.io.FileNotFoundException -> L7f
            java.io.File r2 = r9.f612a     // Catch: java.io.FileNotFoundException -> L7f
            r10.<init>(r2)     // Catch: java.io.FileNotFoundException -> L7f
            r0.f608a = r9     // Catch: java.lang.Throwable -> L77
            r0.f609b = r10     // Catch: java.lang.Throwable -> L77
            r0.e = r5     // Catch: java.lang.Throwable -> L77
            L.b r2 = r3.a(r10)     // Catch: java.lang.Throwable -> L77
            if (r2 != r1) goto L68
            goto L9a
        L68:
            r8 = r2
            r2 = r9
            r9 = r10
            r10 = r8
        L6c:
            H0.a.d(r9, r6)     // Catch: java.io.FileNotFoundException -> L70
            return r10
        L70:
            r9 = r2
            goto L7f
        L72:
            r8 = r2
            r2 = r9
            r9 = r10
            r10 = r8
            goto L79
        L77:
            r2 = move-exception
            goto L72
        L79:
            throw r10     // Catch: java.lang.Throwable -> L7a
        L7a:
            r7 = move-exception
            H0.a.d(r9, r10)     // Catch: java.io.FileNotFoundException -> L70
            throw r7     // Catch: java.io.FileNotFoundException -> L70
        L7f:
            java.io.File r10 = r9.f612a
            boolean r10 = r10.exists()
            if (r10 == 0) goto Lae
            java.io.FileInputStream r10 = new java.io.FileInputStream
            java.io.File r9 = r9.f612a
            r10.<init>(r9)
            r0.f608a = r10     // Catch: java.lang.Throwable -> La6
            r0.f609b = r6     // Catch: java.lang.Throwable -> La6
            r0.e = r4     // Catch: java.lang.Throwable -> La6
            L.b r9 = r3.a(r10)     // Catch: java.lang.Throwable -> La6
            if (r9 != r1) goto L9b
        L9a:
            return r1
        L9b:
            r8 = r10
            r10 = r9
            r9 = r8
        L9e:
            H0.a.d(r9, r6)
            return r10
        La2:
            r8 = r10
            r10 = r9
            r9 = r8
            goto La8
        La6:
            r9 = move-exception
            goto La2
        La8:
            throw r10     // Catch: java.lang.Throwable -> La9
        La9:
            r0 = move-exception
            H0.a.d(r9, r10)
            throw r0
        Lae:
            L.b r9 = new L.b
            r9.<init>(r5)
            return r9
        Lb4:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r10 = "This scope has already been closed."
            r9.<init>(r10)
            throw r9
        */
        throw new UnsupportedOperationException("Method not decompiled: I.T.a(I.T, A3.c):java.lang.Object");
    }

    @Override // I.InterfaceC0041b
    public final void close() {
        this.f613b.set(true);
    }
}
