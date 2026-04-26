package J1;

import android.opengl.Matrix;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FloatBuffer f793a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final float[] f794b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final float[] f795c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f796d;
    public int e = -1;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f797f = -1;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f798g = -1;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f799h = -1;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f800i = -1;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f801j = -1;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f802k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f803l;

    public e() {
        float[] fArr = new float[16];
        this.f794b = fArr;
        float[] fArr2 = new float[16];
        this.f795c = fArr2;
        FloatBuffer floatBufferAsFloatBuffer = ByteBuffer.allocateDirect(80).order(ByteOrder.nativeOrder()).asFloatBuffer();
        this.f793a = floatBufferAsFloatBuffer;
        floatBufferAsFloatBuffer.put(new float[]{-1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f}).position(0);
        Matrix.setIdentityM(fArr, 0);
        Matrix.setIdentityM(fArr2, 0);
    }
}
