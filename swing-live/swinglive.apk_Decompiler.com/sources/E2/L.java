package e2;

import Q3.y0;
import e1.AbstractC0367g;
import m1.C0553h;

/* JADX INFO: loaded from: classes.dex */
public final class L {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0553h f4048a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String[] f4049b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public AbstractC0367g f4050c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public V3.d f4051d;
    public V3.d e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public y0 f4052f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final r f4053g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final Q f4054h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public volatile boolean f4055i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public boolean f4056j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public boolean f4057k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public boolean f4058l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C1.a f4059m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final long f4060n;

    public L(C0553h c0553h) {
        J3.i.e(c0553h, "connectChecker");
        this.f4048a = c0553h;
        this.f4049b = new String[]{"rtmp", "rtmps", "rtmpt", "rtmpts"};
        X3.e eVar = Q3.O.f1596a;
        X3.d dVar = X3.d.f2437c;
        this.f4051d = Q3.F.b(dVar);
        this.e = Q3.F.b(dVar);
        r rVar = new r();
        this.f4053g = rVar;
        this.f4054h = new Q(c0553h, rVar);
        this.f4059m = C1.a.f123a;
        this.f4060n = 5000L;
    }

    /* JADX WARN: Removed duplicated region for block: B:28:0x0077  */
    /* JADX WARN: Removed duplicated region for block: B:36:0x008e  */
    /* JADX WARN: Removed duplicated region for block: B:42:0x00b4  */
    /* JADX WARN: Removed duplicated region for block: B:54:? A[RETURN, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0017  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object a(e2.L r8, boolean r9, A3.c r10) {
        /*
            Method dump skipped, instruction units count: 272
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.L.a(e2.L, boolean, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:24:0x0047  */
    /* JADX WARN: Removed duplicated region for block: B:45:0x008a  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:32:0x0059 -> B:41:0x007e). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:34:0x0064 -> B:41:0x007e). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:39:0x0078 -> B:40:0x0079). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object b(e2.L r6, A3.c r7) {
        /*
            boolean r0 = r7 instanceof e2.C0379K
            if (r0 == 0) goto L13
            r0 = r7
            e2.K r0 = (e2.C0379K) r0
            int r1 = r0.f4047d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4047d = r1
            goto L18
        L13:
            e2.K r0 = new e2.K
            r0.<init>(r6, r7)
        L18:
            java.lang.Object r7 = r0.f4045b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4047d
            w3.i r3 = w3.i.f6729a
            r4 = 2
            r5 = 1
            if (r2 == 0) goto L3c
            if (r2 == r5) goto L38
            if (r2 != r4) goto L30
            e2.L r2 = r0.f4044a
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
            V3.d r7 = r6.f4051d
            boolean r7 = Q3.F.q(r7)
            if (r7 == 0) goto La1
            boolean r7 = r6.f4055i
            if (r7 == 0) goto La1
            e1.g r7 = r6.f4050c     // Catch: java.lang.Throwable -> L2e
            if (r7 == 0) goto L54
            boolean r7 = r7.x()     // Catch: java.lang.Throwable -> L2e
            goto L55
        L54:
            r7 = 0
        L55:
            if (r7 == 0) goto L67
            boolean r7 = r6.f4057k     // Catch: java.lang.Throwable -> L2e
            if (r7 != 0) goto L7e
            r7 = 0
            r0.f4044a = r7     // Catch: java.lang.Throwable -> L2e
            r0.f4047d = r5     // Catch: java.lang.Throwable -> L2e
            java.lang.Object r7 = r6.e(r0)     // Catch: java.lang.Throwable -> L2e
            if (r7 != r1) goto L7e
            goto La2
        L67:
            e2.z r7 = new e2.z     // Catch: java.lang.Throwable -> L2e
            r2 = 5
            r7.<init>(r6, r2)     // Catch: java.lang.Throwable -> L2e
            r0.f4044a = r6     // Catch: java.lang.Throwable -> L2e
            r0.f4047d = r4     // Catch: java.lang.Throwable -> L2e
            java.lang.Object r7 = y1.AbstractC0752b.e(r7, r0)     // Catch: java.lang.Throwable -> L2e
            if (r7 != r1) goto L78
            goto La2
        L78:
            r2 = r6
        L79:
            V3.d r7 = r2.f4051d     // Catch: java.lang.Throwable -> L2e
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
            V3.d r7 = r6.f4051d
            Q3.F.f(r7)
            goto L3f
        La1:
            r1 = r3
        La2:
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.L.b(e2.L, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object c(A3.c r5) {
        /*
            r4 = this;
            boolean r0 = r5 instanceof e2.C0371C
            if (r0 == 0) goto L13
            r0 = r5
            e2.C r0 = (e2.C0371C) r0
            int r1 = r0.f4015c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4015c = r1
            goto L18
        L13:
            e2.C r0 = new e2.C
            r0.<init>(r4, r5)
        L18:
            java.lang.Object r5 = r0.f4013a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4015c
            r3 = 1
            if (r2 == 0) goto L2f
            if (r2 != r3) goto L27
            e1.AbstractC0367g.M(r5)
            goto L3f
        L27:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r0)
            throw r5
        L2f:
            e1.AbstractC0367g.M(r5)
            e1.g r5 = r4.f4050c
            if (r5 == 0) goto L3f
            r0.f4015c = r3
            java.lang.Object r5 = r5.c(r0)
            if (r5 != r1) goto L3f
            return r1
        L3f:
            e2.r r5 = r4.f4053g
            r0 = 0
            r5.f4184b = r0
            r5.f4186d = r0
            r5.f4185c = r0
            r1 = 128(0x80, float:1.8E-43)
            r5.f4195n = r1
            com.google.android.gms.common.internal.r r1 = r5.f4183a
            java.lang.Object r2 = r1.f3597b
            java.util.HashMap r2 = (java.util.HashMap) r2
            r2.clear()
            java.lang.Object r1 = r1.f3598c
            java.util.List r1 = (java.util.List) r1
            r1.clear()
            r5.f4198q = r0
            r5.f4197p = r0
            w3.i r5 = w3.i.f6729a
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.L.c(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:33:0x00a0  */
    /* JADX WARN: Removed duplicated region for block: B:35:0x00a3  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0017  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object d(A3.c r19) {
        /*
            r18 = this;
            r0 = r18
            r1 = r19
            boolean r2 = r1 instanceof e2.C0377I
            if (r2 == 0) goto L17
            r2 = r1
            e2.I r2 = (e2.C0377I) r2
            int r3 = r2.e
            r4 = -2147483648(0xffffffff80000000, float:-0.0)
            r5 = r3 & r4
            if (r5 == 0) goto L17
            int r3 = r3 - r4
            r2.e = r3
            goto L1c
        L17:
            e2.I r2 = new e2.I
            r2.<init>(r0, r1)
        L1c:
            java.lang.Object r1 = r2.f4036c
            z3.a r3 = z3.EnumC0789a.f6999a
            int r4 = r2.e
            e2.r r5 = r0.f4053g
            r6 = 1000(0x3e8, float:1.401E-42)
            r7 = 2
            r8 = 1
            if (r4 == 0) goto L42
            if (r4 == r8) goto L3c
            if (r4 != r7) goto L34
            long r2 = r2.f4035b
            e1.AbstractC0367g.M(r1)
            goto L98
        L34:
            java.lang.IllegalStateException r1 = new java.lang.IllegalStateException
            java.lang.String r2 = "call to 'resume' before 'invoke' with coroutine"
            r1.<init>(r2)
            throw r1
        L3c:
            e1.g r4 = r2.f4034a
            e1.AbstractC0367g.M(r1)
            goto L75
        L42:
            e1.AbstractC0367g.M(r1)
            boolean r1 = r0.f4057k
            if (r1 == 0) goto L56
            m2.i r1 = new m2.i
            java.lang.String r4 = r5.e
            int r9 = r5.f4187f
            boolean r10 = r0.f4056j
            r1.<init>(r4, r9, r10)
            r4 = r1
            goto L68
        L56:
            m2.e r11 = new m2.e
            java.lang.String r13 = r5.e
            int r14 = r5.f4187f
            boolean r15 = r0.f4056j
            long r9 = r0.f4060n
            C1.a r12 = r0.f4059m
            r16 = r9
            r11.<init>(r12, r13, r14, r15, r16)
            r4 = r11
        L68:
            r0.f4050c = r4
            r2.f4034a = r4
            r2.e = r8
            java.lang.Object r1 = r4.f(r2)
            if (r1 != r3) goto L75
            goto L96
        L75:
            boolean r1 = r4.x()
            if (r1 != 0) goto L7e
            java.lang.Boolean r1 = java.lang.Boolean.FALSE
            return r1
        L7e:
            long r8 = android.os.SystemClock.elapsedRealtime()
            long r10 = (long) r6
            long r8 = r8 / r10
            D2.A r1 = new D2.A
            r1.<init>()
            r10 = 0
            r2.f4034a = r10
            r2.f4035b = r8
            r2.e = r7
            java.lang.Object r1 = r1.e(r4, r2)
            if (r1 != r3) goto L97
        L96:
            return r3
        L97:
            r2 = r8
        L98:
            java.lang.Boolean r1 = (java.lang.Boolean) r1
            boolean r1 = r1.booleanValue()
            if (r1 != 0) goto La3
            java.lang.Boolean r1 = java.lang.Boolean.FALSE
            return r1
        La3:
            int r1 = (int) r2
            r5.f4184b = r1
            long r1 = android.os.SystemClock.elapsedRealtimeNanos()
            long r3 = (long) r6
            long r1 = r1 / r3
            java.lang.Boolean r1 = java.lang.Boolean.TRUE
            return r1
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.L.d(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:103:0x01c9  */
    /* JADX WARN: Removed duplicated region for block: B:122:0x0224  */
    /* JADX WARN: Removed duplicated region for block: B:126:0x0230  */
    /* JADX WARN: Removed duplicated region for block: B:133:0x027b  */
    /* JADX WARN: Removed duplicated region for block: B:141:0x029e  */
    /* JADX WARN: Removed duplicated region for block: B:178:0x032a  */
    /* JADX WARN: Removed duplicated region for block: B:181:0x033e  */
    /* JADX WARN: Removed duplicated region for block: B:182:0x0340 A[Catch: ClassCastException -> 0x0068, PHI: r3 r4 r6 r21 r26
      0x0340: PHI (r3v46 java.lang.String) = (r3v44 java.lang.String), (r3v51 java.lang.String) binds: [B:180:0x033c, B:30:0x0081] A[DONT_GENERATE, DONT_INLINE]
      0x0340: PHI (r4v61 java.lang.String) = (r4v58 java.lang.String), (r4v73 java.lang.String) binds: [B:180:0x033c, B:30:0x0081] A[DONT_GENERATE, DONT_INLINE]
      0x0340: PHI (r6v19 java.lang.String) = (r6v17 java.lang.String), (r6v23 java.lang.String) binds: [B:180:0x033c, B:30:0x0081] A[DONT_GENERATE, DONT_INLINE]
      0x0340: PHI (r21v3 java.lang.String) = (r21v1 java.lang.String), (r21v4 java.lang.String) binds: [B:180:0x033c, B:30:0x0081] A[DONT_GENERATE, DONT_INLINE]
      0x0340: PHI (r26v6 java.lang.String) = (r26v4 java.lang.String), (r26v7 java.lang.String) binds: [B:180:0x033c, B:30:0x0081] A[DONT_GENERATE, DONT_INLINE], TryCatch #0 {ClassCastException -> 0x0068, blocks: (B:22:0x0063, B:25:0x006b, B:223:0x0404, B:225:0x0408, B:228:0x0432, B:229:0x0437, B:26:0x0073, B:220:0x03f0, B:29:0x007e, B:182:0x0340, B:184:0x0344, B:187:0x034f, B:189:0x0355, B:192:0x036d, B:196:0x0373, B:199:0x038c, B:201:0x0394, B:204:0x03a0, B:208:0x03a6, B:211:0x03c1, B:212:0x03c8, B:32:0x008c, B:179:0x032c, B:144:0x02bc, B:146:0x02c2, B:153:0x02d7, B:156:0x02df, B:158:0x02e7, B:161:0x02f1, B:163:0x02f5, B:165:0x02f9, B:167:0x02ff, B:173:0x0311, B:176:0x0318, B:213:0x03c9, B:215:0x03d3, B:217:0x03db, B:230:0x0438, B:232:0x0440, B:235:0x046a, B:238:0x0485, B:241:0x04a0, B:247:0x04b2, B:244:0x04a9, B:248:0x04cf), top: B:275:0x0041 }] */
    /* JADX WARN: Removed duplicated region for block: B:184:0x0344 A[Catch: ClassCastException -> 0x0068, TRY_LEAVE, TryCatch #0 {ClassCastException -> 0x0068, blocks: (B:22:0x0063, B:25:0x006b, B:223:0x0404, B:225:0x0408, B:228:0x0432, B:229:0x0437, B:26:0x0073, B:220:0x03f0, B:29:0x007e, B:182:0x0340, B:184:0x0344, B:187:0x034f, B:189:0x0355, B:192:0x036d, B:196:0x0373, B:199:0x038c, B:201:0x0394, B:204:0x03a0, B:208:0x03a6, B:211:0x03c1, B:212:0x03c8, B:32:0x008c, B:179:0x032c, B:144:0x02bc, B:146:0x02c2, B:153:0x02d7, B:156:0x02df, B:158:0x02e7, B:161:0x02f1, B:163:0x02f5, B:165:0x02f9, B:167:0x02ff, B:173:0x0311, B:176:0x0318, B:213:0x03c9, B:215:0x03d3, B:217:0x03db, B:230:0x0438, B:232:0x0440, B:235:0x046a, B:238:0x0485, B:241:0x04a0, B:247:0x04b2, B:244:0x04a9, B:248:0x04cf), top: B:275:0x0041 }] */
    /* JADX WARN: Removed duplicated region for block: B:211:0x03c1 A[Catch: ClassCastException -> 0x0068, TryCatch #0 {ClassCastException -> 0x0068, blocks: (B:22:0x0063, B:25:0x006b, B:223:0x0404, B:225:0x0408, B:228:0x0432, B:229:0x0437, B:26:0x0073, B:220:0x03f0, B:29:0x007e, B:182:0x0340, B:184:0x0344, B:187:0x034f, B:189:0x0355, B:192:0x036d, B:196:0x0373, B:199:0x038c, B:201:0x0394, B:204:0x03a0, B:208:0x03a6, B:211:0x03c1, B:212:0x03c8, B:32:0x008c, B:179:0x032c, B:144:0x02bc, B:146:0x02c2, B:153:0x02d7, B:156:0x02df, B:158:0x02e7, B:161:0x02f1, B:163:0x02f5, B:165:0x02f9, B:167:0x02ff, B:173:0x0311, B:176:0x0318, B:213:0x03c9, B:215:0x03d3, B:217:0x03db, B:230:0x0438, B:232:0x0440, B:235:0x046a, B:238:0x0485, B:241:0x04a0, B:247:0x04b2, B:244:0x04a9, B:248:0x04cf), top: B:275:0x0041 }] */
    /* JADX WARN: Removed duplicated region for block: B:222:0x0402  */
    /* JADX WARN: Removed duplicated region for block: B:223:0x0404 A[Catch: ClassCastException -> 0x0068, PHI: r4 r20
      0x0404: PHI (r4v76 java.lang.String) = (r4v74 java.lang.String), (r4v80 java.lang.String) binds: [B:221:0x0400, B:25:0x006b] A[DONT_GENERATE, DONT_INLINE]
      0x0404: PHI (r20v3 java.lang.String) = (r20v1 java.lang.String), (r20v4 java.lang.String) binds: [B:221:0x0400, B:25:0x006b] A[DONT_GENERATE, DONT_INLINE], TryCatch #0 {ClassCastException -> 0x0068, blocks: (B:22:0x0063, B:25:0x006b, B:223:0x0404, B:225:0x0408, B:228:0x0432, B:229:0x0437, B:26:0x0073, B:220:0x03f0, B:29:0x007e, B:182:0x0340, B:184:0x0344, B:187:0x034f, B:189:0x0355, B:192:0x036d, B:196:0x0373, B:199:0x038c, B:201:0x0394, B:204:0x03a0, B:208:0x03a6, B:211:0x03c1, B:212:0x03c8, B:32:0x008c, B:179:0x032c, B:144:0x02bc, B:146:0x02c2, B:153:0x02d7, B:156:0x02df, B:158:0x02e7, B:161:0x02f1, B:163:0x02f5, B:165:0x02f9, B:167:0x02ff, B:173:0x0311, B:176:0x0318, B:213:0x03c9, B:215:0x03d3, B:217:0x03db, B:230:0x0438, B:232:0x0440, B:235:0x046a, B:238:0x0485, B:241:0x04a0, B:247:0x04b2, B:244:0x04a9, B:248:0x04cf), top: B:275:0x0041 }] */
    /* JADX WARN: Removed duplicated region for block: B:225:0x0408 A[Catch: ClassCastException -> 0x0068, TryCatch #0 {ClassCastException -> 0x0068, blocks: (B:22:0x0063, B:25:0x006b, B:223:0x0404, B:225:0x0408, B:228:0x0432, B:229:0x0437, B:26:0x0073, B:220:0x03f0, B:29:0x007e, B:182:0x0340, B:184:0x0344, B:187:0x034f, B:189:0x0355, B:192:0x036d, B:196:0x0373, B:199:0x038c, B:201:0x0394, B:204:0x03a0, B:208:0x03a6, B:211:0x03c1, B:212:0x03c8, B:32:0x008c, B:179:0x032c, B:144:0x02bc, B:146:0x02c2, B:153:0x02d7, B:156:0x02df, B:158:0x02e7, B:161:0x02f1, B:163:0x02f5, B:165:0x02f9, B:167:0x02ff, B:173:0x0311, B:176:0x0318, B:213:0x03c9, B:215:0x03d3, B:217:0x03db, B:230:0x0438, B:232:0x0440, B:235:0x046a, B:238:0x0485, B:241:0x04a0, B:247:0x04b2, B:244:0x04a9, B:248:0x04cf), top: B:275:0x0041 }] */
    /* JADX WARN: Removed duplicated region for block: B:228:0x0432 A[Catch: ClassCastException -> 0x0068, TryCatch #0 {ClassCastException -> 0x0068, blocks: (B:22:0x0063, B:25:0x006b, B:223:0x0404, B:225:0x0408, B:228:0x0432, B:229:0x0437, B:26:0x0073, B:220:0x03f0, B:29:0x007e, B:182:0x0340, B:184:0x0344, B:187:0x034f, B:189:0x0355, B:192:0x036d, B:196:0x0373, B:199:0x038c, B:201:0x0394, B:204:0x03a0, B:208:0x03a6, B:211:0x03c1, B:212:0x03c8, B:32:0x008c, B:179:0x032c, B:144:0x02bc, B:146:0x02c2, B:153:0x02d7, B:156:0x02df, B:158:0x02e7, B:161:0x02f1, B:163:0x02f5, B:165:0x02f9, B:167:0x02ff, B:173:0x0311, B:176:0x0318, B:213:0x03c9, B:215:0x03d3, B:217:0x03db, B:230:0x0438, B:232:0x0440, B:235:0x046a, B:238:0x0485, B:241:0x04a0, B:247:0x04b2, B:244:0x04a9, B:248:0x04cf), top: B:275:0x0041 }] */
    /* JADX WARN: Removed duplicated region for block: B:252:0x04f3  */
    /* JADX WARN: Removed duplicated region for block: B:254:0x0512  */
    /* JADX WARN: Removed duplicated region for block: B:257:0x0523  */
    /* JADX WARN: Removed duplicated region for block: B:259:0x052a  */
    /* JADX WARN: Removed duplicated region for block: B:264:0x054c A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:267:0x0568  */
    /* JADX WARN: Removed duplicated region for block: B:269:0x056b  */
    /* JADX WARN: Removed duplicated region for block: B:271:0x056e  */
    /* JADX WARN: Removed duplicated region for block: B:34:0x0096 A[PHI: r3 r4 r6 r21 r26
      0x0096: PHI (r3v44 java.lang.String) = (r3v9 java.lang.String), (r3v45 java.lang.String) binds: [B:177:0x0328, B:33:0x008f] A[DONT_GENERATE, DONT_INLINE]
      0x0096: PHI (r4v58 java.lang.String) = (r4v30 java.lang.String), (r4v60 java.lang.String) binds: [B:177:0x0328, B:33:0x008f] A[DONT_GENERATE, DONT_INLINE]
      0x0096: PHI (r6v17 java.lang.String) = (r6v7 java.lang.String), (r6v18 java.lang.String) binds: [B:177:0x0328, B:33:0x008f] A[DONT_GENERATE, DONT_INLINE]
      0x0096: PHI (r21v1 java.lang.String) = (r21v0 java.lang.String), (r21v2 java.lang.String) binds: [B:177:0x0328, B:33:0x008f] A[DONT_GENERATE, DONT_INLINE]
      0x0096: PHI (r26v4 java.lang.String) = (r26v3 java.lang.String), (r26v5 java.lang.String) binds: [B:177:0x0328, B:33:0x008f] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:58:0x00fd  */
    /* JADX WARN: Removed duplicated region for block: B:61:0x010b  */
    /* JADX WARN: Removed duplicated region for block: B:63:0x0111  */
    /* JADX WARN: Removed duplicated region for block: B:65:0x0114  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0028  */
    /* JADX WARN: Removed duplicated region for block: B:89:0x0197  */
    /* JADX WARN: Type inference failed for: r6v14 */
    /* JADX WARN: Type inference failed for: r6v24, types: [e1.g, g2.o, java.lang.String] */
    /* JADX WARN: Type inference failed for: r6v25 */
    /*  JADX ERROR: UnsupportedOperationException in pass: RegionMakerVisitor
        java.lang.UnsupportedOperationException
        	at java.base/java.util.Collections$UnmodifiableCollection.add(Collections.java:1091)
        	at jadx.core.dex.visitors.regions.maker.SwitchRegionMaker$1.leaveRegion(SwitchRegionMaker.java:390)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverseInternal(DepthRegionTraversal.java:70)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.lambda$traverseInternal$0(DepthRegionTraversal.java:68)
        	at java.base/java.util.ArrayList.forEach(ArrayList.java:1596)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverseInternal(DepthRegionTraversal.java:68)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverse(DepthRegionTraversal.java:23)
        	at jadx.core.dex.visitors.regions.maker.SwitchRegionMaker.insertBreaksForCase(SwitchRegionMaker.java:370)
        	at jadx.core.dex.visitors.regions.maker.SwitchRegionMaker.insertBreaks(SwitchRegionMaker.java:85)
        	at jadx.core.dex.visitors.regions.PostProcessRegions.leaveRegion(PostProcessRegions.java:33)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverseInternal(DepthRegionTraversal.java:70)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.lambda$traverseInternal$0(DepthRegionTraversal.java:68)
        	at java.base/java.util.ArrayList.forEach(ArrayList.java:1596)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverseInternal(DepthRegionTraversal.java:68)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverse(DepthRegionTraversal.java:19)
        	at jadx.core.dex.visitors.regions.PostProcessRegions.process(PostProcessRegions.java:23)
        	at jadx.core.dex.visitors.regions.RegionMakerVisitor.visit(RegionMakerVisitor.java:31)
        */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object e(A3.c r26) {
        /*
            Method dump skipped, instruction units count: 1528
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.L.e(A3.c):java.lang.Object");
    }
}
