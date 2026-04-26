package I;

import java.util.concurrent.atomic.AtomicInteger;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class l0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Y3.d f693a = new Y3.d();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0779j f694b = new C0779j();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0779j f695c = new C0779j(new k0(2, null));

    public l0(String str) {
    }

    public final Integer a() {
        return new Integer(((AtomicInteger) this.f694b.f6969b).get());
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(I3.l r8, A3.c r9) {
        /*
            r7 = this;
            boolean r0 = r9 instanceof I.i0
            if (r0 == 0) goto L13
            r0 = r9
            I.i0 r0 = (I.i0) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            I.i0 r0 = new I.i0
            r0.<init>(r7, r9)
        L18:
            java.lang.Object r9 = r0.f672c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            r3 = 2
            r4 = 1
            r5 = 0
            if (r2 == 0) goto L45
            if (r2 == r4) goto L39
            if (r2 != r3) goto L31
            java.lang.Object r8 = r0.f670a
            Y3.a r8 = (Y3.a) r8
            e1.AbstractC0367g.M(r9)     // Catch: java.lang.Throwable -> L2f
            goto L67
        L2f:
            r9 = move-exception
            goto L71
        L31:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r9 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r9)
            throw r8
        L39:
            Y3.d r8 = r0.f671b
            java.lang.Object r2 = r0.f670a
            I3.l r2 = (I3.l) r2
            e1.AbstractC0367g.M(r9)
            r9 = r8
            r8 = r2
            goto L57
        L45:
            e1.AbstractC0367g.M(r9)
            r0.f670a = r8
            Y3.d r9 = r7.f693a
            r0.f671b = r9
            r0.e = r4
            java.lang.Object r2 = r9.c(r0)
            if (r2 != r1) goto L57
            goto L63
        L57:
            r0.f670a = r9     // Catch: java.lang.Throwable -> L6d
            r0.f671b = r5     // Catch: java.lang.Throwable -> L6d
            r0.e = r3     // Catch: java.lang.Throwable -> L6d
            java.lang.Object r8 = r8.invoke(r0)     // Catch: java.lang.Throwable -> L6d
            if (r8 != r1) goto L64
        L63:
            return r1
        L64:
            r6 = r9
            r9 = r8
            r8 = r6
        L67:
            Y3.d r8 = (Y3.d) r8
            r8.e(r5)
            return r9
        L6d:
            r8 = move-exception
            r6 = r9
            r9 = r8
            r8 = r6
        L71:
            Y3.d r8 = (Y3.d) r8
            r8.e(r5)
            throw r9
        */
        throw new UnsupportedOperationException("Method not decompiled: I.l0.b(I3.l, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:24:0x0055  */
    /* JADX WARN: Removed duplicated region for block: B:29:0x005f  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object c(I3.p r7, A3.c r8) throws java.lang.Throwable {
        /*
            r6 = this;
            boolean r0 = r8 instanceof I.j0
            if (r0 == 0) goto L13
            r0 = r8
            I.j0 r0 = (I.j0) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            I.j0 r0 = new I.j0
            r0.<init>(r6, r8)
        L18:
            java.lang.Object r8 = r0.f680c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            r3 = 1
            r4 = 0
            if (r2 == 0) goto L36
            if (r2 != r3) goto L2e
            boolean r7 = r0.f679b
            Y3.d r0 = r0.f678a
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Throwable -> L2c
            goto L53
        L2c:
            r8 = move-exception
            goto L5d
        L2e:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L36:
            e1.AbstractC0367g.M(r8)
            Y3.d r8 = r6.f693a
            boolean r2 = r8.d()
            java.lang.Boolean r5 = java.lang.Boolean.valueOf(r2)     // Catch: java.lang.Throwable -> L59
            r0.f678a = r8     // Catch: java.lang.Throwable -> L59
            r0.f679b = r2     // Catch: java.lang.Throwable -> L59
            r0.e = r3     // Catch: java.lang.Throwable -> L59
            java.lang.Object r7 = r7.invoke(r5, r0)     // Catch: java.lang.Throwable -> L59
            if (r7 != r1) goto L50
            return r1
        L50:
            r0 = r8
            r8 = r7
            r7 = r2
        L53:
            if (r7 == 0) goto L58
            r0.e(r4)
        L58:
            return r8
        L59:
            r7 = move-exception
            r0 = r8
            r8 = r7
            r7 = r2
        L5d:
            if (r7 == 0) goto L62
            r0.e(r4)
        L62:
            throw r8
        */
        throw new UnsupportedOperationException("Method not decompiled: I.l0.c(I3.p, A3.c):java.lang.Object");
    }
}
