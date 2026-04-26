package E1;

import J3.i;
import Q3.O;
import g2.n;
import io.ktor.network.sockets.x;
import io.ktor.utils.io.C0449m;
import io.ktor.utils.io.z;
import java.io.Serializable;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class b extends C1.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f307b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f308c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public x f309d;
    public C0449m e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public C0449m f310f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public n3.e f311g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final String f312h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final int f313i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final boolean f314j;

    public b(String str, int i4, boolean z4) {
        i.e(str, "host");
        this.f307b = str;
        this.f308c = i4;
        X3.e eVar = O.f1596a;
        X3.d dVar = X3.d.f2437c;
        i.e(dVar, "dispatcher");
        this.f311g = new n3.e(dVar);
        this.f312h = str;
        this.f313i = i4;
        this.f314j = z4;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static java.lang.Object k(E1.b r4, A3.c r5) {
        /*
            boolean r0 = r5 instanceof E1.c
            if (r0 == 0) goto L13
            r0 = r5
            E1.c r0 = (E1.c) r0
            int r1 = r0.f318d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f318d = r1
            goto L18
        L13:
            E1.c r0 = new E1.c
            r0.<init>(r4, r5)
        L18:
            java.lang.Object r5 = r0.f316b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f318d
            r3 = 1
            if (r2 == 0) goto L33
            if (r2 != r3) goto L2b
            E1.b r4 = r0.f315a
            e1.AbstractC0367g.M(r5)     // Catch: java.lang.Throwable -> L29
            goto L48
        L29:
            r5 = move-exception
            goto L45
        L2b:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "call to 'resume' before 'invoke' with coroutine"
            r4.<init>(r5)
            throw r4
        L33:
            e1.AbstractC0367g.M(r5)
            io.ktor.utils.io.m r5 = r4.f310f     // Catch: java.lang.Throwable -> L29
            if (r5 == 0) goto L48
            r0.f315a = r4     // Catch: java.lang.Throwable -> L29
            r0.f318d = r3     // Catch: java.lang.Throwable -> L29
            java.lang.Object r5 = r5.i(r0)     // Catch: java.lang.Throwable -> L29
            if (r5 != r1) goto L48
            return r1
        L45:
            e1.AbstractC0367g.h(r5)
        L48:
            r5 = 0
            r4.getClass()     // Catch: java.lang.Throwable -> L5d
            r4.e = r5     // Catch: java.lang.Throwable -> L5d
            r4.f310f = r5     // Catch: java.lang.Throwable -> L5d
            io.ktor.network.sockets.x r5 = r4.f309d     // Catch: java.lang.Throwable -> L5d
            if (r5 == 0) goto L57
            r5.close()     // Catch: java.lang.Throwable -> L5d
        L57:
            n3.e r4 = r4.f311g     // Catch: java.lang.Throwable -> L5d
            r4.close()     // Catch: java.lang.Throwable -> L5d
            goto L61
        L5d:
            r4 = move-exception
            e1.AbstractC0367g.h(r4)
        L61:
            w3.i r4 = w3.i.f6729a
            return r4
        */
        throw new UnsupportedOperationException("Method not decompiled: E1.b.k(E1.b, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static java.lang.Object l(E1.b r6, A3.c r7) throws java.lang.Throwable {
        /*
            boolean r0 = r7 instanceof E1.d
            if (r0 == 0) goto L13
            r0 = r7
            E1.d r0 = (E1.d) r0
            int r1 = r0.f322d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f322d = r1
            goto L18
        L13:
            E1.d r0 = new E1.d
            r0.<init>(r6, r7)
        L18:
            java.lang.Object r7 = r0.f320b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f322d
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            E1.b r6 = r0.f319a
            e1.AbstractC0367g.M(r7)
            goto L41
        L29:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L31:
            e1.AbstractC0367g.M(r7)
            long r4 = r6.f125a
            r0.f319a = r6
            r0.f322d = r3
            java.lang.Object r7 = r6.m(r4, r0)
            if (r7 != r1) goto L41
            return r1
        L41:
            io.ktor.network.sockets.x r7 = (io.ktor.network.sockets.x) r7
            java.lang.String r0 = "<this>"
            J3.i.e(r7, r0)
            io.ktor.utils.io.m r0 = new io.ktor.utils.io.m
            r0.<init>()
            r7.j(r0)
            r6.e = r0
            io.ktor.utils.io.m r0 = new io.ktor.utils.io.m
            r0.<init>()
            r7.u(r0)
            r6.f310f = r0
            java.net.InetSocketAddress r0 = new java.net.InetSocketAddress
            java.lang.String r1 = r6.f307b
            int r2 = r6.f308c
            r0.<init>(r1, r2)
            r0.getAddress()
            r6.f309d = r7
            w3.i r6 = w3.i.f6729a
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: E1.b.l(E1.b, A3.c):java.lang.Object");
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r4v3, types: [byte[], java.io.Serializable] */
    /* JADX WARN: Type inference failed for: r5v1, types: [byte[], java.io.Serializable] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static java.io.Serializable n(E1.b r4, int r5, A3.c r6) {
        /*
            boolean r0 = r6 instanceof E1.e
            if (r0 == 0) goto L13
            r0 = r6
            E1.e r0 = (E1.e) r0
            int r1 = r0.f326d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f326d = r1
            goto L18
        L13:
            E1.e r0 = new E1.e
            r0.<init>(r4, r6)
        L18:
            java.lang.Object r6 = r0.f324b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f326d
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            byte[] r4 = r0.f323a
            e1.AbstractC0367g.M(r6)
            return r4
        L29:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "call to 'resume' before 'invoke' with coroutine"
            r4.<init>(r5)
            throw r4
        L31:
            e1.AbstractC0367g.M(r6)
            byte[] r5 = new byte[r5]
            r0.f323a = r5
            r0.f326d = r3
            java.lang.Object r4 = r4.g(r5, r0)
            if (r4 != r1) goto L41
            return r1
        L41:
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: E1.b.n(E1.b, int, A3.c):java.io.Serializable");
    }

    @Override // C1.b
    public final Object a(InterfaceC0762c interfaceC0762c) {
        return k(this, (A3.c) interfaceC0762c);
    }

    @Override // C1.b
    public final Object b(InterfaceC0762c interfaceC0762c) {
        return l(this, (A3.c) interfaceC0762c);
    }

    @Override // C1.b
    public final Object c(A3.c cVar) {
        Object objN;
        C0449m c0449m = this.f310f;
        return (c0449m == null || (objN = c0449m.n(cVar)) != EnumC0789a.f6999a) ? w3.i.f6729a : objN;
    }

    @Override // C1.b
    public final boolean d() {
        x xVar = this.f309d;
        boolean z4 = false;
        if (xVar != null && xVar.e().l()) {
            z4 = true;
        }
        return !z4;
    }

    @Override // C1.b
    public final Serializable e(int i4, A3.c cVar) {
        return n(this, i4, cVar);
    }

    @Override // C1.b
    public final Object g(byte[] bArr, A3.c cVar) {
        Object objF;
        C0449m c0449m = this.e;
        return (c0449m == null || (objF = z.f(c0449m, bArr, bArr.length, cVar)) != EnumC0789a.f6999a) ? w3.i.f6729a : objF;
    }

    @Override // C1.b
    public final Object h(int i4, A3.c cVar) {
        Object objI;
        C0449m c0449m = this.f310f;
        return (c0449m == null || (objI = z.i(c0449m, (byte) i4, cVar)) != EnumC0789a.f6999a) ? w3.i.f6729a : objI;
    }

    @Override // C1.b
    public final Object i(byte[] bArr, int i4, int i5, n nVar) throws Throwable {
        C0449m c0449m = this.f310f;
        w3.i iVar = w3.i.f6729a;
        if (c0449m != null) {
            c0449m.h().l(bArr, i4, i5 + i4);
            Object objC = z.c(c0449m, nVar);
            EnumC0789a enumC0789a = EnumC0789a.f6999a;
            if (objC != enumC0789a) {
                objC = iVar;
            }
            if (objC == enumC0789a) {
                return objC;
            }
        }
        return iVar;
    }

    @Override // C1.b
    public final Object j(byte[] bArr, A3.c cVar) {
        C0449m c0449m = this.f310f;
        w3.i iVar = w3.i.f6729a;
        if (c0449m != null) {
            c0449m.h().l(bArr, 0, bArr.length);
            Object objC = z.c(c0449m, cVar);
            EnumC0789a enumC0789a = EnumC0789a.f6999a;
            if (objC != enumC0789a) {
                objC = iVar;
            }
            if (objC == enumC0789a) {
                return objC;
            }
        }
        return iVar;
    }

    /* JADX WARN: Code restructure failed: missing block: B:33:0x00f9, code lost:
    
        if (r3 == r6) goto L34;
     */
    /* JADX WARN: Removed duplicated region for block: B:7:0x001a  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object m(long r18, A3.c r20) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 264
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: E1.b.m(long, A3.c):java.lang.Object");
    }
}
