package J1;

import M1.h;
import android.graphics.SurfaceTexture;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.view.Surface;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class b extends a {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int[] f773g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final float[] f774h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final float[] f775i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f776j = -1;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f777k = -1;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f778l = -1;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f779m = -1;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f780n = -1;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public SurfaceTexture f781o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public Surface f782p;

    public b() {
        int[] iArr = new int[1];
        this.f773g = iArr;
        float[] fArr = new float[16];
        this.f774h = fArr;
        float[] fArr2 = new float[16];
        this.f775i = fArr2;
        this.f781o = new SurfaceTexture(iArr[0]);
        this.f782p = new Surface(this.f781o);
        Matrix.setIdentityM(this.f769b, 0);
        Matrix.setIdentityM(this.f770c, 0);
        float[] fArr3 = h.f1087a;
        FloatBuffer floatBufferAsFloatBuffer = ByteBuffer.allocateDirect(80).order(ByteOrder.nativeOrder()).asFloatBuffer();
        this.f768a = floatBufferAsFloatBuffer;
        floatBufferAsFloatBuffer.put(fArr3).position(0);
        Matrix.setIdentityM(fArr, 0);
        Matrix.rotateM(fArr, 0, 0, 0.0f, 0.0f, -1.0f);
        Matrix.setIdentityM(this.f769b, 0);
        float[] fArr4 = this.f769b;
        Matrix.multiplyMM(fArr4, 0, fArr2, 0, fArr4, 0);
        float[] fArr5 = this.f769b;
        Matrix.multiplyMM(fArr5, 0, fArr, 0, fArr5, 0);
        Matrix.setIdentityM(fArr2, 0);
        Matrix.scaleM(fArr2, 0, 1.0f, 1.0f, 1.0f);
        Matrix.setIdentityM(this.f769b, 0);
        float[] fArr6 = this.f769b;
        Matrix.multiplyMM(fArr6, 0, fArr2, 0, fArr6, 0);
        float[] fArr7 = this.f769b;
        Matrix.multiplyMM(fArr7, 0, fArr, 0, fArr7, 0);
    }

    @Override // J1.a
    public final void b() {
        GLES20.glDeleteProgram(this.f776j);
        SurfaceTexture surfaceTexture = this.f781o;
        if (surfaceTexture != null) {
            surfaceTexture.release();
        }
        Surface surface = this.f782p;
        if (surface != null) {
            surface.release();
        }
    }
}
