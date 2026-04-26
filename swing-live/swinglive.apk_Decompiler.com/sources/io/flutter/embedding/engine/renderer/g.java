package io.flutter.embedding.engine.renderer;

import android.graphics.SurfaceTexture;
import android.os.Handler;
import io.flutter.view.TextureRegistry$SurfaceTextureEntry;
import io.flutter.view.q;
import io.flutter.view.r;

/* JADX INFO: loaded from: classes.dex */
public final class g implements TextureRegistry$SurfaceTextureEntry, r {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f4509a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final SurfaceTextureWrapper f4510b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f4511c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public r f4512d;
    public final /* synthetic */ j e;

    public g(j jVar, long j4, SurfaceTexture surfaceTexture) {
        this.e = jVar;
        this.f4509a = j4;
        SurfaceTextureWrapper surfaceTextureWrapper = new SurfaceTextureWrapper(surfaceTexture, new b(this, 1));
        this.f4510b = surfaceTextureWrapper;
        surfaceTextureWrapper.surfaceTexture().setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() { // from class: io.flutter.embedding.engine.renderer.f
            @Override // android.graphics.SurfaceTexture.OnFrameAvailableListener
            public final void onFrameAvailable(SurfaceTexture surfaceTexture2) {
                g gVar = this.f4508a;
                if (gVar.f4511c) {
                    return;
                }
                j jVar2 = gVar.e;
                if (jVar2.f4535a.isAttached()) {
                    gVar.f4510b.markDirty();
                    jVar2.f4535a.scheduleFrame();
                }
            }
        }, new Handler());
    }

    public final void finalize() throws Throwable {
        try {
            if (this.f4511c) {
                return;
            }
            j jVar = this.e;
            jVar.e.post(new h(this.f4509a, jVar.f4535a));
        } finally {
            super.finalize();
        }
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceTextureEntry
    public final long id() {
        return this.f4509a;
    }

    @Override // io.flutter.view.r
    public final void onTrimMemory(int i4) {
        r rVar = this.f4512d;
        if (rVar != null) {
            rVar.onTrimMemory(i4);
        }
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceTextureEntry
    public final void release() {
        if (this.f4511c) {
            return;
        }
        this.f4510b.release();
        j jVar = this.e;
        jVar.f4535a.unregisterTexture(this.f4509a);
        jVar.h(this);
        this.f4511c = true;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceTextureEntry
    public final void setOnFrameConsumedListener(q qVar) {
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceTextureEntry
    public final void setOnTrimMemoryListener(r rVar) {
        this.f4512d = rVar;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceTextureEntry
    public final SurfaceTexture surfaceTexture() {
        return this.f4510b.surfaceTexture();
    }
}
