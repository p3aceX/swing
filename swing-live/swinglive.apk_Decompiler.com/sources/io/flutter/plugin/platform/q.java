package io.flutter.plugin.platform;

import D2.C0026a;
import D2.C0033h;
import D2.K;
import android.app.Activity;
import android.content.Context;
import android.content.MutableContextWrapper;
import android.hardware.display.DisplayManager;
import android.os.Build;
import android.util.SparseArray;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;
import com.google.crypto.tink.shaded.protobuf.S;
import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.view.TextureRegistry$SurfaceProducer;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class q implements j {

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public static final Class[] f4662D = {SurfaceView.class};

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public final D2.v f4663A;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0026a f4667b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Activity f4668c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public D2.r f4669d;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public io.flutter.embedding.engine.renderer.j f4670f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public io.flutter.plugin.editing.i f4671m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public D2.v f4672n;
    public FlutterJNI e = null;
    public int v = 0;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f4680w = false;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public boolean f4681x = true;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public boolean f4664B = false;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final n f4665C = new n(this, 0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final n f4666a = new n(2);

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final HashMap f4674p = new HashMap();

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final C0425a f4673o = new C0425a();

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final HashMap f4675q = new HashMap();

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final SparseArray f4678t = new SparseArray();

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final HashSet f4682y = new HashSet();

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public final HashSet f4683z = new HashSet();

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final SparseArray f4679u = new SparseArray();

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final SparseArray f4676r = new SparseArray();

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final SparseArray f4677s = new SparseArray();

    public q() {
        if (D2.v.f258d == null) {
            D2.v.f258d = new D2.v(1);
        }
        this.f4663A = D2.v.f258d;
    }

    public static void a(q qVar, N2.e eVar) {
        qVar.getClass();
        int i4 = eVar.f1144g;
        if (i4 != 0 && i4 != 1) {
            throw new IllegalStateException(B1.a.n(S.i("Trying to create a view with unknown direction value: ", i4, "(view id: "), eVar.f1139a, ")"));
        }
    }

    public static void e(int i4) {
        int i5 = Build.VERSION.SDK_INT;
        if (i5 < i4) {
            throw new IllegalStateException(B1.a.k("Trying to use platform views with API ", i5, i4, ", required API level is: "));
        }
    }

    public static h j(io.flutter.embedding.engine.renderer.j jVar) {
        int i4 = Build.VERSION.SDK_INT;
        if (i4 < 29) {
            return i4 >= 29 ? new C0427c(jVar.c()) : new x(jVar.e());
        }
        TextureRegistry$SurfaceProducer textureRegistry$SurfaceProducerD = jVar.d(i4 <= 34 ? 2 : 1);
        n nVar = new n(4);
        nVar.f4647b = textureRegistry$SurfaceProducerD;
        return nVar;
    }

    public final y2.k b(N2.e eVar, boolean z4) {
        HashMap map = (HashMap) this.f4666a.f4647b;
        String str = eVar.f1140b;
        y2.h hVar = (y2.h) map.get(str);
        if (hVar == null) {
            throw new IllegalStateException("Trying to create a platform view of unregistered type: " + str);
        }
        ByteBuffer byteBuffer = eVar.f1146i;
        Object objA = byteBuffer != null ? hVar.f6908a.a(byteBuffer) : null;
        Context mutableContextWrapper = z4 ? new MutableContextWrapper(this.f4668c) : this.f4668c;
        J3.i.e(mutableContextWrapper, "context");
        y2.k kVar = new y2.k(mutableContextWrapper, objA, hVar.f6909b);
        Y0.n nVar = hVar.f6910c.f3871f;
        if (nVar != null) {
            nVar.f2492f = kVar;
        }
        FrameLayout frameLayout = kVar.f6916c;
        if (frameLayout == null) {
            throw new IllegalStateException("PlatformView#getView() returned null, but an Android view reference was expected.");
        }
        frameLayout.setLayoutDirection(eVar.f1144g);
        this.f4676r.put(eVar.f1139a, kVar);
        return kVar;
    }

    public final void c() {
        int i4 = 0;
        while (true) {
            SparseArray sparseArray = this.f4678t;
            if (i4 >= sparseArray.size()) {
                return;
            }
            C0428d c0428d = (C0428d) sparseArray.valueAt(i4);
            c0428d.d();
            c0428d.f204a.close();
            i4++;
        }
    }

    @Override // io.flutter.plugin.platform.j
    public final void d() {
        this.f4673o.f4616a = null;
    }

    @Override // io.flutter.plugin.platform.j
    public final void f(io.flutter.view.k kVar) {
        this.f4673o.f4616a = kVar;
    }

    public final void g(boolean z4) {
        int i4 = 0;
        while (true) {
            SparseArray sparseArray = this.f4678t;
            if (i4 >= sparseArray.size()) {
                break;
            }
            int iKeyAt = sparseArray.keyAt(i4);
            C0428d c0428d = (C0428d) sparseArray.valueAt(i4);
            if (this.f4682y.contains(Integer.valueOf(iKeyAt))) {
                E2.c cVar = this.f4669d.f246p;
                if (cVar != null) {
                    c0428d.b(cVar.f342b);
                }
                z4 &= c0428d.e();
            } else {
                if (!this.f4680w) {
                    c0428d.d();
                }
                c0428d.setVisibility(8);
                this.f4669d.removeView(c0428d);
            }
            i4++;
        }
        int i5 = 0;
        while (true) {
            SparseArray sparseArray2 = this.f4677s;
            if (i5 >= sparseArray2.size()) {
                return;
            }
            int iKeyAt2 = sparseArray2.keyAt(i5);
            View view = (View) sparseArray2.get(iKeyAt2);
            if (!this.f4683z.contains(Integer.valueOf(iKeyAt2)) || (!z4 && this.f4681x)) {
                view.setVisibility(8);
            } else {
                view.setVisibility(0);
            }
            i5++;
        }
    }

    public final float h() {
        return this.f4668c.getResources().getDisplayMetrics().density;
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [android.view.View, io.flutter.embedding.engine.renderer.m] */
    public final void i() {
        if (!this.f4681x || this.f4680w) {
            return;
        }
        D2.r rVar = this.f4669d;
        rVar.f242f.c();
        C0033h c0033h = rVar.e;
        if (c0033h == null) {
            C0033h c0033h2 = new C0033h(rVar.getContext(), rVar.getWidth(), rVar.getHeight(), 1);
            rVar.e = c0033h2;
            rVar.addView(c0033h2);
        } else {
            c0033h.g(rVar.getWidth(), rVar.getHeight());
        }
        rVar.f243m = rVar.f242f;
        C0033h c0033h3 = rVar.e;
        rVar.f242f = c0033h3;
        E2.c cVar = rVar.f246p;
        if (cVar != null) {
            c0033h3.b(cVar.f342b);
        }
        this.f4680w = true;
    }

    public final void k() {
        for (C c5 : this.f4674p.values()) {
            int width = c5.f4611f.getWidth();
            h hVar = c5.f4611f;
            int height = hVar.getHeight();
            boolean zIsFocused = c5.a().isFocused();
            v vVarDetachState = c5.f4607a.detachState();
            c5.f4613h.setSurface(null);
            c5.f4613h.release();
            c5.f4613h = ((DisplayManager) c5.f4608b.getSystemService("display")).createVirtualDisplay("flutter-vd#" + c5.e, width, height, c5.f4610d, hVar.getSurface(), 0, C.f4606i, null);
            SingleViewPresentation singleViewPresentation = new SingleViewPresentation(c5.f4608b, c5.f4613h.getDisplay(), c5.f4609c, vVarDetachState, c5.f4612g, zIsFocused);
            singleViewPresentation.show();
            c5.f4607a.cancel();
            c5.f4607a = singleViewPresentation;
        }
    }

    public final MotionEvent l(float f4, N2.f fVar, boolean z4) {
        MotionEvent motionEventA = this.f4663A.A(new K(fVar.f1161p));
        List<List> list = (List) fVar.f1152g;
        ArrayList arrayList = new ArrayList();
        for (List list2 : list) {
            MotionEvent.PointerCoords pointerCoords = new MotionEvent.PointerCoords();
            pointerCoords.orientation = (float) ((Double) list2.get(0)).doubleValue();
            pointerCoords.pressure = (float) ((Double) list2.get(1)).doubleValue();
            pointerCoords.size = (float) ((Double) list2.get(2)).doubleValue();
            double d5 = f4;
            pointerCoords.toolMajor = (float) (((Double) list2.get(3)).doubleValue() * d5);
            pointerCoords.toolMinor = (float) (((Double) list2.get(4)).doubleValue() * d5);
            pointerCoords.touchMajor = (float) (((Double) list2.get(5)).doubleValue() * d5);
            pointerCoords.touchMinor = (float) (((Double) list2.get(6)).doubleValue() * d5);
            pointerCoords.x = (float) (((Double) list2.get(7)).doubleValue() * d5);
            pointerCoords.y = (float) (((Double) list2.get(8)).doubleValue() * d5);
            arrayList.add(pointerCoords);
        }
        int i4 = fVar.e;
        MotionEvent.PointerCoords[] pointerCoordsArr = (MotionEvent.PointerCoords[]) arrayList.toArray(new MotionEvent.PointerCoords[i4]);
        List<List> list3 = (List) fVar.f1151f;
        ArrayList arrayList2 = new ArrayList();
        for (List list4 : list3) {
            MotionEvent.PointerProperties pointerProperties = new MotionEvent.PointerProperties();
            pointerProperties.id = ((Integer) list4.get(0)).intValue();
            pointerProperties.toolType = ((Integer) list4.get(1)).intValue();
            arrayList2.add(pointerProperties);
        }
        MotionEvent.PointerProperties[] pointerPropertiesArr = (MotionEvent.PointerProperties[]) arrayList2.toArray(new MotionEvent.PointerProperties[i4]);
        if (z4 || motionEventA == null) {
            return MotionEvent.obtain(fVar.f1148b.longValue(), fVar.f1149c.longValue(), fVar.f1150d, fVar.e, pointerPropertiesArr, pointerCoordsArr, fVar.f1153h, fVar.f1154i, fVar.f1155j, fVar.f1156k, fVar.f1157l, fVar.f1158m, fVar.f1159n, fVar.f1160o);
        }
        if (motionEventA.getPointerCount() == i4 && motionEventA.getAction() == fVar.f1150d) {
            if (pointerCoordsArr.length < 1) {
                return motionEventA;
            }
            motionEventA.offsetLocation(pointerCoordsArr[0].x - motionEventA.getX(), pointerCoordsArr[0].y - motionEventA.getY());
            return motionEventA;
        }
        return MotionEvent.obtain(motionEventA.getDownTime(), motionEventA.getEventTime(), fVar.f1150d, fVar.e, pointerPropertiesArr, pointerCoordsArr, motionEventA.getMetaState(), motionEventA.getButtonState(), motionEventA.getXPrecision(), motionEventA.getYPrecision(), motionEventA.getDeviceId(), motionEventA.getEdgeFlags(), motionEventA.getSource(), motionEventA.getFlags());
    }

    @Override // io.flutter.plugin.platform.j
    public final boolean m(int i4) {
        return this.f4674p.containsKey(Integer.valueOf(i4));
    }

    public final int n(double d5) {
        return (int) Math.round(d5 * ((double) h()));
    }

    @Override // io.flutter.plugin.platform.j
    public final FrameLayout s(int i4) {
        if (m(i4)) {
            return ((C) this.f4674p.get(Integer.valueOf(i4))).a();
        }
        g gVar = (g) this.f4676r.get(i4);
        if (gVar == null) {
            return null;
        }
        return ((y2.k) gVar).f6916c;
    }
}
