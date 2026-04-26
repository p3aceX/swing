package M1;

import J3.i;
import android.hardware.camera2.CameraCaptureSession;

/* JADX INFO: loaded from: classes.dex */
public final class d extends CameraCaptureSession.StateCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ a f1067a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ b f1068b;

    public d(a aVar, b bVar) {
        this.f1067a = aVar;
        this.f1068b = bVar;
    }

    @Override // android.hardware.camera2.CameraCaptureSession.StateCallback
    public final void onConfigureFailed(CameraCaptureSession cameraCaptureSession) {
        i.e(cameraCaptureSession, "cameraCaptureSession");
        this.f1068b.invoke(cameraCaptureSession);
    }

    @Override // android.hardware.camera2.CameraCaptureSession.StateCallback
    public final void onConfigured(CameraCaptureSession cameraCaptureSession) {
        i.e(cameraCaptureSession, "cameraCaptureSession");
        this.f1067a.invoke(cameraCaptureSession);
    }
}
