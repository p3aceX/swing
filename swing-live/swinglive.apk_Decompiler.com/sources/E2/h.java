package E2;

import a3.C0189a;
import d3.C0359a;
import f3.C0403a;
import java.util.HashMap;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class h {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static volatile h f377b;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashMap f378a;

    public h(int i4) {
        switch (i4) {
            case 1:
                this.f378a = new HashMap();
                break;
            default:
                this.f378a = new HashMap();
                break;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:14:0x00b4  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static E2.h g(p1.d r7, D2.v r8, D2.AbstractActivityC0029d r9, y0.C0747k r10, int r11) {
        /*
            Method dump skipped, instruction units count: 280
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: E2.h.g(p1.d, D2.v, D2.d, y0.k, int):E2.h");
    }

    public X2.a a() {
        U2.a aVar = (U2.a) this.f378a.get("EXPOSURE_OFFSET");
        Objects.requireNonNull(aVar);
        return (X2.a) aVar;
    }

    public Y2.a b() {
        U2.a aVar = (U2.a) this.f378a.get("EXPOSURE_POINT");
        Objects.requireNonNull(aVar);
        return (Y2.a) aVar;
    }

    public C0189a c() {
        U2.a aVar = (U2.a) this.f378a.get("FOCUS_POINT");
        Objects.requireNonNull(aVar);
        return (C0189a) aVar;
    }

    public C0359a d() {
        U2.a aVar = (U2.a) this.f378a.get("RESOLUTION");
        Objects.requireNonNull(aVar);
        return (C0359a) aVar;
    }

    public e3.c e() {
        U2.a aVar = (U2.a) this.f378a.get("SENSOR_ORIENTATION");
        Objects.requireNonNull(aVar);
        return (e3.c) aVar;
    }

    public C0403a f() {
        U2.a aVar = (U2.a) this.f378a.get("ZOOM_LEVEL");
        Objects.requireNonNull(aVar);
        return (C0403a) aVar;
    }
}
