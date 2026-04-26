package V2;

import D2.v;
import K.j;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;

/* JADX INFO: loaded from: classes.dex */
public final class a extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2209b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f2210c;

    public a(v vVar, boolean z4) {
        super(vVar);
        this.f2209b = 1;
        this.f2210c = z4;
    }

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        if (b()) {
            int iB = j.b(this.f2209b);
            if (iB == 0) {
                builder.set(CaptureRequest.CONTROL_AF_MODE, Integer.valueOf(this.f2210c ? 3 : 4));
            } else {
                if (iB != 1) {
                    return;
                }
                builder.set(CaptureRequest.CONTROL_AF_MODE, 1);
            }
        }
    }

    public final boolean b() {
        v vVar = this.f2100a;
        int[] iArr = (int[]) ((CameraCharacteristics) vVar.f260b).get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES);
        Float f4 = (Float) ((CameraCharacteristics) vVar.f260b).get(CameraCharacteristics.LENS_INFO_MINIMUM_FOCUS_DISTANCE);
        return (f4 == null || f4.floatValue() == 0.0f || iArr.length == 0 || (iArr.length == 1 && iArr[0] == 0)) ? false : true;
    }
}
