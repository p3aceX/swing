package V1;

import I.C0053n;
import J3.i;
import Q3.y0;
import android.content.Context;
import android.graphics.Point;
import android.graphics.SurfaceTexture;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import java.nio.Buffer;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: loaded from: classes.dex */
public final class f extends SurfaceView implements c, SurfaceTexture.OnFrameAvailableListener, SurfaceHolder.Callback {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public ThreadPoolExecutor f2188A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final p1.d f2189B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final b f2190C;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicBoolean f2191a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final J1.c f2192b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0053n f2193c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0053n f2194d;
    public final C0053n e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0053n f2195f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final LinkedBlockingQueue f2196m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final LinkedBlockingQueue f2197n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f2198o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f2199p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f2200q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f2201r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f2202s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public int f2203t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public int f2204u;
    public boolean v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f2205w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public boolean f2206x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public boolean f2207y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public O1.a f2208z;

    public f(Context context) {
        super(context);
        this.f2191a = new AtomicBoolean(false);
        this.f2192b = new J1.c();
        this.f2193c = new C0053n(2);
        this.f2194d = new C0053n(2);
        this.e = new C0053n(2);
        this.f2195f = new C0053n(2);
        this.f2196m = new LinkedBlockingQueue();
        this.f2197n = new LinkedBlockingQueue();
        this.f2208z = O1.a.f1443a;
        this.f2189B = new p1.d();
        b bVar = new b();
        bVar.f2182c = 5L;
        this.f2190C = bVar;
        getHolder().addCallback(this);
    }

    public final void a(boolean z4) {
        if (this.f2191a.get()) {
            this.f2189B.getClass();
            if (!z4) {
                this.f2190C.e = true;
            }
            if (!this.f2196m.isEmpty() && ((AtomicBoolean) this.f2192b.f788g).get()) {
                try {
                    if (this.f2194d.p()) {
                        U1.b bVar = (U1.b) this.f2196m.take();
                        J1.c cVar = this.f2192b;
                        bVar.getClass();
                        cVar.d(bVar.f2096a);
                    }
                } catch (InterruptedException unused) {
                    Thread.currentThread().interrupt();
                    return;
                }
            }
            if (((AtomicBoolean) this.f2194d.e).get() && ((AtomicBoolean) this.f2192b.f788g).get()) {
                if (!this.f2194d.p()) {
                    return;
                }
                ((J1.b) this.f2192b.f785c).f781o.updateTexImage();
                J1.b bVar2 = (J1.b) this.f2192b.f785c;
                GLES20.glBindFramebuffer(36160, ((int[]) bVar2.f771d.f6831b)[0]);
                SurfaceTexture surfaceTexture = bVar2.f781o;
                float[] fArr = bVar2.f770c;
                surfaceTexture.getTransformMatrix(fArr);
                GLES20.glViewport(0, 0, bVar2.e, bVar2.f772f);
                GLES20.glUseProgram(bVar2.f776j);
                GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
                GLES20.glClear(16640);
                bVar2.f768a.position(0);
                GLES20.glVertexAttribPointer(bVar2.f779m, 3, 5126, false, 20, (Buffer) bVar2.f768a);
                GLES20.glEnableVertexAttribArray(bVar2.f779m);
                bVar2.f768a.position(3);
                GLES20.glVertexAttribPointer(bVar2.f780n, 2, 5126, false, 20, (Buffer) bVar2.f768a);
                GLES20.glEnableVertexAttribArray(bVar2.f780n);
                GLES20.glUniformMatrix4fv(bVar2.f777k, 1, false, bVar2.f769b, 0);
                GLES20.glUniformMatrix4fv(bVar2.f778l, 1, false, fArr, 0);
                GLES20.glActiveTexture(33984);
                GLES20.glBindTexture(36197, bVar2.f773g[0]);
                GLES20.glDrawArrays(5, 0, 4);
                H0.a.w(bVar2.f780n, bVar2.f779m);
                GLES20.glBindFramebuffer(36160, 0);
                this.f2192b.a(true);
                this.f2192b.b(this.f2198o, this.f2199p, this.f2208z, 0, this.f2205w, this.v);
                this.f2194d.A();
            }
            if (((AtomicBoolean) this.e.e).get() || ((AtomicBoolean) this.f2195f.e).get() || ((AtomicBoolean) this.f2193c.e).get()) {
                this.f2192b.a(false);
            }
            if (((AtomicBoolean) this.e.e).get() && ((AtomicBoolean) this.f2192b.f788g).get()) {
                int i4 = this.f2200q;
                int i5 = this.f2201r;
                if (this.e.p()) {
                    this.f2192b.b(i4, i5, this.f2208z, this.f2204u, this.f2207y, this.f2206x);
                    this.e.A();
                }
            }
            if (((AtomicBoolean) this.f2195f.e).get() && ((AtomicBoolean) this.f2192b.f788g).get()) {
                int i6 = this.f2202s;
                int i7 = this.f2203t;
                if (this.f2195f.p()) {
                    this.f2192b.b(i6, i7, this.f2208z, this.f2204u, this.f2207y, this.f2206x);
                    this.f2195f.A();
                }
            }
        }
    }

