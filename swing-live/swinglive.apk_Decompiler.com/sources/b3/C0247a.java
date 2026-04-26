package b3;

import D2.v;
import T2.p;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.util.Range;

/* JADX INFO: renamed from: b3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0247a extends U2.a {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Range f3286c = new Range(30, 30);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Range f3287b;

    public C0247a(v vVar) {
        Range range;
        super(vVar);
        String str = p.f1989a;
        String str2 = p.f1990b;
        if (str != null && str.equals("google") && str2 != null && str2.equals("Pixel 4a")) {
            this.f3287b = f3286c;
            return;
        }
        Range[] rangeArr = (Range[]) ((CameraCharacteristics) vVar.f260b).get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES);
        if (rangeArr != null) {
            for (Range range2 : rangeArr) {
                int iIntValue = ((Integer) range2.getUpper()).intValue();
                if (iIntValue >= 10 && ((range = this.f3287b) == null || iIntValue > ((Integer) range.getUpper()).intValue())) {
                    this.f3287b = range2;
                }
            }
        }
    }

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        builder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, this.f3287b);
    }
}
