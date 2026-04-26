package D2;

import android.os.Build;
import android.view.SurfaceHolder;
import u1.C0690c;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class N implements SurfaceHolder.Callback2 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0035j f173a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public io.flutter.embedding.engine.renderer.j f174b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final SurfaceHolderCallbackC0034i f175c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0030e f176d = new C0030e(this, 2);
    public final M e;

    public N(SurfaceHolderCallbackC0034i surfaceHolderCallbackC0034i, C0035j c0035j, io.flutter.embedding.engine.renderer.j jVar) {
        boolean z4 = Build.VERSION.SDK_INT < 26;
        this.e = z4 ? new C0779j(this, 2) : new C0690c(this, 2);
        this.f175c = surfaceHolderCallbackC0034i;
        this.f174b = jVar;
        this.f173a = c0035j;
        if (z4) {
            c0035j.setAlpha(0.0f);
        }
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceChanged(SurfaceHolder surfaceHolder, int i4, int i5, int i6) {
        SurfaceHolderCallbackC0034i surfaceHolderCallbackC0034i = this.f175c;
        if (surfaceHolderCallbackC0034i != null) {
            surfaceHolderCallbackC0034i.surfaceChanged(surfaceHolder, i4, i5, i6);
        }
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceCreated(SurfaceHolder surfaceHolder) {
        SurfaceHolderCallbackC0034i surfaceHolderCallbackC0034i = this.f175c;
        if (surfaceHolderCallbackC0034i != null) {
            surfaceHolderCallbackC0034i.surfaceCreated(surfaceHolder);
        }
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        SurfaceHolderCallbackC0034i surfaceHolderCallbackC0034i = this.f175c;
        if (surfaceHolderCallbackC0034i != null) {
            surfaceHolderCallbackC0034i.surfaceDestroyed(surfaceHolder);
        }
    }

    @Override // android.view.SurfaceHolder.Callback2
    public final void surfaceRedrawNeededAsync(SurfaceHolder surfaceHolder, Runnable runnable) {
        io.flutter.embedding.engine.renderer.j jVar = this.f174b;
        if (jVar == null) {
            return;
        }
        jVar.a(new L(this, runnable));
    }

    @Override // android.view.SurfaceHolder.Callback2
    public final void surfaceRedrawNeeded(SurfaceHolder surfaceHolder) {
    }
}
