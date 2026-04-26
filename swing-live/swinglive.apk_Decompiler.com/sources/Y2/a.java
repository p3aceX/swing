package Y2;

import D2.v;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Size;
import e3.c;

/* JADX INFO: loaded from: classes.dex */
public final class a extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Size f2520b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public v f2521c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public MeteringRectangle f2522d;
    public final c e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f2523f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public MeteringRectangle[] f2524g;

    public a(v vVar, c cVar) {
        super(vVar);
        this.f2523f = false;
        this.e = cVar;
    }

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        Integer num = (Integer) ((CameraCharacteristics) this.f2100a.f260b).get(CameraCharacteristics.CONTROL_MAX_REGIONS_AE);
        if (num == null || num.intValue() <= 0) {
            return;
        }
        if (!this.f2523f) {
            this.f2524g = (MeteringRectangle[]) builder.get(CaptureRequest.CONTROL_AE_REGIONS);
            this.f2523f = true;
        }
        MeteringRectangle meteringRectangle = this.f2522d;
        if (meteringRectangle != null) {
            builder.set(CaptureRequest.CONTROL_AE_REGIONS, new MeteringRectangle[]{meteringRectangle});
        } else {
            builder.set(CaptureRequest.CONTROL_AE_REGIONS, this.f2524g);
        }
    }

    public final void b() {
        Size size = this.f2520b;
        if (size == null) {
            throw new AssertionError("The cameraBoundaries should be set (using `ExposurePointFeature.setCameraBoundaries(Size)`) before updating the exposure point.");
        }
        v vVar = this.f2521c;
        if (vVar == null) {
            this.f2522d = null;
            return;
        }
        c cVar = this.e;
        int i4 = cVar.f4242d;
        if (i4 == 0) {
            i4 = cVar.f4241c.e;
        }
        this.f2522d = H0.a.g(size, ((Double) vVar.f260b).doubleValue(), ((Double) this.f2521c.f261c).doubleValue(), i4);
    }
}
