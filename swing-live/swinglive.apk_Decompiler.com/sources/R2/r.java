package r2;

import Q3.F;
import Q3.O;
import Q3.y0;
import m1.C0553h;

/* JADX INFO: loaded from: classes.dex */
public final class r {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0553h f6388a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String[] f6389b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final i f6390c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final x f6391d;
    public C0553h e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public V3.d f6392f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public y0 f6393g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public V3.d f6394h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public volatile boolean f6395i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f6396j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final C1.a f6397k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final long f6398l;

    public r(C0553h c0553h) {
        J3.i.e(c0553h, "connectChecker");
        this.f6388a = c0553h;
        this.f6389b = new String[]{"srt"};
        i iVar = new i();
        this.f6390c = iVar;
        this.f6391d = new x(c0553h, iVar);
        X3.e eVar = O.f1596a;
        X3.d dVar = X3.d.f2437c;
        this.f6392f = F.b(dVar);
        this.f6394h = F.b(dVar);
        this.f6396j = 120000;
        this.f6397k = C1.a.f123a;
        this.f6398l = 5000L;
    }

    /* JADX WARN: Removed duplicated region for block: B:28:0x0078  */
    /* JADX WARN: Removed duplicated region for block: B:34:0x0084  */
    /* JADX WARN: Removed duplicated region for block: B:41:0x009d  */
    /* JADX WARN: Removed duplicated region for block: B:47:0x00e8  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0017  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object a(r2.r r9, boolean r10, A3.c r11) {
        /*
            Method dump skipped, instruction units count: 290
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: r2.r.a(r2.r, boolean, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:24:0x0047  */
    /* JADX WARN: Removed duplicated region for block: B:43:0x008a  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:32:0x0064 -> B:39:0x007e). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:37:0x0078 -> B:38:0x0079). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object b(r2.r r6, A3.c r7) {
        /*
            boolean r0 = r7 instanceof r2.q
            if (r0 == 0) goto L13
            r0 = r7
            r2.q r0 = (r2.q) r0
            int r1 = r0.f6387d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f6387d = r1
            goto L18
        L13:
            r2.q r0 = new r2.q
            r0.<init>(r6, r7)
        L18:
            java.lang.Object r7 = r0.f6385b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f6387d
            w3.i r3 = w3.i.f6729a
            r4 = 2
            r5 = 1
            if (r2 == 0) goto L3c
            if (r2 == r5) goto L38
            if (r2 != r4) goto L30
            r2.r r2 = r0.f6384a
            e1.AbstractC0367g.M(r7)     // Catch: java.lang.Throwable -> L2e
            goto L79
        L2e:
            r7 = move-exception
            goto L80
        L30:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L38:
            e1.AbstractC0367g.M(r7)     // Catch: java.lang.Throwable -> L2e
            goto L7e
        L3c:
            e1.AbstractC0367g.M(r7)
        L3f:
            V3.d r7 = r6.f6392f
            boolean r7 = Q3.F.q(r7)
            if (r7 == 0) goto La1
            boolean r7 = r6.f6395i
            if (r7 == 0) goto La1
            m1.h r7 = r6.e     // Catch: java.lang.Throwable -> L2e
            if (r7 == 0) goto L58
            java.lang.Object r7 = r7.f5788a     // Catch: java.lang.Throwable -> L2e
            C1.b r7 = (C1.b) r7     // Catch: java.lang.Throwable -> L2e
            boolean r7 = r7.d()     // Catch: java.lang.Throwable -> L2e
            goto L59
        L58:
            r7 = 0
        L59:
            if (r7 == 0) goto L67
            r7 = 0
            r0.f6384a = r7     // Catch: java.lang.Throwable -> L2e
            r0.f6387d = r5     // Catch: java.lang.Throwable -> L2e
            java.lang.Object r7 = r6.c(r0)     // Catch: java.lang.Throwable -> L2e
            if (r7 != r1) goto L7e
            goto La2
        L67:
            r2.j r7 = new r2.j     // Catch: java.lang.Throwable -> L2e
            r2 = 1
            r7.<init>(r6, r2)     // Catch: java.lang.Throwable -> L2e
            r0.f6384a = r6     // Catch: java.lang.Throwable -> L2e
            r0.f6387d = r4     // Catch: java.lang.Throwable -> L2e
            java.lang.Object r7 = y1.AbstractC0752b.e(r7, r0)     // Catch: java.lang.Throwable -> L2e
            if (r7 != r1) goto L78
            goto La2
        L78:
            r2 = r6
        L79:
            V3.d r7 = r2.f6392f     // Catch: java.lang.Throwable -> L2e
            Q3.F.f(r7)     // Catch: java.lang.Throwable -> L2e
        L7e:
            r7 = r3
            goto L84
        L80:
            w3.d r7 = e1.AbstractC0367g.h(r7)
        L84:
            java.lang.Throwable r7 = w3.e.a(r7)
            if (r7 == 0) goto L3f
            o3.H r2 = y1.EnumC0755e.f6846a
            java.lang.String r7 = y1.AbstractC0752b.q(r7)
            r2.getClass()
            y1.e r7 = o3.C0592H.i(r7)
            y1.e r2 = y1.EnumC0755e.f6848c
            if (r7 == r2) goto L3f
            V3.d r7 = r6.f6392f
            Q3.F.f(r7)
            goto L3f
        La1:
            r1 = r3
        La2:
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: r2.r.b(r2.r, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:31:0x0067  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object c(A3.c r10) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 360
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: r2.r.c(A3.c):java.lang.Object");
    }
}
