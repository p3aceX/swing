package B;

import D2.v;
import I.C0053n;
import I.C0059u;
import I.InterfaceC0048i;
import O.AbstractComponentCallbacksC0109u;
import O.C0113y;
import O.J;
import O.RunnableC0093d;
import O2.g;
import O2.s;
import Q3.x0;
import T2.C0161f;
import X.L;
import X.N;
import X.t;
import X.u;
import android.app.Activity;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaCodec;
import android.media.MediaFormat;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;
import android.util.SparseIntArray;
import android.view.View;
import android.view.ViewGroup;
import b2.C0246b;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.InterfaceC0282e;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.Task;
import d.C0321a;
import d2.C0354b;
import d2.C0358f;
import e2.Q;
import java.lang.ref.WeakReference;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Proxy;
import java.nio.ByteBuffer;
import java.security.Provider;
import java.security.Security;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicReference;
import k.InterfaceC0495l;
import n2.EnumC0559b;
import o2.C0583c;
import r2.x;
import x2.AbstractC0720a;
import y0.C0747k;
import y1.AbstractC0752b;
import y3.InterfaceC0762c;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class k implements O2.d, T3.d, InterfaceC0048i, O2.m, d.b, Q1.a, O2.h, L, InterfaceC0282e, e1.i, io.flutter.plugin.editing.a, InterfaceC0495l, Continuation {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f103a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f104b;

    public /* synthetic */ k(int i4, boolean z4) {
        this.f103a = i4;
    }

    public static int t(int i4, int i5) {
        int i6 = 0;
        int i7 = 0;
        for (int i8 = 0; i8 < i4; i8++) {
            i6++;
            if (i6 == i5) {
                i7++;
                i6 = 0;
            } else if (i6 > i5) {
                i7++;
                i6 = 1;
            }
        }
        return i6 + 1 > i5 ? i7 + 1 : i7;
    }

    @Override // O2.h
    public void a(final O2.g gVar) {
        switch (this.f103a) {
            case 16:
                C0161f c0161f = (C0161f) this.f104b;
                final S2.a aVar = c0161f.f1956r;
                if (aVar != null) {
                    Handler handler = c0161f.f1951m;
                    final C0747k c0747k = c0161f.f1962y;
                    ((ImageReader) aVar.f1811b).setOnImageAvailableListener(new ImageReader.OnImageAvailableListener() { // from class: g3.a
                        @Override // android.media.ImageReader.OnImageAvailableListener
                        public final void onImageAvailable(ImageReader imageReader) {
                            S2.a aVar2 = aVar;
                            aVar2.getClass();
                            Image imageAcquireNextImage = imageReader.acquireNextImage();
                            if (imageAcquireNextImage == null) {
                                return;
                            }
                            HashMap map = new HashMap();
                            map.put("width", Integer.valueOf(imageAcquireNextImage.getWidth()));
                            map.put("height", Integer.valueOf(imageAcquireNextImage.getHeight()));
                            g gVar2 = gVar;
                            int i4 = aVar2.f1810a;
                            try {
                                try {
                                    if (i4 == 17) {
                                        map.put("planes", aVar2.b(imageAcquireNextImage));
                                    } else {
                                        map.put("planes", S2.a.c(imageAcquireNextImage));
                                    }
                                } catch (IllegalStateException e) {
                                    new Handler(Looper.getMainLooper()).post(new RunnableC0093d(7, gVar2, e));
                                }
                                imageAcquireNextImage.close();
                                map.put("format", Integer.valueOf(i4));
                                C0747k c0747k2 = c0747k;
                                map.put("lensAperture", (Float) c0747k2.f6831b);
                                map.put("sensorExposureTime", (Long) c0747k2.f6832c);
                                map.put("sensorSensitivity", ((Integer) c0747k2.f6833d) == null ? null : Double.valueOf(r8.intValue()));
                                Handler handler2 = new Handler(Looper.getMainLooper());
                                x0 x0Var = new x0(gVar2);
                                x0Var.f1669b = new WeakReference(map);
                                handler2.post(x0Var);
                            } catch (Throwable th) {
                                imageAcquireNextImage.close();
                                throw th;
                            }
                        }
                    }, handler);
                    break;
                }
                break;
            default:
                ((Y0.n) this.f104b).f2491d = gVar;
                Log.d("StreamingPlugin", "EventChannel onListen — eventSink is now SET (true)");
                break;
        }
    }

    @Override // T3.d
    public Object b(T3.e eVar, InterfaceC0762c interfaceC0762c) throws Throwable {
        Object objB = ((v) this.f104b).b(new C0059u(eVar, 0), interfaceC0762c);
        return objB == EnumC0789a.f6999a ? objB : w3.i.f6729a;
    }

    @Override // O2.d
    public void c(ByteBuffer byteBuffer, F2.g gVar) {
        s.f1460b.getClass();
        s.c(byteBuffer);
        ((F2.b) this.f104b).getClass();
    }

    @Override // e1.i
    public Object e(String str) {
        String[] strArr = {"GmsCore_OpenSSL", "AndroidOpenSSL"};
        ArrayList arrayList = new ArrayList();
        for (int i4 = 0; i4 < 2; i4++) {
            Provider provider = Security.getProvider(strArr[i4]);
            if (provider != null) {
                arrayList.add(provider);
            }
        }
        Iterator it = arrayList.iterator();
        Exception exc = null;
        while (true) {
            boolean zHasNext = it.hasNext();
            N n4 = (N) this.f104b;
            if (!zHasNext) {
                return n4.g(str, null);
            }
            try {
                return n4.g(str, (Provider) it.next());
            } catch (Exception e) {
                if (exc == null) {
                    exc = e;
                }
            }
        }
    }

    @Override // X.L
    public View f(int i4) {
        return ((t) this.f104b).o(i4);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Removed duplicated region for block: B:55:0x00f2  */
    /* JADX WARN: Removed duplicated region for block: B:9:0x0030  */
    @Override // O2.m
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void g(D2.v r32, N2.j r33) {
        /*
            Method dump skipped, instruction units count: 966
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: B.k.g(D2.v, N2.j):void");
    }

    @Override // X.L
    public int h() {
        t tVar = (t) this.f104b;
        return tVar.f2376g - tVar.r();
    }

    @Override // X.L
    public int i() {
        return ((t) this.f104b).u();
    }

    @Override // X.L
    public int j(View view) {
        u uVar = (u) view.getLayoutParams();
        ((t) this.f104b).getClass();
        return view.getBottom() + ((u) view.getLayoutParams()).f2377a.bottom + ((ViewGroup.MarginLayoutParams) uVar).bottomMargin;
    }

    @Override // d.b
    public void k(Object obj) {
        C0321a c0321a = (C0321a) obj;
        O.N n4 = (O.N) this.f104b;
        J j4 = (J) n4.f1227E.pollFirst();
        if (j4 == null) {
            Log.w("FragmentManager", "No IntentSenders were started for " + this);
            return;
        }
        C0053n c0053n = n4.f1239c;
        String str = j4.f1218a;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uI = c0053n.i(str);
        if (abstractComponentCallbacksC0109uI != null) {
            abstractComponentCallbacksC0109uI.u(j4.f1219b, c0321a.f3875a, c0321a.f3876b);
        } else {
            Log.w("FragmentManager", "Intent Sender result delivered for unknown Fragment " + str);
        }
    }

    @Override // Q1.a
    public void l(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo) {
        S1.a aVar = (S1.a) this.f104b;
        U1.c cVar = aVar.f1807n;
        cVar.f2097a++;
        if (SystemClock.elapsedRealtime() - cVar.f2098b >= 1000) {
            D2.u uVar = (D2.u) cVar.f2099c;
            if (uVar != null) {
                ((y2.g) uVar.f257b).f6899q.set(cVar.f2097a);
            }
            cVar.f2097a = 0;
            cVar.f2098b = SystemClock.elapsedRealtime();
        }
        if (!aVar.f1801h) {
            aVar.f1804k.c(byteBuffer, bufferInfo);
        }
        if (aVar.f1799f) {
            switch (aVar.f1808o) {
                case 0:
                    J3.i.e(byteBuffer, "videoBuffer");
                    J3.i.e(bufferInfo, "info");
                    e2.L l2 = (e2.L) aVar.f1809p;
                    if (l2 == null) {
                        J3.i.g("rtmpClient");
                        throw null;
                    }
                    l2.f4053g.getClass();
                    l2.f4054h.b(new B1.d(AbstractC0752b.a(byteBuffer), AbstractC0752b.m(bufferInfo), B1.c.f112a));
                    return;
                default:
                    J3.i.e(byteBuffer, "videoBuffer");
                    J3.i.e(bufferInfo, "info");
                    r2.r rVar = (r2.r) aVar.f1809p;
                    if (rVar == null) {
                        J3.i.g("srtClient");
                        throw null;
                    }
                    rVar.f6390c.getClass();
                    rVar.f6391d.b(new B1.d(AbstractC0752b.a(byteBuffer), AbstractC0752b.m(bufferInfo), B1.c.f112a));
                    return;
            }
        }
    }

    @Override // I.InterfaceC0048i
    public Object m(I3.p pVar, A3.j jVar) {
        return ((InterfaceC0048i) this.f104b).m(new L.c(pVar, null), jVar);
    }

    @Override // O2.h
    public void n() {
        switch (this.f103a) {
            case 16:
                C0161f c0161f = (C0161f) this.f104b;
                S2.a aVar = c0161f.f1956r;
                if (aVar != null) {
                    ((ImageReader) aVar.f1811b).setOnImageAvailableListener(null, c0161f.f1951m);
                    break;
                }
                break;
            default:
                Log.d("StreamingPlugin", "EventChannel onCancel — eventSink cleared");
                ((Y0.n) this.f104b).f2491d = null;
                break;
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r2v3, types: [byte[], java.io.Serializable] */
    /* JADX WARN: Type inference failed for: r5v1, types: [byte[], java.io.Serializable] */
    @Override // Q1.a
    public void o(ByteBuffer byteBuffer, ByteBuffer byteBuffer2, ByteBuffer byteBuffer3) {
        H0.a aVar;
        ByteBuffer byteBufferDuplicate = byteBuffer.duplicate();
        ByteBuffer byteBufferDuplicate2 = byteBuffer2 != null ? byteBuffer2.duplicate() : null;
        ByteBuffer byteBufferDuplicate3 = byteBuffer3 != null ? byteBuffer3.duplicate() : null;
        S1.a aVar2 = (S1.a) this.f104b;
        switch (aVar2.f1808o) {
            case 0:
                J3.i.e(byteBufferDuplicate, "sps");
                e2.L l2 = (e2.L) aVar2.f1809p;
                if (l2 == null) {
                    J3.i.g("rtmpClient");
                    throw null;
                }
                Log.i("RtmpClient", "send sps and pps");
                Q q4 = l2.f4054h;
                q4.getClass();
                int iOrdinal = q4.f4076j.f4203w.ordinal();
                if (iOrdinal != 1) {
                    if (iOrdinal == 2) {
                        C0354b c0354b = new C0354b();
                        c0354b.f3931k = AbstractC0752b.l(byteBufferDuplicate);
                        aVar = c0354b;
                    } else {
                        if (byteBufferDuplicate2 == null) {
                            throw new IllegalArgumentException("pps can't be null with h264");
                        }
                        C0246b c0246b = new C0246b(1);
                        ByteBuffer byteBufferP0 = C0246b.p0(byteBufferDuplicate, -1);
                        ByteBuffer byteBufferP02 = C0246b.p0(byteBufferDuplicate2, -1);
                        int iRemaining = byteBufferP0.remaining();
                        ?? r22 = new byte[iRemaining];
                        int iRemaining2 = byteBufferP02.remaining();
                        ?? r5 = new byte[iRemaining2];
                        byteBufferP0.get(r22, 0, iRemaining);
                        byteBufferP02.get(r5, 0, iRemaining2);
                        c0246b.f3279l = r22;
                        c0246b.f3280m = r5;
                        aVar = c0246b;
                    }
                } else {
                    if (byteBufferDuplicate3 == null || byteBufferDuplicate2 == null) {
                        throw new IllegalArgumentException("pps or vps can't be null with h265");
                    }
                    C0358f c0358f = new C0358f();
                    ByteBuffer byteBufferP03 = C0358f.p0(byteBufferDuplicate, -1);
                    ByteBuffer byteBufferP04 = C0358f.p0(byteBufferDuplicate2, -1);
                    ByteBuffer byteBufferP05 = C0358f.p0(byteBufferDuplicate3, -1);
                    int iRemaining3 = byteBufferP03.remaining();
                    byte[] bArr = new byte[iRemaining3];
                    int iRemaining4 = byteBufferP04.remaining();
                    byte[] bArr2 = new byte[iRemaining4];
                    int iRemaining5 = byteBufferP05.remaining();
                    byte[] bArr3 = new byte[iRemaining5];
                    byteBufferP03.get(bArr, 0, iRemaining3);
                    byteBufferP04.get(bArr2, 0, iRemaining4);
                    byteBufferP05.get(bArr3, 0, iRemaining5);
                    c0358f.f3951k = bArr;
                    c0358f.f3952l = bArr2;
                    c0358f.f3953m = bArr3;
                    aVar = c0358f;
                }
                q4.f4078l = aVar;
                return;
            default:
                J3.i.e(byteBufferDuplicate, "sps");
                r2.r rVar = (r2.r) aVar2.f1809p;
                if (rVar == null) {
                    J3.i.g("srtClient");
                    throw null;
                }
                Log.i("SrtClient", "send sps and pps");
                x xVar = rVar.f6391d;
                xVar.getClass();
                EnumC0559b enumC0559bC = AbstractC0720a.c(xVar.f6422j.f6359i);
                C0583c c0583c = xVar.f6427o;
                c0583c.getClass();
                c0583c.f5974i = enumC0559bC;
                c0583c.f5971f = C0583c.d(byteBufferDuplicate);
                c0583c.f5972g = byteBufferDuplicate2 != null ? C0583c.d(byteBufferDuplicate2) : null;
                c0583c.f5973h = byteBufferDuplicate3 != null ? C0583c.d(byteBufferDuplicate3) : null;
                return;
        }
    }

    @Override // X.L
    public int p(View view) {
        u uVar = (u) view.getLayoutParams();
        ((t) this.f104b).getClass();
        return (view.getTop() - ((u) view.getLayoutParams()).f2377a.top) - ((ViewGroup.MarginLayoutParams) uVar).topMargin;
    }

    @Override // I.InterfaceC0048i
    public T3.d q() {
        return ((InterfaceC0048i) this.f104b).q();
    }

    @Override // Q1.a
    public void r(MediaFormat mediaFormat) {
        S1.a aVar = (S1.a) this.f104b;
        if (aVar.f1801h) {
            return;
        }
        aVar.f1804k.f2094g = mediaFormat;
    }

    public f0.d s(Object obj, J3.e eVar, Activity activity, k0.b bVar) throws IllegalAccessException, InvocationTargetException {
        f0.c cVar = new f0.c(eVar, bVar);
        Object objNewProxyInstance = Proxy.newProxyInstance((ClassLoader) this.f104b, new Class[]{v()}, cVar);
        J3.i.d(objNewProxyInstance, "newProxyInstance(loader,…onsumerClass()), handler)");
        obj.getClass().getMethod("addWindowLayoutInfoListener", Activity.class, v()).invoke(obj, activity, objNewProxyInstance);
        return new f0.d(obj.getClass().getMethod("removeWindowLayoutInfoListener", v()), obj, objNewProxyInstance);
    }

    @Override // com.google.android.gms.tasks.Continuation
    public Object then(Task task) {
        boolean zIsSuccessful = task.isSuccessful();
        e1.k kVar = (e1.k) this.f104b;
        if (zIsSuccessful) {
            return kVar.R((String) task.getResult());
        }
        Exception exception = task.getException();
        F.g(exception);
        Log.e("RecaptchaCallWrapper", "Failed to get Recaptcha token, error - " + exception.getMessage() + "\n\n Failing open with a fake token.");
        return kVar.R("NO_RECAPTCHA");
    }

    public void u() {
        ((C0113y) this.f104b).e.P();
    }

    public Class v() throws ClassNotFoundException {
        Class<?> clsLoadClass = ((ClassLoader) this.f104b).loadClass("java.util.function.Consumer");
        J3.i.d(clsLoadClass, "loader.loadClass(\"java.util.function.Consumer\")");
        return clsLoadClass;
    }

    public /* synthetic */ k(Object obj, int i4) {
        this.f103a = i4;
        this.f104b = obj;
    }

    public k(F2.b bVar, int i4) {
        this.f103a = i4;
        switch (i4) {
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                new C0747k(bVar, "flutter/sensitivecontent", O2.r.f1458a, 11).Y(new C0779j(this, 12));
                break;
            case 12:
                this.f104b = new C0053n(bVar, "flutter/system", O2.j.f1453a, null, 5);
                break;
            default:
                p1.d dVar = new p1.d(12);
                C0747k c0747k = new C0747k(bVar, "flutter/navigation", O2.k.f1454a, 11);
                this.f104b = c0747k;
                c0747k.Y(dVar);
                break;
        }
    }

    public k(int i4) {
        this.f103a = i4;
        switch (i4) {
            case 27:
                this.f104b = new AtomicReference(null);
                break;
            default:
                this.f104b = new SparseIntArray();
                break;
        }
    }
}
