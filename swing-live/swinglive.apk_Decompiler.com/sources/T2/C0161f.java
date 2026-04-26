package T2;

import D2.AbstractActivityC0029d;
import D2.AbstractC0038m;
import I.C0053n;
import O.RunnableC0093d;
import a3.C0189a;
import android.content.Context;
import android.graphics.Rect;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.opengl.EGL14;
import android.opengl.GLES20;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;
import com.google.crypto.tink.shaded.protobuf.S;
import d3.C0359a;
import h3.C0415a;
import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Objects;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: renamed from: T2.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0161f implements ImageReader.OnImageAvailableListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public E2.h f1940a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1941b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public N f1942c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1943d;
    public final io.flutter.embedding.engine.renderer.g e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0160e f1944f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final Context f1945g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final C0747k f1946h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public D2.v f1947i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final p1.d f1948j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final AbstractActivityC0029d f1949k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final C0163h f1950l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public Handler f1951m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public HandlerThread f1952n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public D2.v f1953o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public CameraCaptureSession f1954p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public ImageReader f1955q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public S2.a f1956r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public CaptureRequest.Builder f1957s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public MediaRecorder f1958t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f1959u;
    public boolean v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public File f1960w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final com.google.android.gms.common.internal.r f1961x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final C0747k f1962y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public t f1963z;

    public C0161f(AbstractActivityC0029d abstractActivityC0029d, io.flutter.embedding.engine.renderer.g gVar, p1.d dVar, C0747k c0747k, D2.v vVar, C0160e c0160e) {
        if (abstractActivityC0029d == null) {
            throw new IllegalStateException("No activity available!");
        }
        this.f1949k = abstractActivityC0029d;
        this.e = gVar;
        this.f1946h = c0747k;
        this.f1945g = abstractActivityC0029d.getApplicationContext();
        this.f1947i = vVar;
        this.f1948j = dVar;
        this.f1944f = c0160e;
        this.f1940a = E2.h.g(dVar, vVar, abstractActivityC0029d, c0747k, c0160e.f1937b);
        com.google.android.gms.common.internal.r rVar = new com.google.android.gms.common.internal.r(5, false);
        rVar.f3597b = new C0415a();
        rVar.f3598c = new C0415a();
        this.f1961x = rVar;
        C0747k c0747k2 = new C0747k(26, false);
        this.f1962y = c0747k2;
        this.f1950l = new C0163h(this, rVar, c0747k2);
        if (this.f1952n != null) {
            return;
        }
        HandlerThread handlerThread = new HandlerThread("CameraBackground");
        this.f1952n = handlerThread;
        try {
            handlerThread.start();
        } catch (IllegalThreadStateException unused) {
        }
        this.f1951m = new Handler(this.f1952n.getLooper());
    }

    public final void a() {
        Log.i("Camera", "close");
        D2.v vVar = this.f1953o;
        if (vVar != null) {
            ((CameraDevice) vVar.f260b).close();
            this.f1953o = null;
            this.f1954p = null;
        } else if (this.f1954p != null) {
            Log.i("Camera", "closeCaptureSession");
            this.f1954p.close();
            this.f1954p = null;
        }
        ImageReader imageReader = this.f1955q;
        if (imageReader != null) {
            imageReader.close();
            this.f1955q = null;
        }
        S2.a aVar = this.f1956r;
        if (aVar != null) {
            ((ImageReader) aVar.f1811b).close();
            this.f1956r = null;
        }
        MediaRecorder mediaRecorder = this.f1958t;
        if (mediaRecorder != null) {
            mediaRecorder.reset();
            this.f1958t.release();
            this.f1958t = null;
        }
        HandlerThread handlerThread = this.f1952n;
        if (handlerThread != null) {
            handlerThread.quitSafely();
        }
        this.f1952n = null;
        this.f1951m = null;
    }

    public final void b() {
        N n4 = this.f1942c;
        if (n4 != null) {
            n4.f1918m.interrupt();
            n4.f1922q.quitSafely();
            GLES20.glDeleteBuffers(2, n4.f1911f, 0);
            GLES20.glDeleteTextures(1, n4.f1907a, 0);
            EGL14.eglDestroyContext(n4.f1915j, n4.f1916k);
            EGL14.eglDestroySurface(n4.f1915j, n4.f1917l);
            GLES20.glDeleteProgram(n4.f1910d);
            n4.f1920o.release();
            this.f1942c = null;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:26:0x00c6  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void c(int r9, java.lang.Runnable r10, android.view.Surface... r11) throws android.hardware.camera2.CameraAccessException {
        /*
            Method dump skipped, instruction units count: 326
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: T2.C0161f.c(int, java.lang.Runnable, android.view.Surface[]):void");
    }

    public final void d() {
        Log.i("Camera", "lockAutoFocus");
        if (this.f1954p == null) {
            Log.i("Camera", "[unlockAutoFocus] captureSession null, returning");
            return;
        }
        this.f1957s.set(CaptureRequest.CONTROL_AF_TRIGGER, 1);
        try {
            this.f1954p.capture(this.f1957s.build(), null, this.f1951m);
        } catch (CameraAccessException e) {
            this.f1946h.W(e.getMessage() == null ? "CameraAccessException occurred while locking autofocus." : e.getMessage());
        }
    }

    public final void e() {
        int iA;
        C0747k c0747k = this.f1946h;
        Log.i("Camera", "captureStillPicture");
        this.f1950l.f1969b = 5;
        D2.v vVar = this.f1953o;
        if (vVar == null) {
            return;
        }
        try {
            CaptureRequest.Builder builderCreateCaptureRequest = ((CameraDevice) vVar.f260b).createCaptureRequest(2);
            builderCreateCaptureRequest.addTarget(this.f1955q.getSurface());
            CaptureRequest.Key key = CaptureRequest.SCALER_CROP_REGION;
            builderCreateCaptureRequest.set(key, (Rect) this.f1957s.get(key));
            Iterator it = this.f1940a.f378a.values().iterator();
            while (it.hasNext()) {
                ((U2.a) it.next()).a(builderCreateCaptureRequest);
            }
            int i4 = this.f1940a.e().f4242d;
            CaptureRequest.Key key2 = CaptureRequest.JPEG_ORIENTATION;
            if (i4 == 0) {
                e3.b bVar = this.f1940a.e().f4241c;
                iA = bVar.a(bVar.e);
            } else {
                iA = this.f1940a.e().f4241c.a(i4);
            }
            builderCreateCaptureRequest.set(key2, Integer.valueOf(iA));
            M1.c cVar = new M1.c(this, 1);
            try {
                Log.i("Camera", "sending capture request");
                this.f1954p.capture(builderCreateCaptureRequest.build(), cVar, this.f1951m);
            } catch (CameraAccessException e) {
                c0747k.B(this.f1963z, "cameraAccess", e.getMessage());
            }
        } catch (CameraAccessException e4) {
            c0747k.B(this.f1963z, "cameraAccess", e4.getMessage());
        }
    }

    public final void f(Integer num) {
        this.f1941b = num.intValue();
        C0359a c0359aD = this.f1940a.d();
        if (c0359aD.f3957f < 0) {
            this.f1946h.W(S.h(new StringBuilder("Camera with name \""), (String) this.f1947i.f261c, "\" is not supported by this plugin."));
        } else {
            this.f1955q = ImageReader.newInstance(c0359aD.f3954b.getWidth(), c0359aD.f3954b.getHeight(), 256, 1);
            this.f1956r = new S2.a(c0359aD.f3955c.getWidth(), c0359aD.f3955c.getHeight(), this.f1941b);
            ((CameraManager) this.f1949k.getSystemService("camera")).openCamera((String) this.f1947i.f261c, new C0157b(this, c0359aD), this.f1951m);
        }
    }

    public final void g(String str) {
        int iC;
        EncoderProfiles encoderProfiles;
        Log.i("Camera", "prepareMediaRecorder");
        MediaRecorder mediaRecorder = this.f1958t;
        if (mediaRecorder != null) {
            mediaRecorder.release();
        }
        b();
        int i4 = this.f1940a.e().f4242d;
        boolean z4 = K.f1904a >= 31;
        C0160e c0160e = this.f1944f;
        C0160e c0160e2 = (!z4 || this.f1940a.d().e == null) ? new C0160e(this.f1940a.d().f3956d, new C0053n(str, (Integer) c0160e.f1938c, (Integer) c0160e.f1939d, (Integer) c0160e.e, 9)) : new C0160e(this.f1940a.d().e, new C0053n(str, (Integer) c0160e.f1938c, (Integer) c0160e.f1939d, (Integer) c0160e.e, 9));
        c0160e2.f1936a = c0160e.f1936a;
        if (i4 == 0) {
            e3.b bVar = this.f1940a.e().f4241c;
            iC = bVar.c(bVar.e);
        } else {
            iC = this.f1940a.e().f4241c.c(i4);
        }
        c0160e2.f1937b = iC;
        MediaRecorder mediaRecorder2 = new MediaRecorder();
        if (c0160e2.f1936a) {
            mediaRecorder2.setAudioSource(1);
        }
        mediaRecorder2.setVideoSource(2);
        boolean z5 = K.f1904a >= 31;
        C0053n c0053n = (C0053n) c0160e2.e;
        Integer num = (Integer) c0053n.f707c;
        Integer num2 = (Integer) c0053n.f708d;
        Integer num3 = (Integer) c0053n.e;
        if (!z5 || (encoderProfiles = (EncoderProfiles) c0160e2.f1939d) == null) {
            CamcorderProfile camcorderProfile = (CamcorderProfile) c0160e2.f1938c;
            if (camcorderProfile != null) {
                mediaRecorder2.setOutputFormat(camcorderProfile.fileFormat);
                if (c0160e2.f1936a) {
                    mediaRecorder2.setAudioEncoder(camcorderProfile.audioCodec);
                    mediaRecorder2.setAudioEncodingBitRate((num3 == null || num3.intValue() <= 0) ? camcorderProfile.audioBitRate : num3.intValue());
                    mediaRecorder2.setAudioSamplingRate(camcorderProfile.audioSampleRate);
                }
                mediaRecorder2.setVideoEncoder(camcorderProfile.videoCodec);
                mediaRecorder2.setVideoEncodingBitRate((num2 == null || num2.intValue() <= 0) ? camcorderProfile.videoBitRate : num2.intValue());
                mediaRecorder2.setVideoFrameRate((num == null || num.intValue() <= 0) ? camcorderProfile.videoFrameRate : num.intValue());
                mediaRecorder2.setVideoSize(camcorderProfile.videoFrameWidth, camcorderProfile.videoFrameHeight);
            }
        } else {
            mediaRecorder2.setOutputFormat(encoderProfiles.getRecommendedFileFormat());
            EncoderProfiles.VideoProfile videoProfileE = AbstractC0038m.e(((EncoderProfiles) c0160e2.f1939d).getVideoProfiles().get(0));
            if (c0160e2.f1936a) {
                EncoderProfiles.AudioProfile audioProfileD = AbstractC0038m.d(((EncoderProfiles) c0160e2.f1939d).getAudioProfiles().get(0));
                mediaRecorder2.setAudioEncoder(audioProfileD.getCodec());
                mediaRecorder2.setAudioEncodingBitRate((num3 == null || num3.intValue() <= 0) ? audioProfileD.getBitrate() : num3.intValue());
                mediaRecorder2.setAudioSamplingRate(audioProfileD.getSampleRate());
            }
            mediaRecorder2.setVideoEncoder(videoProfileE.getCodec());
            mediaRecorder2.setVideoEncodingBitRate((num2 == null || num2.intValue() <= 0) ? videoProfileE.getBitrate() : num2.intValue());
            mediaRecorder2.setVideoFrameRate((num == null || num.intValue() <= 0) ? videoProfileE.getFrameRate() : num.intValue());
            mediaRecorder2.setVideoSize(videoProfileE.getWidth(), videoProfileE.getHeight());
        }
        mediaRecorder2.setOutputFile((String) c0053n.f706b);
        mediaRecorder2.setOrientationHint(c0160e2.f1937b);
        mediaRecorder2.prepare();
        this.f1958t = mediaRecorder2;
    }

    public final void h(Runnable runnable, q qVar) {
        Log.i("Camera", "refreshPreviewCaptureSession");
        CameraCaptureSession cameraCaptureSession = this.f1954p;
        if (cameraCaptureSession == null) {
            Log.i("Camera", "refreshPreviewCaptureSession: captureSession not yet initialized, skipping preview capture session refresh.");
            return;
        }
        try {
            if (!this.v) {
                cameraCaptureSession.setRepeatingRequest(this.f1957s.build(), this.f1950l, this.f1951m);
            }
            if (runnable != null) {
                runnable.run();
            }
        } catch (CameraAccessException e) {
            qVar.b(e.getMessage());
        } catch (IllegalStateException e4) {
            qVar.b("Camera is closed: " + e4.getMessage());
        }
    }

    public final void i() {
        C0163h c0163h = this.f1950l;
        Log.i("Camera", "runPrecaptureSequence");
        try {
            CaptureRequest.Builder builder = this.f1957s;
            CaptureRequest.Key key = CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER;
            builder.set(key, 0);
            this.f1954p.capture(this.f1957s.build(), c0163h, this.f1951m);
            h(null, new C0156a(this, 1));
            c0163h.f1969b = 3;
            this.f1957s.set(key, 1);
            this.f1954p.capture(this.f1957s.build(), c0163h, this.f1951m);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    public final void j(D2.v vVar) {
        if (!this.f1959u) {
            throw new v(null, "setDescriptionWhileRecordingFailed", "Device was not recording");
        }
        if (K.f1904a < 26) {
            throw new v(null, "setDescriptionWhileRecordingFailed", "Device does not support switching the camera while recording");
        }
        D2.v vVar2 = this.f1953o;
        if (vVar2 != null) {
            ((CameraDevice) vVar2.f260b).close();
            this.f1953o = null;
            this.f1954p = null;
        } else if (this.f1954p != null) {
            Log.i("Camera", "closeCaptureSession");
            this.f1954p.close();
            this.f1954p = null;
        }
        if (this.f1942c == null) {
            C0359a c0359aD = this.f1940a.d();
            this.f1942c = new N(this.f1958t.getSurface(), c0359aD.f3954b.getWidth(), c0359aD.f3954b.getHeight(), new C0159d(this));
        }
        this.f1947i = vVar;
        int i4 = this.f1944f.f1937b;
        E2.h hVarG = E2.h.g(this.f1948j, vVar, this.f1949k, this.f1946h, i4);
        this.f1940a = hVarG;
        hVarG.f378a.put("AUTO_FOCUS", new V2.a(this.f1947i, true));
        n(this.f1947i);
        try {
            f(Integer.valueOf(this.f1941b));
        } catch (CameraAccessException e) {
            throw new v(null, "setDescriptionWhileRecordingFailed", e.getMessage());
        }
    }

    public final void k(t tVar, int i4) {
        U2.a aVar = (U2.a) this.f1940a.f378a.get("FLASH");
        Objects.requireNonNull(aVar);
        Z2.a aVar2 = (Z2.a) aVar;
        aVar2.f2600b = i4;
        aVar2.a(this.f1957s);
        h(new F1.a(tVar, 8), new D2.u(tVar, 6));
    }

    public final void l(int i4) {
        V2.a aVar = (V2.a) this.f1940a.f378a.get("AUTO_FOCUS");
        aVar.f2209b = i4;
        aVar.a(this.f1957s);
        if (this.v) {
            return;
        }
        int iB = K.j.b(i4);
        if (iB == 0) {
            q();
            return;
        }
        if (iB != 1) {
            return;
        }
        if (this.f1954p == null) {
            Log.i("Camera", "[unlockAutoFocus] captureSession null, returning");
            return;
        }
        d();
        this.f1957s.set(CaptureRequest.CONTROL_AF_TRIGGER, 0);
        try {
            this.f1954p.setRepeatingRequest(this.f1957s.build(), null, this.f1951m);
        } catch (CameraAccessException e) {
            throw new v(null, "setFocusModeFailed", "Error setting focus mode: " + e.getMessage());
        }
    }

    public final void m(t tVar, D2.v vVar) {
        C0189a c0189aC = this.f1940a.c();
        if (vVar == null || ((Double) vVar.f260b) == null || ((Double) vVar.f261c) == null) {
            vVar = null;
        }
        c0189aC.f2644c = vVar;
        c0189aC.b();
        c0189aC.a(this.f1957s);
        h(new F1.a(tVar, 6), new D2.u(tVar, 3));
        l(((V2.a) this.f1940a.f378a.get("AUTO_FOCUS")).f2209b);
    }

    /* JADX WARN: Removed duplicated region for block: B:18:0x0049  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void n(D2.v r5) {
        /*
            r4 = this;
            T2.e r0 = r4.f1944f
            java.lang.Object r1 = r0.f1938c
            java.lang.Integer r1 = (java.lang.Integer) r1
            if (r1 == 0) goto L13
            int r1 = r1.intValue()
            if (r1 <= 0) goto L13
            java.lang.Object r0 = r0.f1938c
            java.lang.Integer r0 = (java.lang.Integer) r0
            goto L5b
        L13:
            int r0 = T2.K.f1904a
            r1 = 31
            r2 = 0
            if (r0 < r1) goto L1c
            r0 = 1
            goto L1d
        L1c:
            r0 = r2
        L1d:
            r1 = 0
            if (r0 == 0) goto L4b
            E2.h r0 = r4.f1940a
            d3.a r0 = r0.d()
            android.media.EncoderProfiles r0 = r0.e
            if (r0 == 0) goto L49
            java.util.List r3 = D2.AbstractC0038m.j(r0)
            int r3 = r3.size()
            if (r3 <= 0) goto L49
            java.util.List r0 = D2.AbstractC0038m.j(r0)
            java.lang.Object r0 = r0.get(r2)
            android.media.EncoderProfiles$VideoProfile r0 = D2.AbstractC0038m.e(r0)
            int r0 = D2.AbstractC0038m.b(r0)
            java.lang.Integer r0 = java.lang.Integer.valueOf(r0)
            goto L5b
        L49:
            r0 = r1
            goto L5b
        L4b:
            E2.h r0 = r4.f1940a
            d3.a r0 = r0.d()
            android.media.CamcorderProfile r0 = r0.f3956d
            if (r0 == 0) goto L49
            int r0 = r0.videoFrameRate
            java.lang.Integer r0 = java.lang.Integer.valueOf(r0)
        L5b:
            if (r0 == 0) goto L78
            int r1 = r0.intValue()
            if (r1 <= 0) goto L78
            b3.a r1 = new b3.a
            r1.<init>(r5)
            android.util.Range r5 = new android.util.Range
            r5.<init>(r0, r0)
            r1.f3287b = r5
            E2.h r5 = r4.f1940a
            java.util.HashMap r5 = r5.f378a
            java.lang.String r0 = "FPS_RANGE"
            r5.put(r0, r1)
        L78:
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: T2.C0161f.n(D2.v):void");
    }

    public final void o(boolean z4, boolean z5) {
        F1.a aVar;
        S2.a aVar2;
        ArrayList arrayList = new ArrayList();
        if (z4) {
            arrayList.add(this.f1958t.getSurface());
            aVar = new F1.a(this, 5);
        } else {
            aVar = null;
        }
        if (z5 && (aVar2 = this.f1956r) != null) {
            arrayList.add(((ImageReader) aVar2.f1811b).getSurface());
        }
        arrayList.add(this.f1955q.getSurface());
        c(3, aVar, (Surface[]) arrayList.toArray(new Surface[0]));
    }

    @Override // android.media.ImageReader.OnImageAvailableListener
    public final void onImageAvailable(ImageReader imageReader) {
        Log.i("Camera", "onImageAvailable");
        Image imageAcquireNextImage = imageReader.acquireNextImage();
        if (imageAcquireNextImage == null) {
            return;
        }
        this.f1951m.post(new r(imageAcquireNextImage, this.f1960w, new C0779j(this, 18)));
        this.f1950l.f1969b = 1;
    }

    public final void p(RunnableC0093d runnableC0093d) {
        Surface surface;
        if (!this.f1959u) {
            ImageReader imageReader = this.f1955q;
            if (imageReader != null && imageReader.getSurface() != null) {
                Log.i("Camera", "startPreview");
                c(1, runnableC0093d, this.f1955q.getSurface());
                return;
            } else {
                if (runnableC0093d != null) {
                    runnableC0093d.run();
                    return;
                }
                return;
            }
        }
        if (this.f1942c == null) {
            if (runnableC0093d != null) {
                runnableC0093d.run();
                return;
            }
            return;
        }
        int i4 = this.f1940a.e().f4242d;
        e3.b bVar = this.f1940a.e().f4241c;
        int iC = bVar != null ? i4 == 0 ? bVar.c(bVar.e) : bVar.c(i4) : 0;
        if (((Integer) ((CameraCharacteristics) this.f1947i.f260b).get(CameraCharacteristics.LENS_FACING)).intValue() != this.f1943d) {
            iC = (iC + 180) % 360;
        }
        N n4 = this.f1942c;
        n4.v = iC;
        synchronized (n4.f1927w) {
            while (true) {
                try {
                    surface = n4.f1921p;
                    if (surface == null) {
                        n4.f1927w.wait();
                    }
                } catch (Throwable th) {
                    throw th;
                }
            }
        }
        c(3, runnableC0093d, surface);
    }

    public final void q() {
        Log.i("Camera", "unlockAutoFocus");
        if (this.f1954p == null) {
            Log.i("Camera", "[unlockAutoFocus] captureSession null, returning");
            return;
        }
        try {
            CaptureRequest.Builder builder = this.f1957s;
            CaptureRequest.Key key = CaptureRequest.CONTROL_AF_TRIGGER;
            builder.set(key, 2);
            this.f1954p.capture(this.f1957s.build(), null, this.f1951m);
            this.f1957s.set(key, 0);
            this.f1954p.capture(this.f1957s.build(), null, this.f1951m);
            h(null, new C0156a(this, 2));
        } catch (CameraAccessException e) {
            this.f1946h.W(e.getMessage() == null ? "CameraAccessException occurred while unlocking autofocus." : e.getMessage());
        }
    }
}
