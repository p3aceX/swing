package E1;

import J3.i;
import Q3.O;
import Q3.Q;
import Q3.q0;
import e1.AbstractC0367g;
import io.ktor.network.sockets.A;
import io.ktor.network.sockets.k;
import io.ktor.network.sockets.l;
import io.ktor.network.sockets.p;
import io.ktor.network.sockets.t;
import io.ktor.network.sockets.u;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class h extends C1.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f333b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f334c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C1.c f335d;
    public final u e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public n3.e f336f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public k f337g;

    public h(String str, int i4, C1.c cVar) {
        i.e(str, "host");
        this.f333b = str;
        this.f334c = i4;
        this.f335d = cVar;
        this.e = new u(str, i4);
        X3.e eVar = O.f1596a;
        X3.d dVar = X3.d.f2437c;
        i.e(dVar, "dispatcher");
        this.f336f = new n3.e(dVar);
    }

    @Override // C1.b
    public final Object a(InterfaceC0762c interfaceC0762c) {
        try {
            k kVar = this.f337g;
            if (kVar != null) {
                ((t) kVar).close();
            }
            this.f336f.close();
        } catch (Throwable th) {
            AbstractC0367g.h(th);
        }
        return w3.i.f6729a;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // C1.b
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(y3.InterfaceC0762c r8) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 214
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: E1.h.b(y3.c):java.lang.Object");
    }

    @Override // C1.b
    public final boolean d() {
        Q q4 = this.f337g;
        boolean z4 = false;
        if (q4 != null && ((q0) ((A) q4).e()).l()) {
            z4 = true;
        }
        return !z4;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // C1.b
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object f(A3.c r5) throws java.net.ConnectException {
        /*
            r4 = this;
            boolean r0 = r5 instanceof E1.g
            if (r0 == 0) goto L13
            r0 = r5
            E1.g r0 = (E1.g) r0
            int r1 = r0.f332c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f332c = r1
            goto L18
        L13:
            E1.g r0 = new E1.g
            r0.<init>(r4, r5)
        L18:
            java.lang.Object r5 = r0.f330a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f332c
            r3 = 1
            if (r2 == 0) goto L2f
            if (r2 != r3) goto L27
            e1.AbstractC0367g.M(r5)
            goto L45
        L27:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r0)
            throw r5
        L2f:
            e1.AbstractC0367g.M(r5)
            io.ktor.network.sockets.k r5 = r4.f337g
            if (r5 == 0) goto L5d
            r0.f332c = r3
            io.ktor.network.sockets.t r5 = (io.ktor.network.sockets.t) r5
            S3.t r5 = r5.f4936u
            S3.e r5 = r5.f1851d
            java.lang.Object r5 = r5.y(r0)
            if (r5 != r1) goto L45
            return r1
        L45:
            io.ktor.network.sockets.l r5 = (io.ktor.network.sockets.l) r5
            Z3.a r5 = r5.f4899a
            long r0 = u3.AbstractC0692a.a(r5)
            int r0 = (int) r0
            r1 = -1
            byte[] r5 = Z3.i.e(r5, r1)
            r1 = 0
            M3.f r0 = a.AbstractC0184a.Z(r1, r0)
            byte[] r5 = x3.AbstractC0726f.k0(r5, r0)
            return r5
        L5d:
            java.net.ConnectException r5 = new java.net.ConnectException
            java.lang.String r0 = "Read with socket closed, broken pipe"
            r5.<init>(r0)
            throw r5
        */
        throw new UnsupportedOperationException("Method not decompiled: E1.h.f(A3.c):java.lang.Object");
    }

    @Override // C1.b
    public final Object j(byte[] bArr, A3.c cVar) {
        Z3.a aVar = new Z3.a();
        aVar.l(bArr, 0, bArr.length);
        l lVar = new l(aVar, this.e);
        k kVar = this.f337g;
        w3.i iVar = w3.i.f6729a;
        if (kVar != null) {
            p pVar = ((t) kVar).f4935t;
            pVar.getClass();
            Object objB = pVar.m(lVar, cVar);
            EnumC0789a enumC0789a = EnumC0789a.f6999a;
            if (objB != enumC0789a) {
                objB = iVar;
            }
            if (objB == enumC0789a) {
                return objB;
            }
        }
        return iVar;
    }
}
