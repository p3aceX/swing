package e2;

import b2.C0246b;
import e1.AbstractC0367g;
import m1.C0553h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class Q extends A1.d {

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final r f4076j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public H0.a f4077k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public H0.a f4078l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public AbstractC0367g f4079m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public Q(C0553h c0553h, r rVar) {
        super(c0553h, "RtmpSender");
        J3.i.e(c0553h, "connectChecker");
        this.f4076j = rVar;
        this.f4077k = new C0246b(0);
        this.f4078l = new C0246b(1);
    }

    /* JADX WARN: Code restructure failed: missing block: B:34:0x008e, code lost:
    
        if (r9.f((B1.d) r12, r10, r0) != r1) goto L36;
     */
    /* JADX WARN: Removed duplicated region for block: B:25:0x0055  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x007a  */
    /* JADX WARN: Removed duplicated region for block: B:32:0x007b  */
    /* JADX WARN: Removed duplicated region for block: B:40:0x009d  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:34:0x008e -> B:36:0x0091). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:37:0x0093 -> B:38:0x0097). Please report as a decompilation issue!!! */
    @Override // A1.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object a(A3.c r12) {
        /*
            r11 = this;
            boolean r0 = r12 instanceof e2.O
            if (r0 == 0) goto L13
            r0 = r12
            e2.O r0 = (e2.O) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            e2.O r0 = new e2.O
            r0.<init>(r11, r12)
        L18:
            java.lang.Object r12 = r0.f4069c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            w3.i r3 = w3.i.f6729a
            r4 = 0
            r5 = 0
            r6 = 3
            r7 = 2
            r8 = 1
            if (r2 == 0) goto L52
            if (r2 == r8) goto L48
            if (r2 == r7) goto L3e
            if (r2 != r6) goto L36
            java.lang.Object r0 = r0.f4067a
            java.lang.Throwable r0 = (java.lang.Throwable) r0
            e1.AbstractC0367g.M(r12)
            goto Laf
        L36:
            java.lang.IllegalStateException r12 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r12.<init>(r0)
            throw r12
        L3e:
            java.lang.Object r2 = r0.f4067a
            e2.Q r2 = (e2.Q) r2
            e1.AbstractC0367g.M(r12)     // Catch: java.lang.Throwable -> L46
            goto L91
        L46:
            r12 = move-exception
            goto L93
        L48:
            int r2 = r0.f4068b
            java.lang.Object r9 = r0.f4067a
            e2.Q r9 = (e2.Q) r9
            e1.AbstractC0367g.M(r12)     // Catch: java.lang.Throwable -> L46
            goto L7d
        L52:
            e1.AbstractC0367g.M(r12)
        L55:
            V3.d r12 = r11.f82h
            boolean r12 = Q3.F.q(r12)
            if (r12 == 0) goto Lb8
            boolean r12 = r11.f78c
            if (r12 == 0) goto Lb8
            b.d r12 = new b.d     // Catch: java.lang.Throwable -> L46
            r2 = 1
            r12.<init>(r11, r2)     // Catch: java.lang.Throwable -> L46
            r0.f4067a = r11     // Catch: java.lang.Throwable -> L46
            r0.f4068b = r5     // Catch: java.lang.Throwable -> L46
            r0.e = r8     // Catch: java.lang.Throwable -> L46
            y3.i r2 = y3.C0768i.f6945a     // Catch: java.lang.Throwable -> L46
            Q3.f0 r9 = new Q3.f0     // Catch: java.lang.Throwable -> L46
            r9.<init>(r12, r4)     // Catch: java.lang.Throwable -> L46
            java.lang.Object r12 = Q3.F.B(r2, r9, r0)     // Catch: java.lang.Throwable -> L46
            if (r12 != r1) goto L7b
            goto Lad
        L7b:
            r9 = r11
            r2 = r5
        L7d:
            B1.d r12 = (B1.d) r12     // Catch: java.lang.Throwable -> L46
            e2.P r10 = new e2.P     // Catch: java.lang.Throwable -> L46
            r10.<init>(r9, r4)     // Catch: java.lang.Throwable -> L46
            r0.f4067a = r4     // Catch: java.lang.Throwable -> L46
            r0.f4068b = r2     // Catch: java.lang.Throwable -> L46
            r0.e = r7     // Catch: java.lang.Throwable -> L46
            java.lang.Object r12 = r9.f(r12, r10, r0)     // Catch: java.lang.Throwable -> L46
            if (r12 != r1) goto L91
            goto Lad
        L91:
            r12 = r3
            goto L97
        L93:
            w3.d r12 = e1.AbstractC0367g.h(r12)
        L97:
            java.lang.Throwable r12 = w3.e.a(r12)
            if (r12 == 0) goto L55
            e2.D r2 = new e2.D
            r4 = 1
            r2.<init>(r4, r11, r12)
            r0.f4067a = r12
            r0.e = r6
            java.lang.Object r0 = y1.AbstractC0752b.e(r2, r0)
            if (r0 != r1) goto Lae
        Lad:
            return r1
        Lae:
            r0 = r12
        Laf:
            java.lang.String r12 = r11.f77b
            java.lang.String r1 = "send error: "
            android.util.Log.e(r12, r1, r0)
            r11.f78c = r5
        Lb8:
            return r3
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.Q.a(A3.c):java.lang.Object");
    }

    @Override // A1.d
    public final void e(boolean z4) {
        this.f4077k.a0(z4);
        this.f4078l.a0(z4);
    }

    public final Object f(B1.d dVar, P p4, O o4) {
        w3.i iVar = w3.i.f6729a;
        if (dVar != null) {
            int iOrdinal = dVar.f117c.ordinal();
            if (iOrdinal == 0) {
                Object objL = this.f4078l.l(dVar, new M(p4, null), o4);
                if (objL == EnumC0789a.f6999a) {
                    return objL;
                }
            } else {
                if (iOrdinal != 1) {
                    throw new A0.b();
                }
                Object objL2 = this.f4077k.l(dVar, new N(p4, null), o4);
                if (objL2 == EnumC0789a.f6999a) {
                    return objL2;
                }
            }
        }
        return iVar;
    }
}
