package J1;

import android.opengl.GLES20;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.FloatBuffer;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public abstract class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public FloatBuffer f768a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final float[] f769b = new float[16];

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final float[] f770c = new float[16];

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0747k f771d = new C0747k(5);
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f772f;

    public static void a(int i4, int i5, int[] iArr, int[] iArr2, int[] iArr3) {
        GLES20.glGenFramebuffers(1, iArr, 0);
        GLES20.glGenRenderbuffers(1, iArr2, 0);
        GLES20.glBindRenderbuffer(36161, iArr2[0]);
        GLES20.glRenderbufferStorage(36161, 33189, i4, i5);
        GLES20.glBindFramebuffer(36160, iArr[0]);
        GLES20.glFramebufferRenderbuffer(36160, 36096, 36161, iArr2[0]);
        H0.a.s(iArr3, 1, false);
        GLES20.glTexImage2D(3553, 0, 6408, i4, i5, 0, 6408, 5121, null);
        GLES20.glFramebufferTexture2D(36160, 36064, 3553, iArr3[0], 0);
        int iGlCheckFramebufferStatus = GLES20.glCheckFramebufferStatus(36160);
        if (iGlCheckFramebufferStatus != 36053) {
            throw new RuntimeException(S.d(iGlCheckFramebufferStatus, "FrameBuffer uncompleted code: "));
        }
    }

    public abstract void b();
}
