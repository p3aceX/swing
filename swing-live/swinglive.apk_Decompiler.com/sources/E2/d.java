package E2;

import D2.AbstractActivityC0029d;
import D2.C0032g;
import D2.v;
import Y0.n;
import android.content.Context;
import android.os.Trace;
import android.util.Log;
import android.view.Surface;
import androidx.lifecycle.p;
import com.google.android.gms.common.internal.r;
import io.flutter.plugin.platform.q;
import java.util.HashMap;
import java.util.Iterator;
import m3.AbstractC0554a;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final c f364b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0747k f365c;
    public C0032g e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public n f367f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashMap f363a = new HashMap();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final HashMap f366d = new HashMap();

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f368g = false;

    public d(Context context, c cVar) {
        new HashMap();
        new HashMap();
        new HashMap();
        this.f364b = cVar;
        F2.b bVar = cVar.f343c;
        io.flutter.plugin.platform.n nVar = cVar.f358s.f4666a;
        this.f365c = new C0747k(context, bVar, cVar.f342b, 6);
    }

    public final void a(K2.a aVar) {
        AbstractC0554a.b("FlutterEngineConnectionRegistry#add ".concat(aVar.getClass().getSimpleName()));
        try {
            Class<?> cls = aVar.getClass();
            HashMap map = this.f363a;
            if (map.containsKey(cls)) {
                Log.w("FlutterEngineCxnRegstry", "Attempted to register plugin (" + aVar + ") but it was already registered with this FlutterEngine (" + this.f364b + ").");
                Trace.endSection();
                return;
            }
            aVar.toString();
            map.put(aVar.getClass(), aVar);
            aVar.c(this.f365c);
            if (aVar instanceof L2.a) {
                L2.a aVar2 = (L2.a) aVar;
                this.f366d.put(aVar.getClass(), aVar2);
                if (f()) {
                    aVar2.e(this.f367f);
                }
            }
            Trace.endSection();
        } catch (Throwable th) {
            try {
                Trace.endSection();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    public final void b(AbstractActivityC0029d abstractActivityC0029d, p pVar) {
        this.f367f = new n(abstractActivityC0029d, pVar);
        boolean booleanExtra = abstractActivityC0029d.getIntent() != null ? abstractActivityC0029d.getIntent().getBooleanExtra("enable-software-rendering", false) : false;
        c cVar = this.f364b;
        cVar.f358s.f4664B = booleanExtra;
        r rVar = cVar.f360u;
        q qVar = (q) rVar.f3597b;
        if (qVar.f4668c != null) {
            throw new AssertionError("A PlatformViewsController can only be attached to a single output target.\nattach was called while the PlatformViewsController was already attached.");
        }
        qVar.f4668c = abstractActivityC0029d;
        qVar.f4670f = cVar.f342b;
        F2.b bVar = cVar.f343c;
        qVar.f4672n = new v(bVar, 7);
        io.flutter.plugin.platform.p pVar2 = (io.flutter.plugin.platform.p) rVar.f3598c;
        if (pVar2.f4650c != null) {
            throw new AssertionError("A PlatformViewsController can only be attached to a single output target.\nattach was called while the PlatformViewsController was already attached.");
        }
        pVar2.f4650c = abstractActivityC0029d;
        v vVar = new v(bVar, 6);
        pVar2.f4653m = vVar;
        vVar.f261c = pVar2.v;
        qVar.f4672n.f261c = rVar;
        for (L2.a aVar : this.f366d.values()) {
            if (this.f368g) {
                aVar.b(this.f367f);
            } else {
                aVar.e(this.f367f);
            }
        }
        this.f368g = false;
    }

    public final void c() {
        if (!f()) {
            Log.e("FlutterEngineCxnRegstry", "Attempted to detach plugins from an Activity when no Activity was attached.");
            return;
        }
        AbstractC0554a.b("FlutterEngineConnectionRegistry#detachFromActivity");
        try {
            Iterator it = this.f366d.values().iterator();
            while (it.hasNext()) {
                ((L2.a) it.next()).d();
            }
            d();
            Trace.endSection();
        } catch (Throwable th) {
            try {
                Trace.endSection();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    public final void d() {
        c cVar = this.f364b;
        q qVar = cVar.f358s;
        v vVar = qVar.f4672n;
        if (vVar != null) {
            vVar.f261c = null;
        }
        qVar.c();
        qVar.f4672n = null;
        qVar.f4668c = null;
        qVar.f4670f = null;
        io.flutter.plugin.platform.p pVar = cVar.f359t;
        v vVar2 = pVar.f4653m;
        if (vVar2 != null) {
            vVar2.f261c = null;
        }
        Surface surface = pVar.f4660t;
        if (surface != null) {
            surface.release();
            pVar.f4660t = null;
            pVar.f4661u = null;
        }
        pVar.f4653m = null;
        pVar.f4650c = null;
        this.e = null;
        this.f367f = null;
    }

    public final void e() {
        if (f()) {
            c();
        }
    }

    public final boolean f() {
        return this.e != null;
    }
}
