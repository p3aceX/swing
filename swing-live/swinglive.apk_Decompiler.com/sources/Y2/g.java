package y2;

import O.RunnableC0093d;
import Q3.C0152y;
import Q3.F;
import Q3.O;
import Q3.y0;
import Q3.z0;
import a.AbstractC0184a;
import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.util.Range;
import android.view.WindowManager;
import e1.AbstractC0367g;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;
import m1.C0553h;

/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public volatile boolean f6879A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public C0759a f6880B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final AtomicBoolean f6881C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public float f6882D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public final C0553h f6883E;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f6884a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final V1.f f6885b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final M1.b f6886c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0152y f6887d;
    public final i e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final i f6888f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public S1.a f6889g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public S1.a f6890h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public S1.a f6891i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final AtomicBoolean f6892j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final AtomicBoolean f6893k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final AtomicInteger f6894l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final AtomicInteger f6895m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final AtomicLong f6896n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final AtomicLong f6897o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final AtomicReference f6898p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final AtomicInteger f6899q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final AtomicInteger f6900r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final AtomicInteger f6901s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final L1.a f6902t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public volatile Map f6903u;
    public volatile String v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public y0 f6904w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public y0 f6905x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final V3.d f6906y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public volatile boolean f6907z;

    public g(Context context, V1.f fVar, M1.b bVar, C0152y c0152y, i iVar, i iVar2) {
        J3.i.e(context, "context");
        J3.i.e(fVar, "openGlView");
        this.f6884a = context;
        this.f6885b = fVar;
        this.f6886c = bVar;
        this.f6887d = c0152y;
        this.e = iVar;
        this.f6888f = iVar2;
        this.f6892j = new AtomicBoolean(false);
        this.f6893k = new AtomicBoolean(false);
        this.f6894l = new AtomicInteger(0);
        this.f6895m = new AtomicInteger(0);
        this.f6896n = new AtomicLong(0L);
        this.f6897o = new AtomicLong(0L);
        this.f6898p = new AtomicReference(M1.g.f1084a);
        this.f6899q = new AtomicInteger(0);
        this.f6900r = new AtomicInteger(1280);
        this.f6901s = new AtomicInteger(720);
        this.f6902t = new L1.a();
        this.f6903u = x3.q.f6785a;
        this.v = "classic_slate";
        X3.e eVar = O.f1596a;
        R3.d dVar = V3.o.f2244a;
        z0 z0VarC = F.c();
        dVar.getClass();
        this.f6906y = F.b(AbstractC0367g.A(dVar, z0VarC));
        this.f6907z = true;
        this.f6881C = new AtomicBoolean(false);
        this.f6882D = -1.0f;
        this.f6883E = new C0553h(this);
    }

    public final void a(final boolean z4) {
        Context context = this.f6884a;
        final Activity activity = context instanceof Activity ? (Activity) context : null;
        if (activity == null) {
            return;
        }
        activity.runOnUiThread(new Runnable() { // from class: y2.c
            @Override // java.lang.Runnable
            public final void run() {
                Activity activity2 = activity;
                try {
                    WindowManager.LayoutParams attributes = activity2.getWindow().getAttributes();
                    boolean z5 = z4;
                    g gVar = this;
                    if (z5) {
                        if (gVar.f6882D == -1.0f) {
                            gVar.f6882D = attributes.screenBrightness;
                        }
                        attributes.screenBrightness = 0.1f;
                    } else {
                        float f4 = gVar.f6882D;
                        if (f4 != -1.0f) {
                            attributes.screenBrightness = f4;
                        }
                    }
                    activity2.getWindow().setAttributes(attributes);
                } catch (Exception e) {
                    Log.e("EliteStreamManager", "Battery shield failed", e);
                }
            }
        });
    }

    public final void b(String str) {
        V1.f fVar;
        try {
            if (!this.f6907z) {
                c();
                return;
            }
            h();
            if (this.f6879A) {
                return;
            }
            S1.a aVar = this.f6891i;
            if (aVar != null && (fVar = aVar.f1800g) != null) {
                fVar.setFilter(this.f6902t);
            }
            this.f6879A = true;
            Log.d("EliteStreamManager", "GL filter attached initially: ".concat(str));
        } catch (Exception e) {
            Log.e("EliteStreamManager", "Attach filter failed", e);
        }
    }

    public final void c() {
        V1.f fVar;
        try {
            S1.a aVar = this.f6891i;
            if (aVar != null && (fVar = aVar.f1800g) != null) {
                fVar.setFilter(new K1.b());
            }
            this.f6879A = false;
        } catch (Exception e) {
            Log.e("EliteStreamManager", "Detach filter failed", e);
        }
    }

    public final l d() {
        AtomicLong atomicLong = this.f6896n;
        return new l(this.f6897o.get(), this.f6899q.get(), this.f6894l.get(), this.f6893k.get(), atomicLong.get() > 0 ? (System.currentTimeMillis() - atomicLong.get()) / ((long) 1000) : 0L);
    }

    public final void e(String str) {
        J3.i.e(str, "style");
        if (P3.m.v0(str)) {
            str = "classic_slate";
        }
        this.v = str;
        if (this.f6907z) {
            this.f6885b.post(new b(this, 0));
        }
    }

    public final void f(int i4) {
        V1.f fVar = this.f6885b;
        S1.a aVar = this.f6891i;
        if (aVar == null) {
            return;
        }
        try {
            M1.g gVar = i4 == 1 ? M1.g.f1085b : M1.g.f1084a;
            boolean z4 = aVar.f1803j;
            AtomicReference atomicReference = this.f6898p;
            if (z4 && atomicReference.get() == gVar) {
                Log.d("EliteStreamManager", "Already on preview with same facing, skipping restart");
                return;
            }
            Log.d("EliteStreamManager", "startPreview facing=" + gVar + " (previous=" + atomicReference.get() + ')');
            if (aVar.f1803j) {
                aVar.f();
            }
            atomicReference.set(gVar);
            AtomicInteger atomicInteger = this.f6900r;
            int i5 = atomicInteger.get();
            AtomicInteger atomicInteger2 = this.f6901s;
            int i6 = atomicInteger2.get();
            fVar.f2200q = i5;
            fVar.f2201r = i6;
            aVar.d(gVar, atomicInteger.get(), atomicInteger2.get());
            fVar.postDelayed(new RunnableC0093d(14, aVar, this), 500L);
        } catch (Exception e) {
            Log.e("EliteStreamManager", "Error starting preview", e);
        }
    }

    public final Float g(float f4) {
        S1.a aVar = this.f6891i;
        if (aVar == null) {
            return null;
        }
        try {
            Range rangeF = aVar.f1795a.f();
            float fFloatValue = ((Number) rangeF.getUpper()).floatValue();
            Object lower = rangeF.getLower();
            J3.i.d(lower, "getLower(...)");
            float fFloatValue2 = fFloatValue - ((Number) lower).floatValue();
            float f5 = fFloatValue2 > 0.0f ? fFloatValue2 * 0.12f : 0.1f;
            float f6 = aVar.f1795a.f1079l;
            if (f4 < 0.0f) {
                f5 = -f5;
            }
            Object lower2 = rangeF.getLower();
            J3.i.d(lower2, "getLower(...)");
            float fFloatValue3 = ((Number) lower2).floatValue();
            Object upper = rangeF.getUpper();
            J3.i.d(upper, "getUpper(...)");
            float fJ = AbstractC0184a.j(f6 + f5, fFloatValue3, ((Number) upper).floatValue());
            aVar.f1795a.i(fJ);
            return Float.valueOf(fJ);
        } catch (Exception unused) {
            return null;
        }
    }

    public final void h() {
        try {
            int iIncrementAndGet = this.f6895m.incrementAndGet();
            int i4 = this.f6900r.get();
            int i5 = i4 > 1280 ? 1280 : i4;
            int i6 = this.f6901s.get();
            int i7 = i6 > 720 ? 720 : i6;
            C0759a c0759a = this.f6880B;
            if (c0759a != null) {
                c0759a.d(this.f6903u, i5, i7, this.v, iIncrementAndGet);
            }
        } catch (Exception e) {
            Log.e("EliteStreamManager", "Update bitmap failed", e);
        }
    }
}
