package io.flutter.plugin.platform;

import android.graphics.SurfaceTexture;
import android.view.Surface;

/* JADX INFO: loaded from: classes.dex */
public final class x implements h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final io.flutter.embedding.engine.renderer.g f4696a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public SurfaceTexture f4697b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Surface f4698c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4699d = 0;
    public int e = 0;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f4700f = false;

    public x(io.flutter.embedding.engine.renderer.g gVar) {
        w wVar = new w(this);
        this.f4696a = gVar;
        this.f4697b = gVar.f4510b.surfaceTexture();
        gVar.f4512d = wVar;
    }

    @Override // io.flutter.plugin.platform.h
    public final long b() {
        return this.f4696a.f4509a;
    }

    @Override // io.flutter.plugin.platform.h
    public final void d(int i4, int i5) {
        this.f4699d = i4;
        this.e = i5;
        SurfaceTexture surfaceTexture = this.f4697b;
        if (surfaceTexture != null) {
            surfaceTexture.setDefaultBufferSize(i4, i5);
        }
    }

    @Override // io.flutter.plugin.platform.h
    public final int getHeight() {
        return this.e;
    }

    @Override // io.flutter.plugin.platform.h
    public final Surface getSurface() {
        Surface surface = this.f4698c;
        if (surface == null || this.f4700f) {
            if (surface != null) {
                surface.release();
                this.f4698c = null;
            }
            this.f4698c = new Surface(this.f4697b);
            this.f4700f = false;
        }
        SurfaceTexture surfaceTexture = this.f4697b;
        if (surfaceTexture == null || surfaceTexture.isReleased()) {
            return null;
        }
        return this.f4698c;
    }

    @Override // io.flutter.plugin.platform.h
    public final int getWidth() {
        return this.f4699d;
    }

    @Override // io.flutter.plugin.platform.h
    public final void release() {
        this.f4697b = null;
        Surface surface = this.f4698c;
        if (surface != null) {
            surface.release();
            this.f4698c = null;
        }
    }
}
