package z0;

import D2.AbstractActivityC0029d;
import D2.M;
import D2.N;
import I.C0053n;
import O.AbstractComponentCallbacksC0109u;
import O.DialogInterfaceOnCancelListenerC0106q;
import O.J;
import O2.r;
import Q3.x0;
import X.L;
import X.t;
import X.u;
import android.app.Application;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.Signature;
import android.content.res.Configuration;
import android.os.HandlerThread;
import android.os.SystemClock;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.window.BackEvent;
import androidx.lifecycle.v;
import com.google.android.gms.common.api.internal.C;
import com.google.android.gms.common.api.internal.ComponentCallbacks2C0255c;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.internal.p002firebaseauthapi.zzg;
import com.google.android.gms.tasks.OnFailureListener;
import d.C0321a;
import java.security.GeneralSecurityException;
import java.security.Provider;
import java.security.Security;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import u1.C0690c;
import y0.C0747k;

/* JADX INFO: renamed from: z0.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0779j implements M, O2.m, v, d.b, T3.d, L, e1.i, k.L, OnFailureListener {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static C0779j f6967c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6968a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f6969b;

    public /* synthetic */ C0779j(int i4) {
        this.f6968a = i4;
    }

    public static HashMap o(BackEvent backEvent) {
        HashMap map = new HashMap(3);
        float touchX = backEvent.getTouchX();
        float touchY = backEvent.getTouchY();
        map.put("touchOffset", (Float.isNaN(touchX) || Float.isNaN(touchY)) ? null : Arrays.asList(Float.valueOf(touchX), Float.valueOf(touchY)));
        map.put("progress", Float.valueOf(backEvent.getProgress()));
        map.put("swipeEdge", Integer.valueOf(backEvent.getSwipeEdge()));
        return map;
    }

    public static C0779j r(Context context) {
        F.g(context);
        synchronized (C0779j.class) {
            if (f6967c == null) {
                BinderC0782m binderC0782m = q.f6980a;
                synchronized (q.class) {
                    if (q.f6982c == null) {
                        q.f6982c = context.getApplicationContext();
                    } else {
                        Log.w("GoogleCertificates", "GoogleCertificates has been initialized already");
                    }
                }
                f6967c = new C0779j(context);
            }
        }
        return f6967c;
    }

    public static boolean t(int i4) {
        return (48 <= i4 && i4 <= 57) || i4 == 35 || i4 == 42;
    }

    public static final AbstractBinderC0783n u(PackageInfo packageInfo, AbstractBinderC0783n... abstractBinderC0783nArr) {
        Signature[] signatureArr = packageInfo.signatures;
        if (signatureArr != null) {
            if (signatureArr.length != 1) {
                Log.w("GoogleSignatureVerifier", "Package has more than one signature.");
                return null;
            }
            BinderC0784o binderC0784o = new BinderC0784o(packageInfo.signatures[0].toByteArray());
            for (int i4 = 0; i4 < abstractBinderC0783nArr.length; i4++) {
                if (abstractBinderC0783nArr[i4].equals(binderC0784o)) {
                    return abstractBinderC0783nArr[i4];
                }
            }
        }
        return null;
    }

    public static final boolean v(PackageInfo packageInfo, boolean z4) {
        if (z4 && packageInfo != null && ("com.android.vending".equals(packageInfo.packageName) || "com.google.android.gms".equals(packageInfo.packageName))) {
            ApplicationInfo applicationInfo = packageInfo.applicationInfo;
            z4 = (applicationInfo == null || (applicationInfo.flags & 129) == 0) ? false : true;
        }
        if (packageInfo != null && packageInfo.signatures != null) {
            if ((z4 ? u(packageInfo, AbstractC0785p.f6979a) : u(packageInfo, AbstractC0785p.f6979a[0])) != null) {
                return true;
            }
        }
        return false;
    }

    @Override // k.L
    public void a(j.j jVar, j.k kVar) {
        j.g gVar = (j.g) this.f6969b;
        gVar.f5061f.removeCallbacksAndMessages(null);
        ArrayList arrayList = gVar.f5063n;
        int size = arrayList.size();
        int i4 = 0;
        while (true) {
            if (i4 >= size) {
                i4 = -1;
                break;
            } else if (jVar == ((j.f) arrayList.get(i4)).f5050b) {
                break;
            } else {
                i4++;
            }
        }
        if (i4 == -1) {
            return;
        }
        int i5 = i4 + 1;
        gVar.f5061f.postAtTime(new j.e(this, i5 < arrayList.size() ? (j.f) arrayList.get(i5) : null, kVar, jVar), jVar, SystemClock.uptimeMillis() + 200);
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r7v4, types: [A3.j, I3.p] */
    @Override // T3.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object b(T3.e r7, y3.InterfaceC0762c r8) throws java.lang.Throwable {
        /*
            r6 = this;
            boolean r0 = r8 instanceof T3.a
            if (r0 == 0) goto L13
            r0 = r8
            T3.a r0 = (T3.a) r0
            int r1 = r0.f2019d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f2019d = r1
            goto L18
        L13:
            T3.a r0 = new T3.a
            r0.<init>(r6, r8)
        L18:
            java.lang.Object r8 = r0.f2017b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f2019d
            w3.i r3 = w3.i.f6729a
            r4 = 1
            if (r2 == 0) goto L35
            if (r2 != r4) goto L2d
            U3.l r7 = r0.f2016a
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Throwable -> L2b
            goto L55
        L2b:
            r8 = move-exception
            goto L5f
        L2d:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L35:
            e1.AbstractC0367g.M(r8)
            U3.l r8 = new U3.l
            y3.h r2 = r0.getContext()
            r8.<init>(r7, r2)
            r0.f2016a = r8     // Catch: java.lang.Throwable -> L5d
            r0.f2019d = r4     // Catch: java.lang.Throwable -> L5d
            java.lang.Object r7 = r6.f6969b     // Catch: java.lang.Throwable -> L5d
            A3.j r7 = (A3.j) r7     // Catch: java.lang.Throwable -> L5d
            java.lang.Object r7 = r7.invoke(r8, r0)     // Catch: java.lang.Throwable -> L5d
            if (r7 != r1) goto L50
            goto L51
        L50:
            r7 = r3
        L51:
            if (r7 != r1) goto L54
            return r1
        L54:
            r7 = r8
        L55:
            r7.releaseIntercepted()
            return r3
        L59:
            r5 = r8
            r8 = r7
            r7 = r5
            goto L5f
        L5d:
            r7 = move-exception
            goto L59
        L5f:
            r7.releaseIntercepted()
            throw r8
        */
        throw new UnsupportedOperationException("Method not decompiled: z0.C0779j.b(T3.e, y3.c):java.lang.Object");
    }

    @Override // D2.M
    public void c() {
        N n4 = (N) this.f6969b;
        io.flutter.embedding.engine.renderer.j jVar = n4.f174b;
        if (jVar != null) {
            jVar.a(n4.f176d);
        }
    }

    @Override // e1.i
    public Object e(String str) throws GeneralSecurityException {
        String[] strArr = {"GmsCore_OpenSSL", "AndroidOpenSSL", "Conscrypt"};
        ArrayList arrayList = new ArrayList();
        for (int i4 = 0; i4 < 3; i4++) {
            Provider provider = Security.getProvider(strArr[i4]);
            if (provider != null) {
                arrayList.add(provider);
            }
        }
        Iterator it = arrayList.iterator();
        Exception exc = null;
        while (it.hasNext()) {
            try {
                return ((X.N) this.f6969b).g(str, (Provider) it.next());
            } catch (Exception e) {
                if (exc == null) {
                    exc = e;
                }
            }
        }
        throw new GeneralSecurityException("No good Provider found.", exc);
    }

    @Override // X.L
    public View f(int i4) {
        return ((t) this.f6969b).o(i4);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Removed duplicated region for block: B:78:0x0133  */
    /* JADX WARN: Removed duplicated region for block: B:9:0x002b  */
    @Override // O2.m
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void g(D2.v r41, N2.j r42) {
        /*
            Method dump skipped, instruction units count: 1238
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: z0.C0779j.g(D2.v, N2.j):void");
    }

    @Override // X.L
    public int h() {
        t tVar = (t) this.f6969b;
        return tVar.f2375f - tVar.t();
    }

    @Override // X.L
    public int i() {
        return ((t) this.f6969b).s();
    }

    @Override // X.L
    public int j(View view) {
        u uVar = (u) view.getLayoutParams();
        ((t) this.f6969b).getClass();
        return view.getRight() + ((u) view.getLayoutParams()).f2377a.right + ((ViewGroup.MarginLayoutParams) uVar).rightMargin;
    }

    @Override // d.b
    public void k(Object obj) {
        C0321a c0321a = (C0321a) obj;
        O.N n4 = (O.N) this.f6969b;
        J j4 = (J) n4.f1227E.pollLast();
        if (j4 == null) {
            Log.w("FragmentManager", "No Activities were started for result for " + this);
            return;
        }
        C0053n c0053n = n4.f1239c;
        String str = j4.f1218a;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uI = c0053n.i(str);
        if (abstractComponentCallbacksC0109uI != null) {
            abstractComponentCallbacksC0109uI.u(j4.f1219b, c0321a.f3875a, c0321a.f3876b);
        } else {
            Log.w("FragmentManager", "Activity result delivered for unknown Fragment " + str);
        }
    }

    @Override // k.L
    public void l(j.j jVar, j.k kVar) {
        ((j.g) this.f6969b).f5061f.removeCallbacksAndMessages(jVar);
    }

    @Override // androidx.lifecycle.v
    public void m(Object obj) {
        if (((androidx.lifecycle.n) obj) != null) {
            DialogInterfaceOnCancelListenerC0106q dialogInterfaceOnCancelListenerC0106q = (DialogInterfaceOnCancelListenerC0106q) this.f6969b;
            if (dialogInterfaceOnCancelListenerC0106q.f1366d0) {
                dialogInterfaceOnCancelListenerC0106q.getClass();
                throw new IllegalStateException("Fragment " + dialogInterfaceOnCancelListenerC0106q + " did not return a View from onCreateView() or this was called before onCreateView().");
            }
        }
    }

    @Override // D2.M
    public void n() {
        N n4 = (N) this.f6969b;
        n4.f173a.setAlpha(0.0f);
        io.flutter.embedding.engine.renderer.j jVar = n4.f174b;
        if (jVar != null) {
            jVar.g(n4.f176d);
        }
        n4.f174b = null;
    }

    @Override // com.google.android.gms.tasks.OnFailureListener
    public void onFailure(Exception exc) {
        if (exc instanceof g1.i) {
            C0.a aVar = k1.h.e;
            aVar.e("Failure to refresh token; scheduling refresh after failure", new Object[0]);
            k1.h hVar = (k1.h) ((x0) this.f6969b).f1670c;
            int i4 = (int) hVar.f5531b;
            hVar.f5531b = (i4 == 30 || i4 == 60 || i4 == 120 || i4 == 240 || i4 == 480) ? 2 * hVar.f5531b : i4 != 960 ? 30L : 960L;
            hVar.f5530a = (hVar.f5531b * 1000) + System.currentTimeMillis();
            aVar.e("Scheduling refresh for " + hVar.f5530a, new Object[0]);
            hVar.f5532c.postDelayed(hVar.f5533d, hVar.f5531b * 1000);
        }
    }

    @Override // X.L
    public int p(View view) {
        u uVar = (u) view.getLayoutParams();
        ((t) this.f6969b).getClass();
        return (view.getLeft() - ((u) view.getLayoutParams()).f2377a.left) - ((ViewGroup.MarginLayoutParams) uVar).leftMargin;
    }

    @Override // D2.M
    public void q(io.flutter.embedding.engine.renderer.j jVar) {
        N n4 = (N) this.f6969b;
        io.flutter.embedding.engine.renderer.j jVar2 = n4.f174b;
        if (jVar2 != null) {
            jVar2.g(n4.f176d);
        }
        n4.f174b = jVar;
    }

    public String s(String str, String str2) {
        P2.a aVar = (P2.a) this.f6969b;
        Context contextCreateConfigurationContext = aVar.f1491b;
        AbstractActivityC0029d abstractActivityC0029d = aVar.f1491b;
        if (str2 != null) {
            Locale localeA = P2.a.a(str2);
            Configuration configuration = new Configuration(abstractActivityC0029d.getResources().getConfiguration());
            configuration.setLocale(localeA);
            contextCreateConfigurationContext = abstractActivityC0029d.createConfigurationContext(configuration);
        }
        int identifier = contextCreateConfigurationContext.getResources().getIdentifier(str, "string", abstractActivityC0029d.getPackageName());
        if (identifier != 0) {
            return contextCreateConfigurationContext.getResources().getString(identifier);
        }
        return null;
    }

    public String toString() {
        switch (this.f6968a) {
            case 20:
                return "<" + ((String) this.f6969b) + '>';
            default:
                return super.toString();
        }
    }

    public /* synthetic */ C0779j(Object obj, int i4) {
        this.f6968a = i4;
        this.f6969b = obj;
    }

    public C0779j(Context context) {
        this.f6968a = 0;
        this.f6969b = context.getApplicationContext();
    }

    public C0779j() {
        this.f6968a = 5;
        this.f6969b = new AtomicInteger(0);
    }

    public C0779j(boolean z4) {
        this.f6968a = 6;
        this.f6969b = new AtomicBoolean(z4);
    }

    public C0779j(F2.b bVar, int i4) {
        this.f6968a = i4;
        switch (i4) {
            case 9:
                new C0747k(bVar, "flutter/mousecursor", r.f1458a, 11).Y(new C0690c(this, 9));
                break;
            case 13:
                new C0747k(bVar, "flutter/spellcheck", r.f1458a, 11).Y(new C0690c(this, 13));
                break;
            default:
                p1.d dVar = new p1.d(10);
                C0747k c0747k = new C0747k(bVar, "flutter/backgesture", r.f1458a, 11);
                this.f6969b = c0747k;
                c0747k.Y(dVar);
                break;
        }
    }

    public C0779j(O2.f fVar) {
        this.f6968a = 8;
        new C0747k(fVar, "flutter/keyboard", r.f1458a, 11).Y(new D2.v(this));
    }

    public C0779j(g1.f fVar) {
        this.f6968a = 29;
        fVar.a();
        k1.h hVar = new k1.h();
        k1.h.e.e("Initializing TokenRefresher", new Object[0]);
        HandlerThread handlerThread = new HandlerThread("TokenRefresher", 10);
        handlerThread.start();
        hVar.f5532c = new zzg(handlerThread.getLooper());
        fVar.a();
        hVar.f5533d = new x0(hVar, fVar.f4308b);
        this.f6969b = hVar;
        ComponentCallbacks2C0255c.b((Application) fVar.f4307a.getApplicationContext());
        ComponentCallbacks2C0255c.e.a(new C(this, 1));
    }

    /* JADX WARN: Multi-variable type inference failed */
    public C0779j(I3.p pVar) {
        this.f6968a = 19;
        this.f6969b = (A3.j) pVar;
    }
}
