package O;

import A.C0003c;
import I.C0053n;
import Q3.C0141m;
import T2.C0157b;
import T2.C0161f;
import android.content.Context;
import android.graphics.Typeface;
import android.hardware.camera2.CameraCharacteristics;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.Process;
import android.os.StrictMode;
import android.view.ViewGroup;
import androidx.profileinstaller.ProfileInstallerInitializer;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import d3.C0359a;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.atomic.AtomicReference;
import k.C0502t;
import m1.C0553h;
import m1.ThreadFactoryC0546a;
import o.AbstractFutureC0576h;
import q1.InterfaceC0634a;
import y0.C0747k;

/* JADX INFO: renamed from: O.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class RunnableC0093d implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1337a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1338b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f1339c;

    public /* synthetic */ RunnableC0093d(int i4, Object obj, Object obj2) {
        this.f1337a = i4;
        this.f1338b = obj;
        this.f1339c = obj2;
    }

    @Override // java.lang.Runnable
    public final void run() throws IOException {
        C0003c c0003c;
        switch (this.f1337a) {
            case 0:
                ViewGroup viewGroup = (ViewGroup) this.f1338b;
                J3.i.e(viewGroup, "$container");
                C0095f c0095f = (C0095f) this.f1339c;
                J3.i.e(c0095f, "this$0");
                viewGroup.endViewTransition(null);
                C0096g c0096g = c0095f.f1342b;
                throw null;
            case 1:
                ((C0141m) this.f1338b).B((R3.d) this.f1339c);
                return;
            case 2:
                ((T2.t) this.f1338b).d(Double.valueOf(((X2.a) this.f1339c).f2413b));
                return;
            case 3:
                C0161f c0161f = ((C0157b) this.f1338b).f1931b;
                final C0747k c0747k = c0161f.f1946h;
                C0359a c0359a = (C0359a) this.f1339c;
                final Integer numValueOf = Integer.valueOf(c0359a.f3955c.getWidth());
                final Integer numValueOf2 = Integer.valueOf(c0359a.f3955c.getHeight());
                final int i4 = ((W2.a) c0161f.f1940a.f378a.get("EXPOSURE_LOCK")).f2272b;
                final int i5 = ((V2.a) c0161f.f1940a.f378a.get("AUTO_FOCUS")).f2209b;
                Integer num = (Integer) ((CameraCharacteristics) c0161f.f1940a.b().f2100a.f260b).get(CameraCharacteristics.CONTROL_MAX_REGIONS_AE);
                boolean z4 = false;
                final Boolean boolValueOf = Boolean.valueOf(num != null && num.intValue() > 0);
                Integer num2 = (Integer) ((CameraCharacteristics) c0161f.f1940a.c().f2100a.f260b).get(CameraCharacteristics.CONTROL_MAX_REGIONS_AF);
                if (num2 != null && num2.intValue() > 0) {
                    z4 = true;
                }
                final Boolean boolValueOf2 = Boolean.valueOf(z4);
                ((Handler) c0747k.f6831b).post(new Runnable() { // from class: T2.o
                    @Override // java.lang.Runnable
                    public final void run() {
                        C0747k c0747k2 = c0747k;
                        Double dValueOf = Double.valueOf(numValueOf.doubleValue());
                        Double dValueOf2 = Double.valueOf(numValueOf2.doubleValue());
                        I i6 = new I();
                        i6.f1902a = dValueOf;
                        i6.f1903b = dValueOf2;
                        int iB = K.j.b(i4);
                        B b5 = B.AUTO;
                        if (iB != 0 && iB == 1) {
                            b5 = B.LOCKED;
                        }
                        int iB2 = K.j.b(i5);
                        D d5 = D.AUTO;
                        if (iB2 != 0 && iB2 == 1) {
                            d5 = D.LOCKED;
                        }
                        z zVar = new z();
                        zVar.f2012a = i6;
                        zVar.f2013b = b5;
                        zVar.f2014c = d5;
                        zVar.f2015d = boolValueOf;
                        zVar.e = boolValueOf2;
                        p1.d dVar = new p1.d(17);
                        StringBuilder sb = new StringBuilder("dev.flutter.pigeon.camera_android.CameraEventApi.initialized");
                        D2.v vVar = (D2.v) c0747k2.f6833d;
                        sb.append((String) vVar.f261c);
                        String string = sb.toString();
                        new C0053n((O2.f) vVar.f260b, string, w.f2004d, null, 5).x(new ArrayList(Collections.singletonList(zVar)), new u(dVar, string, 2));
                    }
                });
                return;
            case 4:
                ((T2.t) this.f1338b).d((String) this.f1339c);
                return;
            case 5:
                p1.d dVar = new p1.d(17);
                StringBuilder sb = new StringBuilder("dev.flutter.pigeon.camera_android.CameraEventApi.error");
                D2.v vVar = (D2.v) ((C0747k) this.f1338b).f6833d;
                sb.append((String) vVar.f261c);
                String string = sb.toString();
                new C0053n((O2.f) vVar.f260b, string, T2.w.f2004d, null, 5).x(new ArrayList(Collections.singletonList((String) this.f1339c)), new T2.u(dVar, string, 0));
                return;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                ((ProfileInstallerInitializer) this.f1338b).getClass();
                (Build.VERSION.SDK_INT >= 28 ? V.j.a(Looper.getMainLooper()) : new Handler(Looper.getMainLooper())).postDelayed(new V.g((Context) this.f1339c, 0), new Random().nextInt(Math.max(1000, 1)) + 5000);
                return;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                String str = "Caught IllegalStateException: " + ((IllegalStateException) this.f1339c).getMessage();
                O2.g gVar = (O2.g) this.f1338b;
                if (gVar.f1449a.get()) {
                    return;
                }
                C0747k c0747k2 = gVar.f1450b;
                if (((AtomicReference) c0747k2.f6832c).get() != gVar) {
                    return;
                }
                C0747k c0747k3 = (C0747k) c0747k2.f6833d;
                ((O2.f) c0747k3.f6831b).i((String) c0747k3.f6832c, ((O2.r) c0747k3.f6833d).f(null, "IllegalStateException", str));
                return;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                l1.p pVar = (l1.p) this.f1338b;
                InterfaceC0634a interfaceC0634a = (InterfaceC0634a) this.f1339c;
                if (pVar.f5623b != l1.p.f5621d) {
                    throw new IllegalStateException("provide() can be called only once.");
                }
                synchronized (pVar) {
                    c0003c = pVar.f5622a;
                    pVar.f5622a = null;
                    pVar.f5623b = interfaceC0634a;
                    break;
                }
                c0003c.getClass();
                return;
            case 9:
                l1.o oVar = (l1.o) this.f1338b;
                InterfaceC0634a interfaceC0634a2 = (InterfaceC0634a) this.f1339c;
                synchronized (oVar) {
                    try {
                        if (oVar.f5619b == null) {
                            oVar.f5618a.add(interfaceC0634a2);
                        } else {
                            oVar.f5619b.add(interfaceC0634a2.get());
                        }
                    } catch (Throwable th) {
                        throw th;
                    }
                }
                return;
            case 10:
                ThreadFactoryC0546a threadFactoryC0546a = (ThreadFactoryC0546a) this.f1338b;
                Process.setThreadPriority(threadFactoryC0546a.f5765c);
                StrictMode.ThreadPolicy threadPolicy = threadFactoryC0546a.f5766d;
                if (threadPolicy != null) {
                    StrictMode.setThreadPolicy(threadPolicy);
                }
                ((Runnable) this.f1339c).run();
                return;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                Callable callable = (Callable) this.f1338b;
                C0553h c0553h = (C0553h) this.f1339c;
                try {
                    Object objCall = callable.call();
                    m1.j jVar = (m1.j) c0553h.f5788a;
                    jVar.getClass();
                    if (objCall == null) {
                        objCall = AbstractFutureC0576h.f5953m;
                    }
                    if (AbstractFutureC0576h.f5952f.e(jVar, null, objCall)) {
                        AbstractFutureC0576h.c(jVar);
                        return;
                    }
                    return;
                } catch (Exception e) {
                    c0553h.b(e);
                    return;
                }
            case 12:
                ((C0502t) this.f1338b).d((Typeface) this.f1339c);
                return;
            case 13:
                ((N2.j) ((N2.j) this.f1338b).f1167b).c(this.f1339c);
                return;
            case 14:
                S1.a aVar = (S1.a) this.f1338b;
                y2.g gVar2 = (y2.g) this.f1339c;
                if (aVar.f1803j && gVar2.f6907z) {
                    gVar2.f6885b.post(new y2.b(gVar2, 4));
                    return;
                }
                return;
            case 15:
                O2.g gVar3 = (O2.g) ((Y0.n) this.f1338b).f2491d;
                if (gVar3 != null) {
                    y2.l lVar = (y2.l) this.f1339c;
                    gVar3.a(x3.s.d0(new w3.c("bitrate", Long.valueOf(lVar.f6921a)), new w3.c("fps", Integer.valueOf(lVar.f6922b)), new w3.c("droppedFrames", Integer.valueOf(lVar.f6923c)), new w3.c("isConnected", Boolean.valueOf(lVar.f6924d)), new w3.c("elapsedSeconds", Long.valueOf(lVar.e))));
                    return;
                }
                return;
            default:
                ((z2.b) this.f1338b).f6993b.a((ArrayList) this.f1339c);
                return;
        }
    }
}
