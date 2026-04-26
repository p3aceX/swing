package T2;

import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/* JADX INFO: loaded from: classes.dex */
public final class M extends Thread {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ N f1906a;

    public M(N n4) {
        this.f1906a = n4;
    }

    @Override // java.lang.Thread, java.lang.Runnable
    public final void run() {
        N n4;
        N n5 = this.f1906a;
        synchronized (n5.f1927w) {
            EGLDisplay eGLDisplayEglGetDisplay = EGL14.eglGetDisplay(0);
            n5.f1915j = eGLDisplayEglGetDisplay;
            if (eGLDisplayEglGetDisplay == EGL14.EGL_NO_DISPLAY) {
                throw new RuntimeException("eglDisplay == EGL14.EGL_NO_DISPLAY: " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
            }
            int[] iArr = new int[2];
            if (!EGL14.eglInitialize(eGLDisplayEglGetDisplay, iArr, 0, iArr, 1)) {
                throw new RuntimeException("eglInitialize(): " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
            }
            if (!EGL14.eglQueryString(n5.f1915j, 12373).contains("EGL_ANDROID_presentation_time")) {
                throw new RuntimeException("cannot configure OpenGL. missing EGL_ANDROID_presentation_time");
            }
            EGLConfig[] eGLConfigArr = new EGLConfig[1];
            if (!EGL14.eglChooseConfig(n5.f1915j, K.f1904a >= 26 ? new int[]{12324, 8, 12323, 8, 12322, 8, 12321, 8, 12352, 4, 12610, 1, 12344} : new int[]{12324, 8, 12323, 8, 12322, 8, 12321, 8, 12352, 4, 12344}, 0, eGLConfigArr, 0, 1, new int[1], 0)) {
                throw new RuntimeException(GLUtils.getEGLErrorString(EGL14.eglGetError()));
            }
            int iEglGetError = EGL14.eglGetError();
            if (iEglGetError != 12288) {
                throw new RuntimeException(GLUtils.getEGLErrorString(iEglGetError));
            }
            n5.f1916k = EGL14.eglCreateContext(n5.f1915j, eGLConfigArr[0], EGL14.EGL_NO_CONTEXT, new int[]{12440, 2, 12344}, 0);
            int iEglGetError2 = EGL14.eglGetError();
            if (iEglGetError2 != 12288) {
                throw new RuntimeException(GLUtils.getEGLErrorString(iEglGetError2));
            }
            n5.f1917l = EGL14.eglCreateWindowSurface(n5.f1915j, eGLConfigArr[0], n5.f1919n, new int[]{12344}, 0);
            int iEglGetError3 = EGL14.eglGetError();
            if (iEglGetError3 != 12288) {
                throw new RuntimeException(GLUtils.getEGLErrorString(iEglGetError3));
            }
            EGLDisplay eGLDisplay = n5.f1915j;
            EGLSurface eGLSurface = n5.f1917l;
            if (!EGL14.eglMakeCurrent(eGLDisplay, eGLSurface, eGLSurface, n5.f1916k)) {
                throw new RuntimeException("eglMakeCurrent(): " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
            }
            ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(n5.f1908b.length * 4);
            byteBufferAllocateDirect.order(ByteOrder.nativeOrder());
            byteBufferAllocateDirect.asFloatBuffer().put(n5.f1908b);
            byteBufferAllocateDirect.asFloatBuffer().position(0);
            ByteBuffer byteBufferAllocateDirect2 = ByteBuffer.allocateDirect(n5.f1909c.length * 4);
            byteBufferAllocateDirect2.order(ByteOrder.nativeOrder());
            byteBufferAllocateDirect2.asIntBuffer().put(n5.f1909c);
            byteBufferAllocateDirect2.position(0);
            int iGlCreateShader = GLES20.glCreateShader(35633);
            GLES20.glShaderSource(iGlCreateShader, "  precision highp float;\n            attribute vec3 vertexPosition;\n            attribute vec2 uvs;\n            varying vec2 varUvs;\n            uniform mat4 texMatrix;\n            uniform mat4 mvp;\n\n            void main()\n            {\n                varUvs = (texMatrix * vec4(uvs.x, uvs.y, 0, 1.0)).xy;\n                gl_Position = mvp * vec4(vertexPosition, 1.0);\n            }");
            GLES20.glCompileShader(iGlCreateShader);
            int iGlCreateShader2 = GLES20.glCreateShader(35632);
            GLES20.glShaderSource(iGlCreateShader2, " #extension GL_OES_EGL_image_external : require\n            precision mediump float;\n\n            varying vec2 varUvs;\n            uniform samplerExternalOES texSampler;\n\n            void main()\n            {\n                vec4 c = texture2D(texSampler, varUvs);\n                gl_FragColor = vec4(c.r, c.g, c.b, c.a);\n            }");
            GLES20.glCompileShader(iGlCreateShader2);
            int iGlCreateProgram = GLES20.glCreateProgram();
            n5.f1910d = iGlCreateProgram;
            GLES20.glAttachShader(iGlCreateProgram, iGlCreateShader);
            GLES20.glAttachShader(n5.f1910d, iGlCreateShader2);
            GLES20.glLinkProgram(n5.f1910d);
            GLES20.glDeleteShader(iGlCreateShader);
            GLES20.glDeleteShader(iGlCreateShader2);
            n5.e = GLES20.glGetAttribLocation(n5.f1910d, "vertexPosition");
            n5.f1912g = GLES20.glGetAttribLocation(n5.f1910d, "uvs");
            n5.f1913h = GLES20.glGetUniformLocation(n5.f1910d, "texMatrix");
            n5.f1914i = GLES20.glGetUniformLocation(n5.f1910d, "mvp");
            GLES20.glGenBuffers(2, n5.f1911f, 0);
            GLES20.glBindBuffer(34962, n5.f1911f[0]);
            GLES20.glBufferData(34962, n5.f1908b.length * 4, byteBufferAllocateDirect, 35048);
            GLES20.glBindBuffer(34963, n5.f1911f[1]);
            GLES20.glBufferData(34963, n5.f1909c.length * 4, byteBufferAllocateDirect2, 35048);
            GLES20.glGenTextures(1, n5.f1907a, 0);
            GLES20.glBindTexture(36197, n5.f1907a[0]);
            SurfaceTexture surfaceTexture = new SurfaceTexture(n5.f1907a[0]);
            n5.f1920o = surfaceTexture;
            surfaceTexture.setDefaultBufferSize(n5.f1925t, n5.f1926u);
            HandlerThread handlerThread = new HandlerThread("FrameHandlerThread");
            n5.f1922q = handlerThread;
            handlerThread.start();
            n5.f1921p = new Surface(n5.f1920o);
            n5.f1920o.setOnFrameAvailableListener(new L(n5), new Handler(n5.f1922q.getLooper()));
            n5.f1927w.notifyAll();
        }
        while (!Thread.interrupted()) {
            try {
                synchronized (this.f1906a.f1923r) {
                    while (!this.f1906a.f1924s.booleanValue()) {
                        try {
                            this.f1906a.f1923r.wait(500L);
                        } catch (Throwable th) {
                            throw th;
                        }
                    }
                    n4 = this.f1906a;
                    n4.f1924s = Boolean.FALSE;
                }
                n4.f1920o.updateTexImage();
                float[] fArr = new float[16];
                this.f1906a.f1920o.getTransformMatrix(fArr);
                N n6 = this.f1906a;
                n6.a(n6.f1925t, n6.f1926u, fArr);
            } catch (InterruptedException unused) {
                Log.d("VideoRenderer", "thread interrupted while waiting for frames");
                return;
            }
        }
    }
}
