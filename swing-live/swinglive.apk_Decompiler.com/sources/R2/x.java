package r2;

import k.C0502t;
import m1.C0553h;
import o2.AbstractC0582b;
import o2.C0581a;
import o2.C0583c;
import p2.C0617a;
import q2.C0635a;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class x extends A1.d {

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final i f6422j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public C0635a f6423k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final p2.b f6424l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0502t f6425m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public AbstractC0582b f6426n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final C0583c f6427o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public C0553h f6428p;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public x(C0553h c0553h, i iVar) {
        super(c0553h, "SrtSender");
        J3.i.e(c0553h, "connectChecker");
        this.f6422j = iVar;
        C0635a c0635a = new C0635a();
        this.f6423k = c0635a;
        p2.b bVar = new p2.b();
        bVar.f6194a = c0635a;
        short sC = (short) K3.d.f859a.c(-128, 127);
        C0635a c0635a2 = bVar.f6194a;
        J3.i.e(c0635a2, "service");
        C0617a c0617a = new C0617a(17, (byte) 66, sC, 464, 2);
        c0617a.f6193h = c0635a2;
        bVar.f6197d = c0617a;
        C0635a c0635a3 = bVar.f6194a;
        J3.i.e(c0635a3, "service");
        C0617a c0617a2 = new C0617a(0, (byte) 0, sC, 496, 0);
        c0617a2.f6193h = c0635a3;
        bVar.e = c0617a2;
        c0617a2.e = (byte) 1;
        C0617a c0617a3 = bVar.f6197d;
        c0617a3.e = (byte) (c0617a3.e + 1);
        this.f6424l = bVar;
        this.f6425m = new C0502t(bVar);
        this.f6426n = new C0581a(iVar.f6355d - 16, bVar);
        this.f6427o = new C0583c(iVar.f6355d - 16, bVar);
    }

    /* JADX WARN: Removed duplicated region for block: B:54:0x017b A[PHI: r3 r4 r6
      0x017b: PHI (r3v6 int) = (r3v1 int), (r3v7 int), (r3v10 int) binds: [B:53:0x017a, B:72:0x01d4, B:28:0x006f] A[DONT_GENERATE, DONT_INLINE]
      0x017b: PHI (r4v8 r2.u) = (r4v2 r2.u), (r4v10 r2.u), (r4v2 r2.u) binds: [B:53:0x017a, B:72:0x01d4, B:28:0x006f] A[DONT_GENERATE, DONT_INLINE]
      0x017b: PHI (r6v7 int) = (r6v2 int), (r6v9 int), (r6v11 int) binds: [B:53:0x017a, B:72:0x01d4, B:28:0x006f] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:61:0x01a7  */
    /* JADX WARN: Removed duplicated region for block: B:65:0x01c3  */
    /* JADX WARN: Removed duplicated region for block: B:73:0x01d6  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0019  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:65:0x01c3 -> B:66:0x01c5). Please report as a decompilation issue!!! */
    @Override // A1.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object a(A3.c r19) {
        /*
            Method dump skipped, instruction units count: 506
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: r2.x.a(A3.c):java.lang.Object");
    }

    @Override // A1.d
    public final void e(boolean z4) {
        p2.b bVar = this.f6424l;
        bVar.f6195b = 0;
        bVar.f6196c = 0;
        if (z4) {
            this.f6423k = new C0635a();
        }
        C0502t c0502t = this.f6425m;
        c0502t.f5457a = 0;
        c0502t.f5458b = 0;
        AbstractC0582b abstractC0582b = this.f6426n;
        C0502t c0502t2 = abstractC0582b.f5969c;
        c0502t2.f5457a = 0;
        c0502t2.f5458b = 0;
        abstractC0582b.b(z4);
        C0583c c0583c = this.f6427o;
        C0502t c0502t3 = c0583c.f5969c;
        c0502t3.f5457a = 0;
        c0502t3.f5458b = 0;
        c0583c.b(z4);
    }

    public final Object f(B1.d dVar, v vVar, u uVar) {
        w3.i iVar = w3.i.f6729a;
        if (dVar != null) {
            int iOrdinal = dVar.f117c.ordinal();
            if (iOrdinal == 0) {
                Object objA = this.f6427o.a(dVar, new s(vVar, null), uVar);
                if (objA == EnumC0789a.f6999a) {
                    return objA;
                }
            } else {
                if (iOrdinal != 1) {
                    throw new A0.b();
                }
                Object objA2 = this.f6426n.a(dVar, new t(vVar, null), uVar);
                if (objA2 == EnumC0789a.f6999a) {
                    return objA2;
                }
            }
        }
        return iVar;
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x005d  */
    /* JADX WARN: Removed duplicated region for block: B:26:0x0089  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:24:0x0078 -> B:25:0x007b). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object g(java.util.List r11, n2.EnumC0562e r12, A3.c r13) {
        /*
            r10 = this;
            boolean r0 = r13 instanceof r2.w
            if (r0 == 0) goto L13
            r0 = r13
            r2.w r0 = (r2.w) r0
            int r1 = r0.f6421m
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f6421m = r1
            goto L18
        L13:
            r2.w r0 = new r2.w
            r0.<init>(r10, r13)
        L18:
            java.lang.Object r13 = r0.e
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f6421m
            r3 = 1
            if (r2 == 0) goto L37
            if (r2 != r3) goto L2f
            int r11 = r0.f6419d
            java.util.Iterator r12 = r0.f6418c
            J3.q r2 = r0.f6417b
            n2.e r4 = r0.f6416a
            e1.AbstractC0367g.M(r13)
            goto L7b
        L2f:
            java.lang.IllegalStateException r11 = new java.lang.IllegalStateException
            java.lang.String r12 = "call to 'resume' before 'invoke' with coroutine"
            r11.<init>(r12)
            throw r11
        L37:
            e1.AbstractC0367g.M(r13)
            boolean r13 = r11.isEmpty()
            if (r13 == 0) goto L48
            java.lang.Long r11 = new java.lang.Long
            r12 = 0
            r11.<init>(r12)
            return r11
        L48:
            J3.q r13 = new J3.q
            r13.<init>()
            java.util.Iterator r11 = r11.iterator()
            r2 = 0
            r9 = r12
            r12 = r11
            r11 = r2
            r2 = r13
            r13 = r9
        L57:
            boolean r4 = r12.hasNext()
            if (r4 == 0) goto L89
            java.lang.Object r4 = r12.next()
            n2.c r4 = (n2.C0560c) r4
            m1.h r5 = r10.f6428p
            r0.f6416a = r13
            r0.f6417b = r2
            r0.f6418c = r12
            r0.f6419d = r11
            r0.f6421m = r3
            r2.i r6 = r10.f6422j
            java.lang.Object r4 = r6.e(r4, r5, r0)
            if (r4 != r1) goto L78
            return r1
        L78:
            r9 = r4
            r4 = r13
            r13 = r9
        L7b:
            java.lang.Number r13 = (java.lang.Number) r13
            int r13 = r13.intValue()
            long r5 = r2.f831a
            long r7 = (long) r13
            long r5 = r5 + r7
            r2.f831a = r5
            r13 = r4
            goto L57
        L89:
            n2.e r11 = n2.EnumC0562e.f5875a
            if (r13 != r11) goto L8e
            goto L90
        L8e:
            n2.e r11 = n2.EnumC0562e.f5875a
        L90:
            boolean r11 = r10.f80f
            if (r11 == 0) goto Lb5
            java.lang.String r11 = r13.name()
            long r12 = r2.f831a
            java.lang.StringBuilder r0 = new java.lang.StringBuilder
            java.lang.String r1 = "wrote "
            r0.<init>(r1)
            r0.append(r11)
            java.lang.String r11 = " packet, size "
            r0.append(r11)
            r0.append(r12)
            java.lang.String r11 = r0.toString()
            java.lang.String r12 = r10.f77b
            android.util.Log.i(r12, r11)
        Lb5:
            long r11 = r2.f831a
            java.lang.Long r13 = new java.lang.Long
            r13.<init>(r11)
            return r13
        */
        throw new UnsupportedOperationException("Method not decompiled: r2.x.g(java.util.List, n2.e, A3.c):java.lang.Object");
    }
}
