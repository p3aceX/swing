package k;

import Q3.x0;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import androidx.appcompat.view.menu.ActionMenuItemView;
import androidx.appcompat.widget.ActionMenuView;
import com.swing.live.R;
import java.util.ArrayList;
import u1.C0690c;

/* JADX INFO: renamed from: k.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0492i implements j.p {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public C0490g f5377A;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f5379a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Context f5380b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public j.j f5381c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final LayoutInflater f5382d;
    public j.o e;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ActionMenuView f5384m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public C0491h f5385n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public Drawable f5386o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public boolean f5387p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public boolean f5388q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public boolean f5389r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f5390s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public int f5391t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public int f5392u;
    public boolean v;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public C0489f f5394x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public C0489f f5395y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public x0 f5396z;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f5383f = R.layout.abc_action_menu_item_layout;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final SparseBooleanArray f5393w = new SparseBooleanArray();

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final C0690c f5378B = new C0690c(this, 27);

    public C0492i(Context context) {
        this.f5379a = context;
        this.f5382d = LayoutInflater.from(context);
    }

    @Override // j.p
    public final void a(j.j jVar, boolean z4) {
        g();
        C0489f c0489f = this.f5395y;
        if (c0489f != null && c0489f.b()) {
            c0489f.f5135i.dismiss();
        }
        j.o oVar = this.e;
        if (oVar != null) {
            oVar.a(jVar, z4);
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final View b(j.k kVar, View view, ActionMenuView actionMenuView) {
        View view2 = kVar.f5125z;
        View view3 = view2 != null ? view2 : null;
        if (view3 == null || ((kVar.f5124y & 8) != 0 && view2 != null)) {
            j.q qVar = view instanceof j.q ? (j.q) view : (j.q) this.f5382d.inflate(this.f5383f, (ViewGroup) actionMenuView, false);
            qVar.c(kVar);
            ActionMenuItemView actionMenuItemView = (ActionMenuItemView) qVar;
            actionMenuItemView.setItemInvoker(this.f5384m);
            if (this.f5377A == null) {
                this.f5377A = new C0490g(this);
            }
            actionMenuItemView.setPopupCallback(this.f5377A);
            view3 = (View) qVar;
        }
        view3.setVisibility(kVar.f5101B ? 8 : 0);
        ViewGroup.LayoutParams layoutParams = view3.getLayoutParams();
        actionMenuView.getClass();
        if (!(layoutParams instanceof C0494k)) {
            view3.setLayoutParams(ActionMenuView.i(layoutParams));
        }
        return view3;
    }

    @Override // j.p
    public final void c(Context context, j.j jVar) {
        this.f5380b = context;
        LayoutInflater.from(context);
        this.f5381c = jVar;
        Resources resources = context.getResources();
        if (!this.f5389r) {
            this.f5388q = true;
        }
        int i4 = 2;
        this.f5390s = context.getResources().getDisplayMetrics().widthPixels / 2;
        Configuration configuration = context.getResources().getConfiguration();
        int i5 = configuration.screenWidthDp;
        int i6 = configuration.screenHeightDp;
        if (configuration.smallestScreenWidthDp > 600 || i5 > 600 || ((i5 > 960 && i6 > 720) || (i5 > 720 && i6 > 960))) {
            i4 = 5;
        } else if (i5 >= 500 || ((i5 > 640 && i6 > 480) || (i5 > 480 && i6 > 640))) {
            i4 = 4;
        } else if (i5 >= 360) {
            i4 = 3;
        }
        this.f5392u = i4;
        int measuredWidth = this.f5390s;
        if (this.f5388q) {
            if (this.f5385n == null) {
                C0491h c0491h = new C0491h(this, this.f5379a);
                this.f5385n = c0491h;
                if (this.f5387p) {
                    c0491h.setImageDrawable(this.f5386o);
                    this.f5386o = null;
                    this.f5387p = false;
                }
                int iMakeMeasureSpec = View.MeasureSpec.makeMeasureSpec(0, 0);
                this.f5385n.measure(iMakeMeasureSpec, iMakeMeasureSpec);
            }
            measuredWidth -= this.f5385n.getMeasuredWidth();
        } else {
            this.f5385n = null;
        }
        this.f5391t = measuredWidth;
        float f4 = resources.getDisplayMetrics().density;
    }

    @Override // j.p
    public final boolean d() {
        int size;
        ArrayList arrayListK;
        int i4;
        boolean z4;
        C0492i c0492i = this;
        j.j jVar = c0492i.f5381c;
        if (jVar != null) {
            arrayListK = jVar.k();
            size = arrayListK.size();
        } else {
            size = 0;
            arrayListK = null;
        }
        int i5 = c0492i.f5392u;
        int i6 = c0492i.f5391t;
        int iMakeMeasureSpec = View.MeasureSpec.makeMeasureSpec(0, 0);
        ActionMenuView actionMenuView = c0492i.f5384m;
        int i7 = 0;
        boolean z5 = false;
        int i8 = 0;
        int i9 = 0;
        while (true) {
            i4 = 2;
            z4 = true;
            if (i7 >= size) {
                break;
            }
            j.k kVar = (j.k) arrayListK.get(i7);
            int i10 = kVar.f5124y;
            if ((i10 & 2) == 2) {
                i8++;
            } else if ((i10 & 1) == 1) {
                i9++;
            } else {
                z5 = true;
            }
            if (c0492i.v && kVar.f5101B) {
                i5 = 0;
            }
            i7++;
        }
        if (c0492i.f5388q && (z5 || i9 + i8 > i5)) {
            i5--;
        }
        int i11 = i5 - i8;
        SparseBooleanArray sparseBooleanArray = c0492i.f5393w;
        sparseBooleanArray.clear();
        int i12 = 0;
        int i13 = 0;
        while (i12 < size) {
            j.k kVar2 = (j.k) arrayListK.get(i12);
            int i14 = kVar2.f5124y;
            boolean z6 = (i14 & 2) == i4 ? z4 : false;
            int i15 = kVar2.f5103b;
            if (z6) {
                View viewB = c0492i.b(kVar2, null, actionMenuView);
                viewB.measure(iMakeMeasureSpec, iMakeMeasureSpec);
                int measuredWidth = viewB.getMeasuredWidth();
                i6 -= measuredWidth;
                if (i13 == 0) {
                    i13 = measuredWidth;
                }
                if (i15 != 0) {
                    sparseBooleanArray.put(i15, z4);
                }
                kVar2.d(z4);
            } else if ((i14 & 1) == z4) {
                boolean z7 = sparseBooleanArray.get(i15);
                boolean z8 = ((i11 > 0 || z7) && i6 > 0) ? z4 : false;
                if (z8) {
                    View viewB2 = c0492i.b(kVar2, null, actionMenuView);
                    viewB2.measure(iMakeMeasureSpec, iMakeMeasureSpec);
                    int measuredWidth2 = viewB2.getMeasuredWidth();
                    i6 -= measuredWidth2;
                    if (i13 == 0) {
                        i13 = measuredWidth2;
                    }
                    z8 &= i6 + i13 > 0;
                }
                if (z8 && i15 != 0) {
                    sparseBooleanArray.put(i15, true);
                } else if (z7) {
                    sparseBooleanArray.put(i15, false);
                    for (int i16 = 0; i16 < i12; i16++) {
                        j.k kVar3 = (j.k) arrayListK.get(i16);
                        if (kVar3.f5103b == i15) {
                            if ((kVar3.f5123x & 32) == 32) {
                                i11++;
                            }
                            kVar3.d(false);
                        }
                    }
                }
                if (z8) {
                    i11--;
                }
                kVar2.d(z8);
            } else {
                kVar2.d(false);
                i12++;
                i4 = 2;
                c0492i = this;
                z4 = true;
            }
            i12++;
            i4 = 2;
            c0492i = this;
            z4 = true;
        }
        return z4;
    }

    @Override // j.p
    public final boolean e(j.k kVar) {
        return false;
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // j.p
    public final void f() {
        int i4;
        ActionMenuView actionMenuView = this.f5384m;
        ArrayList arrayList = null;
        boolean z4 = false;
        if (actionMenuView != null) {
            j.j jVar = this.f5381c;
            if (jVar != null) {
                jVar.i();
                ArrayList arrayListK = this.f5381c.k();
                int size = arrayListK.size();
                i4 = 0;
                for (int i5 = 0; i5 < size; i5++) {
                    j.k kVar = (j.k) arrayListK.get(i5);
                    if ((kVar.f5123x & 32) == 32) {
                        View childAt = actionMenuView.getChildAt(i4);
                        j.k itemData = childAt instanceof j.q ? ((j.q) childAt).getItemData() : null;
                        View viewB = b(kVar, childAt, actionMenuView);
                        if (kVar != itemData) {
                            viewB.setPressed(false);
                            viewB.jumpDrawablesToCurrentState();
                        }
                        if (viewB != childAt) {
                            ViewGroup viewGroup = (ViewGroup) viewB.getParent();
                            if (viewGroup != null) {
                                viewGroup.removeView(viewB);
                            }
                            this.f5384m.addView(viewB, i4);
                        }
                        i4++;
                    }
                }
            } else {
                i4 = 0;
            }
            while (i4 < actionMenuView.getChildCount()) {
                if (actionMenuView.getChildAt(i4) == this.f5385n) {
                    i4++;
                } else {
                    actionMenuView.removeViewAt(i4);
                }
            }
        }
        this.f5384m.requestLayout();
        j.j jVar2 = this.f5381c;
        if (jVar2 != null) {
            jVar2.i();
            ArrayList arrayList2 = jVar2.f5088i;
            int size2 = arrayList2.size();
            for (int i6 = 0; i6 < size2; i6++) {
                ((j.k) arrayList2.get(i6)).getClass();
            }
        }
        j.j jVar3 = this.f5381c;
        if (jVar3 != null) {
            jVar3.i();
            arrayList = jVar3.f5089j;
        }
        if (this.f5388q && arrayList != null) {
            int size3 = arrayList.size();
            if (size3 == 1) {
                z4 = !((j.k) arrayList.get(0)).f5101B;
            } else if (size3 > 0) {
                z4 = true;
            }
        }
        if (z4) {
            if (this.f5385n == null) {
                this.f5385n = new C0491h(this, this.f5379a);
            }
            ViewGroup viewGroup2 = (ViewGroup) this.f5385n.getParent();
            if (viewGroup2 != this.f5384m) {
                if (viewGroup2 != null) {
                    viewGroup2.removeView(this.f5385n);
                }
                ActionMenuView actionMenuView2 = this.f5384m;
                C0491h c0491h = this.f5385n;
                actionMenuView2.getClass();
                C0494k c0494kH = ActionMenuView.h();
                c0494kH.f5398c = true;
                actionMenuView2.addView(c0491h, c0494kH);
            }
        } else {
            C0491h c0491h2 = this.f5385n;
            if (c0491h2 != null) {
                ViewParent parent = c0491h2.getParent();
                ActionMenuView actionMenuView3 = this.f5384m;
                if (parent == actionMenuView3) {
                    actionMenuView3.removeView(this.f5385n);
                }
            }
        }
        this.f5384m.setOverflowReserved(this.f5388q);
    }

    public final boolean g() {
        ActionMenuView actionMenuView;
        x0 x0Var = this.f5396z;
        if (x0Var != null && (actionMenuView = this.f5384m) != null) {
            actionMenuView.removeCallbacks(x0Var);
            this.f5396z = null;
            return true;
        }
        C0489f c0489f = this.f5394x;
        if (c0489f == null) {
            return false;
        }
        if (c0489f.b()) {
            c0489f.f5135i.dismiss();
        }
        return true;
    }

    public final boolean h() {
        j.j jVar;
        if (!this.f5388q) {
            return false;
        }
        C0489f c0489f = this.f5394x;
        if ((c0489f != null && c0489f.b()) || (jVar = this.f5381c) == null || this.f5384m == null || this.f5396z != null) {
            return false;
        }
        jVar.i();
        if (jVar.f5089j.isEmpty()) {
            return false;
        }
        x0 x0Var = new x0(this, new C0489f(this, this.f5380b, this.f5381c, this.f5385n), 4, false);
        this.f5396z = x0Var;
        this.f5384m.post(x0Var);
        j.o oVar = this.e;
        if (oVar == null) {
            return true;
        }
        oVar.h(null);
        return true;
    }

    @Override // j.p
    public final boolean i(j.k kVar) {
        return false;
    }

    @Override // j.p
    public final void j(j.o oVar) {
        throw null;
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // j.p
    public final boolean k(j.t tVar) {
        boolean z4;
        if (tVar.hasVisibleItems()) {
            j.t tVar2 = tVar;
            while (true) {
                j.j jVar = tVar2.v;
                if (jVar == this.f5381c) {
                    break;
                }
                tVar2 = (j.t) jVar;
            }
            ActionMenuView actionMenuView = this.f5384m;
            View view = null;
            view = null;
            if (actionMenuView != null) {
                int childCount = actionMenuView.getChildCount();
                int i4 = 0;
                while (true) {
                    if (i4 >= childCount) {
                        break;
                    }
                    View childAt = actionMenuView.getChildAt(i4);
                    if ((childAt instanceof j.q) && ((j.q) childAt).getItemData() == tVar2.f5155w) {
                        view = childAt;
                        break;
                    }
                    i4++;
                }
            }
            if (view != null) {
                tVar.f5155w.getClass();
                int size = tVar.f5085f.size();
                int i5 = 0;
                while (true) {
                    if (i5 >= size) {
                        z4 = false;
                        break;
                    }
                    MenuItem item = tVar.getItem(i5);
                    if (item.isVisible() && item.getIcon() != null) {
                        z4 = true;
                        break;
                    }
                    i5++;
                }
                C0489f c0489f = new C0489f(this, this.f5380b, tVar, view);
                this.f5395y = c0489f;
                c0489f.f5133g = z4;
                j.l lVar = c0489f.f5135i;
                if (lVar != null) {
                    lVar.o(z4);
                }
                C0489f c0489f2 = this.f5395y;
                if (!c0489f2.b()) {
                    if (c0489f2.e == null) {
                        throw new IllegalStateException("MenuPopupHelper cannot be used without an anchor");
                    }
                    c0489f2.d(0, 0, false, false);
                }
                j.o oVar = this.e;
                if (oVar != null) {
                    oVar.h(tVar);
                }
                return true;
            }
        }
        return false;
    }
}
