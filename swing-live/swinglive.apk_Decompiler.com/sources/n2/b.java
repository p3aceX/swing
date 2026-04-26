package N2;

import I.C0053n;
import O2.s;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f1129a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1130b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f1131c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0053n f1132d;

    public b(F2.b bVar) {
        C0053n c0053n = new C0053n(bVar, "flutter/lifecycle", s.f1460b, null, 5);
        this.f1129a = 0;
        this.f1130b = 0;
        this.f1131c = true;
        this.f1132d = c0053n;
    }

    /* JADX WARN: Removed duplicated region for block: B:23:0x0029  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void a(int r5, boolean r6) {
        /*
            r4 = this;
            int r0 = r4.f1129a
            if (r0 != r5) goto L9
            boolean r1 = r4.f1131c
            if (r6 != r1) goto L9
            goto L32
        L9:
            if (r5 != 0) goto L10
            if (r0 != 0) goto L10
            r4.f1131c = r6
            return
        L10:
            int r0 = K.j.b(r5)
            if (r0 == 0) goto L29
            r1 = 1
            r2 = 3
            r3 = 2
            if (r0 == r1) goto L24
            if (r0 == r3) goto L29
            if (r0 == r2) goto L29
            r1 = 4
            if (r0 == r1) goto L29
            r0 = 0
            goto L2a
        L24:
            if (r6 == 0) goto L27
            r2 = r3
        L27:
            r0 = r2
            goto L2a
        L29:
            r0 = r5
        L2a:
            r4.f1129a = r5
            r4.f1131c = r6
            int r5 = r4.f1130b
            if (r0 != r5) goto L33
        L32:
            return
        L33:
            java.lang.StringBuilder r5 = new java.lang.StringBuilder
            java.lang.String r6 = "AppLifecycleState."
            r5.<init>(r6)
            r6 = 1
            if (r0 == r6) goto L57
            r6 = 2
            if (r0 == r6) goto L54
            r6 = 3
            if (r0 == r6) goto L51
            r6 = 4
            if (r0 == r6) goto L4e
            r6 = 5
            if (r0 != r6) goto L4c
            java.lang.String r6 = "PAUSED"
            goto L59
        L4c:
            r5 = 0
            throw r5
        L4e:
            java.lang.String r6 = "HIDDEN"
            goto L59
        L51:
            java.lang.String r6 = "INACTIVE"
            goto L59
        L54:
            java.lang.String r6 = "RESUMED"
            goto L59
        L57:
            java.lang.String r6 = "DETACHED"
        L59:
            java.util.Locale r1 = java.util.Locale.ROOT
            java.lang.String r6 = r6.toLowerCase(r1)
            r5.append(r6)
            java.lang.String r5 = r5.toString()
            I.n r6 = r4.f1132d
            r1 = 0
            r6.x(r5, r1)
            r4.f1130b = r0
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: N2.b.a(int, boolean):void");
    }
}
