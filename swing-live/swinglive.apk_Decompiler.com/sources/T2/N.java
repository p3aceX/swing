package T2;

import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLExt;
import android.opengl.EGLSurface;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.opengl.Matrix;
import android.os.HandlerThread;
import android.os.SystemClock;
import android.util.Log;
import android.view.Surface;

/* JADX INFO: loaded from: classes.dex */
public final class N {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1910d;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public EGLDisplay f1915j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public EGLContext f1916k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public EGLSurface f1917l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final M f1918m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final Surface f1919n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public SurfaceTexture f1920o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public Surface f1921p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public HandlerThread f1922q;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final int f1925t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final int f1926u;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int[] f1907a = new int[1];

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final float[] f1908b = {-1.0f, -1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f};

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int[] f1909c = {2, 1, 0, 0, 3, 2};
    public int e = 0;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int[] f1911f = new int[2];

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f1912g = 0;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f1913h = 0;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f1914i = 0;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final Object f1923r = new Object();

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public Boolean f1924s = Boolean.FALSE;
    public int v = 0;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final Object f1927w = new Object();

    public N(Surface surface, int i4, int i5, C0159d c0159d) {
        this.f1919n = surface;
        this.f1926u = i5;
        this.f1925t = i4;
        Log.d("VideoRenderer", "Starting OpenGL Thread");
        M m4 = new M(this);
        this.f1918m = m4;
        m4.setUncaughtExceptionHandler(c0159d);
        this.f1918m.start();
        Log.d("VideoRenderer", "VideoRenderer setup complete");
    }

    public final void a(int i4, int i5, float[] fArr) {
        GLES20.glClear(16640);
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        GLES20.glViewport(0, 0, i4, i5);
        GLES20.glUseProgram(this.f1910d);
        GLES20.glUniformMatrix4fv(this.f1913h, 1, false, fArr, 0);
        int i6 = this.f1914i;
        float[] fArr2 = new float[16];
        Matrix.setIdentityM(fArr2, 0);
        Matrix.rotateM(fArr2, 0, this.v, 0.0f, 0.0f, 1.0f);
        GLES20.glUniformMatrix4fv(i6, 1, false, fArr2, 0);
        int[] iArr = this.f1911f;
        GLES20.glBindBuffer(34962, iArr[0]);
        GLES20.glBindBuffer(34963, iArr[1]);
        GLES20.glEnableVertexAttribArray(this.e);
        GLES20.glVertexAttribPointer(this.e, 3, 5126, false, 20, 0);
        GLES20.glEnableVertexAttribArray(this.f1912g);
        GLES20.glVertexAttribPointer(this.f1912g, 2, 5126, false, 20, 12);
        GLES20.glDrawElements(4, 6, 5125, 0);
        EGLExt.eglPresentationTimeANDROID(this.f1915j, this.f1917l, SystemClock.uptimeMillis() * 1000000);
        if (EGL14.eglSwapBuffers(this.f1915j, this.f1917l)) {
            return;
        }
        Log.w("VideoRenderer", "eglSwapBuffers() " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
    }
}
