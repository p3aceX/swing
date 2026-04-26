package m2;

import e1.AbstractC0367g;
import e2.C0371C;
import e2.C0377I;
import g2.n;
import y1.AbstractC0752b;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class e extends AbstractC0367g {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C1.b f5805c;

    public e(C1.a aVar, String str, int i4, boolean z4, long j4) {
        C1.b bVar;
        J3.i.e(aVar, "type");
        J3.i.e(str, "host");
        int iOrdinal = aVar.ordinal();
        if (iOrdinal == 0) {
            bVar = new E1.b(str, i4, z4);
        } else {
            if (iOrdinal != 1) {
                throw new A0.b();
            }
            bVar = new D1.a(str, i4, z4);
        }
        bVar.f125a = j4;
        this.f5805c = bVar;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // e1.AbstractC0367g
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object B(A3.c r5) {
        /*
            r4 = this;
            boolean r0 = r5 instanceof m2.a
            if (r0 == 0) goto L13
            r0 = r5
            m2.a r0 = (m2.a) r0
            int r1 = r0.f5795c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5795c = r1
            goto L18
        L13:
            m2.a r0 = new m2.a
            r0.<init>(r4, r5)
        L18:
            java.lang.Object r5 = r0.f5793a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5795c
            r3 = 1
            if (r2 == 0) goto L2f
            if (r2 != r3) goto L27
            e1.AbstractC0367g.M(r5)
            goto L3d
        L27:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r0)
            throw r5
        L2f:
            e1.AbstractC0367g.M(r5)
            r0.f5795c = r3
            C1.b r5 = r4.f5805c
            java.io.Serializable r5 = r5.e(r3, r0)
            if (r5 != r1) goto L3d
            return r1
        L3d:
            byte[] r5 = (byte[]) r5
            r0 = 0
            r5 = r5[r0]
            java.lang.Integer r0 = new java.lang.Integer
            r0.<init>(r5)
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: m2.e.B(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // e1.AbstractC0367g
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object F(y3.InterfaceC0762c r5) {
        /*
            r4 = this;
            boolean r0 = r5 instanceof m2.b
            if (r0 == 0) goto L13
            r0 = r5
            m2.b r0 = (m2.b) r0
            int r1 = r0.f5798c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5798c = r1
            goto L1a
        L13:
            m2.b r0 = new m2.b
            A3.c r5 = (A3.c) r5
            r0.<init>(r4, r5)
        L1a:
            java.lang.Object r5 = r0.f5796a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5798c
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            e1.AbstractC0367g.M(r5)
            goto L40
        L29:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r0)
            throw r5
        L31:
            e1.AbstractC0367g.M(r5)
            r0.f5798c = r3
            C1.b r5 = r4.f5805c
            r2 = 3
            java.io.Serializable r5 = r5.e(r2, r0)
            if (r5 != r1) goto L40
            return r1
        L40:
            byte[] r5 = (byte[]) r5
            int r5 = y1.AbstractC0752b.n(r5)
            java.lang.Integer r0 = new java.lang.Integer
            r0.<init>(r5)
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: m2.e.F(y3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // e1.AbstractC0367g
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object G(y3.InterfaceC0762c r5) {
        /*
            r4 = this;
            boolean r0 = r5 instanceof m2.c
            if (r0 == 0) goto L13
            r0 = r5
            m2.c r0 = (m2.c) r0
            int r1 = r0.f5801c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5801c = r1
            goto L1a
        L13:
            m2.c r0 = new m2.c
            A3.c r5 = (A3.c) r5
            r0.<init>(r4, r5)
        L1a:
            java.lang.Object r5 = r0.f5799a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5801c
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            e1.AbstractC0367g.M(r5)
            goto L40
        L29:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r0)
            throw r5
        L31:
            e1.AbstractC0367g.M(r5)
            r0.f5801c = r3
            C1.b r5 = r4.f5805c
            r2 = 4
            java.io.Serializable r5 = r5.e(r2, r0)
            if (r5 != r1) goto L40
            return r1
        L40:
            byte[] r5 = (byte[]) r5
            int r5 = y1.AbstractC0752b.o(r5)
            java.lang.Integer r0 = new java.lang.Integer
            r0.<init>(r5)
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: m2.e.G(y3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // e1.AbstractC0367g
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object H(y3.InterfaceC0762c r5) {
        /*
            r4 = this;
            boolean r0 = r5 instanceof m2.d
            if (r0 == 0) goto L13
            r0 = r5
            m2.d r0 = (m2.d) r0
            int r1 = r0.f5804c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5804c = r1
            goto L1a
        L13:
            m2.d r0 = new m2.d
            A3.c r5 = (A3.c) r5
            r0.<init>(r4, r5)
        L1a:
            java.lang.Object r5 = r0.f5802a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5804c
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            e1.AbstractC0367g.M(r5)
            goto L40
        L29:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r0)
            throw r5
        L31:
            e1.AbstractC0367g.M(r5)
            r0.f5804c = r3
            C1.b r5 = r4.f5805c
            r2 = 4
            java.io.Serializable r5 = r5.e(r2, r0)
            if (r5 != r1) goto L40
            return r1
        L40:
            byte[] r5 = (byte[]) r5
            java.lang.String r0 = "<this>"
            J3.i.e(r5, r0)
            int r5 = y1.AbstractC0752b.o(r5)
            int r5 = java.lang.Integer.reverseBytes(r5)
            java.lang.Integer r0 = new java.lang.Integer
            r0.<init>(r5)
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: m2.e.H(y3.c):java.lang.Object");
    }

    @Override // e1.AbstractC0367g
    public final Object I(byte[] bArr, A3.c cVar) {
        Object objG = this.f5805c.g(bArr, cVar);
        return objG == EnumC0789a.f6999a ? objG : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object Q(int i4, A3.c cVar) {
        Object objH = this.f5805c.h(i4, cVar);
        return objH == EnumC0789a.f6999a ? objH : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object R(byte[] bArr, int i4, int i5, n nVar) {
        Object objI = this.f5805c.i(bArr, i4, i5, nVar);
        return objI == EnumC0789a.f6999a ? objI : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object S(byte[] bArr, A3.c cVar) {
        Object objJ = this.f5805c.j(bArr, cVar);
        return objJ == EnumC0789a.f6999a ? objJ : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object T(int i4, g2.i iVar) {
        Object objJ = this.f5805c.j(new byte[]{(byte) (i4 >>> 16), (byte) (i4 >>> 8), (byte) i4}, iVar);
        return objJ == EnumC0789a.f6999a ? objJ : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object U(int i4, g2.i iVar) {
        Object objJ = this.f5805c.j(AbstractC0752b.p(i4), iVar);
        return objJ == EnumC0789a.f6999a ? objJ : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object V(int i4, g2.i iVar) {
        Object objJ = this.f5805c.j(AbstractC0752b.p(Integer.reverseBytes(i4)), iVar);
        return objJ == EnumC0789a.f6999a ? objJ : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object c(C0371C c0371c) {
        Object objA = this.f5805c.a(c0371c);
        return objA == EnumC0789a.f6999a ? objA : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object f(C0377I c0377i) {
        Object objB = this.f5805c.b(c0377i);
        return objB == EnumC0789a.f6999a ? objB : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object s(boolean z4, A3.c cVar) {
        Object objC = this.f5805c.c(cVar);
        return objC == EnumC0789a.f6999a ? objC : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final boolean x() {
        return this.f5805c.d();
    }
}
