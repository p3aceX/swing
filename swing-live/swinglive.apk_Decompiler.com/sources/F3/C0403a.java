package f3;

import D2.v;
import T2.K;
import android.graphics.Rect;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.util.Range;

/* JADX INFO: renamed from: f3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0403a extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f4290b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Rect f4291c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Float f4292d;
    public final Float e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Float f4293f;

    public C0403a(v vVar) {
        super(vVar);
        Float fValueOf = Float.valueOf(1.0f);
        this.f4292d = fValueOf;
        this.e = fValueOf;
        CameraCharacteristics.Key key = CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE;
        CameraCharacteristics cameraCharacteristics = (CameraCharacteristics) vVar.f260b;
        Rect rect = (Rect) cameraCharacteristics.get(key);
        this.f4291c = rect;
        if (rect == null) {
            this.f4293f = fValueOf;
            this.f4290b = false;
            return;
        }
        if (K.f1904a >= 30) {
            Range range = (Range) cameraCharacteristics.get(CameraCharacteristics.CONTROL_ZOOM_RATIO_RANGE);
            this.e = range != null ? (Float) range.getLower() : null;
            Range range2 = (Range) cameraCharacteristics.get(CameraCharacteristics.CONTROL_ZOOM_RATIO_RANGE);
            this.f4293f = range2 != null ? (Float) range2.getUpper() : null;
        } else {
            this.e = fValueOf;
            Float f4 = (Float) cameraCharacteristics.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM);
            if (f4 != null && f4.floatValue() >= 1.0f) {
                fValueOf = f4;
            }
            this.f4293f = fValueOf;
        }
        this.f4290b = Float.compare(this.f4293f.floatValue(), this.e.floatValue()) > 0;
    }

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        if (this.f4290b) {
            boolean z4 = K.f1904a >= 30;
            Float f4 = this.e;
            Float f5 = this.f4293f;
            if (z4) {
                CaptureRequest.Key key = CaptureRequest.CONTROL_ZOOM_RATIO;
                float fFloatValue = this.f4292d.floatValue();
                float fFloatValue2 = f4.floatValue();
                float fFloatValue3 = f5.floatValue();
                if (fFloatValue < fFloatValue2) {
                    fFloatValue = fFloatValue2;
                } else if (fFloatValue > fFloatValue3) {
                    fFloatValue = fFloatValue3;
                }
                builder.set(key, Float.valueOf(fFloatValue));
                return;
            }
            float fFloatValue4 = this.f4292d.floatValue();
            float fFloatValue5 = f4.floatValue();
            float fFloatValue6 = f5.floatValue();
            if (fFloatValue4 < fFloatValue5) {
                fFloatValue4 = fFloatValue5;
            } else if (fFloatValue4 > fFloatValue6) {
                fFloatValue4 = fFloatValue6;
            }
            Rect rect = this.f4291c;
            int iWidth = rect.width() / 2;
            int iHeight = rect.height() / 2;
            int iWidth2 = (int) ((rect.width() * 0.5f) / fFloatValue4);
            int iHeight2 = (int) ((rect.height() * 0.5f) / fFloatValue4);
            builder.set(CaptureRequest.SCALER_CROP_REGION, new Rect(iWidth - iWidth2, iHeight - iHeight2, iWidth + iWidth2, iHeight + iHeight2));
        }
    }
}
