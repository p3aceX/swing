package O;

import I.C0053n;
import android.content.res.Resources;
import android.os.BadParcelableException;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import androidx.lifecycle.EnumC0221g;
import androidx.lifecycle.EnumC0222h;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class U {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final D2.v f1287a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0053n f1288b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AbstractComponentCallbacksC0109u f1289c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f1290d = false;
    public int e = -1;

    public U(D2.v vVar, C0053n c0053n, AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        this.f1287a = vVar;
        this.f1288b = c0053n;
        this.f1289c = abstractComponentCallbacksC0109u;
    }

    public final void a() {
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "moveto ACTIVITY_CREATED: " + abstractComponentCallbacksC0109u);
        }
        Bundle bundle = abstractComponentCallbacksC0109u.f1409b;
        if (bundle != null) {
            bundle.getBundle("savedInstanceState");
        }
        abstractComponentCallbacksC0109u.f1386A.P();
        abstractComponentCallbacksC0109u.f1408a = 3;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.t();
        if (!abstractComponentCallbacksC0109u.J) {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onActivityCreated()");
        }
        if (N.J(3)) {
            Log.d("FragmentManager", "moveto RESTORE_VIEW_STATE: " + abstractComponentCallbacksC0109u);
        }
        abstractComponentCallbacksC0109u.f1409b = null;
        N n4 = abstractComponentCallbacksC0109u.f1386A;
        n4.f1229G = false;
        n4.f1230H = false;
        n4.f1235N.f1273h = false;
        n4.u(4);
        this.f1287a.l(abstractComponentCallbacksC0109u, false);
    }

    public final void b() {
        U u4;
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "moveto ATTACHED: " + abstractComponentCallbacksC0109u);
        }
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = abstractComponentCallbacksC0109u.f1413m;
        C0053n c0053n = this.f1288b;
        if (abstractComponentCallbacksC0109u2 != null) {
            u4 = (U) ((HashMap) c0053n.f707c).get(abstractComponentCallbacksC0109u2.e);
            if (u4 == null) {
                throw new IllegalStateException("Fragment " + abstractComponentCallbacksC0109u + " declared target fragment " + abstractComponentCallbacksC0109u.f1413m + " that does not belong to this FragmentManager!");
            }
            abstractComponentCallbacksC0109u.f1414n = abstractComponentCallbacksC0109u.f1413m.e;
            abstractComponentCallbacksC0109u.f1413m = null;
        } else {
            String str = abstractComponentCallbacksC0109u.f1414n;
            if (str != null) {
                u4 = (U) ((HashMap) c0053n.f707c).get(str);
                if (u4 == null) {
                    StringBuilder sb = new StringBuilder("Fragment ");
                    sb.append(abstractComponentCallbacksC0109u);
                    sb.append(" declared target fragment ");
                    throw new IllegalStateException(com.google.crypto.tink.shaded.protobuf.S.h(sb, abstractComponentCallbacksC0109u.f1414n, " that does not belong to this FragmentManager!"));
                }
            } else {
                u4 = null;
            }
        }
        if (u4 != null) {
            u4.j();
        }
        N n4 = abstractComponentCallbacksC0109u.f1424y;
        abstractComponentCallbacksC0109u.f1425z = n4.v;
        abstractComponentCallbacksC0109u.f1387B = n4.f1258x;
        D2.v vVar = this.f1287a;
        vVar.r(abstractComponentCallbacksC0109u, false);
        ArrayList arrayList = abstractComponentCallbacksC0109u.f1406V;
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u3 = ((r) it.next()).f1374a;
            abstractComponentCallbacksC0109u3.f1405U.b();
            androidx.lifecycle.C.a(abstractComponentCallbacksC0109u3);
            Bundle bundle = abstractComponentCallbacksC0109u3.f1409b;
            abstractComponentCallbacksC0109u3.f1405U.c(bundle != null ? bundle.getBundle("registryState") : null);
        }
        arrayList.clear();
        abstractComponentCallbacksC0109u.f1386A.b(abstractComponentCallbacksC0109u.f1425z, abstractComponentCallbacksC0109u.j(), abstractComponentCallbacksC0109u);
        abstractComponentCallbacksC0109u.f1408a = 0;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.v(abstractComponentCallbacksC0109u.f1425z.f1433c);
        if (!abstractComponentCallbacksC0109u.J) {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onAttach()");
        }
        Iterator it2 = abstractComponentCallbacksC0109u.f1424y.f1250o.iterator();
        while (it2.hasNext()) {
            ((S) it2.next()).a();
        }
        N n5 = abstractComponentCallbacksC0109u.f1386A;
        n5.f1229G = false;
        n5.f1230H = false;
        n5.f1235N.f1273h = false;
        n5.u(0);
        vVar.m(abstractComponentCallbacksC0109u, false);
    }

    public final int c() {
        Object obj;
        Object next;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (abstractComponentCallbacksC0109u.f1424y == null) {
            return abstractComponentCallbacksC0109u.f1408a;
        }
        int iMin = this.e;
        int iOrdinal = abstractComponentCallbacksC0109u.f1402R.ordinal();
        if (iOrdinal == 1) {
            iMin = Math.min(iMin, 0);
        } else if (iOrdinal == 2) {
            iMin = Math.min(iMin, 1);
        } else if (iOrdinal == 3) {
            iMin = Math.min(iMin, 5);
        } else if (iOrdinal != 4) {
            iMin = Math.min(iMin, -1);
        }
        if (abstractComponentCallbacksC0109u.f1420t) {
            iMin = abstractComponentCallbacksC0109u.f1421u ? Math.max(this.e, 2) : this.e < 4 ? Math.min(iMin, abstractComponentCallbacksC0109u.f1408a) : Math.min(iMin, 1);
        }
        if (!abstractComponentCallbacksC0109u.f1417q) {
            iMin = Math.min(iMin, 1);
        }
        ViewGroup viewGroup = abstractComponentCallbacksC0109u.f1395K;
        if (viewGroup != null) {
            C0102m c0102mE = C0102m.e(viewGroup, abstractComponentCallbacksC0109u.o());
            c0102mE.getClass();
            Iterator it = c0102mE.f1354b.iterator();
            while (true) {
                obj = null;
                if (!it.hasNext()) {
                    next = null;
                    break;
                }
                next = it.next();
                ((Z) next).getClass();
                if (J3.i.a(null, abstractComponentCallbacksC0109u)) {
                    break;
                }
            }
            Iterator it2 = c0102mE.f1355c.iterator();
            while (true) {
                if (!it2.hasNext()) {
                    break;
                }
                Object next2 = it2.next();
                ((Z) next2).getClass();
                if (J3.i.a(null, abstractComponentCallbacksC0109u)) {
                    obj = next2;
                    break;
                }
            }
        }
        if (abstractComponentCallbacksC0109u.f1418r) {
            iMin = abstractComponentCallbacksC0109u.s() ? Math.min(iMin, 1) : Math.min(iMin, -1);
        }
        if (abstractComponentCallbacksC0109u.f1396L && abstractComponentCallbacksC0109u.f1408a < 5) {
            iMin = Math.min(iMin, 4);
        }
        if (abstractComponentCallbacksC0109u.f1419s && abstractComponentCallbacksC0109u.f1395K != null) {
            iMin = Math.max(iMin, 3);
        }
        if (N.J(2)) {
            Log.v("FragmentManager", "computeExpectedState() of " + iMin + " for " + abstractComponentCallbacksC0109u);
        }
        return iMin;
    }

    public final void d() {
        Bundle bundle;
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "moveto CREATED: " + abstractComponentCallbacksC0109u);
        }
        Bundle bundle2 = abstractComponentCallbacksC0109u.f1409b;
        Bundle bundle3 = bundle2 != null ? bundle2.getBundle("savedInstanceState") : null;
        if (abstractComponentCallbacksC0109u.f1400P) {
            abstractComponentCallbacksC0109u.f1408a = 1;
            Bundle bundle4 = abstractComponentCallbacksC0109u.f1409b;
            if (bundle4 == null || (bundle = bundle4.getBundle("childFragmentManager")) == null) {
                return;
            }
            abstractComponentCallbacksC0109u.f1386A.U(bundle);
            N n4 = abstractComponentCallbacksC0109u.f1386A;
            n4.f1229G = false;
            n4.f1230H = false;
            n4.f1235N.f1273h = false;
            n4.u(1);
            return;
        }
        D2.v vVar = this.f1287a;
        vVar.s(abstractComponentCallbacksC0109u, false);
        abstractComponentCallbacksC0109u.f1386A.P();
        abstractComponentCallbacksC0109u.f1408a = 1;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.f1403S.a(new Y.a(abstractComponentCallbacksC0109u, 1));
        abstractComponentCallbacksC0109u.w(bundle3);
        abstractComponentCallbacksC0109u.f1400P = true;
        if (abstractComponentCallbacksC0109u.J) {
            abstractComponentCallbacksC0109u.f1403S.e(EnumC0221g.ON_CREATE);
            vVar.n(abstractComponentCallbacksC0109u, false);
        } else {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onCreate()");
        }
    }

    public final void e() {
        String resourceName;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (abstractComponentCallbacksC0109u.f1420t) {
            return;
        }
        if (N.J(3)) {
            Log.d("FragmentManager", "moveto CREATE_VIEW: " + abstractComponentCallbacksC0109u);
        }
        Bundle bundle = abstractComponentCallbacksC0109u.f1409b;
        ViewGroup viewGroup = null;
        Bundle bundle2 = bundle != null ? bundle.getBundle("savedInstanceState") : null;
        LayoutInflater layoutInflaterA = abstractComponentCallbacksC0109u.A(bundle2);
        ViewGroup viewGroup2 = abstractComponentCallbacksC0109u.f1395K;
        if (viewGroup2 != null) {
            viewGroup = viewGroup2;
        } else {
            int i4 = abstractComponentCallbacksC0109u.f1389D;
            if (i4 != 0) {
                if (i4 == -1) {
                    throw new IllegalArgumentException("Cannot create fragment " + abstractComponentCallbacksC0109u + " for a container view with no id");
                }
                viewGroup = (ViewGroup) abstractComponentCallbacksC0109u.f1424y.f1257w.Q(i4);
                if (viewGroup == null) {
                    if (!abstractComponentCallbacksC0109u.v) {
                        try {
                            resourceName = abstractComponentCallbacksC0109u.G().getResources().getResourceName(abstractComponentCallbacksC0109u.f1389D);
                        } catch (Resources.NotFoundException unused) {
                            resourceName = "unknown";
                        }
                        throw new IllegalArgumentException("No view found for id 0x" + Integer.toHexString(abstractComponentCallbacksC0109u.f1389D) + " (" + resourceName + ") for fragment " + abstractComponentCallbacksC0109u);
                    }
                } else if (!(viewGroup instanceof B)) {
                    P.c cVar = P.d.f1475a;
                    P.d.b(new P.a(abstractComponentCallbacksC0109u, "Attempting to add fragment " + abstractComponentCallbacksC0109u + " to container " + viewGroup + " which is not a FragmentContainerView"));
                    P.d.a(abstractComponentCallbacksC0109u).getClass();
                }
            }
        }
        abstractComponentCallbacksC0109u.f1395K = viewGroup;
        abstractComponentCallbacksC0109u.F(layoutInflaterA, viewGroup, bundle2);
        abstractComponentCallbacksC0109u.f1408a = 2;
    }

    public final void f() {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uH;
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "movefrom CREATED: " + abstractComponentCallbacksC0109u);
        }
        boolean zIsChangingConfigurations = true;
        boolean z4 = abstractComponentCallbacksC0109u.f1418r && !abstractComponentCallbacksC0109u.s();
        C0053n c0053n = this.f1288b;
        if (z4) {
            c0053n.z(abstractComponentCallbacksC0109u.e, null);
        }
        if (!z4) {
            Q q4 = (Q) c0053n.e;
            if (!((q4.f1269c.containsKey(abstractComponentCallbacksC0109u.e) && q4.f1271f) ? q4.f1272g : true)) {
                String str = abstractComponentCallbacksC0109u.f1414n;
                if (str != null && (abstractComponentCallbacksC0109uH = c0053n.h(str)) != null && abstractComponentCallbacksC0109uH.f1393H) {
                    abstractComponentCallbacksC0109u.f1413m = abstractComponentCallbacksC0109uH;
                }
                abstractComponentCallbacksC0109u.f1408a = 0;
                return;
            }
        }
        C0113y c0113y = abstractComponentCallbacksC0109u.f1425z;
        if (c0113y != null) {
            zIsChangingConfigurations = ((Q) c0053n.e).f1272g;
        } else {
            AbstractActivityC0114z abstractActivityC0114z = c0113y.f1433c;
            if (abstractActivityC0114z != null) {
                zIsChangingConfigurations = true ^ abstractActivityC0114z.isChangingConfigurations();
            }
        }
        if (z4 || zIsChangingConfigurations) {
            ((Q) c0053n.e).b(abstractComponentCallbacksC0109u, false);
        }
        abstractComponentCallbacksC0109u.f1386A.l();
        abstractComponentCallbacksC0109u.f1403S.e(EnumC0221g.ON_DESTROY);
        abstractComponentCallbacksC0109u.f1408a = 0;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.f1400P = false;
        abstractComponentCallbacksC0109u.x();
        if (!abstractComponentCallbacksC0109u.J) {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onDestroy()");
        }
        this.f1287a.o(abstractComponentCallbacksC0109u, false);
        for (U u4 : c0053n.j()) {
            if (u4 != null) {
                String str2 = abstractComponentCallbacksC0109u.e;
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = u4.f1289c;
                if (str2.equals(abstractComponentCallbacksC0109u2.f1414n)) {
                    abstractComponentCallbacksC0109u2.f1413m = abstractComponentCallbacksC0109u;
                    abstractComponentCallbacksC0109u2.f1414n = null;
                }
            }
        }
        String str3 = abstractComponentCallbacksC0109u.f1414n;
        if (str3 != null) {
            abstractComponentCallbacksC0109u.f1413m = c0053n.h(str3);
        }
        c0053n.q(this);
    }

    public final void g() {
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "movefrom CREATE_VIEW: " + abstractComponentCallbacksC0109u);
        }
        ViewGroup viewGroup = abstractComponentCallbacksC0109u.f1395K;
        abstractComponentCallbacksC0109u.f1386A.u(1);
        abstractComponentCallbacksC0109u.f1408a = 1;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.y();
        if (!abstractComponentCallbacksC0109u.J) {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onDestroyView()");
        }
        n.l lVar = ((R.b) new D2.v(abstractComponentCallbacksC0109u, abstractComponentCallbacksC0109u.g()).f261c).f1677c;
        int i4 = lVar.f5860c;
        for (int i5 = 0; i5 < i4; i5++) {
            ((R.a) lVar.f5859b[i5]).i();
        }
        abstractComponentCallbacksC0109u.f1422w = false;
        this.f1287a.x(abstractComponentCallbacksC0109u, false);
        abstractComponentCallbacksC0109u.f1395K = null;
        abstractComponentCallbacksC0109u.f1404T.h(null);
        abstractComponentCallbacksC0109u.f1421u = false;
    }

    public final void h() {
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "movefrom ATTACHED: " + abstractComponentCallbacksC0109u);
        }
        abstractComponentCallbacksC0109u.f1408a = -1;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.z();
        if (!abstractComponentCallbacksC0109u.J) {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onDetach()");
        }
        N n4 = abstractComponentCallbacksC0109u.f1386A;
        if (!n4.f1231I) {
            n4.l();
            abstractComponentCallbacksC0109u.f1386A = new N();
        }
        this.f1287a.p(abstractComponentCallbacksC0109u, false);
        abstractComponentCallbacksC0109u.f1408a = -1;
        abstractComponentCallbacksC0109u.f1425z = null;
        abstractComponentCallbacksC0109u.f1387B = null;
        abstractComponentCallbacksC0109u.f1424y = null;
        if (!abstractComponentCallbacksC0109u.f1418r || abstractComponentCallbacksC0109u.s()) {
            Q q4 = (Q) this.f1288b.e;
            if (!((q4.f1269c.containsKey(abstractComponentCallbacksC0109u.e) && q4.f1271f) ? q4.f1272g : true)) {
                return;
            }
        }
        if (N.J(3)) {
            Log.d("FragmentManager", "initState called for fragment: " + abstractComponentCallbacksC0109u);
        }
        abstractComponentCallbacksC0109u.q();
    }

    public final void i() {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (abstractComponentCallbacksC0109u.f1420t && abstractComponentCallbacksC0109u.f1421u && !abstractComponentCallbacksC0109u.f1422w) {
            if (N.J(3)) {
                Log.d("FragmentManager", "moveto CREATE_VIEW: " + abstractComponentCallbacksC0109u);
            }
            Bundle bundle = abstractComponentCallbacksC0109u.f1409b;
            Bundle bundle2 = bundle != null ? bundle.getBundle("savedInstanceState") : null;
            abstractComponentCallbacksC0109u.F(abstractComponentCallbacksC0109u.A(bundle2), null, bundle2);
        }
    }

    public final void j() {
        C0053n c0053n = this.f1288b;
        boolean z4 = this.f1290d;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (z4) {
            if (N.J(2)) {
                Log.v("FragmentManager", "Ignoring re-entrant call to moveToExpectedState() for " + abstractComponentCallbacksC0109u);
                return;
            }
            return;
        }
        try {
            this.f1290d = true;
            boolean z5 = false;
            while (true) {
                int iC = c();
                int i4 = abstractComponentCallbacksC0109u.f1408a;
                if (iC == i4) {
                    if (!z5 && i4 == -1 && abstractComponentCallbacksC0109u.f1418r && !abstractComponentCallbacksC0109u.s()) {
                        if (N.J(3)) {
                            Log.d("FragmentManager", "Cleaning up state of never attached fragment: " + abstractComponentCallbacksC0109u);
                        }
                        ((Q) c0053n.e).b(abstractComponentCallbacksC0109u, true);
                        c0053n.q(this);
                        if (N.J(3)) {
                            Log.d("FragmentManager", "initState called for fragment: " + abstractComponentCallbacksC0109u);
                        }
                        abstractComponentCallbacksC0109u.q();
                    }
                    if (abstractComponentCallbacksC0109u.f1399O) {
                        N n4 = abstractComponentCallbacksC0109u.f1424y;
                        if (n4 != null && abstractComponentCallbacksC0109u.f1417q && N.K(abstractComponentCallbacksC0109u)) {
                            n4.f1228F = true;
                        }
                        abstractComponentCallbacksC0109u.f1399O = false;
                        abstractComponentCallbacksC0109u.f1386A.o();
                    }
                    this.f1290d = false;
                    return;
                }
                if (iC <= i4) {
                    switch (i4 - 1) {
                        case -1:
                            h();
                            break;
                        case 0:
                            f();
                            break;
                        case 1:
                            g();
                            abstractComponentCallbacksC0109u.f1408a = 1;
                            break;
                        case 2:
                            abstractComponentCallbacksC0109u.f1421u = false;
                            abstractComponentCallbacksC0109u.f1408a = 2;
                            break;
                        case 3:
                            if (N.J(3)) {
                                Log.d("FragmentManager", "movefrom ACTIVITY_CREATED: " + abstractComponentCallbacksC0109u);
                            }
                            abstractComponentCallbacksC0109u.f1408a = 3;
                            break;
                        case 4:
                            o();
                            break;
                        case 5:
                            abstractComponentCallbacksC0109u.f1408a = 5;
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            k();
                            break;
                    }
                } else {
                    switch (i4 + 1) {
                        case 0:
                            b();
                            break;
                        case 1:
                            d();
                            break;
                        case 2:
                            i();
                            e();
                            break;
                        case 3:
                            a();
                            break;
                        case 4:
                            abstractComponentCallbacksC0109u.f1408a = 4;
                            break;
                        case 5:
                            n();
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            abstractComponentCallbacksC0109u.f1408a = 6;
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            m();
                            break;
                    }
                }
                z5 = true;
            }
        } catch (Throwable th) {
            this.f1290d = false;
            throw th;
        }
    }

    public final void k() {
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "movefrom RESUMED: " + abstractComponentCallbacksC0109u);
        }
        abstractComponentCallbacksC0109u.f1386A.u(5);
        abstractComponentCallbacksC0109u.f1403S.e(EnumC0221g.ON_PAUSE);
        abstractComponentCallbacksC0109u.f1408a = 6;
        abstractComponentCallbacksC0109u.J = true;
        this.f1287a.q(abstractComponentCallbacksC0109u, false);
    }

    public final void l(ClassLoader classLoader) {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        Bundle bundle = abstractComponentCallbacksC0109u.f1409b;
        if (bundle == null) {
            return;
        }
        bundle.setClassLoader(classLoader);
        if (abstractComponentCallbacksC0109u.f1409b.getBundle("savedInstanceState") == null) {
            abstractComponentCallbacksC0109u.f1409b.putBundle("savedInstanceState", new Bundle());
        }
        try {
            abstractComponentCallbacksC0109u.f1410c = abstractComponentCallbacksC0109u.f1409b.getSparseParcelableArray("viewState");
            abstractComponentCallbacksC0109u.f1411d = abstractComponentCallbacksC0109u.f1409b.getBundle("viewRegistryState");
            T t4 = (T) abstractComponentCallbacksC0109u.f1409b.getParcelable("state");
            if (t4 != null) {
                abstractComponentCallbacksC0109u.f1414n = t4.f1284r;
                abstractComponentCallbacksC0109u.f1415o = t4.f1285s;
                abstractComponentCallbacksC0109u.f1397M = t4.f1286t;
            }
            if (abstractComponentCallbacksC0109u.f1397M) {
                return;
            }
            abstractComponentCallbacksC0109u.f1396L = true;
        } catch (BadParcelableException e) {
            throw new IllegalStateException("Failed to restore view hierarchy state for fragment " + abstractComponentCallbacksC0109u, e);
        }
    }

    public final void m() {
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "moveto RESUMED: " + abstractComponentCallbacksC0109u);
        }
        C0108t c0108t = abstractComponentCallbacksC0109u.f1398N;
        View view = c0108t == null ? null : c0108t.f1384j;
        if (view != null) {
            for (ViewParent parent = view.getParent(); parent != null; parent = parent.getParent()) {
            }
        }
        abstractComponentCallbacksC0109u.l().f1384j = null;
        abstractComponentCallbacksC0109u.f1386A.P();
        abstractComponentCallbacksC0109u.f1386A.z(true);
        abstractComponentCallbacksC0109u.f1408a = 7;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.B();
        if (!abstractComponentCallbacksC0109u.J) {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onResume()");
        }
        abstractComponentCallbacksC0109u.f1403S.e(EnumC0221g.ON_RESUME);
        N n4 = abstractComponentCallbacksC0109u.f1386A;
        n4.f1229G = false;
        n4.f1230H = false;
        n4.f1235N.f1273h = false;
        n4.u(7);
        this.f1287a.t(abstractComponentCallbacksC0109u, false);
        this.f1288b.z(abstractComponentCallbacksC0109u.e, null);
        abstractComponentCallbacksC0109u.f1409b = null;
        abstractComponentCallbacksC0109u.f1410c = null;
        abstractComponentCallbacksC0109u.f1411d = null;
    }

    public final void n() {
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "moveto STARTED: " + abstractComponentCallbacksC0109u);
        }
        abstractComponentCallbacksC0109u.f1386A.P();
        abstractComponentCallbacksC0109u.f1386A.z(true);
        abstractComponentCallbacksC0109u.f1408a = 5;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.D();
        if (!abstractComponentCallbacksC0109u.J) {
            throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onStart()");
        }
        abstractComponentCallbacksC0109u.f1403S.e(EnumC0221g.ON_START);
        N n4 = abstractComponentCallbacksC0109u.f1386A;
        n4.f1229G = false;
        n4.f1230H = false;
        n4.f1235N.f1273h = false;
        n4.u(5);
        this.f1287a.v(abstractComponentCallbacksC0109u, false);
    }

    public final void o() {
        boolean zJ = N.J(3);
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1289c;
        if (zJ) {
            Log.d("FragmentManager", "movefrom STARTED: " + abstractComponentCallbacksC0109u);
        }
        N n4 = abstractComponentCallbacksC0109u.f1386A;
        n4.f1230H = true;
        n4.f1235N.f1273h = true;
        n4.u(4);
        abstractComponentCallbacksC0109u.f1403S.e(EnumC0221g.ON_STOP);
        abstractComponentCallbacksC0109u.f1408a = 4;
        abstractComponentCallbacksC0109u.J = false;
        abstractComponentCallbacksC0109u.E();
        if (abstractComponentCallbacksC0109u.J) {
            this.f1287a.w(abstractComponentCallbacksC0109u, false);
            return;
        }
        throw new b0("Fragment " + abstractComponentCallbacksC0109u + " did not call through to super.onStop()");
    }

    public U(D2.v vVar, C0053n c0053n, ClassLoader classLoader, G g4, Bundle bundle) {
        this.f1287a = vVar;
        this.f1288b = c0053n;
        T t4 = (T) bundle.getParcelable("state");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uA = g4.a(t4.f1274a);
        abstractComponentCallbacksC0109uA.e = t4.f1275b;
        abstractComponentCallbacksC0109uA.f1420t = t4.f1276c;
        abstractComponentCallbacksC0109uA.v = true;
        abstractComponentCallbacksC0109uA.f1388C = t4.f1277d;
        abstractComponentCallbacksC0109uA.f1389D = t4.e;
        abstractComponentCallbacksC0109uA.f1390E = t4.f1278f;
        abstractComponentCallbacksC0109uA.f1393H = t4.f1279m;
        abstractComponentCallbacksC0109uA.f1418r = t4.f1280n;
        abstractComponentCallbacksC0109uA.f1392G = t4.f1281o;
        abstractComponentCallbacksC0109uA.f1391F = t4.f1282p;
        abstractComponentCallbacksC0109uA.f1402R = EnumC0222h.values()[t4.f1283q];
        abstractComponentCallbacksC0109uA.f1414n = t4.f1284r;
        abstractComponentCallbacksC0109uA.f1415o = t4.f1285s;
        abstractComponentCallbacksC0109uA.f1397M = t4.f1286t;
        this.f1289c = abstractComponentCallbacksC0109uA;
        abstractComponentCallbacksC0109uA.f1409b = bundle;
        Bundle bundle2 = bundle.getBundle("arguments");
        if (bundle2 != null) {
            bundle2.setClassLoader(classLoader);
        }
        N n4 = abstractComponentCallbacksC0109uA.f1424y;
        if (n4 != null && (n4.f1229G || n4.f1230H)) {
            throw new IllegalStateException("Fragment already added and state has been saved");
        }
        abstractComponentCallbacksC0109uA.f1412f = bundle2;
        if (N.J(2)) {
            Log.v("FragmentManager", "Instantiated fragment " + abstractComponentCallbacksC0109uA);
        }
    }

    public U(D2.v vVar, C0053n c0053n, AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, Bundle bundle) {
        this.f1287a = vVar;
        this.f1288b = c0053n;
        this.f1289c = abstractComponentCallbacksC0109u;
        abstractComponentCallbacksC0109u.f1410c = null;
        abstractComponentCallbacksC0109u.f1411d = null;
        abstractComponentCallbacksC0109u.f1423x = 0;
        abstractComponentCallbacksC0109u.f1421u = false;
        abstractComponentCallbacksC0109u.f1417q = false;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = abstractComponentCallbacksC0109u.f1413m;
        abstractComponentCallbacksC0109u.f1414n = abstractComponentCallbacksC0109u2 != null ? abstractComponentCallbacksC0109u2.e : null;
        abstractComponentCallbacksC0109u.f1413m = null;
        abstractComponentCallbacksC0109u.f1409b = bundle;
        abstractComponentCallbacksC0109u.f1412f = bundle.getBundle("arguments");
    }
}
