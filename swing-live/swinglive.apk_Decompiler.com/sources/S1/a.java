package S1;

import B.k;
import D2.u;
import D2.v;
import I.C0053n;
import J3.i;
import K.j;
import M1.e;
import M1.g;
import Q1.b;
import Q3.F;
import Q3.O;
import U1.c;
import V1.f;
import a2.d;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.AudioRecord;
import android.media.audiofx.AcousticEchoCanceler;
import android.media.audiofx.NoiseSuppressor;
import android.opengl.EGLContext;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.SystemClock;
import android.util.Log;
import android.util.Size;
import android.view.MotionEvent;
import android.view.Surface;
import b2.C0246b;
import e2.C0373E;
import e2.C0374F;
import e2.L;
import e2.Q;
import e2.r;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicBoolean;
import o2.AbstractC0582b;
import o2.C0581a;
import o2.C0584d;
import r2.l;
import r2.m;
import r2.x;
import u1.C0690c;
import x3.AbstractC0728h;
import y1.AbstractC0752b;
import y1.EnumC0751a;
import y1.EnumC0758h;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final e f1795a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final b f1796b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final b f1797c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final H1.a f1798d;
    public final G1.a e;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final f f1800g;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final U1.a f1804k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f1805l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f1806m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final c f1807n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ int f1808o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public Object f1809p;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f1799f = false;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public boolean f1801h = false;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public boolean f1802i = false;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public boolean f1803j = false;

    public a(f fVar, int i4) {
        this.f1808o = i4;
        c cVar = new c();
        cVar.f2097a = 0;
        cVar.f2098b = SystemClock.elapsedRealtime();
        this.f1807n = cVar;
        u uVar = new u(this, 2);
        C0779j c0779j = new C0779j(this, 17);
        k kVar = new k(this, 15);
        C0690c c0690c = new C0690c(this, 18);
        Context context = fVar.getContext();
        this.f1800g = fVar;
        this.f1795a = new e(context);
        this.f1798d = new H1.a(uVar);
        this.f1796b = new b(kVar);
        this.f1797c = new b(c0690c);
        this.e = new G1.a(c0779j);
        U1.a aVar = new U1.a();
        aVar.f2089a = 2;
        aVar.f2090b = EnumC0758h.f6856a;
        EnumC0751a enumC0751a = EnumC0751a.f6835a;
        aVar.f2091c = -1;
        aVar.f2092d = -1;
        aVar.e = 0L;
        aVar.f2093f = 1;
        this.f1804k = aVar;
    }

    public final boolean a(int i4) {
        H0.a aVar;
        AbstractC0582b c0584d;
        H1.a aVar2 = this.f1798d;
        aVar2.getClass();
        try {
            aVar2.f523g = 12;
            int iMax = Math.max(AudioRecord.getMinBufferSize(44100, 12, 2), 8192);
            aVar2.f520c = new byte[iMax];
            byte[] bArr = new byte[iMax];
            byte[] bArr2 = new byte[iMax];
            aVar2.f521d = new byte[iMax];
            AudioRecord audioRecord = new AudioRecord(0, 44100, aVar2.f523g, 2, 40960);
            aVar2.f518a = audioRecord;
            audioRecord.getAudioSessionId();
            aVar2.f525i = new v(2);
        } catch (IllegalArgumentException e) {
            Log.e("MicrophoneManager", "create microphone error", e);
        }
        if (aVar2.f518a.getState() != 1) {
            throw new IllegalArgumentException("Some parameters specified are not valid");
        }
        Log.i("MicrophoneManager", "Microphone created, 44100hz, ".concat("Stereo"));
        aVar2.f522f = true;
        if (!aVar2.f522f) {
            return false;
        }
        switch (this.f1808o) {
            case 0:
                L l2 = (L) this.f1809p;
                if (l2 == null) {
                    i.g("rtmpClient");
                    throw null;
                }
                r rVar = l2.f4053g;
                rVar.f4202u = 44100;
                rVar.v = true;
                Q q4 = l2.f4054h;
                int iOrdinal = q4.f4076j.f4204x.ordinal();
                if (iOrdinal == 0) {
                    b2.c cVar = new b2.c();
                    cVar.f3282j = d.f2638b;
                    aVar = cVar;
                } else if (iOrdinal == 1) {
                    C0246b c0246b = new C0246b(0);
                    c0246b.f3279l = d.f2638b;
                    aVar = c0246b;
                } else {
                    if (iOrdinal != 2) {
                        throw new A0.b();
                    }
                    b2.d dVar = new b2.d();
                    dVar.f3285k = 44100;
                    aVar = dVar;
                }
                q4.f4077k = aVar;
                break;
                break;
            default:
                r2.r rVar2 = (r2.r) this.f1809p;
                if (rVar2 == null) {
                    i.g("srtClient");
                    throw null;
                }
                x xVar = rVar2.f6391d;
                r2.i iVar = xVar.f6422j;
                int iOrdinal2 = iVar.f6360j.ordinal();
                if (iOrdinal2 == 0) {
                    throw new IllegalArgumentException(B1.a.m("Unsupported codec: ", iVar.f6360j.name()));
                }
                r2.i iVar2 = xVar.f6422j;
                p2.b bVar = xVar.f6424l;
                if (iOrdinal2 == 1) {
                    C0581a c0581a = new C0581a(iVar2.f6355d - 16, bVar);
                    c0581a.e = 44100;
                    c0581a.f5964f = 2;
                    c0584d = c0581a;
                } else {
                    if (iOrdinal2 != 2) {
                        throw new A0.b();
                    }
                    int i5 = iVar2.f6355d - 16;
                    i.e(bVar, "psiManager");
                    c0584d = new C0584d(i5, bVar);
                }
                xVar.f6426n = c0584d;
                break;
                break;
        }
        boolean zR = this.e.r(i4, 44100, true);
        this.f1802i = zR;
        return zR;
    }

    public final void b(int i4, int i5, int i6, int i7, int i8) throws ExecutionException, TimeoutException {
        int i9;
        int i10;
        int i11;
        int i12;
        Size[] outputSizes;
        List listAsList;
        Object obj;
        if (i8 == 90 || i8 == 270) {
            i9 = i4;
            i10 = i5;
            i11 = i6;
            i12 = i7;
        } else {
            i10 = i4;
            i9 = i5;
            i12 = i6;
            i11 = i7;
        }
        f fVar = this.f1800g;
        fVar.f2200q = i10;
        fVar.f2201r = i9;
        if (this.f1801h) {
            fVar.f2202s = i12;
            fVar.f2203t = i11;
        }
        fVar.setRotation(i8 != 0 ? i8 - 90 : 270);
        Size size = null;
        if (!this.f1800g.f2191a.get()) {
            f fVar2 = this.f1800g;
            LinkedBlockingQueue linkedBlockingQueue = fVar2.f2197n;
            linkedBlockingQueue.clear();
            ThreadPoolExecutor threadPoolExecutor = fVar2.f2188A;
            if (threadPoolExecutor != null) {
                threadPoolExecutor.shutdownNow();
            }
            fVar2.f2188A = null;
            TimeUnit timeUnit = TimeUnit.MILLISECONDS;
            ThreadPoolExecutor threadPoolExecutor2 = new ThreadPoolExecutor(1, 1, 0L, timeUnit, linkedBlockingQueue);
            fVar2.f2188A = threadPoolExecutor2;
            V1.e eVar = new V1.e(fVar2, 0);
            try {
                if (!threadPoolExecutor2.isTerminated() && !threadPoolExecutor2.isShutdown()) {
                    threadPoolExecutor2.submit(new F1.a(eVar, 20)).get(5000L, timeUnit);
                }
            } catch (InterruptedException unused) {
            }
        }
        b bVar = this.f1796b;
        if (bVar.f1560x != null && bVar.f425h) {
            f fVar3 = this.f1800g;
            Surface surface = this.f1796b.f1560x;
            fVar3.getClass();
            i.e(surface, "surface");
            C0053n c0053n = fVar3.f2194d;
            if (((AtomicBoolean) c0053n.e).get()) {
                C0053n c0053n2 = fVar3.e;
                c0053n2.v();
                c0053n2.g(2, 2, surface, (EGLContext) c0053n.f706b);
            }
        }
        b bVar2 = this.f1797c;
        if (bVar2.f1560x != null && bVar2.f425h) {
            f fVar4 = this.f1800g;
            Surface surface2 = this.f1797c.f1560x;
            fVar4.getClass();
            i.e(surface2, "surface");
            C0053n c0053n3 = fVar4.f2194d;
            if (((AtomicBoolean) c0053n3.e).get()) {
                C0053n c0053n4 = fVar4.f2195f;
                c0053n4.v();
                c0053n4.g(2, 2, surface2, (EGLContext) c0053n3.f706b);
            }
        }
        int iMax = Math.max(this.f1796b.f1561y, this.f1797c.f1561y);
        int iMax2 = Math.max(this.f1796b.f1562z, this.f1797c.f1562z);
        e eVar2 = this.f1795a;
        SurfaceTexture surfaceTexture = this.f1800g.getSurfaceTexture();
        int i13 = this.f1796b.f1546A;
        String str = eVar2.f1069a;
        i.e(surfaceTexture, "surfaceTexture");
        Size size2 = new Size(iMax, iMax2);
        g gVar = eVar2.f1076i;
        i.e(gVar, "facing");
        try {
            CameraCharacteristics cameraCharacteristics = eVar2.f1072d.getCameraCharacteristics(e.e(eVar2, gVar));
            i.d(cameraCharacteristics, "getCameraCharacteristics(...)");
            CameraCharacteristics.Key key = CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP;
            i.d(key, "SCALER_STREAM_CONFIGURATION_MAP");
            try {
                obj = cameraCharacteristics.get(key);
            } catch (IllegalArgumentException unused2) {
                obj = null;
            }
            StreamConfigurationMap streamConfigurationMap = (StreamConfigurationMap) obj;
            if (streamConfigurationMap == null) {
                outputSizes = new Size[0];
            } else {
                outputSizes = streamConfigurationMap.getOutputSizes(SurfaceTexture.class);
                if (outputSizes == null) {
                    outputSizes = new Size[0];
                }
            }
        } catch (Exception e) {
            Log.e(str, "Error", e);
            outputSizes = new Size[0];
        }
        Size size3 = size2.getWidth() < size2.getHeight() ? new Size(size2.getHeight(), size2.getWidth()) : size2;
        int length = outputSizes.length;
        int i14 = 0;
        while (true) {
            if (i14 >= length) {
                break;
            }
            Size size4 = outputSizes[i14];
            if (i.a(size4, size3)) {
                size = size4;
                break;
            }
            i14++;
        }
        if (size != null) {
            size2 = size3;
        } else {
            float width = size3.getWidth() / size3.getHeight();
            ArrayList arrayList = new ArrayList();
            for (Size size5 : outputSizes) {
                if (size5.getWidth() / size5.getHeight() == width) {
                    arrayList.add(size5);
                }
            }
            if (!arrayList.isEmpty()) {
                ArrayList arrayListK0 = AbstractC0728h.k0(arrayList);
                arrayListK0.add(size3);
                M1.f fVar5 = new M1.f(0);
                if (arrayListK0.size() <= 1) {
                    listAsList = AbstractC0728h.i0(arrayListK0);
                } else {
                    Object[] array = arrayListK0.toArray(new Object[0]);
                    i.e(array, "<this>");
                    if (array.length > 1) {
                        Arrays.sort(array, fVar5);
                    }
                    listAsList = Arrays.asList(array);
                    i.d(listAsList, "asList(...)");
                }
                int iIndexOf = listAsList.indexOf(size3);
                size2 = iIndexOf > 0 ? (Size) listAsList.get(iIndexOf - 1) : (Size) listAsList.get(iIndexOf + 1);
            }
        }
        Log.i(str, "optimal resolution set to: " + size2.getWidth() + "x" + size2.getHeight());
        surfaceTexture.setDefaultBufferSize(size2.getWidth(), size2.getHeight());
        eVar2.f1071c = new Surface(surfaceTexture);
        eVar2.f1081n = i13;
        eVar2.f1074g = true;
    }

    public final void c(MotionEvent motionEvent) {
        e eVar = this.f1795a;
        eVar.getClass();
        if (motionEvent.getPointerCount() < 2 || motionEvent.getAction() != 2) {
            return;
        }
        float x4 = motionEvent.getX(0) - motionEvent.getX(1);
        float y4 = motionEvent.getY(0) - motionEvent.getY(1);
        float fSqrt = (float) Math.sqrt((y4 * y4) + (x4 * x4));
        float f4 = eVar.f1078k;
        if (fSqrt > f4) {
            eVar.i(eVar.f1079l + 0.1f);
        } else if (fSqrt < f4) {
            eVar.i(eVar.f1079l - 0.1f);
        }
        eVar.f1078k = fSqrt;
    }

    public final void d(g gVar, int i4, int i5) {
        int i6 = this.f1796b.f1546A;
        e eVar = this.f1795a;
        eVar.getClass();
        String strE = e.e(eVar, gVar);
        if (this.f1803j) {
            Log.e("Camera2Base", "Streaming or preview started, ignored");
            return;
        }
        this.f1805l = i4;
        this.f1806m = i5;
        b bVar = this.f1796b;
        bVar.f1546A = i6;
        bVar.f1548C = 0;
        b bVar2 = this.f1797c;
        bVar2.f1546A = i6;
        bVar2.f1548C = 0;
        b(i4, i5, i4, i5, 0);
        this.f1795a.g(strE);
        this.f1803j = true;
    }

    public final void e(String str) {
        a aVar;
        this.f1799f = true;
        if (this.f1804k.b()) {
            aVar = this;
            if (aVar.f1796b.f425h) {
                aVar.f1796b.r();
            }
            if (aVar.f1797c.f425h) {
                aVar.f1797c.r();
            }
        } else {
            long jC = AbstractC0752b.c();
            this.f1796b.m(jC);
            if (this.f1801h) {
                this.f1797c.m(jC);
            }
            if (this.f1802i) {
                this.e.m(jC);
            }
            b bVar = this.f1796b;
            int i4 = bVar.f1561y;
            int i5 = bVar.f1562z;
            b bVar2 = this.f1797c;
            aVar = this;
            aVar.b(i4, i5, bVar2.f1561y, bVar2.f1562z, bVar.f1548C);
            if (aVar.f1802i) {
                H1.a aVar2 = aVar.f1798d;
                synchronized (aVar2) {
                    int iB = j.b(1);
                    if (iB == 0) {
                        AudioRecord audioRecord = aVar2.f518a;
                        if (audioRecord == null) {
                            throw new IllegalStateException("Error starting, microphone was stopped or not created, use createMicrophone() before start()");
                        }
                        audioRecord.startRecording();
                    } else {
                        if (iB == 1) {
                            throw new IllegalStateException("Error starting, microphone was stopped or not created, use createMicrophone() before start()");
                        }
                        if (iB == 2) {
                            throw new IllegalStateException("Error starting, microphone was stopped or not created, use createMicrophone() before start()");
                        }
                    }
                    aVar2.e = true;
                    HandlerThread handlerThread = new HandlerThread("MicrophoneManager");
                    aVar2.f526j = handlerThread;
                    handlerThread.start();
                    new Handler(aVar2.f526j.getLooper()).post(new F1.a(aVar2, 2));
                }
            }
            e eVar = aVar.f1795a;
            if (!eVar.f1080m) {
                eVar.g(eVar.f1075h);
            }
            aVar.f1803j = true;
        }
        switch (aVar.f1808o) {
            case 0:
                b bVar3 = aVar.f1796b;
                int i6 = bVar3.f1548C;
                if (i6 == 90 || i6 == 270) {
                    L l2 = (L) aVar.f1809p;
                    if (l2 == null) {
                        i.g("rtmpClient");
                        throw null;
                    }
                    int i7 = bVar3.f1562z;
                    int i8 = bVar3.f1561y;
                    r rVar = l2.f4053g;
                    rVar.f4199r = i7;
                    rVar.f4200s = i8;
                } else {
                    L l4 = (L) aVar.f1809p;
                    if (l4 == null) {
                        i.g("rtmpClient");
                        throw null;
                    }
                    int i9 = bVar3.f1561y;
                    int i10 = bVar3.f1562z;
                    r rVar2 = l4.f4053g;
                    rVar2.f4199r = i9;
                    rVar2.f4200s = i10;
                }
                L l5 = (L) aVar.f1809p;
                if (l5 == null) {
                    i.g("rtmpClient");
                    throw null;
                }
                l5.f4053g.f4201t = bVar3.f1546A;
                if (!l5.f4055i) {
                    l5.f4055i = true;
                    l5.f4052f = F.s(l5.f4051d, null, new C0373E(str, l5, null), 3);
                }
                break;
                break;
            default:
                r2.r rVar3 = (r2.r) aVar.f1809p;
                if (rVar3 == null) {
                    i.g("srtClient");
                    throw null;
                }
                if (!rVar3.f6395i) {
                    rVar3.f6395i = true;
                    rVar3.f6393g = F.s(rVar3.f6392f, null, new l(str, rVar3, null), 3);
                }
                break;
                break;
        }
        aVar.f1803j = true;
    }

    public final void f() {
        if (this.f1799f || this.f1804k.b()) {
            Log.e("Camera2Base", "Streaming or preview stopped, ignored");
            return;
        }
        if (!this.f1803j) {
            Log.e("Camera2Base", "Preview stopped, ignored");
            return;
        }
        this.f1800g.b();
        this.f1795a.a(true);
        this.f1803j = false;
        this.f1805l = 0;
        this.f1806m = 0;
    }

    public final void g() {
        if (this.f1799f) {
            this.f1799f = false;
            switch (this.f1808o) {
                case 0:
                    L l2 = (L) this.f1809p;
                    if (l2 == null) {
                        i.g("rtmpClient");
                        throw null;
                    }
                    X3.e eVar = O.f1596a;
                    F.s(F.b(X3.d.f2437c), null, new C0374F(l2, null), 3);
                    break;
                    break;
                default:
                    r2.r rVar = (r2.r) this.f1809p;
                    if (rVar == null) {
                        i.g("srtClient");
                        throw null;
                    }
                    X3.e eVar2 = O.f1596a;
                    F.s(F.b(X3.d.f2437c), null, new m(rVar, null), 3);
                    break;
                    break;
            }
        }
        if (this.f1804k.f2089a == 3) {
            return;
        }
        this.f1803j = true;
        if (this.f1802i) {
            H1.a aVar = this.f1798d;
            synchronized (aVar) {
                try {
                    aVar.e = false;
                    aVar.f522f = false;
                    HandlerThread handlerThread = aVar.f526j;
                    if (handlerThread != null) {
                        handlerThread.quitSafely();
                    }
                    AudioRecord audioRecord = aVar.f518a;
                    if (audioRecord != null) {
                        audioRecord.setRecordPositionUpdateListener(null);
                        aVar.f518a.stop();
                        aVar.f518a.release();
                        aVar.f518a = null;
                    }
                    v vVar = aVar.f525i;
                    if (vVar != null) {
                        AcousticEchoCanceler acousticEchoCanceler = (AcousticEchoCanceler) vVar.f260b;
                        if (acousticEchoCanceler != null) {
                            acousticEchoCanceler.setEnabled(false);
                        }
                        AcousticEchoCanceler acousticEchoCanceler2 = (AcousticEchoCanceler) vVar.f260b;
                        if (acousticEchoCanceler2 != null) {
                            acousticEchoCanceler2.release();
                        }
                        vVar.f260b = null;
                        NoiseSuppressor noiseSuppressor = (NoiseSuppressor) vVar.f261c;
                        if (noiseSuppressor != null) {
                            noiseSuppressor.setEnabled(false);
                        }
                        NoiseSuppressor noiseSuppressor2 = (NoiseSuppressor) vVar.f261c;
                        if (noiseSuppressor2 != null) {
                            noiseSuppressor2.release();
                        }
                        vVar.f261c = null;
                    }
                    Log.i("MicrophoneManager", "Microphone stopped");
                } catch (Throwable th) {
                    throw th;
                }
            }
        }
        f fVar = this.f1800g;
        fVar.f2197n.clear();
        fVar.e.v();
        f fVar2 = this.f1800g;
        fVar2.f2197n.clear();
        fVar2.f2195f.v();
        this.f1796b.o(true);
        if (this.f1801h) {
            this.f1797c.o(true);
        }
        if (this.f1802i) {
            this.e.o(true);
        }
        U1.a aVar2 = this.f1804k;
        aVar2.f2094g = null;
        aVar2.f2095h = null;
    }

    public final void h() {
        boolean z4 = this.f1799f;
        g gVar = g.f1084a;
        g gVar2 = g.f1085b;
        if (z4 || this.f1804k.b() || this.f1803j) {
            e eVar = this.f1795a;
            eVar.getClass();
            try {
                eVar.h((eVar.f1070b == null || eVar.f1076i == gVar2) ? e.e(eVar, gVar) : e.e(eVar, gVar2));
                return;
            } catch (Exception e) {
                Log.e(eVar.f1069a, "Error", e);
                return;
            }
        }
        e eVar2 = this.f1795a;
        if (eVar2.f1076i != gVar2) {
            gVar = gVar2;
        }
        try {
            String strE = e.e(eVar2, gVar);
            eVar2.f1076i = gVar;
            eVar2.f1075h = strE;
        } catch (Exception e4) {
            Log.e(eVar2.f1069a, "Error", e4);
        }
    }
}
