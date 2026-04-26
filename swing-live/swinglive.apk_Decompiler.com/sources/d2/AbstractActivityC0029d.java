package D2;

import I.C0053n;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Trace;
import android.util.Log;
import android.view.View;
import android.window.OnBackInvokedCallback;
import androidx.lifecycle.EnumC0221g;
import io.flutter.embedding.engine.FlutterJNI;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import m3.AbstractC0554a;
import y0.C0747k;

/* JADX INFO: renamed from: D2.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractActivityC0029d extends Activity implements androidx.lifecycle.n {
    public static final int e = View.generateViewId();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f185a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0032g f186b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final androidx.lifecycle.p f187c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final OnBackInvokedCallback f188d;

    public AbstractActivityC0029d() {
        int i4 = Build.VERSION.SDK_INT;
        this.f188d = i4 < 33 ? null : i4 >= 34 ? new C0028c(this) : new C0027b(this, 0);
        this.f187c = new androidx.lifecycle.p(this);
    }

    public final String a() {
        String dataString;
        if ((getApplicationInfo().flags & 2) == 0 || !"android.intent.action.RUN".equals(getIntent().getAction()) || (dataString = getIntent().getDataString()) == null) {
            return null;
        }
        return dataString;
    }

    public final int d() {
        if (!getIntent().hasExtra("background_mode")) {
            return 1;
        }
        String stringExtra = getIntent().getStringExtra("background_mode");
        if (stringExtra == null) {
            throw new NullPointerException("Name is null");
        }
        if (stringExtra.equals("opaque")) {
            return 1;
        }
        if (stringExtra.equals("transparent")) {
            return 2;
        }
        throw new IllegalArgumentException("No enum constant io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode.".concat(stringExtra));
    }

    public final String e() {
        return getIntent().getStringExtra("cached_engine_id");
    }

    public final String f() {
        if (getIntent().hasExtra("dart_entrypoint")) {
            return getIntent().getStringExtra("dart_entrypoint");
        }
        try {
            Bundle bundleH = h();
            String string = bundleH != null ? bundleH.getString("io.flutter.Entrypoint") : null;
            return string != null ? string : "main";
        } catch (PackageManager.NameNotFoundException unused) {
            return "main";
        }
    }

    public final String g() {
        if (getIntent().hasExtra("route")) {
            return getIntent().getStringExtra("route");
        }
        try {
            Bundle bundleH = h();
            if (bundleH != null) {
                return bundleH.getString("io.flutter.InitialRoute");
            }
            return null;
        } catch (PackageManager.NameNotFoundException unused) {
            return null;
        }
    }

    public final Bundle h() {
        return getPackageManager().getActivityInfo(getComponentName(), 128).metaData;
    }

    @Override // androidx.lifecycle.n
    public final androidx.lifecycle.p i() {
        return this.f187c;
    }

    public final void j(boolean z4) {
        if (z4 && !this.f185a) {
            if (Build.VERSION.SDK_INT >= 33) {
                getOnBackInvokedDispatcher().registerOnBackInvokedCallback(0, this.f188d);
                this.f185a = true;
                return;
            }
            return;
        }
        if (z4 || !this.f185a || Build.VERSION.SDK_INT < 33) {
            return;
        }
        getOnBackInvokedDispatcher().unregisterOnBackInvokedCallback(this.f188d);
        this.f185a = false;
    }

    public final boolean k() {
        boolean booleanExtra = getIntent().getBooleanExtra("destroy_engine_with_activity", false);
        return (e() != null || this.f186b.f198g) ? booleanExtra : getIntent().getBooleanExtra("destroy_engine_with_activity", true);
    }

    public final boolean l() {
        return getIntent().hasExtra("enable_state_restoration") ? getIntent().getBooleanExtra("enable_state_restoration", false) : e() == null;
    }

    public final boolean m(String str) {
        C0032g c0032g = this.f186b;
        if (c0032g == null) {
            Log.w("FlutterActivity", "FlutterActivity " + hashCode() + " " + str + " called after release.");
            return false;
        }
        if (c0032g.f201j) {
            return true;
        }
        Log.w("FlutterActivity", "FlutterActivity " + hashCode() + " " + str + " called after detach.");
        return false;
    }

    @Override // android.app.Activity
    public final void onActivityResult(int i4, int i5, Intent intent) {
        if (m("onActivityResult")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            if (c0032g.f194b == null) {
                Log.w("FlutterActivityAndFragmentDelegate", "onActivityResult() invoked before FlutterFragment was attached to an Activity.");
                return;
            }
            Objects.toString(intent);
            E2.d dVar = c0032g.f194b.f344d;
            if (!dVar.f()) {
                Log.e("FlutterEngineCxnRegstry", "Attempted to notify ActivityAware plugins of onActivityResult, but no Activity was attached.");
                return;
            }
            AbstractC0554a.b("FlutterEngineConnectionRegistry#onActivityResult");
            try {
                Y0.n nVar = dVar.f367f;
                nVar.getClass();
                Iterator it = new HashSet((HashSet) nVar.f2490c).iterator();
                while (true) {
                    boolean z4 = false;
                    while (it.hasNext()) {
                        if (((O2.o) it.next()).a(i4, i5, intent) || z4) {
                            z4 = true;
                        }
                    }
                    Trace.endSection();
                    return;
                }
            } catch (Throwable th) {
                try {
                    Trace.endSection();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
                throw th;
            }
        }
    }

    @Override // android.app.Activity
    public final void onBackPressed() {
        if (m("onBackPressed")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                ((C0747k) cVar.f348i.f104b).O("popRoute", null, null);
            } else {
                Log.w("FlutterActivityAndFragmentDelegate", "Invoked onBackPressed() before FlutterFragment was attached to an Activity.");
            }
        }
    }

    /* JADX WARN: Finally extract failed */
    /* JADX WARN: Removed duplicated region for block: B:190:0x0491  */
    /* JADX WARN: Removed duplicated region for block: B:197:0x0539  */
    /* JADX WARN: Removed duplicated region for block: B:202:0x0544  */
    /* JADX WARN: Removed duplicated region for block: B:206:0x059a A[LOOP:0: B:204:0x0592->B:206:0x059a, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:210:0x05b1 A[LOOP:1: B:208:0x05a9->B:210:0x05b1, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:214:0x05c8 A[LOOP:2: B:212:0x05c0->B:214:0x05c8, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:218:0x05e1 A[LOOP:3: B:216:0x05d9->B:218:0x05e1, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:221:0x05f7 A[LOOP:4: B:219:0x05ef->B:221:0x05f7, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:224:0x060f  */
    /* JADX WARN: Removed duplicated region for block: B:242:0x0672  */
    /* JADX WARN: Removed duplicated region for block: B:262:0x05a8 A[EDGE_INSN: B:262:0x05a8->B:207:0x05a8 BREAK  A[LOOP:0: B:204:0x0592->B:206:0x059a], SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:263:0x05bf A[EDGE_INSN: B:263:0x05bf->B:211:0x05bf BREAK  A[LOOP:1: B:208:0x05a9->B:210:0x05b1], SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:264:0x05d4 A[EDGE_INSN: B:264:0x05d4->B:215:0x05d4 BREAK  A[LOOP:2: B:212:0x05c0->B:214:0x05c8], SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:265:0x05ef A[EDGE_INSN: B:265:0x05ef->B:219:0x05ef BREAK  A[LOOP:3: B:216:0x05d9->B:218:0x05e1], SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:266:0x0603 A[EDGE_INSN: B:266:0x0603->B:222:0x0603 BREAK  A[LOOP:4: B:219:0x05ef->B:221:0x05f7], SYNTHETIC] */
    /* JADX WARN: Type inference failed for: r6v13, types: [android.view.View, io.flutter.embedding.engine.renderer.m] */
    @Override // android.app.Activity
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void onCreate(android.os.Bundle r14) {
        /*
            Method dump skipped, instruction units count: 1672
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.AbstractActivityC0029d.onCreate(android.os.Bundle):void");
    }

    @Override // android.app.Activity
    public void onDestroy() {
        super.onDestroy();
        if (m("onDestroy")) {
            this.f186b.e();
            this.f186b.f();
        }
        if (Build.VERSION.SDK_INT >= 33) {
            getOnBackInvokedDispatcher().unregisterOnBackInvokedCallback(this.f188d);
            this.f185a = false;
        }
        C0032g c0032g = this.f186b;
        if (c0032g != null) {
            c0032g.f193a = null;
            c0032g.f194b = null;
            c0032g.f195c = null;
            c0032g.f196d = null;
            c0032g.e = null;
            this.f186b = null;
        }
        this.f187c.e(EnumC0221g.ON_DESTROY);
    }

    @Override // android.app.Activity
    public final void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (m("onNewIntent")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar == null) {
                Log.w("FlutterActivityAndFragmentDelegate", "onNewIntent() invoked before FlutterFragment was attached to an Activity.");
                return;
            }
            E2.d dVar = cVar.f344d;
            if (dVar.f()) {
                AbstractC0554a.b("FlutterEngineConnectionRegistry#onNewIntent");
                try {
                    Iterator it = ((HashSet) dVar.f367f.f2491d).iterator();
                    if (it.hasNext()) {
                        if (it.next() != null) {
                            throw new ClassCastException();
                        }
                        throw null;
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
            } else {
                Log.e("FlutterEngineCxnRegstry", "Attempted to notify ActivityAware plugins of onNewIntent, but no Activity was attached.");
            }
            String strD = c0032g.d(intent);
            if (strD == null || strD.isEmpty()) {
                return;
            }
            B.k kVar = c0032g.f194b.f348i;
            kVar.getClass();
            HashMap map = new HashMap();
            map.put("location", strD);
            ((C0747k) kVar.f104b).O("pushRouteInformation", map, null);
        }
    }

    @Override // android.app.Activity
    public final void onPause() {
        super.onPause();
        if (m("onPause")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            c0032g.f193a.getClass();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                N2.b bVar = cVar.f346g;
                bVar.a(3, bVar.f1131c);
            }
        }
        this.f187c.e(EnumC0221g.ON_PAUSE);
    }

    @Override // android.app.Activity
    public final void onPostResume() {
        super.onPostResume();
        if (m("onPostResume")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            if (c0032g.f194b == null) {
                Log.w("FlutterActivityAndFragmentDelegate", "onPostResume() invoked before FlutterFragment was attached to an Activity.");
                return;
            }
            io.flutter.plugin.platform.f fVar = c0032g.f196d;
            if (fVar != null) {
                fVar.d();
            }
            c0032g.f194b.f358s.k();
        }
    }

    @Override // android.app.Activity
    public final void onRequestPermissionsResult(int i4, String[] strArr, int[] iArr) {
        if (m("onRequestPermissionsResult")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            if (c0032g.f194b == null) {
                Log.w("FlutterActivityAndFragmentDelegate", "onRequestPermissionResult() invoked before FlutterFragment was attached to an Activity.");
                return;
            }
            Arrays.toString(strArr);
            Arrays.toString(iArr);
            E2.d dVar = c0032g.f194b.f344d;
            if (!dVar.f()) {
                Log.e("FlutterEngineCxnRegstry", "Attempted to notify ActivityAware plugins of onRequestPermissionsResult, but no Activity was attached.");
                return;
            }
            AbstractC0554a.b("FlutterEngineConnectionRegistry#onRequestPermissionsResult");
            try {
                Iterator it = ((HashSet) dVar.f367f.f2489b).iterator();
                while (true) {
                    boolean z4 = false;
                    while (it.hasNext()) {
                        if (((O2.p) it.next()).b(i4, strArr, iArr) || z4) {
                            z4 = true;
                        }
                    }
                    Trace.endSection();
                    return;
                }
            } catch (Throwable th) {
                try {
                    Trace.endSection();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
                throw th;
            }
        }
    }

    @Override // android.app.Activity
    public final void onResume() {
        super.onResume();
        this.f187c.e(EnumC0221g.ON_RESUME);
        if (m("onResume")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            c0032g.f194b.f342b.i();
            c0032g.f193a.getClass();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                N2.b bVar = cVar.f346g;
                bVar.a(2, bVar.f1131c);
            }
        }
    }

    @Override // android.app.Activity
    public final void onSaveInstanceState(Bundle bundle) {
        super.onSaveInstanceState(bundle);
        if (m("onSaveInstanceState")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            if (c0032g.f193a.l()) {
                bundle.putByteArray("framework", c0032g.f194b.f350k.f1170b);
            }
            c0032g.f193a.getClass();
            Bundle bundle2 = new Bundle();
            E2.d dVar = c0032g.f194b.f344d;
            if (dVar.f()) {
                AbstractC0554a.b("FlutterEngineConnectionRegistry#onSaveInstanceState");
                try {
                    Iterator it = ((HashSet) dVar.f367f.f2492f).iterator();
                    if (it.hasNext()) {
                        if (it.next() != null) {
                            throw new ClassCastException();
                        }
                        throw null;
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
            } else {
                Log.e("FlutterEngineCxnRegstry", "Attempted to notify ActivityAware plugins of onSaveInstanceState, but no Activity was attached.");
            }
            bundle.putBundle("plugins", bundle2);
            if (c0032g.f193a.e() == null || c0032g.f193a.k()) {
                return;
            }
            bundle.putBoolean("enableOnBackInvokedCallbackState", c0032g.f193a.f185a);
        }
    }

    @Override // android.app.Activity
    public final void onStart() {
        Bundle bundleH;
        super.onStart();
        this.f187c.e(EnumC0221g.ON_START);
        if (m("onStart")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            if (c0032g.f193a.e() == null && !c0032g.f194b.f343c.f447f) {
                String strG = c0032g.f193a.g();
                if (strG == null) {
                    AbstractActivityC0029d abstractActivityC0029d = c0032g.f193a;
                    abstractActivityC0029d.getClass();
                    strG = c0032g.d(abstractActivityC0029d.getIntent());
                    if (strG == null) {
                        strG = "/";
                    }
                }
                AbstractActivityC0029d abstractActivityC0029d2 = c0032g.f193a;
                abstractActivityC0029d2.getClass();
                try {
                    bundleH = abstractActivityC0029d2.h();
                } catch (PackageManager.NameNotFoundException unused) {
                }
                String string = bundleH != null ? bundleH.getString("io.flutter.EntrypointUri") : null;
                c0032g.f193a.f();
                ((C0747k) c0032g.f194b.f348i.f104b).O("setInitialRoute", strG, null);
                String strA = c0032g.f193a.a();
                if (strA == null || strA.isEmpty()) {
                    strA = ((I2.e) C0747k.N().f6831b).f764d.f754b;
                }
                c0032g.f194b.f343c.a(string == null ? new F2.a(strA, c0032g.f193a.f()) : new F2.a(strA, string, c0032g.f193a.f()), (List) c0032g.f193a.getIntent().getSerializableExtra("dart_entrypoint_args"));
            }
            Integer num = c0032g.f202k;
            if (num != null) {
                c0032g.f195c.setVisibility(num.intValue());
            }
        }
    }

    @Override // android.app.Activity
    public final void onStop() {
        super.onStop();
        if (m("onStop")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            c0032g.f193a.getClass();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                N2.b bVar = cVar.f346g;
                bVar.a(5, bVar.f1131c);
            }
            c0032g.f202k = Integer.valueOf(c0032g.f195c.getVisibility());
            c0032g.f195c.setVisibility(8);
            E2.c cVar2 = c0032g.f194b;
            if (cVar2 != null) {
                cVar2.f342b.f(40);
            }
        }
        this.f187c.e(EnumC0221g.ON_STOP);
    }

    @Override // android.app.Activity, android.content.ComponentCallbacks2
    public final void onTrimMemory(int i4) {
        super.onTrimMemory(i4);
        if (m("onTrimMemory")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                if (c0032g.f200i && i4 >= 10) {
                    FlutterJNI flutterJNI = cVar.f343c.f443a;
                    if (flutterJNI.isAttached()) {
                        flutterJNI.notifyLowMemoryWarning();
                    }
                    B.k kVar = c0032g.f194b.f356q;
                    kVar.getClass();
                    HashMap map = new HashMap(1);
                    map.put("type", "memoryPressure");
                    ((C0053n) kVar.f104b).x(map, null);
                }
                c0032g.f194b.f342b.f(i4);
                io.flutter.plugin.platform.q qVar = c0032g.f194b.f358s;
                if (i4 < 40) {
                    qVar.getClass();
                    return;
                }
                Iterator it = qVar.f4674p.values().iterator();
                while (it.hasNext()) {
                    ((io.flutter.plugin.platform.C) it.next()).f4613h.setSurface(null);
                }
            }
        }
    }

    @Override // android.app.Activity
    public final void onUserLeaveHint() {
        if (m("onUserLeaveHint")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            E2.c cVar = c0032g.f194b;
            if (cVar == null) {
                Log.w("FlutterActivityAndFragmentDelegate", "onUserLeaveHint() invoked before FlutterFragment was attached to an Activity.");
                return;
            }
            E2.d dVar = cVar.f344d;
            if (!dVar.f()) {
                Log.e("FlutterEngineCxnRegstry", "Attempted to notify ActivityAware plugins of onUserLeaveHint, but no Activity was attached.");
                return;
            }
            AbstractC0554a.b("FlutterEngineConnectionRegistry#onUserLeaveHint");
            try {
                Iterator it = ((HashSet) dVar.f367f.e).iterator();
                if (!it.hasNext()) {
                    Trace.endSection();
                } else {
                    if (it.next() != null) {
                        throw new ClassCastException();
                    }
                    throw null;
                }
            } catch (Throwable th) {
                try {
                    Trace.endSection();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
                throw th;
            }
        }
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public final void onWindowFocusChanged(boolean z4) {
        super.onWindowFocusChanged(z4);
        if (m("onWindowFocusChanged")) {
            C0032g c0032g = this.f186b;
            c0032g.c();
            c0032g.f193a.getClass();
            E2.c cVar = c0032g.f194b;
            if (cVar != null) {
                N2.b bVar = cVar.f346g;
                if (z4) {
                    bVar.a(bVar.f1129a, true);
                } else {
                    bVar.a(bVar.f1129a, false);
                }
            }
        }
    }
}
