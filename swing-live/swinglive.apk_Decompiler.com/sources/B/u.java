package b;

import O.AbstractComponentCallbacksC0109u;
import O.C0090a;
import O.C0102m;
import O.E;
import O.N;
import O.V;
import O.Y;
import O.Z;
import android.os.Build;
import android.util.Log;
import android.window.OnBackInvokedCallback;
import android.window.OnBackInvokedDispatcher;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.ListIterator;
import x3.AbstractC0728h;
import x3.C0725e;

/* JADX INFO: loaded from: classes.dex */
public final class u {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Runnable f3263a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0725e f3264b = new C0725e();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public E f3265c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final OnBackInvokedCallback f3266d;
    public OnBackInvokedDispatcher e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f3267f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f3268g;

    public u(Runnable runnable) {
        this.f3263a = runnable;
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 33) {
            this.f3266d = i4 >= 34 ? C0240q.f3255a.a(new C0236m(this, 0), new C0236m(this, 1), new C0237n(this, 0), new C0237n(this, 1)) : C0238o.f3250a.a(new C0237n(this, 2));
        }
    }

    public final void a() {
        Object objPrevious;
        E e = this.f3265c;
        if (e == null) {
            C0725e c0725e = this.f3264b;
            c0725e.getClass();
            ListIterator listIterator = c0725e.listIterator(c0725e.f6781c);
            while (true) {
                if (listIterator.hasPrevious()) {
                    objPrevious = listIterator.previous();
                    if (((E) objPrevious).f1209a) {
                        break;
                    }
                } else {
                    objPrevious = null;
                    break;
                }
            }
            e = (E) objPrevious;
        }
        this.f3265c = null;
        if (e == null) {
            this.f3263a.run();
            return;
        }
        boolean zJ = N.J(3);
        N n4 = e.f1212d;
        if (zJ) {
            Log.d("FragmentManager", "handleOnBackPressed. PREDICTIVE_BACK = true fragment manager " + n4);
        }
        n4.z(true);
        C0090a c0090a = n4.f1243h;
        E e4 = n4.f1244i;
        if (c0090a == null) {
            if (e4.f1209a) {
                if (N.J(3)) {
                    Log.d("FragmentManager", "Calling popBackStackImmediate via onBackPressed callback");
                }
                n4.Q();
                return;
            } else {
                if (N.J(3)) {
                    Log.d("FragmentManager", "Calling onBackPressed via onBackPressed callback");
                }
                n4.f1242g.a();
                return;
            }
        }
        ArrayList arrayList = n4.f1248m;
        if (!arrayList.isEmpty()) {
            LinkedHashSet linkedHashSet = new LinkedHashSet(N.E(n4.f1243h));
            Iterator it = arrayList.iterator();
            while (it.hasNext()) {
                if (it.next() != null) {
                    throw new ClassCastException();
                }
                Iterator it2 = linkedHashSet.iterator();
                if (it2.hasNext()) {
                    throw null;
                }
            }
        }
        Iterator it3 = n4.f1243h.f1304a.iterator();
        while (it3.hasNext()) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = ((V) it3.next()).f1292b;
            if (abstractComponentCallbacksC0109u != null) {
                abstractComponentCallbacksC0109u.f1419s = false;
            }
        }
        for (C0102m c0102m : n4.f(new ArrayList(Collections.singletonList(n4.f1243h)), 0, 1)) {
            c0102m.getClass();
            if (N.J(3)) {
                Log.d("FragmentManager", "SpecialEffectsController: Completing Back ");
            }
            ArrayList arrayList2 = c0102m.f1355c;
            c0102m.f(arrayList2);
            c0102m.getClass();
            J3.i.e(arrayList2, "operations");
            ArrayList arrayList3 = new ArrayList();
            Iterator it4 = arrayList2.iterator();
            while (it4.hasNext()) {
                ((Z) it4.next()).getClass();
                x3.n.W(arrayList3, null);
            }
            List listI0 = AbstractC0728h.i0(AbstractC0728h.m0(arrayList3));
            int size = listI0.size();
            for (int i4 = 0; i4 < size; i4++) {
                ((Y) listI0.get(i4)).a(c0102m.f1353a);
            }
            int size2 = arrayList2.size();
            for (int i5 = 0; i5 < size2; i5++) {
                c0102m.a((Z) arrayList2.get(i5));
            }
            List listI02 = AbstractC0728h.i0(arrayList2);
            if (listI02.size() > 0) {
                ((Z) listI02.get(0)).getClass();
                throw null;
            }
        }
        n4.f1243h = null;
        n4.e0();
        if (N.J(3)) {
            Log.d("FragmentManager", "Op is being set to null");
            Log.d("FragmentManager", "OnBackPressedCallback enabled=" + e4.f1209a + " for  FragmentManager " + n4);
        }
    }

    public final void b(boolean z4) {
        OnBackInvokedDispatcher onBackInvokedDispatcher = this.e;
        OnBackInvokedCallback onBackInvokedCallback = this.f3266d;
        if (onBackInvokedDispatcher == null || onBackInvokedCallback == null) {
            return;
        }
        C0238o c0238o = C0238o.f3250a;
        if (z4 && !this.f3267f) {
            c0238o.b(onBackInvokedDispatcher, 0, onBackInvokedCallback);
            this.f3267f = true;
        } else {
            if (z4 || !this.f3267f) {
                return;
            }
            c0238o.c(onBackInvokedDispatcher, onBackInvokedCallback);
            this.f3267f = false;
        }
    }

    public final void c() {
        boolean z4 = this.f3268g;
        boolean z5 = false;
        C0725e c0725e = this.f3264b;
        if (c0725e == null || !c0725e.isEmpty()) {
            Iterator<E> it = c0725e.iterator();
            while (true) {
                if (!it.hasNext()) {
                    break;
                } else if (((E) it.next()).f1209a) {
                    z5 = true;
                    break;
                }
            }
        }
        this.f3268g = z5;
        if (z5 == z4 || Build.VERSION.SDK_INT < 33) {
            return;
        }
        b(z5);
    }
}
