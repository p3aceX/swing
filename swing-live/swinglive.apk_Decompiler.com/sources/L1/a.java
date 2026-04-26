package L1;

import K.j;
import K.k;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.PointF;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.opengl.Matrix;
import com.swing.live.R;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import p1.d;
import u1.C0690c;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class a extends K1.a {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public final float f872A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public boolean f873B;
    public final FloatBuffer v;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final C0690c f886y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public final C0747k f887z;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f874l = -1;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f875m = -1;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f876n = -1;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f877o = -1;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f878p = -1;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f879q = -1;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f880r = -1;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f881s = -1;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public int f882t = -1;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final int f883u = R.raw.object_fragment;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public int[] f884w = {-1};

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final d f885x = new d(5);

    public a() {
        C0747k c0747k = new C0747k(4);
        this.f887z = c0747k;
        this.f872A = 1.0f;
        this.f873B = false;
        FloatBuffer floatBufferAsFloatBuffer = ByteBuffer.allocateDirect(80).order(ByteOrder.nativeOrder()).asFloatBuffer();
        this.f768a = floatBufferAsFloatBuffer;
        floatBufferAsFloatBuffer.put(new float[]{-1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f}).position(0);
        float[] fArrJ = c0747k.J();
        FloatBuffer floatBufferAsFloatBuffer2 = ByteBuffer.allocateDirect(32).order(ByteOrder.nativeOrder()).asFloatBuffer();
        this.v = floatBufferAsFloatBuffer2;
        floatBufferAsFloatBuffer2.put(fArrJ).position(0);
        Matrix.setIdentityM(this.f769b, 0);
        Matrix.setIdentityM(this.f770c, 0);
        this.f886y = new C0690c(16, false);
    }

    @Override // J1.a
    public final void b() {
        GLES20.glDeleteProgram(this.f874l);
        int[] iArr = this.f884w;
        GLES20.glDeleteTextures(iArr.length, iArr, 0);
        this.f884w = new int[]{-1};
        C0747k c0747k = this.f887z;
        c0747k.getClass();
        c0747k.f6832c = new PointF(100.0f, 100.0f);
        c0747k.f6833d = new PointF(0.0f, 0.0f);
    }

    @Override // K1.a
    public final void c() {
        H0.a.w(this.f876n, this.f877o, this.f875m);
    }

    @Override // K1.a
    public final void d() {
        if (this.f873B) {
            int[] iArr = this.f884w;
            GLES20.glDeleteTextures(iArr.length, iArr, 0);
            this.f884w = new int[]{-1};
            Bitmap[] bitmapArr = {(Bitmap) this.f886y.f6642b};
            this.f885x.getClass();
            int[] iArr2 = new int[1];
            H0.a.s(iArr2, 1, false);
            Bitmap bitmap = bitmapArr[0];
            if (bitmap != null && !bitmap.isRecycled()) {
                GLES20.glBindTexture(3553, iArr2[0]);
                GLUtils.texImage2D(3553, 0, bitmapArr[0], 0);
                bitmapArr[0].recycle();
            }
            bitmapArr[0] = null;
            this.f884w = iArr2;
            this.f873B = false;
        }
        GLES20.glUseProgram(this.f874l);
        this.f768a.position(0);
        GLES20.glVertexAttribPointer(this.f875m, 3, 5126, false, 20, (Buffer) this.f768a);
        GLES20.glEnableVertexAttribArray(this.f875m);
        this.f768a.position(3);
        GLES20.glVertexAttribPointer(this.f876n, 2, 5126, false, 20, (Buffer) this.f768a);
        GLES20.glEnableVertexAttribArray(this.f876n);
        this.v.position(0);
        GLES20.glVertexAttribPointer(this.f877o, 2, 5126, false, 8, (Buffer) this.v);
        GLES20.glEnableVertexAttribArray(this.f877o);
        GLES20.glUniformMatrix4fv(this.f878p, 1, false, this.f769b, 0);
        GLES20.glUniformMatrix4fv(this.f879q, 1, false, this.f770c, 0);
        GLES20.glUniform1i(this.f880r, 0);
        GLES20.glActiveTexture(33984);
        GLES20.glBindTexture(3553, this.f849i);
        GLES20.glUniform1i(this.f881s, 1);
        GLES20.glActiveTexture(33985);
        GLES20.glBindTexture(3553, this.f884w[0]);
        GLES20.glUniform1f(this.f882t, this.f884w[0] == -1 ? 0.0f : this.f872A);
    }

    @Override // K1.a
    public final void f(Context context) {
        int iP = H0.a.p(H0.a.E(context, R.raw.object_vertex), H0.a.E(context, this.f883u));
        this.f874l = iP;
        this.f875m = GLES20.glGetAttribLocation(iP, "aPosition");
        this.f876n = GLES20.glGetAttribLocation(this.f874l, "aTextureCoord");
        this.f877o = GLES20.glGetAttribLocation(this.f874l, "aTextureObjectCoord");
        this.f878p = GLES20.glGetUniformLocation(this.f874l, "uMVPMatrix");
        this.f879q = GLES20.glGetUniformLocation(this.f874l, "uSTMatrix");
        this.f880r = GLES20.glGetUniformLocation(this.f874l, "uSampler");
        this.f881s = GLES20.glGetUniformLocation(this.f874l, "uObject");
        this.f882t = GLES20.glGetUniformLocation(this.f874l, "uAlpha");
    }

    public final void g() {
        C0747k c0747k = this.f887z;
        c0747k.getClass();
        switch (j.b(1)) {
            case 0:
                PointF pointF = (PointF) c0747k.f6833d;
                PointF pointF2 = (PointF) c0747k.f6832c;
                pointF.x = 50.0f - (pointF2.x / 2.0f);
                pointF.y = 50.0f - (pointF2.x / 2.0f);
                break;
            case 1:
                PointF pointF3 = (PointF) c0747k.f6833d;
                pointF3.x = 0.0f;
                pointF3.y = 50.0f - (((PointF) c0747k.f6832c).y / 2.0f);
                break;
            case 2:
                PointF pointF4 = (PointF) c0747k.f6833d;
                PointF pointF5 = (PointF) c0747k.f6832c;
                pointF4.x = 100.0f - pointF5.x;
                pointF4.y = 50.0f - (pointF5.y / 2.0f);
                break;
            case 3:
                PointF pointF6 = (PointF) c0747k.f6833d;
                pointF6.x = 50.0f - (((PointF) c0747k.f6832c).x / 2.0f);
                pointF6.y = 0.0f;
                break;
            case 4:
                PointF pointF7 = (PointF) c0747k.f6833d;
                PointF pointF8 = (PointF) c0747k.f6832c;
                pointF7.x = 50.0f - (pointF8.x / 2.0f);
                pointF7.y = 100.0f - pointF8.y;
                break;
            case 5:
                PointF pointF9 = (PointF) c0747k.f6833d;
                pointF9.x = 0.0f;
                pointF9.y = 0.0f;
                break;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                PointF pointF10 = (PointF) c0747k.f6833d;
                pointF10.x = 100.0f - ((PointF) c0747k.f6832c).x;
                pointF10.y = 0.0f;
                break;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                PointF pointF11 = (PointF) c0747k.f6833d;
                pointF11.x = 0.0f;
                pointF11.y = 100.0f - ((PointF) c0747k.f6832c).y;
                break;
            case k.BYTES_FIELD_NUMBER /* 8 */:
                PointF pointF12 = (PointF) c0747k.f6833d;
                PointF pointF13 = (PointF) c0747k.f6832c;
                pointF12.x = 100.0f - pointF13.x;
                pointF12.y = 100.0f - pointF13.y;
                break;
        }
        this.v.put(c0747k.J()).position(0);
    }

    public final void h() {
        C0747k c0747k = this.f887z;
        PointF pointF = (PointF) c0747k.f6833d;
        float f4 = pointF.x;
        PointF pointF2 = (PointF) c0747k.f6832c;
        pointF.x = f4 / (100.0f / pointF2.x);
        pointF.y /= 100.0f / pointF2.y;
        c0747k.f6832c = new PointF(100.0f, 100.0f);
        this.v.put(c0747k.J()).position(0);
    }
}
