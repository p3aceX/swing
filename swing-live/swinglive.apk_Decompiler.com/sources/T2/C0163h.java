package T2;

import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.util.Log;
import h3.C0415a;
import y0.C0747k;

/* JADX INFO: renamed from: T2.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0163h extends CameraCaptureSession.CaptureCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0161f f1968a;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final com.google.android.gms.common.internal.r f1970c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0747k f1971d;
    public final CaptureResult.Key e = CaptureResult.CONTROL_AE_STATE;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final CaptureResult.Key f1972f = CaptureResult.CONTROL_AF_STATE;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1969b = 1;

    public C0163h(C0161f c0161f, com.google.android.gms.common.internal.r rVar, C0747k c0747k) {
        this.f1968a = c0161f;
        this.f1970c = rVar;
        this.f1971d = c0747k;
    }

    public final void a(CaptureResult captureResult) {
        Integer num = (Integer) captureResult.get(this.e);
        Integer num2 = (Integer) captureResult.get(this.f1972f);
        if (captureResult instanceof TotalCaptureResult) {
            Float f4 = (Float) captureResult.get(CaptureResult.LENS_APERTURE);
            Long l2 = (Long) captureResult.get(CaptureResult.SENSOR_EXPOSURE_TIME);
            Integer num3 = (Integer) captureResult.get(CaptureResult.SENSOR_SENSITIVITY);
            C0747k c0747k = this.f1971d;
            c0747k.f6831b = f4;
            c0747k.f6832c = l2;
            c0747k.f6833d = num3;
        }
        if (this.f1969b != 1) {
            StringBuilder sb = new StringBuilder("CameraCaptureCallback | state: ");
            int i4 = this.f1969b;
            sb.append(i4 != 1 ? i4 != 2 ? i4 != 3 ? i4 != 4 ? i4 != 5 ? "null" : "STATE_CAPTURING" : "STATE_WAITING_PRECAPTURE_DONE" : "STATE_WAITING_PRECAPTURE_START" : "STATE_WAITING_FOCUS" : "STATE_PREVIEW");
            sb.append(" | afState: ");
            sb.append(num2);
            sb.append(" | aeState: ");
            sb.append(num);
            Log.d("CameraCaptureCallback", sb.toString());
        }
        int iB = K.j.b(this.f1969b);
        C0161f c0161f = this.f1968a;
        com.google.android.gms.common.internal.r rVar = this.f1970c;
        if (iB == 1) {
            if (num2 == null) {
                return;
            }
            if (num2.intValue() == 4 || num2.intValue() == 5) {
                if (num == null || num.intValue() == 2) {
                    c0161f.e();
                    return;
                } else {
                    c0161f.i();
                    return;
                }
            }
            if (((C0415a) rVar.f3597b).a()) {
                Log.w("CameraCaptureCallback", "Focus timeout, moving on with capture");
                if (num == null || num.intValue() == 2) {
                    c0161f.e();
                    return;
                } else {
                    c0161f.i();
                    return;
                }
            }
            return;
        }
        if (iB != 2) {
            if (iB != 3) {
                return;
            }
            if (num == null || num.intValue() != 5) {
                c0161f.e();
                return;
            } else {
                if (((C0415a) rVar.f3598c).a()) {
                    Log.w("CameraCaptureCallback", "Metering timeout waiting for pre-capture to finish, moving on with capture");
                    c0161f.e();
                    return;
                }
                return;
            }
        }
        if (num == null || num.intValue() == 2 || num.intValue() == 5 || num.intValue() == 4) {
            this.f1969b = 4;
        } else if (((C0415a) rVar.f3598c).a()) {
            Log.w("CameraCaptureCallback", "Metering timeout waiting for pre-capture to start, moving on with capture");
            this.f1969b = 4;
        }
    }

    @Override // android.hardware.camera2.CameraCaptureSession.CaptureCallback
    public final void onCaptureCompleted(CameraCaptureSession cameraCaptureSession, CaptureRequest captureRequest, TotalCaptureResult totalCaptureResult) {
        a(totalCaptureResult);
    }

    @Override // android.hardware.camera2.CameraCaptureSession.CaptureCallback
    public final void onCaptureProgressed(CameraCaptureSession cameraCaptureSession, CaptureRequest captureRequest, CaptureResult captureResult) {
        a(captureResult);
    }
}
