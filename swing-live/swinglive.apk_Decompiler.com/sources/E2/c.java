package E2;

import D2.AbstractActivityC0029d;
import D2.v;
import N2.m;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import com.google.android.gms.common.internal.r;
import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.plugin.platform.p;
import io.flutter.plugin.platform.q;
import java.util.HashMap;
import java.util.HashSet;
import m3.InterfaceC0555b;
import u1.C0690c;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class c implements InterfaceC0555b {

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public static long f339y = 1;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public static final HashMap f340z = new HashMap();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FlutterJNI f341a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final io.flutter.embedding.engine.renderer.j f342b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final F2.b f343c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final d f344d;
    public final P2.a e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0747k f345f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final N2.b f346g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final C0779j f347h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final B.k f348i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final C0779j f349j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final N2.k f350k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final v f351l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0690c f352m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final B.k f353n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final m f354o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final C0779j f355p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final B.k f356q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final v f357r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final q f358s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final p f359t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final r f360u;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final long f361w;
    public final HashSet v = new HashSet();

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final a f362x = new a(this);

    public c(AbstractActivityC0029d abstractActivityC0029d, FlutterJNI flutterJNI, q qVar, boolean z4, boolean z5) throws Exception {
        AssetManager assets;
        long j4 = f339y;
        f339y = 1 + j4;
        this.f361w = j4;
        f340z.put(Long.valueOf(j4), this);
        try {
            assets = abstractActivityC0029d.createPackageContext(abstractActivityC0029d.getPackageName(), 0).getAssets();
        } catch (PackageManager.NameNotFoundException unused) {
            assets = abstractActivityC0029d.getAssets();
        }
        C0747k c0747kN = C0747k.N();
        if (flutterJNI == null) {
            Object obj = c0747kN.f6832c;
            flutterJNI = new FlutterJNI();
        }
        this.f341a = flutterJNI;
        F2.b bVar = new F2.b(flutterJNI, assets, this.f361w);
        this.f343c = bVar;
        flutterJNI.setPlatformMessageHandler(bVar.f446d);
        C0747k.N().getClass();
        this.f345f = new C0747k(bVar, flutterJNI);
        new p1.d(bVar);
        this.f346g = new N2.b(bVar);
        v vVar = new v(bVar, 4);
        this.f347h = new C0779j(bVar, 9);
        this.f348i = new B.k(bVar, 8);
        this.f349j = new C0779j(bVar, 7);
        this.f351l = new v(bVar, 5);
        v vVar2 = new v(bVar, abstractActivityC0029d.getPackageManager());
        this.f350k = new N2.k(bVar, z5);
        this.f352m = new C0690c(bVar);
        this.f353n = new B.k(bVar, 11);
        m mVar = new m(bVar);
        this.f354o = mVar;
        this.f355p = new C0779j(bVar, 13);
        this.f356q = new B.k(bVar, 12);
        this.f357r = new v(bVar, 10);
        P2.a aVar = new P2.a(abstractActivityC0029d, vVar);
        this.e = aVar;
        I2.e eVar = (I2.e) c0747kN.f6831b;
        if (!flutterJNI.isAttached()) {
            eVar.c(abstractActivityC0029d.getApplicationContext());
            eVar.a(abstractActivityC0029d, null);
        }
        p pVar = new p();
        pVar.f4648a = qVar.f4666a;
        pVar.e = flutterJNI;
        qVar.e = flutterJNI;
        flutterJNI.addEngineLifecycleListener(this.f362x);
        flutterJNI.setPlatformViewsController(qVar);
        flutterJNI.setPlatformViewsController2(pVar);
        flutterJNI.setLocalizationPlugin(aVar);
        c0747kN.getClass();
        flutterJNI.setDeferredComponentManager(null);
        flutterJNI.setSettingsChannel(mVar);
        if (!flutterJNI.isAttached()) {
            flutterJNI.attachToNative();
            if (!flutterJNI.isAttached()) {
                throw new RuntimeException("FlutterEngine failed to attach to its native Object reference.");
            }
        }
        this.f342b = new io.flutter.embedding.engine.renderer.j(flutterJNI);
        this.f358s = qVar;
        this.f359t = pVar;
        r rVar = new r(7, false);
        rVar.f3597b = qVar;
        rVar.f3598c = pVar;
        this.f360u = rVar;
        d dVar = new d(abstractActivityC0029d.getApplicationContext(), this);
        this.f344d = dVar;
        aVar.b(abstractActivityC0029d.getResources().getConfiguration());
        if (z4 && eVar.f764d.e) {
            H0.a.Z(this);
        }
        e1.k.c(abstractActivityC0029d, this);
        dVar.a(new R2.a(vVar2));
    }
}
