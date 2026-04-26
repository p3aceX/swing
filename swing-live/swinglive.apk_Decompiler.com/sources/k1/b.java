package K1;

import android.content.Context;
import android.opengl.GLES20;
import android.opengl.Matrix;
import com.swing.live.R;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class b extends a {

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f852l = -1;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f853m = -1;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f854n = -1;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f855o = -1;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f856p = -1;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f857q = -1;

    public b() {
        FloatBuffer floatBufferAsFloatBuffer = ByteBuffer.allocateDirect(80).order(ByteOrder.nativeOrder()).asFloatBuffer();
        this.f768a = floatBufferAsFloatBuffer;
        floatBufferAsFloatBuffer.put(new float[]{-1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f}).position(0);
        Matrix.setIdentityM(this.f769b, 0);
        Matrix.setIdentityM(this.f770c, 0);
    }

    @Override // J1.a
    public final void b() {
        GLES20.glDeleteProgram(this.f852l);
    }

    @Override // K1.a
    public final void c() {
        H0.a.w(this.f854n, this.f853m);
    }

    @Override // K1.a
    public final void d() {
        GLES20.glUseProgram(this.f852l);
        this.f768a.position(0);
        GLES20.glVertexAttribPointer(this.f853m, 3, 5126, false, 20, (Buffer) this.f768a);
        GLES20.glEnableVertexAttribArray(this.f853m);
        this.f768a.position(3);
        GLES20.glVertexAttribPointer(this.f854n, 2, 5126, false, 20, (Buffer) this.f768a);
        GLES20.glEnableVertexAttribArray(this.f854n);
        GLES20.glUniformMatrix4fv(this.f855o, 1, false, this.f769b, 0);
        GLES20.glUniformMatrix4fv(this.f856p, 1, false, this.f770c, 0);
        GLES20.glUniform1i(this.f857q, 0);
        GLES20.glActiveTexture(33984);
        GLES20.glBindTexture(3553, this.f849i);
    }

    @Override // K1.a
    public final void f(Context context) {
        int iP = H0.a.p(H0.a.E(context, R.raw.simple_vertex), H0.a.E(context, R.raw.simple_fragment));
        this.f852l = iP;
        this.f853m = GLES20.glGetAttribLocation(iP, "aPosition");
        this.f854n = GLES20.glGetAttribLocation(this.f852l, "aTextureCoord");
        this.f855o = GLES20.glGetUniformLocation(this.f852l, "uMVPMatrix");
        this.f856p = GLES20.glGetUniformLocation(this.f852l, "uSTMatrix");
        this.f857q = GLES20.glGetUniformLocation(this.f852l, "uSampler");
    }
}
