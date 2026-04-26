package T2;

import I.C0053n;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import u1.C0690c;
import y0.C0747k;

/* JADX INFO: renamed from: T2.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class RunnableC0169n implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1980a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f1981b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f1982c;

    public /* synthetic */ RunnableC0169n(Object obj, int i4, int i5) {
        this.f1980a = i5;
        this.f1982c = obj;
        this.f1981b = i4;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f1980a) {
            case 0:
                C0747k c0747k = (C0747k) this.f1982c;
                int iB = K.j.b(this.f1981b);
                A a5 = A.PORTRAIT_UP;
                if (iB != 0) {
                    if (iB == 1) {
                        a5 = A.PORTRAIT_DOWN;
                    } else if (iB == 2) {
                        a5 = A.LANDSCAPE_LEFT;
                    } else if (iB == 3) {
                        a5 = A.LANDSCAPE_RIGHT;
                    }
                }
                p1.d dVar = new p1.d(17);
                C0690c c0690c = (C0690c) c0747k.f6832c;
                String str = "dev.flutter.pigeon.camera_android.CameraGlobalEventApi.deviceOrientationChanged";
                new C0053n((O2.f) c0690c.f6642b, str, w.f2004d, null, 5).x(new ArrayList(Collections.singletonList(a5)), new u(dVar, str, 3));
                break;
            default:
                int i4 = this.f1981b & 4;
                io.flutter.plugin.platform.f fVar = ((io.flutter.plugin.platform.e) this.f1982c).f4625b;
                if (i4 != 0) {
                    D2.v vVar = (D2.v) fVar.f4629d;
                    vVar.getClass();
                    ((C0747k) vVar.f260b).O("SystemChrome.systemUIChange", Arrays.asList(Boolean.FALSE), null);
                } else {
                    D2.v vVar2 = (D2.v) fVar.f4629d;
                    vVar2.getClass();
                    ((C0747k) vVar2.f260b).O("SystemChrome.systemUIChange", Arrays.asList(Boolean.TRUE), null);
                }
                break;
        }
    }
}
