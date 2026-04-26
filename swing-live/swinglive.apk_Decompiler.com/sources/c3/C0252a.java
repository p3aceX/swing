package c3;

import D2.v;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import java.util.HashMap;

/* JADX INFO: renamed from: c3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0252a extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f3300b;

    public C0252a(v vVar) {
        super(vVar);
        b bVar = b.fast;
        HashMap map = new HashMap();
        this.f3300b = map;
        map.put(b.off, 0);
        map.put(bVar, 1);
        map.put(b.highQuality, 2);
        map.put(b.minimal, 3);
        map.put(b.zeroShutterLag, 4);
    }

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        int[] iArr = (int[]) ((CameraCharacteristics) this.f2100a.f260b).get(CameraCharacteristics.NOISE_REDUCTION_AVAILABLE_NOISE_REDUCTION_MODES);
        if (iArr == null || iArr.length <= 0) {
            return;
        }
        builder.set(CaptureRequest.NOISE_REDUCTION_MODE, (Integer) this.f3300b.get(b.fast));
    }
}
