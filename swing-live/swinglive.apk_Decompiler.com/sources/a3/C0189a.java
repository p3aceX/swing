package a3;

import D2.v;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Size;
import e3.c;

/* JADX INFO: renamed from: a3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0189a extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Size f2643b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public v f2644c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public MeteringRectangle f2645d;
    public final c e;

    public C0189a(v vVar, c cVar) {
        super(vVar);
        this.e = cVar;
    }

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        Integer num = (Integer) ((CameraCharacteristics) this.f2100a.f260b).get(CameraCharacteristics.CONTROL_MAX_REGIONS_AF);
        if (num == null || num.intValue() <= 0) {
            return;
        }
        CaptureRequest.Key key = CaptureRequest.CONTROL_AF_REGIONS;
        MeteringRectangle meteringRectangle = this.f2645d;
        builder.set(key, meteringRectangle == null ? null : new MeteringRectangle[]{meteringRectangle});
    }

    public final void b() {
        Size size = this.f2643b;
        if (size == null) {
            throw new AssertionError("The cameraBoundaries should be set (using `FocusPointFeature.setCameraBoundaries(Size)`) before updating the focus point.");
        }
        v vVar = this.f2644c;
        if (vVar == null) {
            this.f2645d = null;
            return;
        }
        c cVar = this.e;
        int i4 = cVar.f4242d;
        if (i4 == 0) {
            i4 = cVar.f4241c.e;
        }
        this.f2645d = H0.a.g(size, ((Double) vVar.f260b).doubleValue(), ((Double) this.f2644c.f261c).doubleValue(), i4);
    }
}
