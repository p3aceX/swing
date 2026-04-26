package W2;

import android.hardware.camera2.CaptureRequest;

/* JADX INFO: loaded from: classes.dex */
public final class a extends U2.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2272b;

    @Override // U2.a
    public final void a(CaptureRequest.Builder builder) {
        builder.set(CaptureRequest.CONTROL_AE_LOCK, Boolean.valueOf(this.f2272b == 2));
    }
}
