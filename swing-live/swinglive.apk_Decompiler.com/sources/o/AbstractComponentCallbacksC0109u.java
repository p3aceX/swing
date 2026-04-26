package O;

import a.AbstractC0184a;
import android.app.Application;
import android.content.ComponentCallbacks;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.Log;
import android.util.SparseArray;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.lifecycle.EnumC0222h;
import androidx.lifecycle.InterfaceC0218d;
import b.C0229f;
import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;
import y0.C0747k;

/* JADX INFO: renamed from: O.u, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractComponentCallbacksC0109u implements ComponentCallbacks, View.OnCreateContextMenuListener, androidx.lifecycle.n, androidx.lifecycle.I, InterfaceC0218d, Y.g {

    /* JADX INFO: renamed from: X, reason: collision with root package name */
    public static final Object f1385X = new Object();

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public AbstractComponentCallbacksC0109u f1387B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public int f1388C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public int f1389D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public String f1390E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public boolean f1391F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public boolean f1392G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public boolean f1393H;
    public boolean J;

    /* JADX INFO: renamed from: K, reason: collision with root package name */
    public ViewGroup f1395K;

    /* JADX INFO: renamed from: L, reason: collision with root package name */
    public boolean f1396L;

    /* JADX INFO: renamed from: N, reason: collision with root package name */
    public C0108t f1398N;

    /* JADX INFO: renamed from: O, reason: collision with root package name */
    public boolean f1399O;

    /* JADX INFO: renamed from: P, reason: collision with root package name */
    public boolean f1400P;

    /* JADX INFO: renamed from: Q, reason: collision with root package name */
    public String f1401Q;

    /* JADX INFO: renamed from: R, reason: collision with root package name */
    public EnumC0222h f1402R;

    /* JADX INFO: renamed from: S, reason: collision with root package name */
    public androidx.lifecycle.p f1403S;

    /* JADX INFO: renamed from: T, reason: collision with root package name */
    public final androidx.lifecycle.u f1404T;

    /* JADX INFO: renamed from: U, reason: collision with root package name */
    public Y.f f1405U;

    /* JADX INFO: renamed from: V, reason: collision with root package name */
    public final ArrayList f1406V;

    /* JADX INFO: renamed from: W, reason: collision with root package name */
    public final r f1407W;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Bundle f1409b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public SparseArray f1410c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Bundle f1411d;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Bundle f1412f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public AbstractComponentCallbacksC0109u f1413m;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f1415o;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public boolean f1417q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public boolean f1418r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public boolean f1419s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f1420t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f1421u;
    public boolean v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f1422w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public int f1423x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public N f1424y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public C0113y f1425z;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f1408a = -1;
    public String e = UUID.randomUUID().toString();

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public String f1414n = null;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public Boolean f1416p = null;

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public N f1386A = new N();

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public final boolean f1394I = true;

    /* JADX INFO: renamed from: M, reason: collision with root package name */
    public boolean f1397M = true;

    public AbstractComponentCallbacksC0109u() {
        new F.b(this, 2);
        this.f1402R = EnumC0222h.e;
        this.f1404T = new androidx.lifecycle.u();
        new AtomicInteger();
        this.f1406V = new ArrayList();
        this.f1407W = new r(this);
        p();
    }

    public LayoutInflater A(Bundle bundle) {
        C0113y c0113y = this.f1425z;
        if (c0113y == null) {
            throw new IllegalStateException("onGetLayoutInflater() cannot be executed until the Fragment is attached to the FragmentManager.");
        }
        AbstractActivityC0114z abstractActivityC0114z = c0113y.f1435f;
        LayoutInflater layoutInflaterCloneInContext = abstractActivityC0114z.getLayoutInflater().cloneInContext(abstractActivityC0114z);
        layoutInflaterCloneInContext.setFactory2(this.f1386A.f1241f);
        return layoutInflaterCloneInContext;
    }

    public void B() {
        this.J = true;
    }

    public abstract void C(Bundle bundle);

    public abstract void D();

    public abstract void E();

    public void F(LayoutInflater layoutInflater, ViewGroup viewGroup, Bundle bundle) {
        this.f1386A.P();
        this.f1422w = true;
        g();
    }

    public final Context G() {
        C0113y c0113y = this.f1425z;
        AbstractActivityC0114z abstractActivityC0114z = c0113y == null ? null : c0113y.f1433c;
        if (abstractActivityC0114z != null) {
            return abstractActivityC0114z;
        }
        throw new IllegalStateException("Fragment " + this + " not attached to a context.");
    }

    public final void H(int i4, int i5, int i6, int i7) {
        if (this.f1398N == null && i4 == 0 && i5 == 0 && i6 == 0 && i7 == 0) {
            return;
        }
        l().f1377b = i4;
        l().f1378c = i5;
        l().f1379d = i6;
        l().e = i7;
    }

    @Override // androidx.lifecycle.InterfaceC0218d
    public final Q.c a() {
        Application application;
        Context applicationContext = G().getApplicationContext();
        while (true) {
            if (!(applicationContext instanceof ContextWrapper)) {
                application = null;
                break;
            }
            if (applicationContext instanceof Application) {
                application = (Application) applicationContext;
                break;
            }
            applicationContext = ((ContextWrapper) applicationContext).getBaseContext();
        }
        if (application == null && N.J(3)) {
            Log.d("FragmentManager", "Could not find Application instance from Context " + G().getApplicationContext() + ", you will not be able to use AndroidViewModel with the default ViewModelProvider.Factory");
        }
        Q.c cVar = new Q.c();
        LinkedHashMap linkedHashMap = (LinkedHashMap) cVar.f1509a;
        if (application != null) {
            linkedHashMap.put(androidx.lifecycle.G.f3060a, application);
        }
        linkedHashMap.put(androidx.lifecycle.C.f3050a, this);
        linkedHashMap.put(androidx.lifecycle.C.f3051b, this);
        Bundle bundle = this.f1412f;
        if (bundle != null) {
            linkedHashMap.put(androidx.lifecycle.C.f3052c, bundle);
        }
        return cVar;
    }

    @Override // Y.g
    public final Y.e c() {
        return (Y.e) this.f1405U.f2464c;
    }

    public final void f(int i4, Intent intent) throws Exception {
        if (this.f1425z == null) {
            throw new IllegalStateException("Fragment " + this + " not attached to Activity");
        }
        N nO = o();
        if (nO.f1224B == null) {
            C0113y c0113y = nO.v;
            c0113y.getClass();
            J3.i.e(intent, "intent");
            if (i4 != -1) {
                throw new IllegalStateException("Starting activity with a requestCode requires a FragmentActivity host");
            }
            r.h.startActivity(c0113y.f1433c, intent, null);
            return;
        }
        String str = this.e;
        J j4 = new J();
        j4.f1218a = str;
        j4.f1219b = i4;
        nO.f1227E.addLast(j4);
        C0747k c0747k = nO.f1224B;
        C0229f c0229f = (C0229f) c0747k.f6833d;
        HashMap map = c0229f.f3216b;
        String str2 = (String) c0747k.f6831b;
        Integer num = (Integer) map.get(str2);
        H0.a aVar = (H0.a) c0747k.f6832c;
        if (num != null) {
            c0229f.f3218d.add(str2);
            try {
                c0229f.b(num.intValue(), aVar, intent);
                return;
            } catch (Exception e) {
                c0229f.f3218d.remove(str2);
                throw e;
            }
        }
        throw new IllegalStateException("Attempting to launch an unregistered ActivityResultLauncher with contract " + aVar + " and input " + intent + ". You must ensure the ActivityResultLauncher is registered before calling launch().");
    }

    @Override // androidx.lifecycle.I
    public final androidx.lifecycle.H g() {
        if (this.f1424y == null) {
            throw new IllegalStateException("Can't access ViewModels from detached fragment");
        }
        if (n() == 1) {
            throw new IllegalStateException("Calling getViewModelStore() before a Fragment reaches onCreate() when using setMaxLifecycle(INITIALIZED) is not supported");
        }
        HashMap map = this.f1424y.f1235N.e;
        androidx.lifecycle.H h4 = (androidx.lifecycle.H) map.get(this.e);
        if (h4 != null) {
            return h4;
        }
        androidx.lifecycle.H h5 = new androidx.lifecycle.H();
        map.put(this.e, h5);
        return h5;
    }

    @Override // androidx.lifecycle.n
    public final androidx.lifecycle.p i() {
        return this.f1403S;
    }

    public AbstractC0184a j() {
        return new C0107s(this);
    }

    public void k(String str, FileDescriptor fileDescriptor, PrintWriter printWriter, String[] strArr) {
        String str2;
        printWriter.print(str);
        printWriter.print("mFragmentId=#");
        printWriter.print(Integer.toHexString(this.f1388C));
        printWriter.print(" mContainerId=#");
        printWriter.print(Integer.toHexString(this.f1389D));
        printWriter.print(" mTag=");
        printWriter.println(this.f1390E);
        printWriter.print(str);
        printWriter.print("mState=");
        printWriter.print(this.f1408a);
        printWriter.print(" mWho=");
        printWriter.print(this.e);
        printWriter.print(" mBackStackNesting=");
        printWriter.println(this.f1423x);
        printWriter.print(str);
        printWriter.print("mAdded=");
        printWriter.print(this.f1417q);
        printWriter.print(" mRemoving=");
        printWriter.print(this.f1418r);
        printWriter.print(" mFromLayout=");
        printWriter.print(this.f1420t);
        printWriter.print(" mInLayout=");
        printWriter.println(this.f1421u);
        printWriter.print(str);
        printWriter.print("mHidden=");
        printWriter.print(this.f1391F);
        printWriter.print(" mDetached=");
        printWriter.print(this.f1392G);
        printWriter.print(" mMenuVisible=");
        printWriter.print(this.f1394I);
        printWriter.print(" mHasMenu=");
        printWriter.println(false);
        printWriter.print(str);
        printWriter.print("mRetainInstance=");
        printWriter.print(this.f1393H);
        printWriter.print(" mUserVisibleHint=");
        printWriter.println(this.f1397M);
        if (this.f1424y != null) {
            printWriter.print(str);
            printWriter.print("mFragmentManager=");
            printWriter.println(this.f1424y);
        }
        if (this.f1425z != null) {
            printWriter.print(str);
            printWriter.print("mHost=");
            printWriter.println(this.f1425z);
        }
        if (this.f1387B != null) {
            printWriter.print(str);
            printWriter.print("mParentFragment=");
            printWriter.println(this.f1387B);
        }
        if (this.f1412f != null) {
            printWriter.print(str);
            printWriter.print("mArguments=");
            printWriter.println(this.f1412f);
        }
        if (this.f1409b != null) {
            printWriter.print(str);
            printWriter.print("mSavedFragmentState=");
            printWriter.println(this.f1409b);
        }
        if (this.f1410c != null) {
            printWriter.print(str);
            printWriter.print("mSavedViewState=");
            printWriter.println(this.f1410c);
        }
        if (this.f1411d != null) {
            printWriter.print(str);
            printWriter.print("mSavedViewRegistryState=");
            printWriter.println(this.f1411d);
        }
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uH = this.f1413m;
        if (abstractComponentCallbacksC0109uH == null) {
            N n4 = this.f1424y;
            abstractComponentCallbacksC0109uH = (n4 == null || (str2 = this.f1414n) == null) ? null : n4.f1239c.h(str2);
        }
        if (abstractComponentCallbacksC0109uH != null) {
            printWriter.print(str);
            printWriter.print("mTarget=");
            printWriter.print(abstractComponentCallbacksC0109uH);
            printWriter.print(" mTargetRequestCode=");
            printWriter.println(this.f1415o);
        }
        printWriter.print(str);
        printWriter.print("mPopDirection=");
        C0108t c0108t = this.f1398N;
        printWriter.println(c0108t == null ? false : c0108t.f1376a);
        C0108t c0108t2 = this.f1398N;
        if ((c0108t2 == null ? 0 : c0108t2.f1377b) != 0) {
            printWriter.print(str);
            printWriter.print("getEnterAnim=");
            C0108t c0108t3 = this.f1398N;
            printWriter.println(c0108t3 == null ? 0 : c0108t3.f1377b);
        }
        C0108t c0108t4 = this.f1398N;
        if ((c0108t4 == null ? 0 : c0108t4.f1378c) != 0) {
            printWriter.print(str);
            printWriter.print("getExitAnim=");
            C0108t c0108t5 = this.f1398N;
            printWriter.println(c0108t5 == null ? 0 : c0108t5.f1378c);
        }
        C0108t c0108t6 = this.f1398N;
        if ((c0108t6 == null ? 0 : c0108t6.f1379d) != 0) {
            printWriter.print(str);
            printWriter.print("getPopEnterAnim=");
            C0108t c0108t7 = this.f1398N;
            printWriter.println(c0108t7 == null ? 0 : c0108t7.f1379d);
        }
        C0108t c0108t8 = this.f1398N;
        if ((c0108t8 == null ? 0 : c0108t8.e) != 0) {
            printWriter.print(str);
            printWriter.print("getPopExitAnim=");
            C0108t c0108t9 = this.f1398N;
            printWriter.println(c0108t9 != null ? c0108t9.e : 0);
        }
        if (this.f1395K != null) {
            printWriter.print(str);
            printWriter.print("mContainer=");
            printWriter.println(this.f1395K);
        }
        C0113y c0113y = this.f1425z;
        if ((c0113y != null ? c0113y.f1433c : null) != null) {
            new D2.v(this, g()).y(str, printWriter);
        }
        printWriter.print(str);
        printWriter.println("Child " + this.f1386A + ":");
        this.f1386A.v(com.google.crypto.tink.shaded.protobuf.S.f(str, "  "), fileDescriptor, printWriter, strArr);
    }

    public final C0108t l() {
        if (this.f1398N == null) {
            C0108t c0108t = new C0108t();
            Object obj = f1385X;
            c0108t.f1381g = obj;
            c0108t.f1382h = obj;
            c0108t.f1383i = obj;
            c0108t.f1384j = null;
            this.f1398N = c0108t;
        }
        return this.f1398N;
    }

    public final N m() {
        if (this.f1425z != null) {
            return this.f1386A;
        }
        throw new IllegalStateException("Fragment " + this + " has not been attached yet.");
    }

    public final int n() {
        EnumC0222h enumC0222h = this.f1402R;
        return (enumC0222h == EnumC0222h.f3068b || this.f1387B == null) ? enumC0222h.ordinal() : Math.min(enumC0222h.ordinal(), this.f1387B.n());
    }

    public final N o() {
        N n4 = this.f1424y;
        if (n4 != null) {
            return n4;
        }
        throw new IllegalStateException("Fragment " + this + " not associated with a fragment manager.");
    }

    @Override // android.content.ComponentCallbacks
    public final void onConfigurationChanged(Configuration configuration) {
        this.J = true;
    }

    @Override // android.view.View.OnCreateContextMenuListener
    public final void onCreateContextMenu(ContextMenu contextMenu, View view, ContextMenu.ContextMenuInfo contextMenuInfo) {
        C0113y c0113y = this.f1425z;
        AbstractActivityC0114z abstractActivityC0114z = c0113y == null ? null : c0113y.f1432b;
        if (abstractActivityC0114z != null) {
            abstractActivityC0114z.onCreateContextMenu(contextMenu, view, contextMenuInfo);
            return;
        }
        throw new IllegalStateException("Fragment " + this + " not attached to an activity.");
    }

    @Override // android.content.ComponentCallbacks
    public final void onLowMemory() {
        this.J = true;
    }

    public final void p() {
        this.f1403S = new androidx.lifecycle.p(this);
        this.f1405U = new Y.f(this);
        ArrayList arrayList = this.f1406V;
        r rVar = this.f1407W;
        if (arrayList.contains(rVar)) {
            return;
        }
        if (this.f1408a < 0) {
            arrayList.add(rVar);
            return;
        }
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = rVar.f1374a;
        abstractComponentCallbacksC0109u.f1405U.b();
        androidx.lifecycle.C.a(abstractComponentCallbacksC0109u);
        Bundle bundle = abstractComponentCallbacksC0109u.f1409b;
        abstractComponentCallbacksC0109u.f1405U.c(bundle != null ? bundle.getBundle("registryState") : null);
    }

    public final void q() {
        p();
        this.f1401Q = this.e;
        this.e = UUID.randomUUID().toString();
        this.f1417q = false;
        this.f1418r = false;
        this.f1420t = false;
        this.f1421u = false;
        this.v = false;
        this.f1423x = 0;
        this.f1424y = null;
        this.f1386A = new N();
        this.f1425z = null;
        this.f1388C = 0;
        this.f1389D = 0;
        this.f1390E = null;
        this.f1391F = false;
        this.f1392G = false;
    }

    public final boolean r() {
        if (this.f1391F) {
            return true;
        }
        N n4 = this.f1424y;
        if (n4 != null) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1387B;
            n4.getClass();
            if (abstractComponentCallbacksC0109u == null ? false : abstractComponentCallbacksC0109u.r()) {
                return true;
            }
        }
        return false;
    }

    public final boolean s() {
        return this.f1423x > 0;
    }

    public void t() {
        this.J = true;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder(128);
        sb.append(getClass().getSimpleName());
        sb.append("{");
        sb.append(Integer.toHexString(System.identityHashCode(this)));
        sb.append("} (");
        sb.append(this.e);
        if (this.f1388C != 0) {
            sb.append(" id=0x");
            sb.append(Integer.toHexString(this.f1388C));
        }
        if (this.f1390E != null) {
            sb.append(" tag=");
            sb.append(this.f1390E);
        }
        sb.append(")");
        return sb.toString();
    }

    public void u(int i4, int i5, Intent intent) {
        if (N.J(2)) {
            Log.v("FragmentManager", "Fragment " + this + " received the following in onActivityResult(): requestCode: " + i4 + " resultCode: " + i5 + " data: " + intent);
        }
    }

    public void v(AbstractActivityC0114z abstractActivityC0114z) {
        this.J = true;
        C0113y c0113y = this.f1425z;
        if ((c0113y == null ? null : c0113y.f1432b) != null) {
            this.J = true;
        }
    }

    public abstract void w(Bundle bundle);

    public void x() {
        this.J = true;
    }

    public void y() {
        this.J = true;
    }

    public void z() {
        this.J = true;
    }
}
