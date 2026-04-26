package io.flutter.embedding.engine;

import A.C0003c;
import A.K;
import D2.C0033h;
import E2.b;
import E2.i;
import E2.j;
import E2.k;
import F2.f;
import G2.a;
import H2.c;
import H2.d;
import I.C0053n;
import M.g;
import N2.m;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaExtractor;
import android.os.Build;
import android.os.Looper;
import android.util.Log;
import android.util.SparseArray;
import android.view.Choreographer;
import android.view.Surface;
import android.view.SurfaceControl;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import android.widget.FrameLayout;
import androidx.annotation.Keep;
import com.google.android.gms.common.internal.r;
import com.google.crypto.tink.shaded.protobuf.S;
import io.flutter.embedding.engine.mutatorsstack.FlutterMutatorsStack;
import io.flutter.embedding.engine.renderer.SurfaceTextureWrapper;
import io.flutter.embedding.engine.renderer.l;
import io.flutter.plugin.platform.C0428d;
import io.flutter.plugin.platform.o;
import io.flutter.plugin.platform.p;
import io.flutter.plugin.platform.q;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.TextureRegistry$ImageConsumer;
import io.flutter.view.e;
import io.flutter.view.h;
import io.flutter.view.u;
import io.flutter.view.v;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import o3.C0592H;
import p0.C0616a;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
@Keep
public class FlutterJNI {
    private static final String TAG = "FlutterJNI";
    private static k asyncWaitForVsyncDelegate = null;
    private static float displayDensity = -1.0f;
    private static float displayHeight = -1.0f;
    private static float displayWidth = -1.0f;
    private static boolean initCalled = false;
    private static boolean loadLibraryCalled = false;
    private static boolean prefetchDefaultFontManagerCalled = false;
    private static float refreshRateFPS = 60.0f;
    private static String vmServiceUri;
    private j accessibilityDelegate;
    private a deferredComponentManager;
    private P2.a localizationPlugin;
    private Long nativeShellHolderId;
    private F2.j platformMessageHandler;
    private q platformViewsController;
    private p platformViewsController2;
    private m settingsChannel;
    private ReentrantReadWriteLock shellHolderLock = new ReentrantReadWriteLock();
    private final Set<b> engineLifecycleListeners = new CopyOnWriteArraySet();
    private final Set<io.flutter.embedding.engine.renderer.k> flutterUiDisplayListeners = new CopyOnWriteArraySet();
    private final Set<l> flutterUiResizeListeners = new CopyOnWriteArraySet();
    private final Looper mainLooper = Looper.getMainLooper();