    public final void b() {
        this.f2191a.set(false);
        this.f2197n.clear();
        ThreadPoolExecutor threadPoolExecutor = this.f2188A;
        if (threadPoolExecutor != null) {
            threadPoolExecutor.shutdownNow();
        }
        this.f2188A = null;
        b bVar = this.f2190C;
        bVar.f2183d = false;
        y0 y0Var = bVar.f2181b;
        if (y0Var != null) {
            y0Var.a(null);
        }
        bVar.e = false;
        this.f2193c.v();
        this.e.v();
        this.f2195f.v();
        this.f2194d.v();
        J1.c cVar = this.f2192b;
        ((AtomicBoolean) cVar.f788g).set(false);
        ((J1.b) cVar.f785c).b();
        ArrayList arrayList = (ArrayList) cVar.f787f;
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            ((K1.a) it.next()).b();
        }
        arrayList.clear();
        GLES20.glDeleteProgram(((J1.e) cVar.f786d).e);
    }

    public Point getEncoderSize() {
        return new Point(this.f2200q, this.f2201r);
    }

    public Surface getSurface() {
        Surface surface = ((J1.b) this.f2192b.f785c).f782p;
        i.d(surface, "getSurface(...)");
        return surface;
    }

    @Override // V1.c
    public SurfaceTexture getSurfaceTexture() {
        SurfaceTexture surfaceTexture = ((J1.b) this.f2192b.f785c).f781o;
        i.d(surfaceTexture, "getSurfaceTexture(...)");
        return surfaceTexture;
    }

    @Override // android.graphics.SurfaceTexture.OnFrameAvailableListener
    public final void onFrameAvailable(SurfaceTexture surfaceTexture) {
        ThreadPoolExecutor threadPoolExecutor;
        i.e(surfaceTexture, "surfaceTexture");
        if (this.f2191a.get() && (threadPoolExecutor = this.f2188A) != null) {
            threadPoolExecutor.execute(new d(this, 0));
        }
    }

    public final void setAspectRatioMode(O1.a aVar) {
        i.e(aVar, "aspectRatioMode");
        this.f2208z = aVar;
    }

    @Override // V1.c
    public void setFilter(K1.a aVar) {
        i.e(aVar, "baseFilterRender");
        LinkedBlockingQueue linkedBlockingQueue = this.f2196m;
        U1.b bVar = new U1.b();
        bVar.f2096a = aVar;
        linkedBlockingQueue.add(bVar);
    }

    public void setForceRender(boolean z4) {
        b bVar = this.f2190C;
        bVar.f2180a = z4;
        bVar.f2182c = 5;
    }

    public void setIsPreviewHorizontalFlip(boolean z4) {
        this.v = z4;
    }

    public void setIsPreviewVerticalFlip(boolean z4) {
        this.f2205w = z4;
    }

    public void setIsStreamHorizontalFlip(boolean z4) {
        this.f2206x = z4;
    }

    public void setIsStreamVerticalFlip(boolean z4) {
        this.f2207y = z4;
    }

    public void setRenderErrorCallback(g gVar) {
        i.e(gVar, "callback");
    }

    @Override // V1.c
    public void setRotation(int i4) {
        J1.b bVar = (J1.b) this.f2192b.f785c;
        Matrix.setIdentityM(bVar.f774h, 0);
        Matrix.rotateM(bVar.f774h, 0, i4, 0.0f, 0.0f, -1.0f);
        Matrix.setIdentityM(bVar.f769b, 0);
        float[] fArr = bVar.f769b;
        Matrix.multiplyMM(fArr, 0, bVar.f775i, 0, fArr, 0);
        float[] fArr2 = bVar.f769b;
        Matrix.multiplyMM(fArr2, 0, bVar.f774h, 0, fArr2, 0);
    }

    public void setStreamRotation(int i4) {
        this.f2204u = i4;
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceChanged(SurfaceHolder surfaceHolder, int i4, int i5, int i6) {
        i.e(surfaceHolder, "holder");
        this.f2198o = i5;
        this.f2199p = i6;
        ArrayList arrayList = (ArrayList) this.f2192b.f787f;
        int size = arrayList.size();
        for (int i7 = 0; i7 < size; i7++) {
            ((K1.a) arrayList.get(i7)).getClass();
        }
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceCreated(SurfaceHolder surfaceHolder) {
        i.e(surfaceHolder, "holder");
    }

    @Override // android.view.SurfaceHolder.Callback
    public final void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        i.e(surfaceHolder, "holder");
        b();
    }
}
