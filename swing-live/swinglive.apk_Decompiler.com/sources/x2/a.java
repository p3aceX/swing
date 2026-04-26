package X2;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.util.Rational;

/* JADX INFO: loaded from: classes.dex */
public final class a extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public double f2413b;

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        builder.set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, Integer.valueOf((int) this.f2413b));
    }

    public final double b() {
        Rational rational = (Rational) ((CameraCharacteristics) this.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP);
        if (rational == null) {
            return 0.0d;
        }
        return rational.doubleValue();
    }
}