    private static void asyncWaitForVsync(long j4) {
        k kVar = asyncWaitForVsyncDelegate;
        if (kVar == null) {
            throw new IllegalStateException("An AsyncWaitForVsyncDelegate must be registered with FlutterJNI before asyncWaitForVsync() is invoked.");
        }
        e eVar = (e) kVar;
        eVar.getClass();
        Choreographer choreographer = Choreographer.getInstance();
        v vVar = (v) eVar.f4703a;
        u uVar = vVar.f4828c;
        if (uVar != null) {
            uVar.f4823a = j4;
            vVar.f4828c = null;
        } else {
            uVar = new u(vVar, j4);
        }
        choreographer.postFrameCallback(uVar);
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r2v4 */
    /* JADX WARN: Type inference failed for: r2v5 */
    public static Bitmap decodeImage(ByteBuffer byteBuffer, long j4) {
        H2.b bVar;
        C0690c c0690c = 0;
        c0690c = 0;
        if (Build.VERSION.SDK_INT < 28) {
            return null;
        }
        i iVar = new i(j4);
        d dVar = new d();
        int iRemaining = byteBuffer.remaining();
        byte[] bArr = new byte[iRemaining];
        byteBuffer.get(bArr);
        byteBuffer.rewind();
        int iE = 1;
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeByteArray(bArr, 0, iRemaining, options);
            dVar.f532d = options.outMimeType;
            dVar.f533f = options.outHeight;
            dVar.f534g = options.outWidth;
        } catch (Exception e) {
            Log.e("BitmapMetadataReader", "Failed to decode image for mime type", e);
        }
        if ("image/heif".equals(dVar.f532d)) {
            try {
                c cVar = new c(bArr);
                MediaExtractor mediaExtractor = new MediaExtractor();
                mediaExtractor.setDataSource(cVar);
                H0.a.R(dVar, mediaExtractor);
            } catch (Exception e4) {
                Log.e("MediaMetadataReader", "Failed to decode HEIF image using MediaExtractor", e4);
            }
            nativeImageHeaderCallback(iVar.f379a, dVar.f529a, dVar.f530b);
            try {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bArr);
                try {
                    g gVar = new g(byteArrayInputStream);
                    M.c cVarC = gVar.c("Orientation");
                    if (cVarC != null) {
                        try {
                            iE = cVarC.e(gVar.f937f);
                        } catch (NumberFormatException unused) {
                        }
                    }
                    dVar.e = iE;
                    byteArrayInputStream.close();
                } finally {
                }
            } catch (IOException e5) {
                Log.e("ExifMetadataReader", "Failed to read EXIF metadata", e5);
            }
        }
        if ("image/heif".equals(dVar.f532d)) {
            int i4 = Build.VERSION.SDK_INT;
            if (i4 == 36) {
                bVar = new H2.b(c0690c, 0);
            } else if (i4 < 36) {
                bVar = new H2.b(c0690c, 1);
            }
            c0690c = bVar;
        }
        if (c0690c == 0) {
            c0690c = new C0690c(iVar, 5);
        }
        return c0690c.u(byteBuffer, dVar);
    }

    private void ensureAttachedToNative() {
        if (this.nativeShellHolderId == null) {
            throw new RuntimeException("Cannot execute operation because FlutterJNI is not attached to native.");
        }
    }

    private void ensureNotAttachedToNative() {
        if (this.nativeShellHolderId != null) {
            throw new RuntimeException("Cannot execute operation because FlutterJNI is attached to native.");
        }
    }

    private void ensureRunningOnMainThread() {
        if (Looper.myLooper() == this.mainLooper) {
            return;
        }
        throw new RuntimeException("Methods marked with @UiThread must be executed on the main thread. Current thread: " + Thread.currentThread().getName());
    }

    public static String getVMServiceUri() {
        return vmServiceUri;
    }

    private void handlePlatformMessageResponse(int i4, ByteBuffer byteBuffer) {
        O2.e eVar;
        F2.j jVar = this.platformMessageHandler;
        if (jVar == null || (eVar = (O2.e) ((F2.i) jVar).f468f.remove(Integer.valueOf(i4))) == null) {
            return;
        }
        try {
            eVar.a(byteBuffer);
            if (byteBuffer == null || !byteBuffer.isDirect()) {
                return;
            }
            byteBuffer.limit(0);
        } catch (Error e) {
            Thread threadCurrentThread = Thread.currentThread();
            if (threadCurrentThread.getUncaughtExceptionHandler() == null) {
                throw e;
            }
            threadCurrentThread.getUncaughtExceptionHandler().uncaughtException(threadCurrentThread, e);
        } catch (Exception e4) {
            Log.e("DartMessenger", "Uncaught exception in binary message reply handler", e4);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static /* synthetic */ void lambda$loadLibrary$0(String str) {
    }

    private native long nativeAttach(FlutterJNI flutterJNI);

    private native void nativeCleanupMessageData(long j4);

    private native void nativeDeferredComponentInstallFailure(int i4, String str, boolean z4);

    private native void nativeDestroy(long j4);

    private native void nativeDispatchEmptyPlatformMessage(long j4, String str, int i4);

    private native void nativeDispatchPlatformMessage(long j4, String str, ByteBuffer byteBuffer, int i4, int i5);

    private native void nativeDispatchPointerDataPacket(long j4, ByteBuffer byteBuffer, int i4);

    private native void nativeDispatchSemanticsAction(long j4, int i4, int i5, ByteBuffer byteBuffer, int i6);

    private native boolean nativeFlutterTextUtilsIsEmoji(int i4);

    private native boolean nativeFlutterTextUtilsIsEmojiModifier(int i4);

    private native boolean nativeFlutterTextUtilsIsEmojiModifierBase(int i4);

    private native boolean nativeFlutterTextUtilsIsRegionalIndicator(int i4);

    private native boolean nativeFlutterTextUtilsIsVariationSelector(int i4);

    private native Bitmap nativeGetBitmap(long j4);

    private native boolean nativeGetIsSoftwareRenderingEnabled();

    public static native void nativeImageHeaderCallback(long j4, int i4, int i5);

    private static native void nativeInit(Context context, String[] strArr, String str, String str2, String str3, long j4, int i4);

    private native void nativeInvokePlatformMessageEmptyResponseCallback(long j4, int i4);

    private native void nativeInvokePlatformMessageResponseCallback(long j4, int i4, ByteBuffer byteBuffer, int i5);

    private native boolean nativeIsSurfaceControlEnabled(long j4);

    private native void nativeLoadDartDeferredLibrary(long j4, int i4, String[] strArr);

    @Deprecated
    public static native FlutterCallbackInformation nativeLookupCallbackInformation(long j4);

    private native void nativeMarkTextureFrameAvailable(long j4, long j5);

    private native void nativeNotifyLowMemoryWarning(long j4);

    private native void nativeOnVsync(long j4, long j5, long j6);

    private static native void nativePrefetchDefaultFontManager();

    private native void nativeRegisterImageTexture(long j4, long j5, WeakReference<TextureRegistry$ImageConsumer> weakReference, boolean z4);

    private native void nativeRegisterTexture(long j4, long j5, WeakReference<SurfaceTextureWrapper> weakReference);

    private native void nativeRunBundleAndSnapshotFromLibrary(long j4, String str, String str2, String str3, AssetManager assetManager, List<String> list, long j5);

    private native void nativeScheduleFrame(long j4);

    private native void nativeSetAccessibilityFeatures(long j4, int i4);

    private native void nativeSetSemanticsEnabled(long j4, boolean z4);

    private native void nativeSetViewportMetrics(long j4, float f4, int i4, int i5, int i6, int i7, int i8, int i9, int i10, int i11, int i12, int i13, int i14, int i15, int i16, int i17, int i18, int[] iArr, int[] iArr2, int[] iArr3, int i19, int i20, int i21, int i22);

    private native FlutterJNI nativeSpawn(long j4, String str, String str2, String str3, List<String> list, long j5);

    private native void nativeSurfaceChanged(long j4, int i4, int i5);

    private native void nativeSurfaceCreated(long j4, Surface surface);

    private native void nativeSurfaceDestroyed(long j4);

    private native void nativeSurfaceWindowChanged(long j4, Surface surface);

    private native void nativeUnregisterTexture(long j4, long j5);

    private native void nativeUpdateDisplayMetrics(long j4);

    private native void nativeUpdateJavaAssetManager(long j4, AssetManager assetManager, String str);

    private native void nativeUpdateRefreshRate(float f4);

    private void onPreEngineRestart() {
        Iterator<b> it = this.engineLifecycleListeners.iterator();
        while (it.hasNext()) {
            it.next().a();
        }
    }

    private void setApplicationLocale(String str) {
        ensureRunningOnMainThread();
        j jVar = this.accessibilityDelegate;
        if (jVar != null) {
            ((io.flutter.view.k) ((e) jVar).f4703a).f4799m = str;
        }
    }

    private void updateCustomAccessibilityActions(ByteBuffer byteBuffer, String[] strArr) {
        ensureRunningOnMainThread();
        j jVar = this.accessibilityDelegate;
        if (jVar != null) {
            byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
            io.flutter.view.k kVar = (io.flutter.view.k) ((e) jVar).f4703a;
            kVar.getClass();
            while (byteBuffer.hasRemaining()) {
                io.flutter.view.i iVarB = kVar.b(byteBuffer.getInt());
                iVarB.f4733c = byteBuffer.getInt();
                iVarB.f4734d = io.flutter.view.k.d(byteBuffer, strArr);
                iVarB.e = io.flutter.view.k.d(byteBuffer, strArr);
            }
        }
    }

    private void updateSemantics(ByteBuffer byteBuffer, String[] strArr, ByteBuffer[] byteBufferArr) {
        ensureRunningOnMainThread();
        j jVar = this.accessibilityDelegate;
        if (jVar != null) {
            ((e) jVar).a(byteBuffer, strArr, byteBufferArr);
        }
    }

    public boolean IsSurfaceControlEnabled() {
        return nativeIsSurfaceControlEnabled(this.nativeShellHolderId.longValue());
    }

    public void addEngineLifecycleListener(b bVar) {
        ensureRunningOnMainThread();
        this.engineLifecycleListeners.add(bVar);
    }

    public void addIsDisplayingFlutterUiListener(io.flutter.embedding.engine.renderer.k kVar) {
        ensureRunningOnMainThread();
        this.flutterUiDisplayListeners.add(kVar);
    }

    public void addResizingFlutterUiListener(l lVar) {
        ensureRunningOnMainThread();
        this.flutterUiResizeListeners.add(lVar);
    }

    @SuppressLint({"NewApi"})
    public void applyTransactions() {
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("");
        }
        SurfaceControl.Transaction transactionG = K.g();
        int i4 = 0;
        while (true) {
            ArrayList arrayList = pVar.f4658r;
            if (i4 >= arrayList.size()) {
                transactionG.apply();
                arrayList.clear();
                return;
            } else {
                transactionG = transactionG.merge(o.d(arrayList.get(i4)));
                i4++;
            }
        }
    }

    public void attachToNative() {
        ensureRunningOnMainThread();
        ensureNotAttachedToNative();
        this.shellHolderLock.writeLock().lock();
        try {
            this.nativeShellHolderId = Long.valueOf(performNativeAttach(this));
        } finally {
            this.shellHolderLock.writeLock().unlock();
        }
    }

    public void cleanupMessageData(long j4) {
        nativeCleanupMessageData(j4);
    }

    /* JADX WARN: Code restructure failed: missing block: B:45:0x012c, code lost:
    
        r4 = r0.iterator();
     */
    /* JADX WARN: Code restructure failed: missing block: B:47:0x0134, code lost:
    
        if (r4.hasNext() == false) goto L76;
     */
    /* JADX WARN: Code restructure failed: missing block: B:48:0x0136, code lost:
    
        r5 = (java.util.Locale) r4.next();
     */
    /* JADX WARN: Code restructure failed: missing block: B:49:0x0148, code lost:
    
        if (r3.getLanguage().equals(r5.toLanguageTag()) == false) goto L77;
     */
    /* JADX WARN: Code restructure failed: missing block: B:51:0x014b, code lost:
    
        r4 = r0.iterator();
     */
    /* JADX WARN: Code restructure failed: missing block: B:53:0x0153, code lost:
    
        if (r4.hasNext() == false) goto L78;
     */
    /* JADX WARN: Code restructure failed: missing block: B:54:0x0155, code lost:
    
        r5 = (java.util.Locale) r4.next();
     */
    /* JADX WARN: Code restructure failed: missing block: B:55:0x0167, code lost:
    
        if (r3.getLanguage().equals(r5.getLanguage()) == false) goto L79;
     */
    /* JADX WARN: Code restructure failed: missing block: B:57:0x016a, code lost:
    
        r2 = r2 + 1;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.String[] computePlatformResolvedLocale(java.lang.String[] r10) {
        /*
            Method dump skipped, instruction units count: 393
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.flutter.embedding.engine.FlutterJNI.computePlatformResolvedLocale(java.lang.String[]):java.lang.String[]");
    }

    public FlutterOverlaySurface createOverlaySurface() {
        ensureRunningOnMainThread();
        q qVar = this.platformViewsController;
        if (qVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to position an overlay surface");
        }
        C0428d c0428d = new C0428d(qVar.f4669d.getContext(), qVar.f4669d.getWidth(), qVar.f4669d.getHeight(), 2);
        c0428d.f4623n = qVar.f4673o;
        int i4 = qVar.v;
        qVar.v = i4 + 1;
        qVar.f4678t.put(i4, c0428d);
        return new FlutterOverlaySurface(i4, c0428d.getSurface());
    }

    @SuppressLint({"NewApi"})
    public FlutterOverlaySurface createOverlaySurface2() {
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to position an overlay surface");
        }
        if (pVar.f4660t == null) {
            SurfaceControl.Builder builderF = K.f();
            builderF.setBufferSize(pVar.f4651d.getWidth(), pVar.f4651d.getHeight());
            builderF.setFormat(1);
            builderF.setName("Flutter Overlay Surface");
            builderF.setOpaque(false);
            builderF.setHidden(false);
            SurfaceControl surfaceControlBuild = builderF.build();
            SurfaceControl.Transaction transactionBuildReparentTransaction = pVar.f4651d.getRootSurfaceControl().buildReparentTransaction(surfaceControlBuild);
            transactionBuildReparentTransaction.setLayer(surfaceControlBuild, 1000);
            transactionBuildReparentTransaction.apply();
            pVar.f4660t = K.e(surfaceControlBuild);
            pVar.f4661u = surfaceControlBuild;
        }
        return new FlutterOverlaySurface(0, pVar.f4660t);
    }

    @SuppressLint({"NewApi"})
    public SurfaceControl.Transaction createTransaction() {
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("");
        }
        SurfaceControl.Transaction transactionG = K.g();
        pVar.f4658r.add(transactionG);
        return transactionG;
    }

    public void deferredComponentInstallFailure(int i4, String str, boolean z4) {
        ensureRunningOnMainThread();
        nativeDeferredComponentInstallFailure(i4, str, z4);
    }

    @SuppressLint({"NewApi"})
    public void destroyOverlaySurface2() {
        ensureRunningOnMainThread();
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to destroy an overlay surface");
        }
        Surface surface = pVar.f4660t;
        if (surface != null) {
            surface.release();
            pVar.f4660t = null;
            pVar.f4661u = null;
        }
    }

    public void destroyOverlaySurfaces() {
        ensureRunningOnMainThread();
        q qVar = this.platformViewsController;
        if (qVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to destroy an overlay surface");
        }
        qVar.c();
    }

    public void detachFromNativeAndReleaseResources() {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        this.shellHolderLock.writeLock().lock();
        try {
            nativeDestroy(this.nativeShellHolderId.longValue());
            this.nativeShellHolderId = null;
        } finally {
            this.shellHolderLock.writeLock().unlock();
        }
    }

    public void dispatchEmptyPlatformMessage(String str, int i4) {
        ensureRunningOnMainThread();
        if (isAttached()) {
            nativeDispatchEmptyPlatformMessage(this.nativeShellHolderId.longValue(), str, i4);
            return;
        }
        Log.w(TAG, "Tried to send a platform message to Flutter, but FlutterJNI was detached from native C++. Could not send. Channel: " + str + ". Response ID: " + i4);
    }

    public void dispatchPlatformMessage(String str, ByteBuffer byteBuffer, int i4, int i5) {
        ensureRunningOnMainThread();
        if (isAttached()) {
            nativeDispatchPlatformMessage(this.nativeShellHolderId.longValue(), str, byteBuffer, i4, i5);
            return;
        }
        Log.w(TAG, "Tried to send a platform message to Flutter, but FlutterJNI was detached from native C++. Could not send. Channel: " + str + ". Response ID: " + i5);
    }

    public void dispatchPointerDataPacket(ByteBuffer byteBuffer, int i4) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeDispatchPointerDataPacket(this.nativeShellHolderId.longValue(), byteBuffer, i4);
    }

    public void dispatchSemanticsAction(int i4, h hVar) {
        dispatchSemanticsAction(i4, hVar, null);
    }

    @SuppressLint({"NewApi"})
    public void endFrame2() {
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("");
        }
        SurfaceControl.Transaction transactionG = K.g();
        int i4 = 0;
        while (true) {
            ArrayList arrayList = pVar.f4659s;
            if (i4 >= arrayList.size()) {
                arrayList.clear();
                pVar.f4651d.invalidate();
                pVar.f4651d.getRootSurfaceControl().applyTransactionOnDraw(transactionG);
                return;
            }
            transactionG = transactionG.merge(o.d(arrayList.get(i4)));
            i4++;
        }
    }

    public Bitmap getBitmap() {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        return nativeGetBitmap(this.nativeShellHolderId.longValue());
    }

    public boolean getIsSoftwareRenderingEnabled() {
        return nativeGetIsSoftwareRenderingEnabled();
    }

    /* JADX WARN: Removed duplicated region for block: B:22:0x0067  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public float getScaledFontSize(float r7, int r8) {
        /*
            r6 = this;
            N2.m r0 = r6.settingsChannel
            r1 = 0
            if (r0 != 0) goto L6
            goto L69
        L6:
            y0.k r0 = r0.f1177a
            java.lang.Object r2 = r0.f6832c
            N2.l r2 = (N2.l) r2
            java.lang.Object r3 = r0.f6831b
            java.util.concurrent.ConcurrentLinkedQueue r3 = (java.util.concurrent.ConcurrentLinkedQueue) r3
            if (r2 != 0) goto L1a
            java.lang.Object r2 = r3.poll()
            N2.l r2 = (N2.l) r2
            r0.f6832c = r2
        L1a:
            java.lang.Object r2 = r0.f6832c
            N2.l r2 = (N2.l) r2
            if (r2 == 0) goto L2d
            int r4 = r2.f1175a
            if (r4 >= r8) goto L2d
            java.lang.Object r2 = r3.poll()
            N2.l r2 = (N2.l) r2
            r0.f6832c = r2
            goto L1a
        L2d:
            java.lang.String r3 = "Cannot find config with generation: "
            java.lang.String r4 = "SettingsChannel"
            if (r2 != 0) goto L49
            java.lang.StringBuilder r0 = new java.lang.StringBuilder
            r0.<init>(r3)
            r0.append(r8)
            java.lang.String r2 = ", after exhausting the queue."
            r0.append(r2)
            java.lang.String r0 = r0.toString()
            android.util.Log.e(r4, r0)
        L47:
            r2 = r1
            goto L64
        L49:
            int r5 = r2.f1175a
            if (r5 == r8) goto L64
            java.lang.String r2 = ", the oldest config is now: "
            java.lang.StringBuilder r2 = com.google.crypto.tink.shaded.protobuf.S.i(r3, r8, r2)
            java.lang.Object r0 = r0.f6832c
            N2.l r0 = (N2.l) r0
            int r0 = r0.f1175a
            r2.append(r0)
            java.lang.String r0 = r2.toString()
            android.util.Log.e(r4, r0)
            goto L47
        L64:
            if (r2 != 0) goto L67
            goto L69
        L67:
            android.util.DisplayMetrics r1 = r2.f1176b
        L69:
            if (r1 != 0) goto L8a
            java.lang.StringBuilder r7 = new java.lang.StringBuilder
            java.lang.String r0 = "getScaledFontSize called with configurationId "
            r7.<init>(r0)
            java.lang.String r8 = java.lang.String.valueOf(r8)
            r7.append(r8)
            java.lang.String r8 = ", which can't be found."
            r7.append(r8)
            java.lang.String r7 = r7.toString()
            java.lang.String r8 = "FlutterJNI"
            android.util.Log.e(r8, r7)
            r7 = -1082130432(0xffffffffbf800000, float:-1.0)
            return r7
        L8a:
            r8 = 2
            float r7 = android.util.TypedValue.applyDimension(r8, r7, r1)
            float r8 = r1.density
            float r7 = r7 / r8
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: io.flutter.embedding.engine.FlutterJNI.getScaledFontSize(float, int):float");
    }

    public void handlePlatformMessage(String str, ByteBuffer byteBuffer, int i4, long j4) {
        f fVar;
        boolean z4;
        F2.j jVar = this.platformMessageHandler;
        if (jVar == null) {
            nativeCleanupMessageData(j4);
            return;
        }
        F2.i iVar = (F2.i) jVar;
        synchronized (iVar.f467d) {
            try {
                fVar = (f) iVar.f465b.get(str);
                z4 = iVar.e.get() && fVar == null;
                if (z4) {
                    if (!iVar.f466c.containsKey(str)) {
                        iVar.f466c.put(str, new LinkedList());
                    }
                    ((List) iVar.f466c.get(str)).add(new F2.d(j4, byteBuffer, i4));
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        if (z4) {
            return;
        }
        iVar.a(str, fVar, byteBuffer, i4, j4);
    }

    @SuppressLint({"NewApi"})
    public void hideOverlaySurface2() {
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to destroy an overlay surface");
        }
        if (pVar.f4661u == null) {
            return;
        }
        SurfaceControl.Transaction transactionG = K.g();
        transactionG.setVisibility(pVar.f4661u, false);
        transactionG.apply();
    }

    @SuppressLint({"NewApi"})
    public void hidePlatformView2(int i4) {
        ensureRunningOnMainThread();
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to hide a platform view");
        }
        if (pVar.a(i4)) {
            ((J2.b) pVar.f4656p.get(i4)).setVisibility(8);
        }
    }

    public void init(Context context, String[] strArr, String str, String str2, String str3, long j4, int i4) {
        if (initCalled) {
            Log.w(TAG, "FlutterJNI.init called more than once");
        }
        nativeInit(context, strArr, str, str2, str3, j4, i4);
        initCalled = true;
    }

    public void invokePlatformMessageEmptyResponseCallback(int i4) {
        this.shellHolderLock.readLock().lock();
        try {
            if (isAttached()) {
                nativeInvokePlatformMessageEmptyResponseCallback(this.nativeShellHolderId.longValue(), i4);
            } else {
                Log.w(TAG, "Tried to send a platform message response, but FlutterJNI was detached from native C++. Could not send. Response ID: " + i4);
            }
            this.shellHolderLock.readLock().unlock();
        } catch (Throwable th) {
            this.shellHolderLock.readLock().unlock();
            throw th;
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r1v11 */
    /* JADX WARN: Type inference failed for: r1v6, types: [boolean] */
    /* JADX WARN: Type inference failed for: r1v9, types: [io.flutter.embedding.engine.FlutterJNI] */
    public void invokePlatformMessageResponseCallback(int i4, ByteBuffer byteBuffer, int i5) throws Throwable {
        FlutterJNI flutterJNIIsAttached;
        if (!byteBuffer.isDirect()) {
            throw new IllegalArgumentException("Expected a direct ByteBuffer.");
        }
        this.shellHolderLock.readLock().lock();
        try {
            flutterJNIIsAttached = isAttached();
            try {
                if (flutterJNIIsAttached != 0) {
                    FlutterJNI flutterJNI = this;
                    flutterJNI.nativeInvokePlatformMessageResponseCallback(this.nativeShellHolderId.longValue(), i4, byteBuffer, i5);
                    flutterJNIIsAttached = flutterJNI;
                } else {
                    flutterJNIIsAttached = this;
                    Log.w(TAG, "Tried to send a platform message response, but FlutterJNI was detached from native C++. Could not send. Response ID: " + i4);
                }
                flutterJNIIsAttached.shellHolderLock.readLock().unlock();
            } catch (Throwable th) {
                th = th;
                Throwable th2 = th;
                flutterJNIIsAttached.shellHolderLock.readLock().unlock();
                throw th2;
            }
        } catch (Throwable th3) {
            th = th3;
            flutterJNIIsAttached = this;
        }
    }

    public boolean isAttached() {
        return this.nativeShellHolderId != null;
    }

    public boolean isCodePointEmoji(int i4) {
        return nativeFlutterTextUtilsIsEmoji(i4);
    }

    public boolean isCodePointEmojiModifier(int i4) {
        return nativeFlutterTextUtilsIsEmojiModifier(i4);
    }

    public boolean isCodePointEmojiModifierBase(int i4) {
        return nativeFlutterTextUtilsIsEmojiModifierBase(i4);
    }

    public boolean isCodePointRegionalIndicator(int i4) {
        return nativeFlutterTextUtilsIsRegionalIndicator(i4);
    }

    public boolean isCodePointVariantSelector(int i4) {
        return nativeFlutterTextUtilsIsVariationSelector(i4);
    }

    public void loadDartDeferredLibrary(int i4, String[] strArr) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeLoadDartDeferredLibrary(this.nativeShellHolderId.longValue(), i4, strArr);
    }

    public void loadLibrary(Context context) throws Throwable {
        r rVar;
        r rVarC;
        String[] strArrH;
        ZipFile zipFile;
        InputStream inputStream;
        InputStream inputStream2;
        FileOutputStream fileOutputStream;
        FileOutputStream fileOutputStream2;
        if (loadLibraryCalled) {
            Log.w(TAG, "FlutterJNI.loadLibrary called more than once");
        }
        C0003c c0003c = new C0003c(2);
        C0053n c0053n = new C0053n(14);
        c0053n.e = c0003c;
        if (context == null) {
            throw new IllegalArgumentException("Given context is null");
        }
        c0053n.n("Beginning load of %s...", "flutter");
        C0592H c0592h = (C0592H) c0053n.f707c;
        HashSet hashSet = (HashSet) c0053n.f706b;
        if (hashSet.contains("flutter")) {
            c0053n.n("%s already loaded previously!", "flutter");
        } else {
            try {
                c0592h.getClass();
                System.loadLibrary("flutter");
                hashSet.add("flutter");
                c0053n.n("%s (%s) was loaded normally!", "flutter", null);
            } catch (UnsatisfiedLinkError e) {
                c0053n.n("Loading the library normally failed: %s", Log.getStackTraceString(e));
                c0053n.n("%s (%s) was not loaded normally, re-linking...", "flutter", null);
                File fileM = c0053n.m(context);
                if (!fileM.exists()) {
                    File dir = context.getDir("lib", 0);
                    File fileM2 = c0053n.m(context);
                    c0592h.getClass();
                    File[] fileArrListFiles = dir.listFiles(new C0616a(System.mapLibraryName("flutter")));
                    if (fileArrListFiles != null) {
                        for (File file : fileArrListFiles) {
                            if (!file.getAbsolutePath().equals(fileM2.getAbsolutePath())) {
                                file.delete();
                            }
                        }
                    }
                    String[] strArr = Build.SUPPORTED_ABIS;
                    if (strArr.length <= 0) {
                        String str = Build.CPU_ABI2;
                        strArr = (str == null || str.length() == 0) ? new String[]{Build.CPU_ABI} : new String[]{Build.CPU_ABI, str};
                    }
                    String strMapLibraryName = System.mapLibraryName("flutter");
                    ((C0592H) c0053n.f708d).getClass();
                    try {
                        rVarC = C0592H.c(context, strArr, strMapLibraryName, c0053n);
                    } catch (Throwable th) {
                        th = th;
                        rVar = null;
                    }
                    try {
                        if (rVarC == null) {
                            try {
                                strArrH = C0592H.h(context, strMapLibraryName);
                            } catch (Exception e4) {
                                strArrH = new String[]{e4.toString()};
                            }
                            StringBuilder sb = new StringBuilder("Could not find '");
                            sb.append(strMapLibraryName);
                            sb.append("'. Looked for: ");
                            sb.append(Arrays.toString(strArr));
                            sb.append(", but only found: ");
                            throw new A0.b(S.h(sb, Arrays.toString(strArrH), "."));
                        }
                        int i4 = 0;
                        while (true) {
                            int i5 = i4 + 1;
                            zipFile = (ZipFile) rVarC.f3597b;
                            if (i4 < 5) {
                                c0053n.n("Found %s! Extracting...", strMapLibraryName);
                                try {
                                    if (fileM.exists() || fileM.createNewFile()) {
                                        try {
                                            inputStream2 = zipFile.getInputStream((ZipEntry) rVarC.f3598c);
                                        } catch (FileNotFoundException unused) {
                                            inputStream2 = null;
                                        } catch (IOException unused2) {
                                            inputStream2 = null;
                                        } catch (Throwable th2) {
                                            th = th2;
                                            inputStream = null;
                                        }
                                        try {
                                            fileOutputStream2 = new FileOutputStream(fileM);
                                            try {
                                                byte[] bArr = new byte[4096];
                                                long j4 = 0;
                                                while (true) {
                                                    int i6 = inputStream2.read(bArr);
                                                    if (i6 == -1) {
                                                        break;
                                                    }
                                                    fileOutputStream2.write(bArr, 0, i6);
                                                    j4 += (long) i6;
                                                }
                                                fileOutputStream2.flush();
                                                fileOutputStream2.getFD().sync();
                                                if (j4 == fileM.length()) {
                                                    C0592H.b(inputStream2);
                                                    C0592H.b(fileOutputStream2);
                                                    fileM.setReadable(true, false);
                                                    fileM.setExecutable(true, false);
                                                    fileM.setWritable(true);
                                                    break;
                                                }
                                                C0592H.b(inputStream2);
                                                C0592H.b(fileOutputStream2);
                                            } catch (FileNotFoundException unused3) {
                                                C0592H.b(inputStream2);
                                                C0592H.b(fileOutputStream2);
                                                i4 = i5;
                                            } catch (IOException unused4) {
                                                C0592H.b(inputStream2);
                                                C0592H.b(fileOutputStream2);
                                                i4 = i5;
                                            } catch (Throwable th3) {
                                                th = th3;
                                                inputStream = inputStream2;
                                                fileOutputStream = fileOutputStream2;
                                                C0592H.b(inputStream);
                                                C0592H.b(fileOutputStream);
                                                throw th;
                                            }
                                        } catch (FileNotFoundException unused5) {
                                            fileOutputStream2 = null;
                                            C0592H.b(inputStream2);
                                            C0592H.b(fileOutputStream2);
                                            i4 = i5;
                                        } catch (IOException unused6) {
                                            fileOutputStream2 = null;
                                            C0592H.b(inputStream2);
                                            C0592H.b(fileOutputStream2);
                                            i4 = i5;
                                        } catch (Throwable th4) {
                                            th = th4;
                                            inputStream = inputStream2;
                                            fileOutputStream = null;
                                            C0592H.b(inputStream);
                                            C0592H.b(fileOutputStream);
                                            throw th;
                                        }
                                    }
                                } catch (IOException unused7) {
                                }
                                i4 = i5;
                            } else if (((C0003c) c0053n.e) != null) {
                                lambda$loadLibrary$0("FATAL! Couldn't extract the library from the APK!");
                            }
                        }
                        try {
                            zipFile.close();
                        } catch (IOException unused8) {
                        }
                    } catch (Throwable th5) {
                        th = th5;
                        rVar = rVarC;
                        if (rVar != null) {
                            try {
                                ((ZipFile) rVar.f3597b).close();
                            } catch (IOException unused9) {
                            }
                        }
                        throw th;
                    }
                }
                String absolutePath = fileM.getAbsolutePath();
                c0592h.getClass();
                System.load(absolutePath);
                hashSet.add("flutter");
                c0053n.n("%s (%s) was re-linked!", "flutter", null);
            }
        }
        loadLibraryCalled = true;
    }

    public void markTextureFrameAvailable(long j4) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeMarkTextureFrameAvailable(this.nativeShellHolderId.longValue(), j4);
    }

    public void maybeResizeSurfaceView(int i4, int i5) {
        boolean z4;
        Iterator<l> it = this.flutterUiResizeListeners.iterator();
        while (it.hasNext()) {
            D2.r rVar = ((D2.p) it.next()).f225a;
            View view = rVar.f242f;
            if (view != null) {
                ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
                boolean z5 = true;
                if (view.getHeight() != i5) {
                    layoutParams.height = i5;
                    z4 = true;
                } else {
                    z4 = false;
                }
                if (view.getWidth() != i4) {
                    layoutParams.width = i4;
                } else {
                    z5 = z4;
                }
                if (z5) {
                    rVar.f238a.set(false);
                    view.setLayoutParams(layoutParams);
                }
            } else {
                Log.e("FlutterView", "Flutter engine view not set.");
            }
        }
    }

    public void notifyLowMemoryWarning() {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeNotifyLowMemoryWarning(this.nativeShellHolderId.longValue());
    }

    public void onBeginFrame() {
        ensureRunningOnMainThread();
        q qVar = this.platformViewsController;
        if (qVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to begin the frame");
        }
        qVar.f4682y.clear();
        qVar.f4683z.clear();
    }

    public void onDisplayOverlaySurface(int i4, int i5, int i6, int i7, int i8) {
        ensureRunningOnMainThread();
        q qVar = this.platformViewsController;
        if (qVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to position an overlay surface");
        }
        SparseArray sparseArray = qVar.f4678t;
        if (sparseArray.get(i4) == null) {
            throw new IllegalStateException(B1.a.l("The overlay surface (id:", i4, ") doesn't exist"));
        }
        qVar.i();
        View view = (C0428d) sparseArray.get(i4);
        if (view.getParent() == null) {
            qVar.f4669d.addView(view);
        }
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(i7, i8);
        layoutParams.leftMargin = i5;
        layoutParams.topMargin = i6;
        view.setLayoutParams(layoutParams);
        view.setVisibility(0);
        view.bringToFront();
        qVar.f4682y.add(Integer.valueOf(i4));
    }

    public void onDisplayPlatformView(int i4, int i5, int i6, int i7, int i8, int i9, int i10, FlutterMutatorsStack flutterMutatorsStack) {
        ensureRunningOnMainThread();
        q qVar = this.platformViewsController;
        if (qVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to position a platform view");
        }
        qVar.i();
        SparseArray sparseArray = qVar.f4676r;
        io.flutter.plugin.platform.g gVar = (io.flutter.plugin.platform.g) sparseArray.get(i4);
        if (gVar == null) {
            return;
        }
        SparseArray sparseArray2 = qVar.f4677s;
        if (sparseArray2.get(i4) == null) {
            FrameLayout frameLayout = ((y2.k) gVar).f6916c;
            if (frameLayout == null) {
                throw new IllegalStateException("PlatformView#getView() returned null, but an Android view reference was expected.");
            }
            if (frameLayout.getParent() != null) {
                throw new IllegalStateException("The Android view returned from PlatformView#getView() was already added to a parent view.");
            }
            Activity activity = qVar.f4668c;
            J2.b bVar = new J2.b(activity, activity.getResources().getDisplayMetrics().density, qVar.f4667b);
            bVar.setOnDescendantFocusChangeListener(new io.flutter.plugin.platform.k(qVar, i4, 0));
            sparseArray2.put(i4, bVar);
            frameLayout.setImportantForAccessibility(4);
            bVar.addView(frameLayout);
            qVar.f4669d.addView(bVar);
        }
        J2.b bVar2 = (J2.b) sparseArray2.get(i4);
        bVar2.f807a = flutterMutatorsStack;
        bVar2.f809c = i5;
        bVar2.f810d = i6;
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(i7, i8);
        layoutParams.leftMargin = i5;
        layoutParams.topMargin = i6;
        bVar2.setLayoutParams(layoutParams);
        bVar2.setWillNotDraw(false);
        bVar2.setVisibility(0);
        bVar2.bringToFront();
        FrameLayout.LayoutParams layoutParams2 = new FrameLayout.LayoutParams(i9, i10);
        FrameLayout frameLayout2 = ((y2.k) ((io.flutter.plugin.platform.g) sparseArray.get(i4))).f6916c;
        if (frameLayout2 != null) {
            frameLayout2.setLayoutParams(layoutParams2);
            frameLayout2.bringToFront();
        }
        qVar.f4683z.add(Integer.valueOf(i4));
    }

    @SuppressLint({"NewApi"})
    public void onDisplayPlatformView2(int i4, int i5, int i6, int i7, int i8, int i9, int i10, FlutterMutatorsStack flutterMutatorsStack) {
        ensureRunningOnMainThread();
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to position a platform view");
        }
        if (pVar.a(i4)) {
            J2.b bVar = (J2.b) pVar.f4656p.get(i4);
            bVar.f807a = flutterMutatorsStack;
            bVar.f809c = i5;
            bVar.f810d = i6;
            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(i7, i8);
            layoutParams.leftMargin = i5;
            layoutParams.topMargin = i6;
            bVar.setLayoutParams(layoutParams);
            bVar.setWillNotDraw(false);
            bVar.setVisibility(0);
            bVar.bringToFront();
            FrameLayout.LayoutParams layoutParams2 = new FrameLayout.LayoutParams(i9, i10);
            FrameLayout frameLayout = ((y2.k) ((io.flutter.plugin.platform.g) pVar.f4655o.get(i4))).f6916c;
            if (frameLayout != null) {
                frameLayout.setLayoutParams(layoutParams2);
                frameLayout.bringToFront();
            }
        }
    }

    /* JADX WARN: Type inference failed for: r3v1, types: [android.view.View, io.flutter.embedding.engine.renderer.m] */
    public void onEndFrame() {
        ?? r32;
        ensureRunningOnMainThread();
        q qVar = this.platformViewsController;
        if (qVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to end the frame");
        }
        boolean z4 = false;
        if (!qVar.f4680w || !qVar.f4683z.isEmpty()) {
            if (qVar.f4680w) {
                C0033h c0033h = qVar.f4669d.e;
                if (c0033h != null ? c0033h.e() : false) {
                    z4 = true;
                }
            }
            qVar.g(z4);
            return;
        }
        qVar.f4680w = false;
        D2.r rVar = qVar.f4669d;
        F1.a aVar = new F1.a(qVar, 16);
        C0033h c0033h2 = rVar.e;
        if (c0033h2 == null || (r32 = rVar.f243m) == 0) {
            return;
        }
        rVar.f242f = r32;
        rVar.f243m = null;
        io.flutter.embedding.engine.renderer.j jVar = rVar.f246p.f342b;
        if (jVar != null) {
            r32.a();
            jVar.a(new D2.q(rVar, jVar, aVar));
            return;
        }
        c0033h2.d();
        C0033h c0033h3 = rVar.e;
        if (c0033h3 != null) {
            c0033h3.f204a.close();
            rVar.removeView(rVar.e);
            rVar.e = null;
        }
        aVar.run();
    }

    public void onFirstFrame() {
        ensureRunningOnMainThread();
        Iterator<io.flutter.embedding.engine.renderer.k> it = this.flutterUiDisplayListeners.iterator();
        while (it.hasNext()) {
            it.next().b();
        }
    }

    public void onRenderingStopped() {
        ensureRunningOnMainThread();
        Iterator<io.flutter.embedding.engine.renderer.k> it = this.flutterUiDisplayListeners.iterator();
        while (it.hasNext()) {
            it.next().a();
        }
    }

    public void onSurfaceChanged(int i4, int i5) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeSurfaceChanged(this.nativeShellHolderId.longValue(), i4, i5);
    }

    public void onSurfaceCreated(Surface surface) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeSurfaceCreated(this.nativeShellHolderId.longValue(), surface);
    }

    public void onSurfaceDestroyed() {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        onRenderingStopped();
        nativeSurfaceDestroyed(this.nativeShellHolderId.longValue());
    }

    public void onSurfaceWindowChanged(Surface surface) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeSurfaceWindowChanged(this.nativeShellHolderId.longValue(), surface);
    }

    public void onVsync(long j4, long j5, long j6) {
        nativeOnVsync(j4, j5, j6);
    }

    public long performNativeAttach(FlutterJNI flutterJNI) {
        return nativeAttach(flutterJNI);
    }

    public void prefetchDefaultFontManager() {
        if (prefetchDefaultFontManagerCalled) {
            Log.w(TAG, "FlutterJNI.prefetchDefaultFontManager called more than once");
        }
        nativePrefetchDefaultFontManager();
        prefetchDefaultFontManagerCalled = true;
    }

    public void registerImageTexture(long j4, TextureRegistry$ImageConsumer textureRegistry$ImageConsumer, boolean z4) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeRegisterImageTexture(this.nativeShellHolderId.longValue(), j4, new WeakReference<>(textureRegistry$ImageConsumer), z4);
    }

    public void registerTexture(long j4, SurfaceTextureWrapper surfaceTextureWrapper) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeRegisterTexture(this.nativeShellHolderId.longValue(), j4, new WeakReference<>(surfaceTextureWrapper));
    }

    public void removeEngineLifecycleListener(b bVar) {
        ensureRunningOnMainThread();
        this.engineLifecycleListeners.remove(bVar);
    }

    public void removeIsDisplayingFlutterUiListener(io.flutter.embedding.engine.renderer.k kVar) {
        ensureRunningOnMainThread();
        this.flutterUiDisplayListeners.remove(kVar);
    }

    public void removeResizingFlutterUiListener(l lVar) {
        ensureRunningOnMainThread();
        this.flutterUiResizeListeners.remove(lVar);
    }

    public void requestDartDeferredLibrary(int i4) {
        Log.e(TAG, "No DeferredComponentManager found. Android setup must be completed before using split AOT deferred components.");
    }

    public void runBundleAndSnapshotFromLibrary(String str, String str2, String str3, AssetManager assetManager, List<String> list, long j4) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeRunBundleAndSnapshotFromLibrary(this.nativeShellHolderId.longValue(), str, str2, str3, assetManager, list, j4);
    }

    public void scheduleFrame() {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeScheduleFrame(this.nativeShellHolderId.longValue());
    }

    public void setAccessibilityDelegate(j jVar) {
        ensureRunningOnMainThread();
        this.accessibilityDelegate = jVar;
    }

    public void setAccessibilityFeatures(int i4) {
        ensureRunningOnMainThread();
        if (isAttached()) {
            setAccessibilityFeaturesInNative(i4);
        }
    }

    public void setAccessibilityFeaturesInNative(int i4) {
        nativeSetAccessibilityFeatures(this.nativeShellHolderId.longValue(), i4);
    }

    public void setAsyncWaitForVsyncDelegate(k kVar) {
        asyncWaitForVsyncDelegate = kVar;
    }

    public void setDeferredComponentManager(a aVar) {
        ensureRunningOnMainThread();
        if (aVar != null) {
            aVar.a();
        }
    }

    public void setLocalizationPlugin(P2.a aVar) {
        ensureRunningOnMainThread();
        this.localizationPlugin = aVar;
    }

    public void setPlatformMessageHandler(F2.j jVar) {
        ensureRunningOnMainThread();
        this.platformMessageHandler = jVar;
    }

    public void setPlatformViewsController(q qVar) {
        ensureRunningOnMainThread();
        this.platformViewsController = qVar;
    }

    public void setPlatformViewsController2(p pVar) {
        ensureRunningOnMainThread();
        this.platformViewsController2 = pVar;
    }

    public void setRefreshRateFPS(float f4) {
        refreshRateFPS = f4;
        updateRefreshRate();
    }

    public void setSemanticsEnabled(boolean z4) {
        ensureRunningOnMainThread();
        if (isAttached()) {
            setSemanticsEnabledInNative(z4);
        }
    }

    public void setSemanticsEnabledInNative(boolean z4) {
        nativeSetSemanticsEnabled(this.nativeShellHolderId.longValue(), z4);
    }

    public void setSemanticsTreeEnabled(boolean z4) {
        ensureRunningOnMainThread();
        j jVar = this.accessibilityDelegate;
        if (jVar == null || z4) {
            return;
        }
        io.flutter.view.k kVar = (io.flutter.view.k) ((e) jVar).f4703a;
        kVar.f4793g.clear();
        io.flutter.view.j jVar2 = kVar.f4795i;
        if (jVar2 != null) {
            kVar.h(jVar2.f4762b, 65536);
        }
        kVar.f4795i = null;
        kVar.f4802p = null;
        AccessibilityEvent accessibilityEventE = kVar.e(0, 2048);
        accessibilityEventE.setContentChangeTypes(1);
        kVar.i(accessibilityEventE);
    }

    public void setSettingsChannel(m mVar) {
        ensureRunningOnMainThread();
        this.settingsChannel = mVar;
    }

    public void setViewportMetrics(float f4, int i4, int i5, int i6, int i7, int i8, int i9, int i10, int i11, int i12, int i13, int i14, int i15, int i16, int i17, int i18, int[] iArr, int[] iArr2, int[] iArr3, int i19, int i20, int i21, int i22) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeSetViewportMetrics(this.nativeShellHolderId.longValue(), f4, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, iArr, iArr2, iArr3, i19, i20, i21, i22);
    }

    @SuppressLint({"NewApi"})
    public void showOverlaySurface2() {
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("platformViewsController must be set before attempting to destroy an overlay surface");
        }
        if (pVar.f4661u == null) {
            return;
        }
        SurfaceControl.Transaction transactionG = K.g();
        transactionG.setVisibility(pVar.f4661u, true);
        transactionG.apply();
    }

    public FlutterJNI spawn(String str, String str2, String str3, List<String> list, long j4) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        FlutterJNI flutterJNINativeSpawn = nativeSpawn(this.nativeShellHolderId.longValue(), str, str2, str3, list, j4);
        Long l2 = flutterJNINativeSpawn.nativeShellHolderId;
        if ((l2 == null || l2.longValue() == 0) ? false : true) {
            return flutterJNINativeSpawn;
        }
        throw new IllegalStateException("Failed to spawn new JNI connected shell from existing shell.");
    }

    @SuppressLint({"NewApi"})
    public void swapTransactions() {
        p pVar = this.platformViewsController2;
        if (pVar == null) {
            throw new RuntimeException("");
        }
        synchronized (pVar) {
            try {
                pVar.f4659s.clear();
                for (int i4 = 0; i4 < pVar.f4658r.size(); i4++) {
                    pVar.f4659s.add(o.d(pVar.f4658r.get(i4)));
                }
                pVar.f4658r.clear();
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public void unregisterTexture(long j4) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeUnregisterTexture(this.nativeShellHolderId.longValue(), j4);
    }

    public void updateDisplayMetrics(int i4, float f4, float f5, float f6) {
        displayWidth = f4;
        displayHeight = f5;
        displayDensity = f6;
        if (loadLibraryCalled) {
            nativeUpdateDisplayMetrics(this.nativeShellHolderId.longValue());
        }
    }

    public void updateJavaAssetManager(AssetManager assetManager, String str) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeUpdateJavaAssetManager(this.nativeShellHolderId.longValue(), assetManager, str);
    }

    public void updateRefreshRate() {
        if (loadLibraryCalled) {
            nativeUpdateRefreshRate(refreshRateFPS);
        }
    }

    public void dispatchSemanticsAction(int i4, h hVar, Object obj) {
        ByteBuffer byteBufferB;
        int iPosition;
        ensureAttachedToNative();
        if (obj != null) {
            byteBufferB = O2.q.f1455a.b(obj);
            iPosition = byteBufferB.position();
        } else {
            byteBufferB = null;
            iPosition = 0;
        }
        dispatchSemanticsAction(i4, hVar.f4730a, byteBufferB, iPosition);
    }

    public void dispatchSemanticsAction(int i4, int i5, ByteBuffer byteBuffer, int i6) {
        ensureRunningOnMainThread();
        ensureAttachedToNative();
        nativeDispatchSemanticsAction(this.nativeShellHolderId.longValue(), i4, i5, byteBuffer, i6);
    }
}
