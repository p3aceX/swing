package e3;

import D2.AbstractActivityC0029d;
import K.j;
import android.content.IntentFilter;
import android.view.WindowManager;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final IntentFilter f4234g = new IntentFilter("android.intent.action.CONFIGURATION_CHANGED");

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractActivityC0029d f4235a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0747k f4236b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f4237c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f4238d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public C0397a f4239f;

    public b(AbstractActivityC0029d abstractActivityC0029d, C0747k c0747k, boolean z4, int i4) {
        this.f4235a = abstractActivityC0029d;
        this.f4236b = c0747k;
        this.f4237c = z4;
        this.f4238d = i4;
    }

    /* JADX WARN: Removed duplicated region for block: B:14:0x001f  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final int a(int r6) {
        /*
            r5 = this;
            if (r6 != 0) goto L6
            int r6 = r5.b()
        L6:
            int r6 = K.j.b(r6)
            r0 = 270(0x10e, float:3.78E-43)
            if (r6 == 0) goto L27
            r1 = 1
            if (r6 == r1) goto L25
            r1 = 2
            r2 = 180(0xb4, float:2.52E-43)
            boolean r3 = r5.f4237c
            r4 = 0
            if (r6 == r1) goto L22
            r1 = 3
            if (r6 == r1) goto L1d
            goto L29
        L1d:
            if (r3 == 0) goto L20
        L1f:
            r2 = r4
        L20:
            r4 = r2
            goto L29
        L22:
            if (r3 == 0) goto L1f
            goto L20
        L25:
            r4 = r0
            goto L29
        L27:
            r4 = 90
        L29:
            int r6 = r5.f4238d
            int r4 = r4 + r6
            int r4 = r4 + r0
            int r4 = r4 % 360
            return r4
        */
        throw new UnsupportedOperationException("Method not decompiled: e3.b.a(int):int");
    }

    public final int b() {
        AbstractActivityC0029d abstractActivityC0029d = this.f4235a;
        int rotation = ((WindowManager) abstractActivityC0029d.getSystemService("window")).getDefaultDisplay().getRotation();
        int i4 = abstractActivityC0029d.getResources().getConfiguration().orientation;
        if (i4 != 1) {
            if (i4 == 2) {
                return (rotation == 0 || rotation == 1) ? 3 : 4;
            }
        } else if (rotation != 0 && rotation != 1) {
            return 2;
        }
        return 1;
    }

    public final int c(int i4) {
        if (i4 == 0) {
            i4 = b();
        }
        int iB = j.b(i4);
        int i5 = 0;
        if (iB != 0) {
            if (iB == 1) {
                i5 = 180;
            } else if (iB == 2) {
                i5 = 270;
            } else if (iB == 3) {
                i5 = 90;
            }
        }
        if (this.f4237c) {
            i5 *= -1;
        }
        return ((i5 + this.f4238d) + 360) % 360;
    }
}
