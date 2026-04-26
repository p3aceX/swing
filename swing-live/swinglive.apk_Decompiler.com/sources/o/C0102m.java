package O;

import android.animation.AnimatorSet;
import android.content.Context;
import android.util.Log;
import android.view.ViewGroup;
import com.swing.live.R;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.NoSuchElementException;
import x3.AbstractC0728h;
import x3.AbstractC0729i;

/* JADX INFO: renamed from: O.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0102m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ViewGroup f1353a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f1354b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ArrayList f1355c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f1356d;
    public boolean e;

    public C0102m(ViewGroup viewGroup) {
        J3.i.e(viewGroup, "container");
        this.f1353a = viewGroup;
        this.f1354b = new ArrayList();
        this.f1355c = new ArrayList();
    }

    public static final C0102m e(ViewGroup viewGroup, N n4) {
        J3.i.e(viewGroup, "container");
        J3.i.e(n4, "fragmentManager");
        J3.i.d(n4.H(), "fragmentManager.specialEffectsControllerFactory");
        Object tag = viewGroup.getTag(R.id.special_effects_controller_view_tag);
        if (tag instanceof C0102m) {
            return (C0102m) tag;
        }
        C0102m c0102m = new C0102m(viewGroup);
        viewGroup.setTag(R.id.special_effects_controller_view_tag, c0102m);
        return c0102m;
    }

    public final void a(Z z4) {
        J3.i.e(z4, "operation");
        if (z4.f1303b) {
            throw null;
        }
    }

    public final void b(ArrayList arrayList, boolean z4) {
        Iterator it = arrayList.iterator();
        if (it.hasNext()) {
            ((Z) it.next()).getClass();
            throw null;
        }
        ListIterator listIterator = arrayList.listIterator(arrayList.size());
        if (listIterator.hasPrevious()) {
            ((Z) listIterator.previous()).getClass();
            throw null;
        }
        if (N.J(2)) {
            Log.v("FragmentManager", "Executing operations from " + ((Object) null) + " to " + ((Object) null));
        }
        ArrayList<C0096g> arrayList2 = new ArrayList();
        ArrayList arrayList3 = new ArrayList();
        if (arrayList.isEmpty()) {
            throw new NoSuchElementException("List is empty.");
        }
        ((Z) arrayList.get(AbstractC0729i.S(arrayList))).getClass();
        Iterator it2 = arrayList.iterator();
        if (it2.hasNext()) {
            ((Z) it2.next()).getClass();
            throw null;
        }
        Iterator it3 = arrayList.iterator();
        if (it3.hasNext()) {
            Z z5 = (Z) it3.next();
            arrayList2.add(new C0096g(z5, z4));
            new C0101l(z5);
            z5.getClass();
            if (!z4) {
                throw null;
            }
            throw null;
        }
        ArrayList arrayList4 = new ArrayList();
        for (Object obj : arrayList3) {
            if (!((C0101l) obj).N()) {
                arrayList4.add(obj);
            }
        }
        ArrayList arrayList5 = new ArrayList();
        Iterator it4 = arrayList4.iterator();
        while (it4.hasNext()) {
            ((C0101l) it4.next()).getClass();
        }
        Iterator it5 = arrayList5.iterator();
        while (it5.hasNext()) {
            ((C0101l) it5.next()).getClass();
        }
        ArrayList arrayList6 = new ArrayList();
        ArrayList arrayList7 = new ArrayList();
        Iterator it6 = arrayList2.iterator();
        if (it6.hasNext()) {
            ((C0096g) it6.next()).getClass();
            throw null;
        }
        arrayList7.isEmpty();
        for (C0096g c0096g : arrayList2) {
            Context context = this.f1353a.getContext();
            c0096g.getClass();
            J3.i.d(context, "context");
            D2.v vVarP0 = c0096g.p0(context);
            if (vVarP0 != null) {
                if (((AnimatorSet) vVarP0.f261c) != null) {
                    throw null;
                }
                arrayList6.add(c0096g);
            }
        }
        Iterator it7 = arrayList6.iterator();
        if (it7.hasNext()) {
            ((C0096g) it7.next()).getClass();
            throw null;
        }
    }

    public final void c() {
        if (this.e) {
            return;
        }
        if (!this.f1353a.isAttachedToWindow()) {
            d();
            this.f1356d = false;
            return;
        }
        synchronized (this.f1354b) {
            try {
                if (this.f1354b.isEmpty()) {
                    ArrayList<Z> arrayListK0 = AbstractC0728h.k0(this.f1355c);
                    this.f1355c.clear();
                    for (Z z4 : arrayListK0) {
                        if (N.J(2)) {
                            Log.v("FragmentManager", "SpecialEffectsController: Cancelling operation " + z4 + " with no incoming pendingOperations");
                        }
                        ViewGroup viewGroup = this.f1353a;
                        z4.getClass();
                        J3.i.e(viewGroup, "container");
                        z4.a(viewGroup);
                        this.f1355c.add(z4);
                    }
                } else {
                    ArrayList arrayListK02 = AbstractC0728h.k0(this.f1355c);
                    this.f1355c.clear();
                    Iterator it = arrayListK02.iterator();
                    if (it.hasNext()) {
                        Z z5 = (Z) it.next();
                        if (N.J(2)) {
                            Log.v("FragmentManager", "SpecialEffectsController: Cancelling operation " + z5);
                        }
                        z5.getClass();
                        throw null;
                    }
                    g();
                    ArrayList arrayListK03 = AbstractC0728h.k0(this.f1354b);
                    if (arrayListK03.isEmpty()) {
                        return;
                    }
                    this.f1354b.clear();
                    this.f1355c.addAll(arrayListK03);
                    if (N.J(2)) {
                        Log.v("FragmentManager", "SpecialEffectsController: Executing pending operations");
                    }
                    b(arrayListK03, this.f1356d);
                    Iterator it2 = arrayListK03.iterator();
                    if (it2.hasNext()) {
                        ((Z) it2.next()).getClass();
                        throw null;
                    }
                    ArrayList arrayList = new ArrayList();
                    Iterator it3 = arrayListK03.iterator();
                    while (it3.hasNext()) {
                        ((Z) it3.next()).getClass();
                        x3.n.W(arrayList, null);
                    }
                    if (!arrayList.isEmpty()) {
                        f(arrayListK03);
                        int size = arrayListK03.size();
                        for (int i4 = 0; i4 < size; i4++) {
                            a((Z) arrayListK03.get(i4));
                        }
                    }
                    this.f1356d = false;
                    if (N.J(2)) {
                        Log.v("FragmentManager", "SpecialEffectsController: Finished executing pending operations");
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void d() {
        if (N.J(2)) {
            Log.v("FragmentManager", "SpecialEffectsController: Forcing all operations to complete");
        }
        boolean zIsAttachedToWindow = this.f1353a.isAttachedToWindow();
        synchronized (this.f1354b) {
            try {
                g();
                f(this.f1354b);
                for (Z z4 : AbstractC0728h.k0(this.f1355c)) {
                    if (N.J(2)) {
                        Log.v("FragmentManager", "SpecialEffectsController: " + (zIsAttachedToWindow ? "" : "Container " + this.f1353a + " is not attached to window. ") + "Cancelling running operation " + z4);
                    }
                    z4.a(this.f1353a);
                }
                for (Z z5 : AbstractC0728h.k0(this.f1354b)) {
                    if (N.J(2)) {
                        Log.v("FragmentManager", "SpecialEffectsController: " + (zIsAttachedToWindow ? "" : "Container " + this.f1353a + " is not attached to window. ") + "Cancelling pending operation " + z5);
                    }
                    z5.a(this.f1353a);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void f(ArrayList arrayList) {
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            Z z4 = (Z) arrayList.get(i4);
            if (!z4.f1302a) {
                z4.f1302a = true;
            }
        }
        ArrayList arrayList2 = new ArrayList();
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            ((Z) it.next()).getClass();
            x3.n.W(arrayList2, null);
        }
        List listI0 = AbstractC0728h.i0(AbstractC0728h.m0(arrayList2));
        int size2 = listI0.size();
        for (int i5 = 0; i5 < size2; i5++) {
            Y y4 = (Y) listI0.get(i5);
            y4.getClass();
            ViewGroup viewGroup = this.f1353a;
            J3.i.e(viewGroup, "container");
            if (!y4.f1301a) {
                y4.c(viewGroup);
            }
            y4.f1301a = true;
        }
    }

    public final void g() {
        Iterator it = this.f1354b.iterator();
        while (it.hasNext()) {
            ((Z) it.next()).getClass();
        }
    }
}
