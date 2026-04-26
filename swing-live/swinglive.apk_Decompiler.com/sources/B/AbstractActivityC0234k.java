package b;

import O.AbstractActivityC0114z;
import O.C0110v;
import O.C0112x;
import O.F;
import android.annotation.SuppressLint;
import android.app.Application;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Trace;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import androidx.lifecycle.B;
import androidx.lifecycle.C;
import androidx.lifecycle.G;
import androidx.lifecycle.H;
import androidx.lifecycle.I;
import androidx.lifecycle.InterfaceC0218d;
import androidx.lifecycle.z;
import c.C0248a;
import com.swing.live.R;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;
import q.x;
import y0.C0747k;
import z.InterfaceC0769a;

/* JADX INFO: renamed from: b.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractActivityC0234k extends q.i implements I, InterfaceC0218d, Y.g, v, r.i {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0248a f3229b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0747k f3230c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final androidx.lifecycle.p f3231d;
    public final Y.f e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public H f3232f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public u f3233m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final ExecutorC0233j f3234n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final Y.f f3235o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final C0229f f3236p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final CopyOnWriteArrayList f3237q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final CopyOnWriteArrayList f3238r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final CopyOnWriteArrayList f3239s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final CopyOnWriteArrayList f3240t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final CopyOnWriteArrayList f3241u;
    public boolean v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f3242w;

    public AbstractActivityC0234k() {
        C0248a c0248a = new C0248a();
        this.f3229b = c0248a;
        AbstractActivityC0114z abstractActivityC0114z = (AbstractActivityC0114z) this;
        this.f3230c = new C0747k(new F1.a(abstractActivityC0114z, 13));
        androidx.lifecycle.p pVar = new androidx.lifecycle.p(this);
        this.f3231d = pVar;
        Y.f fVar = new Y.f(this);
        this.e = fVar;
        this.f3233m = null;
        ExecutorC0233j executorC0233j = new ExecutorC0233j(abstractActivityC0114z);
        this.f3234n = executorC0233j;
        this.f3235o = new Y.f(executorC0233j, new C0227d(abstractActivityC0114z, 0));
        new AtomicInteger();
        this.f3236p = new C0229f(abstractActivityC0114z);
        this.f3237q = new CopyOnWriteArrayList();
        this.f3238r = new CopyOnWriteArrayList();
        this.f3239s = new CopyOnWriteArrayList();
        this.f3240t = new CopyOnWriteArrayList();
        this.f3241u = new CopyOnWriteArrayList();
        this.v = false;
        this.f3242w = false;
        pVar.a(new C0230g(abstractActivityC0114z, 0));
        pVar.a(new C0230g(abstractActivityC0114z, 1));
        pVar.a(new C0230g(abstractActivityC0114z, 2));
        fVar.b();
        C.a(this);
        ((Y.e) fVar.f2464c).b("android:support:activity-result", new C0110v(abstractActivityC0114z, 1));
        C0112x c0112x = new C0112x(abstractActivityC0114z, 1);
        if (c0248a.f3295b != null) {
            c0112x.a();
        }
        c0248a.f3294a.add(c0112x);
    }

    @Override // androidx.lifecycle.InterfaceC0218d
    public final Q.c a() {
        Q.c cVar = new Q.c();
        Application application = getApplication();
        LinkedHashMap linkedHashMap = (LinkedHashMap) cVar.f1509a;
        if (application != null) {
            linkedHashMap.put(G.f3060a, getApplication());
        }
        linkedHashMap.put(C.f3050a, this);
        linkedHashMap.put(C.f3051b, this);
        if (getIntent() != null && getIntent().getExtras() != null) {
            linkedHashMap.put(C.f3052c, getIntent().getExtras());
        }
        return cVar;
    }

    @Override // android.app.Activity
    public final void addContentView(View view, ViewGroup.LayoutParams layoutParams) {
        h();
        this.f3234n.a(getWindow().getDecorView());
        super.addContentView(view, layoutParams);
    }

    @Override // b.v
    public final u b() {
        if (this.f3233m == null) {
            this.f3233m = new u(new F.b(this, 8));
            this.f3231d.a(new Y.a(this, 3));
        }
        return this.f3233m;
    }

    @Override // Y.g
    public final Y.e c() {
        return (Y.e) this.e.f2464c;
    }

    @Override // r.i
    public final void d(InterfaceC0769a interfaceC0769a) {
        this.f3237q.add(interfaceC0769a);
    }

    @Override // r.i
    public final void e(InterfaceC0769a interfaceC0769a) {
        this.f3237q.remove(interfaceC0769a);
    }

    @Override // androidx.lifecycle.I
    public final H g() {
        if (getApplication() == null) {
            throw new IllegalStateException("Your activity is not yet attached to the Application instance. You can't request ViewModel before onCreate call.");
        }
        if (this.f3232f == null) {
            C0232i c0232i = (C0232i) getLastNonConfigurationInstance();
            if (c0232i != null) {
                this.f3232f = c0232i.f3224a;
            }
            if (this.f3232f == null) {
                this.f3232f = new H();
            }
        }
        return this.f3232f;
    }

    public final void h() {
        View decorView = getWindow().getDecorView();
        J3.i.e(decorView, "<this>");
        decorView.setTag(R.id.view_tree_lifecycle_owner, this);
        View decorView2 = getWindow().getDecorView();
        J3.i.e(decorView2, "<this>");
        decorView2.setTag(R.id.view_tree_view_model_store_owner, this);
        View decorView3 = getWindow().getDecorView();
        J3.i.e(decorView3, "<this>");
        decorView3.setTag(R.id.view_tree_saved_state_registry_owner, this);
        View decorView4 = getWindow().getDecorView();
        J3.i.e(decorView4, "<this>");
        decorView4.setTag(R.id.view_tree_on_back_pressed_dispatcher_owner, this);
        View decorView5 = getWindow().getDecorView();
        J3.i.e(decorView5, "<this>");
        decorView5.setTag(R.id.report_drawn, this);
    }

    @Override // androidx.lifecycle.n
    public final androidx.lifecycle.p i() {
        return this.f3231d;
    }

    @Override // android.app.Activity
    public void onActivityResult(int i4, int i5, Intent intent) {
        if (this.f3236p.a(i4, i5, intent)) {
            return;
        }
        super.onActivityResult(i4, i5, intent);
    }

    @Override // android.app.Activity
    public final void onBackPressed() {
        b().a();
    }

    @Override // android.app.Activity, android.content.ComponentCallbacks
    public final void onConfigurationChanged(Configuration configuration) {
        super.onConfigurationChanged(configuration);
        Iterator it = this.f3237q.iterator();
        while (it.hasNext()) {
            ((InterfaceC0769a) it.next()).accept(configuration);
        }
    }

    @Override // q.i, android.app.Activity
    public void onCreate(Bundle bundle) {
        this.e.c(bundle);
        C0248a c0248a = this.f3229b;
        c0248a.getClass();
        c0248a.f3295b = this;
        Iterator it = c0248a.f3294a.iterator();
        while (it.hasNext()) {
            ((C0112x) it.next()).a();
        }
        super.onCreate(bundle);
        int i4 = B.f3048b;
        z.b(this);
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public final boolean onCreatePanelMenu(int i4, Menu menu) {
        if (i4 != 0) {
            return true;
        }
        super.onCreatePanelMenu(i4, menu);
        getMenuInflater();
        Iterator it = ((CopyOnWriteArrayList) this.f3230c.f6832c).iterator();
        while (it.hasNext()) {
            ((F) it.next()).f1213a.k();
        }
        return true;
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public boolean onMenuItemSelected(int i4, MenuItem menuItem) {
        if (super.onMenuItemSelected(i4, menuItem)) {
            return true;
        }
        if (i4 != 0) {
            return false;
        }
        Iterator it = ((CopyOnWriteArrayList) this.f3230c.f6832c).iterator();
        while (it.hasNext()) {
            if (((F) it.next()).f1213a.p()) {
                return true;
            }
        }
        return false;
    }

    @Override // android.app.Activity
    public final void onMultiWindowModeChanged(boolean z4) {
        if (this.v) {
            return;
        }
        Iterator it = this.f3240t.iterator();
        while (it.hasNext()) {
            ((InterfaceC0769a) it.next()).accept(new q.k(z4));
        }
    }

    @Override // android.app.Activity
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Iterator it = this.f3239s.iterator();
        while (it.hasNext()) {
            ((InterfaceC0769a) it.next()).accept(intent);
        }
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public final void onPanelClosed(int i4, Menu menu) {
        Iterator it = ((CopyOnWriteArrayList) this.f3230c.f6832c).iterator();
        while (it.hasNext()) {
            ((F) it.next()).f1213a.q();
        }
        super.onPanelClosed(i4, menu);
    }

    @Override // android.app.Activity
    public final void onPictureInPictureModeChanged(boolean z4) {
        if (this.f3242w) {
            return;
        }
        Iterator it = this.f3241u.iterator();
        while (it.hasNext()) {
            ((InterfaceC0769a) it.next()).accept(new x(z4));
        }
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public final boolean onPreparePanel(int i4, View view, Menu menu) {
        if (i4 != 0) {
            return true;
        }
        super.onPreparePanel(i4, view, menu);
        Iterator it = ((CopyOnWriteArrayList) this.f3230c.f6832c).iterator();
        while (it.hasNext()) {
            ((F) it.next()).f1213a.t();
        }
        return true;
    }

    @Override // android.app.Activity
    public void onRequestPermissionsResult(int i4, String[] strArr, int[] iArr) {
        if (this.f3236p.a(i4, -1, new Intent().putExtra("androidx.activity.result.contract.extra.PERMISSIONS", strArr).putExtra("androidx.activity.result.contract.extra.PERMISSION_GRANT_RESULTS", iArr))) {
            return;
        }
        super.onRequestPermissionsResult(i4, strArr, iArr);
    }

    @Override // android.app.Activity
    public final Object onRetainNonConfigurationInstance() {
        C0232i c0232i;
        H h4 = this.f3232f;
        if (h4 == null && (c0232i = (C0232i) getLastNonConfigurationInstance()) != null) {
            h4 = c0232i.f3224a;
        }
        if (h4 == null) {
            return null;
        }
        C0232i c0232i2 = new C0232i();
        c0232i2.f3224a = h4;
        return c0232i2;
    }

    @Override // q.i, android.app.Activity
    public void onSaveInstanceState(Bundle bundle) {
        androidx.lifecycle.p pVar = this.f3231d;
        if (pVar != null) {
            pVar.g();
        }
        super.onSaveInstanceState(bundle);
        this.e.d(bundle);
    }

    @Override // android.app.Activity, android.content.ComponentCallbacks2
    public final void onTrimMemory(int i4) {
        super.onTrimMemory(i4);
        Iterator it = this.f3238r.iterator();
        while (it.hasNext()) {
            ((InterfaceC0769a) it.next()).accept(Integer.valueOf(i4));
        }
    }

    @Override // android.app.Activity
    public final void reportFullyDrawn() {
        try {
            if (H0.a.J()) {
                Trace.beginSection(H0.a.h0("reportFullyDrawn() for ComponentActivity"));
            }
            super.reportFullyDrawn();
            Y.f fVar = this.f3235o;
            synchronized (fVar.f2463b) {
                try {
                    fVar.f2462a = true;
                    Iterator it = ((ArrayList) fVar.f2464c).iterator();
                    while (it.hasNext()) {
                        ((I3.a) it.next()).a();
                    }
                    ((ArrayList) fVar.f2464c).clear();
                } finally {
                }
            }
            Trace.endSection();
        } catch (Throwable th) {
            Trace.endSection();
            throw th;
        }
    }

    @Override // android.app.Activity
    public final void setContentView(int i4) {
        h();
        this.f3234n.a(getWindow().getDecorView());
        super.setContentView(i4);
    }

    @Override // android.app.Activity
    public final void onMultiWindowModeChanged(boolean z4, Configuration configuration) {
        this.v = true;
        try {
            super.onMultiWindowModeChanged(z4, configuration);
            this.v = false;
            for (InterfaceC0769a interfaceC0769a : this.f3240t) {
                J3.i.e(configuration, "newConfig");
                interfaceC0769a.accept(new q.k(z4));
            }
        } catch (Throwable th) {
            this.v = false;
            throw th;
        }
    }

    @Override // android.app.Activity
    public final void onPictureInPictureModeChanged(boolean z4, Configuration configuration) {
        this.f3242w = true;
        try {
            super.onPictureInPictureModeChanged(z4, configuration);
            this.f3242w = false;
            for (InterfaceC0769a interfaceC0769a : this.f3241u) {
                J3.i.e(configuration, "newConfig");
                interfaceC0769a.accept(new x(z4));
            }
        } catch (Throwable th) {
            this.f3242w = false;
            throw th;
        }
    }

    @Override // android.app.Activity
    public void setContentView(@SuppressLint({"UnknownNullness", "MissingNullability"}) View view) {
        h();
        this.f3234n.a(getWindow().getDecorView());
        super.setContentView(view);
    }

    @Override // android.app.Activity
    public final void setContentView(View view, ViewGroup.LayoutParams layoutParams) {
        h();
        this.f3234n.a(getWindow().getDecorView());
        super.setContentView(view, layoutParams);
    }
}
