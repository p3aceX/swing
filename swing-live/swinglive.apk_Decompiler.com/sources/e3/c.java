package e3;

import D2.AbstractActivityC0029d;
import D2.v;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class c extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Integer f4240b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final b f4241c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4242d;

    public c(v vVar, AbstractActivityC0029d abstractActivityC0029d, C0747k c0747k) {
        super(vVar);
        this.f4240b = 0;
        CameraCharacteristics.Key key = CameraCharacteristics.SENSOR_ORIENTATION;
        CameraCharacteristics cameraCharacteristics = (CameraCharacteristics) vVar.f260b;
        Integer num = (Integer) cameraCharacteristics.get(key);
        num.getClass();
        this.f4240b = num;
        b bVar = new b(abstractActivityC0029d, c0747k, ((Integer) cameraCharacteristics.get(CameraCharacteristics.LENS_FACING)).intValue() == 0, this.f4240b.intValue());
        this.f4241c = bVar;
        if (bVar.f4239f != null) {
            return;
        }
        C0397a c0397a = new C0397a(bVar);
        bVar.f4239f = c0397a;
        abstractActivityC0029d.registerReceiver(c0397a, b.f4234g);
        bVar.f4239f.onReceive(abstractActivityC0029d, null);
    }

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
    }
}
