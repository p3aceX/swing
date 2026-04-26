package T2;

import android.graphics.SurfaceTexture;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public final class L implements SurfaceTexture.OnFrameAvailableListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ N f1905a;

    public L(N n4) {
        this.f1905a = n4;
    }

    @Override // android.graphics.SurfaceTexture.OnFrameAvailableListener
    public final void onFrameAvailable(SurfaceTexture surfaceTexture) {
        synchronized (this.f1905a.f1923r) {
            try {
                if (this.f1905a.f1924s.booleanValue()) {
                    Log.w("VideoRenderer", "Frame available before processing other frames. dropping frames");
                }
                N n4 = this.f1905a;
                n4.f1924s = Boolean.TRUE;
                n4.f1923r.notifyAll();
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
