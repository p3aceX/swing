package D2;

import android.util.Log;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import io.flutter.embedding.engine.FlutterJNI;

/* JADX INFO: renamed from: D2.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0037l extends TextureView implements io.flutter.embedding.engine.renderer.m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f217a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f218b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public io.flutter.embedding.engine.renderer.j f219c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Surface f220d;
    public final boolean e;

    public C0037l(AbstractActivityC0029d abstractActivityC0029d) {
        super(abstractActivityC0029d, null);
        this.f217a = false;
        this.f218b = false;
        this.e = false;
        setSurfaceTextureListener(new TextureViewSurfaceTextureListenerC0036k(this));
        this.e = H0.a.K(getContext());
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void a() {
        if (this.f219c == null) {
            Log.w("FlutterTextureView", "resume() invoked when no FlutterRenderer was attached.");
            return;
        }
        if (this.f217a) {
            e();
        }
        this.f218b = false;
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void b(io.flutter.embedding.engine.renderer.j jVar) {
        io.flutter.embedding.engine.renderer.j jVar2 = this.f219c;
        if (jVar2 != null) {
            jVar2.j();
        }
        this.f219c = jVar;
        a();
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void c() {
        if (this.f219c == null) {
            Log.w("FlutterTextureView", "pause() invoked when no FlutterRenderer was attached.");
        } else {
            this.f218b = true;
        }
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void d() {
        if (this.f219c == null) {
            Log.w("FlutterTextureView", "detachFromRenderer() invoked when no FlutterRenderer was attached.");
            return;
        }
        if (getWindowToken() != null) {
            io.flutter.embedding.engine.renderer.j jVar = this.f219c;
            if (jVar == null) {
                throw new IllegalStateException("disconnectSurfaceFromRenderer() should only be called when flutterRenderer is non-null.");
            }
            jVar.j();
            Surface surface = this.f220d;
            if (surface != null) {
                surface.release();
                this.f220d = null;
            }
        }
        this.f219c = null;
    }

    public final void e() {
        if (this.f219c == null || getSurfaceTexture() == null) {
            throw new IllegalStateException("connectSurfaceToRenderer() should only be called when flutterRenderer and getSurfaceTexture() are non-null.");
        }
        Surface surface = this.f220d;
        if (surface != null) {
            surface.release();
            this.f220d = null;
        }
        Surface surface2 = new Surface(getSurfaceTexture());
        this.f220d = surface2;
        io.flutter.embedding.engine.renderer.j jVar = this.f219c;
        boolean z4 = this.f218b;
        if (!z4) {
            jVar.j();
        }
        jVar.f4537c = surface2;
        FlutterJNI flutterJNI = jVar.f4535a;
        if (z4) {
            flutterJNI.onSurfaceWindowChanged(surface2);
        } else {
            flutterJNI.onSurfaceCreated(surface2);
        }
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public io.flutter.embedding.engine.renderer.j getAttachedRenderer() {
        return this.f219c;
    }

    @Override // android.view.View
    public final void onMeasure(int i4, int i5) {
        if (!this.e) {
            super.onMeasure(i4, i5);
            return;
        }
        int mode = View.MeasureSpec.getMode(i4);
        setMeasuredDimension(Math.max(View.MeasureSpec.getSize(i4), mode == 0 ? 1 : 0), Math.max(View.MeasureSpec.getSize(i5), View.MeasureSpec.getMode(i5) == 0 ? 1 : 0));
    }

    public void setRenderSurface(Surface surface) {
        this.f220d = surface;
    }
}
