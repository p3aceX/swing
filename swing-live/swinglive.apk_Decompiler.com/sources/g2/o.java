package g2;

import X.N;
import e1.AbstractC0367g;
import e2.C0372D;
import java.io.InputStream;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public abstract class o {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final N f4399b = new N(16);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final w3.f f4400a;

    public o(f fVar) {
        this.f4400a = new w3.f(new C0372D(2, fVar, this));
    }

    public final j a() {
        return (j) this.f4400a.a();
    }

    public abstract int b();

    public abstract g c();

    public abstract void d(InputStream inputStream);

    public abstract byte[] e();

    /* JADX WARN: Code restructure failed: missing block: B:26:0x00a9, code lost:
    
        if (r15.b(r9, r8, r0) != r1) goto L17;
     */
    /* JADX WARN: Code restructure failed: missing block: B:29:0x00bd, code lost:
    
        if (r15.R(r0, r7, r14, r2) == r1) goto L30;
     */
    /* JADX WARN: Removed duplicated region for block: B:21:0x006c  */
    /* JADX WARN: Removed duplicated region for block: B:28:0x00ac  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:26:0x00a9 -> B:17:0x0043). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object f(e1.AbstractC0367g r14, A3.c r15) {
        /*
            r13 = this;
            boolean r0 = r15 instanceof g2.n
            if (r0 == 0) goto L13
            r0 = r15
            g2.n r0 = (g2.n) r0
            int r1 = r0.f4398n
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4398n = r1
            goto L18
        L13:
            g2.n r0 = new g2.n
            r0.<init>(r13, r15)
        L18:
            java.lang.Object r15 = r0.f4396f
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4398n
            r3 = 3
            r4 = 2
            r5 = 1
            if (r2 == 0) goto L57
            if (r2 == r5) goto L49
            if (r2 == r4) goto L36
            if (r2 != r3) goto L2e
            e1.AbstractC0367g.M(r15)
            goto Lc0
        L2e:
            java.lang.IllegalStateException r14 = new java.lang.IllegalStateException
            java.lang.String r15 = "call to 'resume' before 'invoke' with coroutine"
            r14.<init>(r15)
            throw r14
        L36:
            int r14 = r0.e
            int r2 = r0.f4395d
            int r6 = r0.f4394c
            byte[] r7 = r0.f4393b
            e1.g r8 = r0.f4392a
            e1.AbstractC0367g.M(r15)
        L43:
            r15 = r2
            r2 = r0
            r0 = r7
            r7 = r15
            r15 = r8
            goto L6a
        L49:
            int r14 = r0.e
            int r2 = r0.f4395d
            int r6 = r0.f4394c
            byte[] r7 = r0.f4393b
            e1.g r8 = r0.f4392a
            e1.AbstractC0367g.M(r15)
            goto L84
        L57:
            e1.AbstractC0367g.M(r15)
            byte[] r15 = r13.e()
            int r2 = r13.b()
            r6 = 128(0x80, float:1.8E-43)
            r7 = 0
            r12 = r15
            r15 = r14
            r14 = r2
            r2 = r0
            r0 = r12
        L6a:
            if (r14 <= r6) goto Lac
            r2.f4392a = r15
            r2.f4393b = r0
            r2.f4394c = r6
            r2.f4395d = r7
            r2.e = r14
            r2.f4398n = r5
            java.lang.Object r8 = r15.R(r0, r7, r6, r2)
            if (r8 != r1) goto L7f
            goto Lbf
        L7f:
            r8 = r7
            r7 = r0
            r0 = r2
            r2 = r8
            r8 = r15
        L84:
            int r14 = r14 - r6
            int r2 = r2 + r6
            g2.j r15 = r13.a()
            g2.f r9 = new g2.f
            f2.b r10 = f2.EnumC0402b.f4287c
            g2.j r11 = r13.a()
            g2.f r11 = r11.f4371a
            int r11 = r11.f4338b
            r9.<init>(r10, r11)
            r0.f4392a = r8
            r0.f4393b = r7
            r0.f4394c = r6
            r0.f4395d = r2
            r0.e = r14
            r0.f4398n = r4
            java.lang.Object r15 = r15.b(r9, r8, r0)
            if (r15 != r1) goto L43
            goto Lbf
        Lac:
            r4 = 0
            r2.f4392a = r4
            r2.f4393b = r4
            r2.f4394c = r6
            r2.f4395d = r7
            r2.e = r14
            r2.f4398n = r3
            java.lang.Object r14 = r15.R(r0, r7, r14, r2)
            if (r14 != r1) goto Lc0
        Lbf:
            return r1
        Lc0:
            w3.i r14 = w3.i.f6729a
            return r14
        */
        throw new UnsupportedOperationException("Method not decompiled: g2.o.f(e1.g, A3.c):java.lang.Object");
    }

    public final Object g(AbstractC0367g abstractC0367g, A3.c cVar) {
        j jVarA = a();
        Object objB = jVarA.b(jVarA.f4371a, abstractC0367g, cVar);
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        w3.i iVar = w3.i.f6729a;
        if (objB != enumC0789a) {
            objB = iVar;
        }
        return objB == enumC0789a ? objB : iVar;
    }
}
