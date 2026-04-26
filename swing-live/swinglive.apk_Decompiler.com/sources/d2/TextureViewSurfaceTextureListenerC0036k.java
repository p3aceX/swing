package D2;

import android.graphics.SurfaceTexture;
import android.view.Surface;
import android.view.TextureView;

/* JADX INFO: renamed from: D2.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class TextureViewSurfaceTextureListenerC0036k implements TextureView.SurfaceTextureListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ C0037l f216a;

    public TextureViewSurfaceTextureListenerC0036k(C0037l c0037l) {
        this.f216a = c0037l;
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public final void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int i4, int i5) {
        C0037l c0037l = this.f216a;
        c0037l.f217a = true;
        if ((c0037l.f219c == null || c0037l.f218b) ? false : true) {
            c0037l.e();
        }
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public final boolean onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture) {
        C0037l c0037l = this.f216a;
        boolean z4 = false;
        c0037l.f217a = false;
        io.flutter.embedding.engine.renderer.j jVar = c0037l.f219c;
        if (jVar != null && !c0037l.f218b) {
            z4 = true;
        }
        if (z4) {
            if (jVar == null) {
                throw new IllegalStateException("disconnectSurfaceFromRenderer() should only be called when flutterRenderer is non-null.");
            }
            jVar.j();
            Surface surface = c0037l.f220d;
            if (surface != null) {
                surface.release();
                c0037l.f220d = null;
            }
        }
        Surface surface2 = c0037l.f220d;
        if (surface2 != null) {
            surface2.release();
            c0037l.f220d = null;
        }
        return true;
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public final void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int i4, int i5) {
        C0037l c0037l = this.f216a;
        io.flutter.embedding.engine.renderer.j jVar = c0037l.f219c;
        if (jVar == null || c0037l.f218b) {
            return;
        }
        if (jVar == null) {
            throw new IllegalStateException("changeSurfaceSize() should only be called when flutterRenderer is non-null.");
        }
        jVar.f4535a.onSurfaceChanged(i4, i5);
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public final void onSurfaceTextureUpdated(SurfaceTexture surfaceTexture) {
    }
}
