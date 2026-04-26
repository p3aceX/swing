package M1;

import J3.i;
import T2.C0161f;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.params.Face;

/* JADX INFO: loaded from: classes.dex */
public final class c extends CameraCaptureSession.CaptureCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1065a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1066b;

    public /* synthetic */ c(Object obj, int i4) {
        this.f1065a = i4;
        this.f1066b = obj;
    }

    @Override // android.hardware.camera2.CameraCaptureSession.CaptureCallback
    public final void onCaptureCompleted(CameraCaptureSession cameraCaptureSession, CaptureRequest captureRequest, TotalCaptureResult totalCaptureResult) {
        switch (this.f1065a) {
            case 0:
                i.e(cameraCaptureSession, "session");
                i.e(captureRequest, "request");
                i.e(totalCaptureResult, "result");
                e eVar = (e) this.f1066b;
                eVar.getClass();
                if (((Face[]) totalCaptureResult.get(CaptureResult.STATISTICS_FACES)) != null) {
                    eVar.getClass();
                    break;
                }
                break;
            default:
                ((C0161f) this.f1066b).q();
                break;
        }
    }

    @Override // android.hardware.camera2.CameraCaptureSession.CaptureCallback
    public void onCaptureStarted(CameraCaptureSession cameraCaptureSession, CaptureRequest captureRequest, long j4, long j5) {
        switch (this.f1065a) {
            case 0:
                i.e(cameraCaptureSession, "session");
                i.e(captureRequest, "request");
                ((e) this.f1066b).getClass();
                break;
            default:
                super.onCaptureStarted(cameraCaptureSession, captureRequest, j4, j5);
                break;
        }
    }
}
