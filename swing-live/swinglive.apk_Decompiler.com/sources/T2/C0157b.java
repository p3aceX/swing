package T2;

import O.RunnableC0093d;
import android.hardware.camera2.CameraDevice;
import android.os.Handler;
import android.util.Log;
import d3.C0359a;
import y0.C0747k;

/* JADX INFO: renamed from: T2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0157b extends CameraDevice.StateCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ C0359a f1930a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0161f f1931b;

    public C0157b(C0161f c0161f, C0359a c0359a) {
        this.f1931b = c0161f;
        this.f1930a = c0359a;
    }

    @Override // android.hardware.camera2.CameraDevice.StateCallback
    public final void onClosed(CameraDevice cameraDevice) {
        Log.i("Camera", "open | onClosed");
        C0161f c0161f = this.f1931b;
        c0161f.f1953o = null;
        if (c0161f.f1954p != null) {
            Log.i("Camera", "closeCaptureSession");
            c0161f.f1954p.close();
            c0161f.f1954p = null;
        }
        C0747k c0747k = c0161f.f1946h;
        ((Handler) c0747k.f6831b).post(new F1.a(c0747k, 11));
    }

    @Override // android.hardware.camera2.CameraDevice.StateCallback
    public final void onDisconnected(CameraDevice cameraDevice) {
        Log.i("Camera", "open | onDisconnected");
        C0161f c0161f = this.f1931b;
        c0161f.a();
        c0161f.f1946h.W("The camera was disconnected.");
    }

    @Override // android.hardware.camera2.CameraDevice.StateCallback
    public final void onError(CameraDevice cameraDevice, int i4) {
        Log.i("Camera", "open | onError");
        C0161f c0161f = this.f1931b;
        c0161f.a();
        c0161f.f1946h.W(i4 != 1 ? i4 != 2 ? i4 != 3 ? i4 != 4 ? i4 != 5 ? "Unknown camera error" : "The camera service has encountered a fatal error." : "The camera device has encountered a fatal error" : "The camera device could not be opened due to a device policy." : "Max cameras in use" : "The camera device is in use already.");
    }

    @Override // android.hardware.camera2.CameraDevice.StateCallback
    public final void onOpened(CameraDevice cameraDevice) {
        C0161f c0161f = this.f1931b;
        c0161f.f1953o = new D2.v(20, c0161f, cameraDevice);
        try {
            c0161f.p(c0161f.f1959u ? null : new RunnableC0093d(3, this, this.f1930a));
        } catch (Exception e) {
            c0161f.f1946h.W(e.getMessage() == null ? e.getClass().getName().concat(" occurred while opening camera.") : e.getMessage());
            c0161f.a();
        }
    }
}
