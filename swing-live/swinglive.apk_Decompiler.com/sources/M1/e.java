package M1;

import A.AbstractC0005e;
import J3.i;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.OutputConfiguration;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.util.Log;
import android.util.Range;
import android.view.Surface;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public final class e extends CameraDevice.StateCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f1069a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public CameraDevice f1070b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Surface f1071c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final CameraManager f1072d;
    public Handler e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public CameraCaptureSession f1073f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f1074g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public String f1075h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public g f1076i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public CaptureRequest.Builder f1077j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public float f1078k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public float f1079l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f1080m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f1081n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final Semaphore f1082o;

    public e(Context context) {
        i.e(context, "context");
        this.f1069a = "Camera2ApiManager";
        SurfaceTexture surfaceTexture = new SurfaceTexture(-1);
        surfaceTexture.release();
        this.f1071c = new Surface(surfaceTexture);
        Object systemService = context.getSystemService("camera");
        i.c(systemService, "null cannot be cast to non-null type android.hardware.camera2.CameraManager");
        this.f1072d = (CameraManager) systemService;
        String strE = "0";
        this.f1075h = "0";
        g gVar = g.f1084a;
        this.f1076i = gVar;
        this.f1081n = 30;
        this.f1082o = new Semaphore(0);
        try {
            strE = e(this, gVar);
        } catch (Exception unused) {
        }
        this.f1075h = strE;
        new c(this, 0);
        i.d(this.f1072d.getCameraIdList(), "getCameraIdList(...)");
    }

    public static void b(CameraDevice cameraDevice, ArrayList arrayList, a aVar, b bVar, Handler handler) throws CameraAccessException {
        d dVar = new d(aVar, bVar);
        if (Build.VERSION.SDK_INT < 28) {
            cameraDevice.createCaptureSession(arrayList, dVar, handler);
            return;
        }
        ArrayList arrayList2 = new ArrayList(AbstractC0730j.V(arrayList));
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            arrayList2.add(new OutputConfiguration((Surface) it.next()));
        }
        Iterator it2 = arrayList2.iterator();
        while (it2.hasNext()) {
            ((OutputConfiguration) it2.next()).setPhysicalCameraId(null);
        }
        AbstractC0005e.s();
        cameraDevice.createCaptureSession(AbstractC0005e.i(arrayList2, Executors.newSingleThreadExecutor(), dVar));
    }

    public static String e(e eVar, g gVar) throws CameraAccessException {
        CameraManager cameraManager = eVar.f1072d;
        eVar.getClass();
        i.e(gVar, "facing");
        i.e(cameraManager, "cameraManager");
        int i4 = gVar == g.f1084a ? 1 : 0;
        String[] cameraIdList = cameraManager.getCameraIdList();
        i.d(cameraIdList, "getCameraIdList(...)");
        for (String str : cameraIdList) {
            Integer num = (Integer) cameraManager.getCameraCharacteristics(str).get(CameraCharacteristics.LENS_FACING);
            if (num != null && num.intValue() == i4) {
                i.b(str);
                return str;
            }
        }
        if (cameraIdList.length == 0) {
            throw new A0.b("Camera no detected");
        }
        String str2 = cameraIdList[0];
        i.d(str2, "get(...)");
        return str2;
    }

    public final void a(boolean z4) {
        Looper looper;
        this.f1079l = 1.0f;
        CameraCaptureSession cameraCaptureSession = this.f1073f;
        if (cameraCaptureSession != null) {
            cameraCaptureSession.close();
        }
        this.f1073f = null;
        CameraDevice cameraDevice = this.f1070b;
        if (cameraDevice != null) {
            cameraDevice.close();
        }
        this.f1070b = null;
        Handler handler = this.e;
        if (handler != null && (looper = handler.getLooper()) != null) {
            looper.quitSafely();
        }
        this.e = null;
        if (z4) {
            SurfaceTexture surfaceTexture = new SurfaceTexture(-1);
            surfaceTexture.release();
            this.f1071c = new Surface(surfaceTexture);
            this.f1077j = null;
        }
        this.f1074g = false;
        this.f1080m = false;
    }

    public final CaptureRequest c(CameraDevice cameraDevice, ArrayList arrayList) throws CameraAccessException {
        CaptureRequest.Builder builderCreateCaptureRequest = cameraDevice.createCaptureRequest(1);
        i.d(builderCreateCaptureRequest, "createCaptureRequest(...)");
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            builderCreateCaptureRequest.addTarget((Surface) it.next());
        }
        builderCreateCaptureRequest.set(CaptureRequest.CONTROL_MODE, 1);
        int iMin = Math.min(60, this.f1081n);
        builderCreateCaptureRequest.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, new Range(Integer.valueOf(iMin), Integer.valueOf(iMin)));
        this.f1077j = builderCreateCaptureRequest;
        CaptureRequest captureRequestBuild = builderCreateCaptureRequest.build();
        i.d(captureRequestBuild, "build(...)");
        return captureRequestBuild;
    }

    public final CameraCharacteristics d() {
        try {
            return this.f1072d.getCameraCharacteristics(this.f1075h);
        } catch (Exception e) {
            Log.e(this.f1069a, "Error", e);
            return null;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x0049  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.util.Range f() {
        /*
            r8 = this;
            android.hardware.camera2.CameraCharacteristics r0 = r8.d()
            r1 = 1065353216(0x3f800000, float:1.0)
            java.lang.Float r2 = java.lang.Float.valueOf(r1)
            if (r0 != 0) goto L12
            android.util.Range r0 = new android.util.Range
            r0.<init>(r2, r2)
            return r0
        L12:
            int r3 = android.os.Build.VERSION.SDK_INT
            r4 = 30
            r5 = 0
            if (r3 < r4) goto L49
            android.hardware.camera2.CameraCharacteristics r3 = r8.d()
            r4 = -1
            if (r3 != 0) goto L21
            goto L34
        L21:
            android.hardware.camera2.CameraCharacteristics$Key r6 = android.hardware.camera2.CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL
            java.lang.String r7 = "INFO_SUPPORTED_HARDWARE_LEVEL"
            J3.i.d(r6, r7)
            java.lang.Object r3 = y1.AbstractC0752b.k(r3, r6)
            java.lang.Integer r3 = (java.lang.Integer) r3
            if (r3 == 0) goto L34
            int r4 = r3.intValue()
        L34:
            r3 = 2
            if (r4 == r3) goto L49
            android.hardware.camera2.CameraCharacteristics$Key r3 = A.T.f()
            java.lang.String r4 = "CONTROL_ZOOM_RATIO_RANGE"
            J3.i.d(r3, r4)
            java.lang.Object r3 = r0.get(r3)     // Catch: java.lang.IllegalArgumentException -> L45
            goto L46
        L45:
            r3 = r5
        L46:
            android.util.Range r3 = (android.util.Range) r3
            goto L4a
        L49:
            r3 = r5
        L4a:
            if (r3 != 0) goto L69
            android.hardware.camera2.CameraCharacteristics$Key r3 = android.hardware.camera2.CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM
            java.lang.String r4 = "SCALER_AVAILABLE_MAX_DIGITAL_ZOOM"
            J3.i.d(r3, r4)
            java.lang.Object r5 = r0.get(r3)     // Catch: java.lang.IllegalArgumentException -> L57
        L57:
            java.lang.Float r5 = (java.lang.Float) r5
            if (r5 == 0) goto L5f
            float r1 = r5.floatValue()
        L5f:
            android.util.Range r0 = new android.util.Range
            java.lang.Float r1 = java.lang.Float.valueOf(r1)
            r0.<init>(r2, r1)
            return r0
        L69:
            return r3
        */
        throw new UnsupportedOperationException("Method not decompiled: M1.e.f():android.util.Range");
    }

    public final void g(String str) {
        Object obj;
        CameraManager cameraManager = this.f1072d;
        i.e(str, "cameraId");
        this.f1075h = str;
        if (!this.f1074g) {
            throw new IllegalStateException("You need prepare camera before open it");
        }
        StringBuilder sb = new StringBuilder();
        String str2 = this.f1069a;
        sb.append(str2);
        sb.append(" Id = ");
        sb.append(str);
        HandlerThread handlerThread = new HandlerThread(sb.toString());
        handlerThread.start();
        Handler handler = new Handler(handlerThread.getLooper());
        this.e = handler;
        try {
            cameraManager.openCamera(str, this, handler);
            this.f1082o.acquireUninterruptibly();
            CameraCharacteristics cameraCharacteristics = cameraManager.getCameraCharacteristics(str);
            i.d(cameraCharacteristics, "getCameraCharacteristics(...)");
            this.f1080m = true;
            CameraCharacteristics.Key key = CameraCharacteristics.LENS_FACING;
            i.d(key, "LENS_FACING");
            try {
                obj = cameraCharacteristics.get(key);
            } catch (IllegalArgumentException unused) {
                obj = null;
            }
            Integer num = (Integer) obj;
            if (num != null) {
                this.f1076i = num.intValue() == 0 ? g.f1085b : g.f1084a;
            }
        } catch (Exception e) {
            Log.e(str2, "Error", e);
        }
    }

    public final void h(String str) {
        i.e(str, "cameraId");
        if (this.f1070b != null) {
            a(false);
            Surface surface = this.f1071c;
            int i4 = this.f1081n;
            i.e(surface, "surface");
            this.f1071c = surface;
            this.f1081n = i4;
            this.f1074g = true;
            g(str);
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:21:0x0070 A[Catch: Exception -> 0x006d, TRY_LEAVE, TryCatch #0 {Exception -> 0x006d, blocks: (B:9:0x003c, B:11:0x0044, B:18:0x0061, B:34:0x00cb, B:41:0x00de, B:40:0x00db, B:14:0x004c, B:16:0x005b, B:21:0x0070, B:22:0x0077, B:25:0x007d, B:28:0x0082, B:31:0x0097, B:33:0x00ac, B:42:0x00e1, B:43:0x00e6, B:44:0x00e7, B:45:0x00ec, B:37:0x00d2), top: B:48:0x003c, inners: #1 }] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void i(float r13) {
        /*
            Method dump skipped, instruction units count: 241
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: M1.e.i(float):void");
    }

    @Override // android.hardware.camera2.CameraDevice.StateCallback
    public final void onDisconnected(CameraDevice cameraDevice) {
        i.e(cameraDevice, "cameraDevice");
        cameraDevice.close();
        this.f1082o.release();
        Log.i(this.f1069a, "Camera disconnected");
    }

    @Override // android.hardware.camera2.CameraDevice.StateCallback
    public final void onError(CameraDevice cameraDevice, int i4) {
        i.e(cameraDevice, "cameraDevice");
        cameraDevice.close();
        this.f1082o.release();
        Log.e(this.f1069a, "Open failed: " + i4);
    }

    @Override // android.hardware.camera2.CameraDevice.StateCallback
    public final void onOpened(CameraDevice cameraDevice) {
        String str = this.f1069a;
        i.e(cameraDevice, "cameraDevice");
        this.f1070b = cameraDevice;
        try {
            ArrayList arrayList = new ArrayList();
            arrayList.add(this.f1071c);
            b(cameraDevice, arrayList, new a(0, this, c(cameraDevice, arrayList)), new b(this, 0), this.e);
        } catch (IllegalStateException unused) {
            h(this.f1075h);
        } catch (Exception e) {
            Log.e(str, "Error", e);
        }
        this.f1082o.release();
        Log.i(str, "Camera opened");
    }
}
