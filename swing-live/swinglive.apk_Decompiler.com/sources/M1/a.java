package M1;

import I3.l;
import J3.i;
import O.RunnableC0093d;
import Q3.C;
import Q3.F;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import io.ktor.utils.io.C0449m;
import o3.C0588D;
import o3.x;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class a implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1060a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1061b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f1062c;

    public /* synthetic */ a(int i4, Object obj, Object obj2) {
        this.f1060a = i4;
        this.f1061b = obj;
        this.f1062c = obj2;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        switch (this.f1060a) {
            case 0:
                CaptureRequest captureRequest = (CaptureRequest) this.f1062c;
                CameraCaptureSession cameraCaptureSession = (CameraCaptureSession) obj;
                i.e(cameraCaptureSession, "it");
                e eVar = (e) this.f1061b;
                eVar.f1073f = cameraCaptureSession;
                try {
                    cameraCaptureSession.setRepeatingRequest(captureRequest, null, eVar.e);
                } catch (IllegalStateException unused) {
                    eVar.h(eVar.f1075h);
                } catch (Exception e) {
                    Log.e(eVar.f1069a, "Error", e);
                }
                break;
            case 1:
                ((R3.d) this.f1061b).f1714c.removeCallbacks((RunnableC0093d) this.f1062c);
                break;
            case 2:
                ((Y3.c) this.f1062c).getClass();
                ((Y3.d) this.f1061b).e(null);
                break;
            default:
                C c5 = new C("cio-tls-closer");
                C0449m c0449m = (C0449m) this.f1062c;
                C0588D c0588d = (C0588D) this.f1061b;
                F.s(c0588d, c5, new x(c0449m, c0588d, null), 2);
                break;
        }
        return w3.i.f6729a;
    }
}
