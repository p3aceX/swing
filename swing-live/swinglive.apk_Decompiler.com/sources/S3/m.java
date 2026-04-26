package S3;

import Q3.D;
import Q3.E;
import Q3.F;
import y3.AbstractC0760a;

/* JADX INFO: loaded from: classes.dex */
public abstract class m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final l f1853a = new l();

    public static e a(int i4, c cVar, int i5) {
        if ((i5 & 2) != 0) {
            cVar = c.f1813a;
        }
        if (i4 == -2) {
            if (cVar != c.f1813a) {
                return new q(1, cVar);
            }
            i.f1850h.getClass();
            return new e(h.f1849b);
        }
        if (i4 != -1) {
            return i4 != 0 ? i4 != Integer.MAX_VALUE ? cVar == c.f1813a ? new e(i4) : new q(i4, cVar) : new e(com.google.android.gms.common.api.f.API_PRIORITY_OTHER) : cVar == c.f1813a ? new e(0) : new q(1, cVar);
        }
        if (cVar == c.f1813a) {
            return new q(1, c.f1814b);
        }
        throw new IllegalArgumentException("CONFLATED capacity cannot be used with non-default onBufferOverflow");
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r4v0, types: [S3.u] */
    /* JADX WARN: Type inference failed for: r5v0, types: [I3.a, K.b] */
    /* JADX WARN: Type inference failed for: r5v1, types: [I3.a] */
    /* JADX WARN: Type inference failed for: r5v3, types: [I3.a] */
    /* JADX WARN: Type inference failed for: r5v6 */
    /* JADX WARN: Type inference failed for: r5v7 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object b(S3.u r4, K.b r5, A3.c r6) {
        /*
            boolean r0 = r6 instanceof S3.r
            if (r0 == 0) goto L13
            r0 = r6
            S3.r r0 = (S3.r) r0
            int r1 = r0.f1858c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f1858c = r1
            goto L18
        L13:
            S3.r r0 = new S3.r
            r0.<init>(r6)
        L18:
            java.lang.Object r6 = r0.f1857b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f1858c
            r3 = 1
            if (r2 == 0) goto L33
            if (r2 != r3) goto L2b
            I3.a r5 = r0.f1856a
            e1.AbstractC0367g.M(r6)     // Catch: java.lang.Throwable -> L29
            goto L63
        L29:
            r4 = move-exception
            goto L69
        L2b:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "call to 'resume' before 'invoke' with coroutine"
            r4.<init>(r5)
            throw r4
        L33:
            e1.AbstractC0367g.M(r6)
            y3.h r6 = r0.getContext()
            Q3.B r2 = Q3.B.f1565b
            y3.f r6 = r6.i(r2)
            if (r6 != r4) goto L6d
            r0.f1856a = r5     // Catch: java.lang.Throwable -> L29
            r0.f1858c = r3     // Catch: java.lang.Throwable -> L29
            Q3.m r6 = new Q3.m     // Catch: java.lang.Throwable -> L29
            y3.c r0 = e1.k.w(r0)     // Catch: java.lang.Throwable -> L29
            r6.<init>(r3, r0)     // Catch: java.lang.Throwable -> L29
            r6.r()     // Catch: java.lang.Throwable -> L29
            S3.s r0 = new S3.s     // Catch: java.lang.Throwable -> L29
            r0.<init>(r6)     // Catch: java.lang.Throwable -> L29
            S3.j r4 = (S3.j) r4     // Catch: java.lang.Throwable -> L29
            r4.f0(r0)     // Catch: java.lang.Throwable -> L29
            java.lang.Object r4 = r6.q()     // Catch: java.lang.Throwable -> L29
            if (r4 != r1) goto L63
            return r1
        L63:
            r5.a()
            w3.i r4 = w3.i.f6729a
            return r4
        L69:
            r5.a()
            throw r4
        L6d:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "awaitClose() can only be invoked from the producer context"
            r4.<init>(r5)
            throw r4
        */
        throw new UnsupportedOperationException("Method not decompiled: S3.m.b(S3.u, K.b, A3.c):java.lang.Object");
    }

    public static t c(D d5, AbstractC0760a abstractC0760a, I3.p pVar) {
        c cVar = c.f1813a;
        E e = E.f1571a;
        t tVar = new t(F.t(d5, abstractC0760a), a(0, cVar, 4), true, true);
        tVar.e0(e, tVar, pVar);
        return tVar;
    }
}
