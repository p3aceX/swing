package T2;

import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import java.util.Iterator;

/* JADX INFO: renamed from: T2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0158c extends CameraCaptureSession.StateCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f1932a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Runnable f1933b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0161f f1934c;

    public C0158c(C0161f c0161f, Runnable runnable) {
        this.f1934c = c0161f;
        this.f1933b = runnable;
    }

    @Override // android.hardware.camera2.CameraCaptureSession.StateCallback
    public final void onClosed(CameraCaptureSession cameraCaptureSession) {
        Log.i("Camera", "CameraCaptureSession onClosed");
        this.f1932a = true;
    }

    @Override // android.hardware.camera2.CameraCaptureSession.StateCallback
    public final void onConfigureFailed(CameraCaptureSession cameraCaptureSession) {
        Log.i("Camera", "CameraCaptureSession onConfigureFailed");
        this.f1934c.f1946h.W("Failed to configure camera session.");
    }

    @Override // android.hardware.camera2.CameraCaptureSession.StateCallback
    public final void onConfigured(CameraCaptureSession cameraCaptureSession) {
        Log.i("Camera", "CameraCaptureSession onConfigured");
        C0161f c0161f = this.f1934c;
        if (c0161f.f1953o == null || this.f1932a) {
            c0161f.f1946h.W("The camera was closed during configuration.");
            return;
        }
        c0161f.f1954p = cameraCaptureSession;
        Log.i("Camera", "Updating builder settings");
        CaptureRequest.Builder builder = c0161f.f1957s;
        Iterator it = c0161f.f1940a.f378a.values().iterator();
        while (it.hasNext()) {
            ((U2.a) it.next()).a(builder);
        }
        c0161f.h(this.f1933b, new D2.u(this, 9));
    }
}
