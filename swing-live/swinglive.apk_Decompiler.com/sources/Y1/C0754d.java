package y1;

import J3.i;
import android.os.SystemClock;
import m1.C0553h;

/* JADX INFO: renamed from: y1.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0754d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0553h f6842a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public long f6843b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public long f6844c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public long f6845d;

    public C0754d(C0553h c0553h) {
        i.e(c0553h, "bitrateChecker");
        this.f6842a = c0553h;
        this.f6845d = SystemClock.elapsedRealtime();
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object a(long r9, A3.c r11) {
        /*
            r8 = this;
            boolean r0 = r11 instanceof y1.C0753c
            if (r0 == 0) goto L13
            r0 = r11
            y1.c r0 = (y1.C0753c) r0
            int r1 = r0.f6841c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f6841c = r1
            goto L18
        L13:
            y1.c r0 = new y1.c
            r0.<init>(r8, r11)
        L18:
            java.lang.Object r11 = r0.f6839a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f6841c
            r3 = 0
            r5 = 1
            if (r2 == 0) goto L31
            if (r2 != r5) goto L29
            e1.AbstractC0367g.M(r11)
            goto L72
        L29:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r10 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r10)
            throw r9
        L31:
            e1.AbstractC0367g.M(r11)
            long r6 = r8.f6843b
            long r6 = r6 + r9
            r8.f6843b = r6
            long r9 = android.os.SystemClock.elapsedRealtime()
            long r6 = r8.f6845d
            long r9 = r9 - r6
            r6 = 1000(0x3e8, double:4.94E-321)
            int r11 = (r9 > r6 ? 1 : (r9 == r6 ? 0 : -1))
            if (r11 < 0) goto L7a
            long r6 = r8.f6843b
            float r11 = (float) r6
            float r9 = (float) r9
            r10 = 1148846080(0x447a0000, float:1000.0)
            float r9 = r9 / r10
            float r11 = r11 / r9
            long r9 = (long) r11
            long r6 = r8.f6844c
            int r11 = (r6 > r3 ? 1 : (r6 == r3 ? 0 : -1))
            if (r11 != 0) goto L57
            r8.f6844c = r9
        L57:
            long r6 = r8.f6844c
            float r11 = (float) r6
            long r9 = r9 - r6
            float r9 = (float) r9
            r10 = 1065353216(0x3f800000, float:1.0)
            float r10 = r10 * r9
            float r10 = r10 + r11
            long r9 = (long) r10
            r8.f6844c = r9
            b.d r9 = new b.d
            r10 = 3
            r9.<init>(r8, r10)
            r0.f6841c = r5
            java.lang.Object r9 = y1.AbstractC0752b.e(r9, r0)
            if (r9 != r1) goto L72
            return r1
        L72:
            long r9 = android.os.SystemClock.elapsedRealtime()
            r8.f6845d = r9
            r8.f6843b = r3
        L7a:
            w3.i r9 = w3.i.f6729a
            return r9
        */
        throw new UnsupportedOperationException("Method not decompiled: y1.C0754d.a(long, A3.c):java.lang.Object");
    }
}
