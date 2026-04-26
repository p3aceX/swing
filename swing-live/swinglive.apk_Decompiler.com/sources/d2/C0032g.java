package D2;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Trace;
import android.util.Log;
import android.util.SparseArray;
import io.flutter.embedding.engine.FlutterJNI;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import m3.AbstractC0554a;
import u1.C0690c;
import y0.C0747k;

/* JADX INFO: renamed from: D2.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0032g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractActivityC0029d f193a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public E2.c f194b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public r f195c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public io.flutter.plugin.platform.f f196d;
    public S2.a e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public ViewTreeObserverOnPreDrawListenerC0031f f197f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f198g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public boolean f199h;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public boolean f201j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public Integer f202k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final C0030e f203l = new C0030e(this, 0);

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public boolean f200i = false;

    public C0032g(AbstractActivityC0029d abstractActivityC0029d) {
        this.f193a = abstractActivityC0029d;
    }

    public final void a(E2.f fVar) {
        String strA = this.f193a.a();
        if (strA == null || strA.isEmpty()) {
            strA = ((I2.e) C0747k.N().f6831b).f764d.f754b;
        }
        F2.a aVar = new F2.a(strA, this.f193a.f());
        String strG = this.f193a.g();
        if (strG == null) {
            AbstractActivityC0029d abstractActivityC0029d = this.f193a;
            abstractActivityC0029d.getClass();
            strG = d(abstractActivityC0029d.getIntent());
            if (strG == null) {
                strG = "/";
            }
        }
        fVar.f372b = aVar;
        fVar.f373c = strG;
        fVar.f374d = (List) this.f193a.getIntent().getSerializableExtra("dart_entrypoint_args");
    }

    public final void b() {
        if (this.f193a.k()) {
            throw new AssertionError("The internal FlutterEngine created by " + this.f193a + " has been attached to by another activity. To persist a FlutterEngine beyond the ownership of this activity, explicitly create a FlutterEngine");
        }
        AbstractActivityC0029d abstractActivityC0029d = this.f193a;
        abstractActivityC0029d.getClass();
        Log.w("FlutterActivity", "FlutterActivity " + abstractActivityC0029d + " connection to the engine " + abstractActivityC0029d.f186b.f194b + " evicted by another attaching activity");
        C0032g c0032g = abstractActivityC0029d.f186b;
        if (c0032g != null) {
            c0032g.e();
            abstractActivityC0029d.f186b.f();
        }
    }

    public final void c() {
        if (this.f193a == null) {
            throw new IllegalStateException("Cannot execute method on a destroyed FlutterActivityAndFragmentDelegate.");
        }
    }

    public final String d(Intent intent) {
        boolean z4;
        Uri data;
        AbstractActivityC0029d abstractActivityC0029d = this.f193a;
        abstractActivityC0029d.getClass();
        try {
            Bundle bundleH = abstractActivityC0029d.h();
            z4 = (bundleH == null || !bundleH.containsKey("flutter_deeplinking_enabled")) ? true : bundleH.getBoolean("flutter_deeplinking_enabled");
        } catch (PackageManager.NameNotFoundException unused) {
            z4 = false;
        }
        if (!z4 || (data = intent.getData()) == null) {
            return null;
        }
        return data.toString();
    }

    public final void e() {
        c();
        if (this.f197f != null) {
            this.f195c.getViewTreeObserver().removeOnPreDrawListener(this.f197f);
            this.f197f = null;
        }
        r rVar = this.f195c;
        if (rVar != null) {
            rVar.a();
            r rVar2 = this.f195c;
            rVar2.f244n.remove(this.f203l);
        }
    }

    public final void f() {
        if (this.f201j) {
            c();
            this.f193a.getClass();
            this.f193a.getClass();
            AbstractActivityC0029d abstractActivityC0029d = this.f193a;
            abstractActivityC0029d.getClass();
            if (abstractActivityC0029d.isChangingConfigurations()) {
                E2.d dVar = this.f194b.f344d;
                if (dVar.f()) {
                    AbstractC0554a.b("FlutterEngineConnectionRegistry#detachFromActivityForConfigChanges");
                    try {
                        dVar.f368g = true;
                        Iterator it = dVar.f366d.values().iterator();
                        while (it.hasNext()) {
                            ((L2.a) it.next()).f();
                        }
                        dVar.d();
                        Trace.endSection();
                    } finally {
                    }
                } else {
                    Log.e("FlutterEngineCxnRegstry", "Attempted to detach plugins from an Activity when no Activity was attached.");
                }
            } else {
                this.f194b.f344d.c();
            }
            io.flutter.plugin.platform.f fVar = this.f196d;
            if (fVar != null) {
                ((v) fVar.f4629d).f261c = null;
                this.f196d = null;
            }
            S2.a aVar = this.e;
            if (aVar != null) {
                ((B.k) aVar.f1812c).f104b = null;
                aVar.f1811b = null;
                this.e = null;
            }
            this.f193a.getClass();
            E2.c cVar = this.f194b;
            if (cVar != null) {
                N2.b bVar = cVar.f346g;
                bVar.a(1, bVar.f1131c);
            }
            if (this.f193a.k()) {
                E2.c cVar2 = this.f194b;
                Iterator it2 = cVar2.v.iterator();
                while (it2.hasNext()) {
                    ((E2.b) it2.next()).b();
                }
                E2.d dVar2 = cVar2.f344d;
                dVar2.e();
                HashMap map = dVar2.f363a;
                for (Class cls : new HashSet(map.keySet())) {
                    K2.a aVar2 = (K2.a) map.get(cls);
                    if (aVar2 != null) {
                        AbstractC0554a.b("FlutterEngineConnectionRegistry#remove ".concat(cls.getSimpleName()));
                        try {
                            if (aVar2 instanceof L2.a) {
                                if (dVar2.f()) {
                                    ((L2.a) aVar2).d();
                                }
                                dVar2.f366d.remove(cls);
                            }
                            aVar2.m(dVar2.f365c);
                            map.remove(cls);
                            Trace.endSection();
                        } finally {
                        }
                    }
                }
                map.clear();
                while (true) {
                    io.flutter.plugin.platform.q qVar = cVar2.f358s;
                    SparseArray sparseArray = qVar.f4676r;
                    if (sparseArray.size() <= 0) {
                        break;
                    }
                    qVar.f4665C.p(sparseArray.keyAt(0));
                }
                while (true) {
                    io.flutter.plugin.platform.p pVar = cVar2.f359t;
                    SparseArray sparseArray2 = pVar.f4655o;
                    if (sparseArray2.size() <= 0) {
                        break;
                    }
                    pVar.v.p(sparseArray2.keyAt(0));
                }
                cVar2.f343c.f443a.setPlatformMessageHandler(null);
                FlutterJNI flutterJNI = cVar2.f341a;
                flutterJNI.removeEngineLifecycleListener(cVar2.f362x);
                flutterJNI.setDeferredComponentManager(null);
                flutterJNI.detachFromNativeAndReleaseResources();
                C0747k.N().getClass();
                E2.c.f340z.remove(Long.valueOf(cVar2.f361w));
                if (this.f193a.e() != null) {
                    if (C0690c.f6640d == null) {
                        C0690c.f6640d = new C0690c(3);
                    }
                    C0690c c0690c = C0690c.f6640d;
                    ((HashMap) c0690c.f6642b).remove(this.f193a.e());
                }
                this.f194b = null;
            }
            this.f201j = false;
        }
    }
}
