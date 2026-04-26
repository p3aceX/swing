package io.flutter.embedding.engine.renderer;

import android.graphics.SurfaceTexture;
import android.os.Handler;
import android.view.Surface;
import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.view.TextureRegistry$GLTextureConsumer;
import io.flutter.view.TextureRegistry$SurfaceProducer;
import io.flutter.view.s;

/* JADX INFO: loaded from: classes.dex */
public final class n implements TextureRegistry$SurfaceProducer, TextureRegistry$GLTextureConsumer {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f4542a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4543b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4544c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f4545d;
    public Surface e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final g f4546f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final Handler f4547g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final FlutterJNI f4548h;

    public n(long j4, Handler handler, FlutterJNI flutterJNI, g gVar) {
        this.f4542a = j4;
        this.f4547g = handler;
        this.f4548h = flutterJNI;
        this.f4546f = gVar;
    }

    public final void finalize() throws Throwable {
        try {
            if (this.f4545d) {
                return;
            }
            release();
            this.f4547g.post(new h(this.f4542a, this.f4548h));
        } finally {
            super.finalize();
        }
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final Surface getForcedNewSurface() {
        this.e = null;
        return getSurface();
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final int getHeight() {
        return this.f4544c;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final Surface getSurface() {
        Surface surface = this.e;
        if (surface == null || !surface.isValid()) {
            this.e = new Surface(this.f4546f.f4510b.surfaceTexture());
        }
        return this.e;
    }

    @Override // io.flutter.view.TextureRegistry$GLTextureConsumer
    public final SurfaceTexture getSurfaceTexture() {
        return this.f4546f.f4510b.surfaceTexture();
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final int getWidth() {
        return this.f4543b;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final boolean handlesCropAndRotation() {
        return true;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final long id() {
        return this.f4542a;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final void release() {
        this.f4546f.release();
        this.e.release();
        this.e = null;
        this.f4545d = true;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final void scheduleFrame() {
        this.f4548h.markTextureFrameAvailable(this.f4542a);
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final void setCallback(s sVar) {
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public final void setSize(int i4, int i5) {
        this.f4543b = i4;
        this.f4544c = i5;
        this.f4546f.f4510b.surfaceTexture().setDefaultBufferSize(i4, i5);
    }
}
