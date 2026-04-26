package D2;

import android.util.Log;
import android.view.SurfaceHolder;

/* JADX INFO: renamed from: D2.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class SurfaceHolderCallbackC0034i implements SurfaceHolder.Callback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f210a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f211b;

    public /* synthetic */ SurfaceHolderCallbackC0034i(Object obj, int i4) {
        this.f210a = i4;
        this.f211b = obj;
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceChanged(SurfaceHolder surfaceHolder, int i4, int i5, int i6) {
        y2.k kVar;
        y2.g gVar;
        switch (this.f210a) {
            case 0:
                C0035j c0035j = (C0035j) this.f211b;
                io.flutter.embedding.engine.renderer.j jVar = c0035j.f214c;
                if (jVar == null || c0035j.f213b) {
                    return;
                }
                if (jVar == null) {
                    throw new IllegalStateException("changeSurfaceSize() should only be called when flutterRenderer is non-null.");
                }
                jVar.f4535a.onSurfaceChanged(i5, i6);
                return;
            default:
                J3.i.e(surfaceHolder, "holder");
                Log.d("StreamPreviewView", "surfaceChanged: " + i5 + 'x' + i6);
                if (i5 <= 0 || i6 <= 0 || (gVar = (kVar = (y2.k) this.f211b).e) == null) {
                    return;
                }
                gVar.f(kVar.f6915b);
                return;
        }
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceCreated(SurfaceHolder surfaceHolder) {
        switch (this.f210a) {
            case 0:
                C0035j c0035j = (C0035j) this.f211b;
                c0035j.f212a = true;
                if ((c0035j.f214c == null || c0035j.f213b) ? false : true) {
                    c0035j.e();
                }
                break;
            default:
                J3.i.e(surfaceHolder, "holder");
                StringBuilder sb = new StringBuilder("surfaceCreated: ");
                y2.k kVar = (y2.k) this.f211b;
                sb.append(kVar.f6917d.getWidth());
                sb.append('x');
                V1.f fVar = kVar.f6917d;
                sb.append(fVar.getHeight());
                Log.d("StreamPreviewView", sb.toString());
                fVar.post(new F1.a(kVar, 21));
                break;
        }
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        y2.g gVar;
        S1.a aVar;
        switch (this.f210a) {
            case 0:
                C0035j c0035j = (C0035j) this.f211b;
                boolean z4 = false;
                c0035j.f212a = false;
                io.flutter.embedding.engine.renderer.j jVar = c0035j.f214c;
                if (jVar != null && !c0035j.f213b) {
                    z4 = true;
                }
                if (z4) {
                    if (jVar == null) {
                        throw new IllegalStateException("disconnectSurfaceFromRenderer() should only be called when flutterRenderer is non-null.");
                    }
                    jVar.j();
                    return;
                }
                return;
            default:
                J3.i.e(surfaceHolder, "holder");
                Log.d("StreamPreviewView", "surfaceDestroyed");
                y2.k kVar = (y2.k) this.f211b;
                y2.g gVar2 = kVar.e;
                if (gVar2 == null || gVar2.f6892j.get() || (gVar = kVar.e) == null || (aVar = gVar.f6891i) == null) {
                    return;
                }
                aVar.f();
                return;
        }
    }
}
