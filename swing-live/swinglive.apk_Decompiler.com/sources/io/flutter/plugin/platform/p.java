package io.flutter.plugin.platform;

import D2.C0026a;
import android.app.Activity;
import android.util.SparseArray;
import android.view.Surface;
import android.view.SurfaceControl;
import android.widget.FrameLayout;
import io.flutter.embedding.engine.FlutterJNI;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class p implements j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public n f4648a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0026a f4649b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Activity f4650c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public D2.r f4651d;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public io.flutter.plugin.editing.i f4652f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public D2.v f4653m;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final D2.v f4657q;
    public FlutterJNI e = null;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public Surface f4660t = null;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public SurfaceControl f4661u = null;
    public final n v = new n(this, 3);

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final C0425a f4654n = new C0425a();

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final SparseArray f4655o = new SparseArray();

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final SparseArray f4656p = new SparseArray();

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final ArrayList f4658r = new ArrayList();

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final ArrayList f4659s = new ArrayList();

    public p() {
        if (D2.v.f258d == null) {
            D2.v.f258d = new D2.v(1);
        }
        this.f4657q = D2.v.f258d;
    }

    public final boolean a(int i4) {
        g gVar = (g) this.f4655o.get(i4);
        if (gVar == null) {
            return false;
        }
        SparseArray sparseArray = this.f4656p;
        if (sparseArray.get(i4) != null) {
            return true;
        }
        FrameLayout frameLayout = ((y2.k) gVar).f6916c;
        if (frameLayout == null) {
            throw new IllegalStateException("PlatformView#getView() returned null, but an Android view reference was expected.");
        }
        if (frameLayout.getParent() != null) {
            throw new IllegalStateException("The Android view returned from PlatformView#getView() was already added to a parent view.");
        }
        Activity activity = this.f4650c;
        J2.b bVar = new J2.b(activity, activity.getResources().getDisplayMetrics().density, this.f4649b);
        bVar.setOnDescendantFocusChangeListener(new k(this, i4, 1));
        sparseArray.put(i4, bVar);
        frameLayout.setImportantForAccessibility(4);
        bVar.addView(frameLayout);
        this.f4651d.addView(bVar);
        return true;
    }

    @Override // io.flutter.plugin.platform.j
    public final void d() {
        this.f4654n.f4616a = null;
    }

    @Override // io.flutter.plugin.platform.j
    public final void f(io.flutter.view.k kVar) {
        this.f4654n.f4616a = kVar;
    }

    @Override // io.flutter.plugin.platform.j
    public final boolean m(int i4) {
        return false;
    }

    @Override // io.flutter.plugin.platform.j
    public final FrameLayout s(int i4) {
        g gVar = (g) this.f4655o.get(i4);
        if (gVar == null) {
            return null;
        }
        return ((y2.k) gVar).f6916c;
    }
}
