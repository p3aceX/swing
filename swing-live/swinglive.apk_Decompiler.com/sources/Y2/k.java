package y2;

import D2.SurfaceHolderCallbackC0034i;
import D2.u;
import Q3.C0152y;
import Q3.F;
import Q3.y0;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import e2.L;
import java.util.Map;
import m1.C0553h;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
public final class k implements io.flutter.plugin.platform.g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f6914a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6915b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final FrameLayout f6916c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final V1.f f6917d;
    public g e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public M1.b f6918f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public m f6919g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public m f6920h;

    public k(Context context, Object obj, C0690c c0690c) {
        J3.i.e(context, "context");
        J3.i.e(c0690c, "messenger");
        this.f6914a = obj;
        boolean z4 = obj instanceof Map;
        Map map = z4 ? (Map) obj : null;
        Object obj2 = map != null ? map.get("cameraFacing") : null;
        Integer num = obj2 instanceof Integer ? (Integer) obj2 : null;
        this.f6915b = num != null ? num.intValue() : 0;
        Map map2 = z4 ? (Map) obj : null;
        Object obj3 = map2 != null ? map2.get("overlayEnabled") : null;
        Boolean bool = obj3 instanceof Boolean ? (Boolean) obj3 : null;
        boolean zBooleanValue = bool != null ? bool.booleanValue() : true;
        Map map3 = z4 ? (Map) obj : null;
        Object obj4 = map3 != null ? map3.get("overlayStyle") : null;
        String str = obj4 instanceof String ? (String) obj4 : null;
        String str2 = str == null ? "classic_slate" : str;
        Map map4 = z4 ? (Map) obj : null;
        Object obj5 = map4 != null ? map4.get("streamWidth") : null;
        Integer num2 = obj5 instanceof Integer ? (Integer) obj5 : null;
        int iIntValue = num2 != null ? num2.intValue() : 1280;
        Map map5 = z4 ? (Map) obj : null;
        Object obj6 = map5 != null ? map5.get("streamHeight") : null;
        Integer num3 = obj6 instanceof Integer ? (Integer) obj6 : null;
        int iIntValue2 = num3 != null ? num3.intValue() : 720;
        FrameLayout frameLayout = new FrameLayout(context);
        this.f6916c = frameLayout;
        V1.f fVar = new V1.f(context);
        this.f6917d = fVar;
        frameLayout.addView(fVar);
        fVar.setAspectRatioMode(O1.a.f1443a);
        fVar.setZOrderMediaOverlay(true);
        g gVar = new g(context, fVar, new M1.b(this, 7), new C0152y(5), new i(this, 0), new i(this, 1));
        this.e = gVar;
        C0553h c0553h = gVar.f6883E;
        J3.i.e(c0553h, "connectChecker");
        S1.a aVar = new S1.a(fVar, 0);
        aVar.f1809p = new L(c0553h);
        gVar.f6889g = aVar;
        gVar.f6891i = aVar;
        gVar.f6880B = new C0759a(context, new d(gVar));
        gVar.f6879A = false;
        S1.a aVar2 = gVar.f6889g;
        if (aVar2 != null) {
            aVar2.f1807n.f2099c = new u(gVar, 14);
        }
        g gVar2 = this.e;
        if (gVar2 != null && iIntValue > 0 && iIntValue2 > 0) {
            gVar2.f6900r.set(iIntValue);
            gVar2.f6901s.set(iIntValue2);
            V1.f fVar2 = gVar2.f6885b;
            fVar2.f2200q = iIntValue;
            fVar2.f2201r = iIntValue2;
            if (gVar2.f6907z) {
                gVar2.f6885b.post(new b(gVar2, 1));
            }
        }
        g gVar3 = this.e;
        if (gVar3 != null) {
            gVar3.f6900r.get();
            gVar3.f6901s.get();
            gVar3.f6907z = zBooleanValue;
            if (gVar3.f6907z) {
                gVar3.b("setOverlayEnabled");
            } else {
                gVar3.c();
            }
        }
        g gVar4 = this.e;
        if (gVar4 != null) {
            gVar4.e(str2);
        }
        fVar.getHolder().addCallback(new SurfaceHolderCallbackC0034i(this, 1));
        fVar.setOnTouchListener(new View.OnTouchListener() { // from class: y2.j
            @Override // android.view.View.OnTouchListener
            public final boolean onTouch(View view, MotionEvent motionEvent) {
                g gVar5 = this.f6913a.e;
                if (gVar5 == null) {
                    return false;
                }
                J3.i.b(motionEvent);
                if (motionEvent.getPointerCount() < 2) {
                    return false;
                }
                try {
                    S1.a aVar3 = gVar5.f6891i;
                    if (aVar3 == null) {
                        return true;
                    }
                    aVar3.c(motionEvent);
                    return true;
                } catch (Exception unused) {
                    return false;
                }
            }
        });
    }

    public final void a() {
        Log.d("StreamPreviewView", "StreamPreviewView disposed");
        g gVar = this.e;
        if (gVar != null) {
            y0 y0Var = gVar.f6904w;
            if (y0Var != null) {
                y0Var.a(null);
            }
            y0 y0Var2 = gVar.f6905x;
            if (y0Var2 != null) {
                y0Var2.a(null);
            }
            F.f(gVar.f6906y);
            C0759a c0759a = gVar.f6880B;
            if (c0759a != null) {
                Bitmap bitmap = c0759a.f6861b;
                if (bitmap != null) {
                    bitmap.recycle();
                }
                c0759a.f6861b = null;
                c0759a.f6862c = null;
            }
            gVar.f6880B = null;
            try {
                S1.a aVar = gVar.f6891i;
                if (aVar != null) {
                    aVar.g();
                }
                S1.a aVar2 = gVar.f6891i;
                if (aVar2 != null) {
                    aVar2.f();
                }
            } catch (Exception e) {
                Log.e("EliteStreamManager", "Release failed", e);
            }
            gVar.f6892j.set(false);
            gVar.f6893k.set(false);
            gVar.f6896n.set(0L);
            gVar.f6897o.set(0L);
            gVar.f6888f.a();
            gVar.f6879A = false;
            gVar.f6889g = null;
            gVar.f6890h = null;
            gVar.f6891i = null;
        }
        this.e = null;
    }

    public final boolean b(String str, int i4, int i5, int i6, int i7, int i8, int i9, boolean z4, boolean z5) {
        boolean z6;
        g gVar = this.e;
        if (gVar != null) {
            boolean zF0 = P3.m.F0(str, "srt://");
            if (zF0 && gVar.f6890h == null) {
                V1.f fVar = gVar.f6885b;
                C0553h c0553h = gVar.f6883E;
                J3.i.e(fVar, "openGlView");
                J3.i.e(c0553h, "connectChecker");
                S1.a aVar = new S1.a(fVar, 1);
                aVar.f1809p = new r2.r(c0553h);
                gVar.f6890h = aVar;
            }
            S1.a aVar2 = zF0 ? gVar.f6890h : gVar.f6889g;
            gVar.f6891i = aVar2;
            if (aVar2 != null) {
                try {
                    M1.g gVar2 = i9 == 1 ? M1.g.f1085b : M1.g.f1084a;
                    gVar.f6900r.set(i4);
                    gVar.f6901s.set(i5);
                    V1.f fVar2 = gVar.f6885b;
                    fVar2.f2200q = i4;
                    fVar2.f2201r = i5;
                    gVar.f6907z = z5;
                    if (!aVar2.f1803j) {
                        gVar.f6898p.set(gVar2);
                        aVar2.d(gVar2, i4, i5);
                    } else if (gVar2 != gVar.f6898p.get()) {
                        aVar2.h();
                        gVar.f6898p.set(gVar2);
                    }
                    int i10 = i7 * 1000;
                    if (aVar2.f1803j) {
                        if (i4 == aVar2.f1805l && i5 == aVar2.f1806m) {
                            Q1.b bVar = aVar2.f1796b;
                            if (i6 != bVar.f1546A || bVar.f1548C != 0) {
                            }
                        }
                        aVar2.f();
                    }
                    aVar2.f1801h = false;
                    if (aVar2.f1796b.q(i4, i5, i6, i10, 0, 2, 13, -1, -1) && aVar2.a(i8 * 1000)) {
                        if (z4) {
                            aVar2.f1798d.f524h = false;
                            z6 = true;
                        } else {
                            z6 = true;
                            aVar2.f1798d.f524h = true;
                        }
                        aVar2.e(str);
                        gVar.f6892j.set(z6);
                        gVar.f6896n.set(System.currentTimeMillis());
                        y0 y0Var = gVar.f6904w;
                        if (y0Var != null) {
                            y0Var.a(null);
                        }
                        gVar.f6904w = F.s(gVar.f6906y, null, new f(gVar, null), 3);
                        y0 y0Var2 = gVar.f6905x;
                        if (y0Var2 != null) {
                            y0Var2.a(null);
                        }
                        gVar.f6905x = F.s(gVar.f6906y, null, new e(gVar, i7, null), 3);
                        gVar.a(z6);
                        gVar.f6879A = false;
                        gVar.f6885b.post(new b(gVar, 3));
                        return z6;
                    }
                } catch (Exception e) {
                    Log.e("EliteStreamManager", "Error starting stream", e);
                }
            }
        }
        return false;
    }
}
