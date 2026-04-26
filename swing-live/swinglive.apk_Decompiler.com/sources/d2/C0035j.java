package D2;

import android.graphics.Region;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.View;
import io.flutter.embedding.engine.FlutterJNI;

/* JADX INFO: renamed from: D2.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0035j extends SurfaceView implements io.flutter.embedding.engine.renderer.m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f212a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f213b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public io.flutter.embedding.engine.renderer.j f214c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f215d;
    public final N e;

    public C0035j(AbstractActivityC0029d abstractActivityC0029d, boolean z4) {
        super(abstractActivityC0029d, null);
        this.f212a = false;
        this.f213b = false;
        this.f215d = false;
        N n4 = new N(new SurfaceHolderCallbackC0034i(this, 0), this, this.f214c);
        this.e = n4;
        if (z4) {
            getHolder().setFormat(-2);
            setZOrderOnTop(true);
        }
        this.f215d = H0.a.K(getContext());
        getHolder().addCallback(n4);
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void a() {
        if (this.f214c == null) {
            Log.w("FlutterSurfaceView", "resume() invoked when no FlutterRenderer was attached.");
            return;
        }
        this.e.e.c();
        if (this.f212a) {
            e();
        }
        this.f213b = false;
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void b(io.flutter.embedding.engine.renderer.j jVar) {
        io.flutter.embedding.engine.renderer.j jVar2 = this.f214c;
        if (jVar2 != null) {
            jVar2.j();
        }
        this.f214c = jVar;
        this.e.e.q(jVar);
        a();
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void c() {
        if (this.f214c == null) {
            Log.w("FlutterSurfaceView", "pause() invoked when no FlutterRenderer was attached.");
        } else {
            this.f213b = true;
        }
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public final void d() {
        if (this.f214c == null) {
            Log.w("FlutterSurfaceView", "detachFromRenderer() invoked when no FlutterRenderer was attached.");
            return;
        }
        if (getWindowToken() != null) {
            io.flutter.embedding.engine.renderer.j jVar = this.f214c;
            if (jVar == null) {
                throw new IllegalStateException("disconnectSurfaceFromRenderer() should only be called when flutterRenderer is non-null.");
            }
            jVar.j();
        }
        this.e.e.n();
        this.f214c = null;
    }

    public final void e() {
        if (this.f214c == null || getHolder() == null) {
            throw new IllegalStateException("connectSurfaceToRenderer() should only be called when flutterRenderer and getHolder() are non-null.");
        }
        io.flutter.embedding.engine.renderer.j jVar = this.f214c;
        Surface surface = getHolder().getSurface();
        boolean z4 = this.f213b;
        if (!z4) {
            jVar.j();
        }
        jVar.f4537c = surface;
        FlutterJNI flutterJNI = jVar.f4535a;
        if (z4) {
            flutterJNI.onSurfaceWindowChanged(surface);
        } else {
            flutterJNI.onSurfaceCreated(surface);
        }
    }

    @Override // android.view.SurfaceView, android.view.View
    public final boolean gatherTransparentRegion(Region region) {
        if (getAlpha() < 1.0f) {
            return false;
        }
        int[] iArr = new int[2];
        getLocationInWindow(iArr);
        int i4 = iArr[0];
        region.op(i4, iArr[1], (getRight() + i4) - getLeft(), (getBottom() + iArr[1]) - getTop(), Region.Op.DIFFERENCE);
        return true;
    }

    @Override // io.flutter.embedding.engine.renderer.m
    public io.flutter.embedding.engine.renderer.j getAttachedRenderer() {
        return this.f214c;
    }

    @Override // android.view.SurfaceView, android.view.View
    public final void onMeasure(int i4, int i5) {
        if (!this.f215d) {
            super.onMeasure(i4, i5);
            return;
        }
        int mode = View.MeasureSpec.getMode(i4);
        setMeasuredDimension(Math.max(View.MeasureSpec.getSize(i4), mode == 0 ? 1 : 0), Math.max(View.MeasureSpec.getSize(i5), View.MeasureSpec.getMode(i5) == 0 ? 1 : 0));
    }
}
