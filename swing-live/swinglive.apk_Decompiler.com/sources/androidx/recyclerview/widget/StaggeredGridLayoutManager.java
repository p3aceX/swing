package androidx.recyclerview.widget;

import A.C;
import H0.a;
import J1.c;
import Q.b;
import X.B;
import X.C0181l;
import X.G;
import X.I;
import X.J;
import X.t;
import X.u;
import android.content.Context;
import android.graphics.Rect;
import android.os.Parcelable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import java.lang.reflect.Field;
import java.util.BitSet;
import p1.d;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
public class StaggeredGridLayoutManager extends t {

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final int f3185h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final J[] f3186i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final b f3187j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final b f3188k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final int f3189l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final boolean f3190m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final boolean f3191n = false;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final C0690c f3192o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final int f3193p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public I f3194q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final boolean f3195r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final F.b f3196s;

    public StaggeredGridLayoutManager(Context context, AttributeSet attributeSet, int i4, int i5) {
        this.f3185h = -1;
        this.f3190m = false;
        C0690c c0690c = new C0690c(22, false);
        this.f3192o = c0690c;
        this.f3193p = 2;
        new Rect();
        new d(this, 29);
        this.f3195r = true;
        this.f3196s = new F.b(this, 6);
        C0181l c0181lW = t.w(context, attributeSet, i4, i5);
        int i6 = c0181lW.f2360b;
        if (i6 != 0 && i6 != 1) {
            throw new IllegalArgumentException("invalid orientation.");
        }
        a(null);
        if (i6 != this.f3189l) {
            this.f3189l = i6;
            b bVar = this.f3187j;
            this.f3187j = this.f3188k;
            this.f3188k = bVar;
            H();
        }
        int i7 = c0181lW.f2361c;
        a(null);
        if (i7 != this.f3185h) {
            c0690c.f6642b = null;
            H();
            this.f3185h = i7;
            new BitSet(this.f3185h);
            this.f3186i = new J[this.f3185h];
            for (int i8 = 0; i8 < this.f3185h; i8++) {
                this.f3186i[i8] = new J(this, i8);
            }
            H();
        }
        boolean z4 = c0181lW.f2362d;
        a(null);
        I i9 = this.f3194q;
        if (i9 != null && i9.f2296n != z4) {
            i9.f2296n = z4;
        }
        this.f3190m = z4;
        H();
        this.f3187j = b.b(this, this.f3189l);
        this.f3188k = b.b(this, 1 - this.f3189l);
    }

    @Override // X.t
    public final void A(AccessibilityEvent accessibilityEvent) {
        super.A(accessibilityEvent);
        if (p() > 0) {
            View viewO = O(false);
            View viewN = N(false);
            if (viewO == null || viewN == null) {
                return;
            }
            ((u) viewO.getLayoutParams()).getClass();
            throw null;
        }
    }

    @Override // X.t
    public final void B(Parcelable parcelable) {
        if (parcelable instanceof I) {
            this.f3194q = (I) parcelable;
            H();
        }
    }

    @Override // X.t
    public final Parcelable C() {
        I i4 = this.f3194q;
        if (i4 != null) {
            I i5 = new I();
            i5.f2292c = i4.f2292c;
            i5.f2290a = i4.f2290a;
            i5.f2291b = i4.f2291b;
            i5.f2293d = i4.f2293d;
            i5.e = i4.e;
            i5.f2294f = i4.f2294f;
            i5.f2296n = i4.f2296n;
            i5.f2297o = i4.f2297o;
            i5.f2298p = i4.f2298p;
            i5.f2295m = i4.f2295m;
            return i5;
        }
        I i6 = new I();
        i6.f2296n = this.f3190m;
        i6.f2297o = false;
        i6.f2298p = false;
        i6.e = 0;
        if (p() <= 0) {
            i6.f2290a = -1;
            i6.f2291b = -1;
            i6.f2292c = 0;
            return i6;
        }
        P();
        i6.f2290a = 0;
        View viewN = this.f3191n ? N(true) : O(true);
        if (viewN != null) {
            ((u) viewN.getLayoutParams()).getClass();
            throw null;
        }
        i6.f2291b = -1;
        int i7 = this.f3185h;
        i6.f2292c = i7;
        i6.f2293d = new int[i7];
        for (int i8 = 0; i8 < this.f3185h; i8++) {
            J j4 = this.f3186i[i8];
            int iF = j4.f2300b;
            if (iF == Integer.MIN_VALUE) {
                if (j4.f2299a.size() == 0) {
                    iF = Integer.MIN_VALUE;
                } else {
                    View view = (View) j4.f2299a.get(0);
                    G g4 = (G) view.getLayoutParams();
                    j4.f2300b = j4.e.f3187j.d(view);
                    g4.getClass();
                    iF = j4.f2300b;
                }
            }
            if (iF != Integer.MIN_VALUE) {
                iF -= this.f3187j.f();
            }
            i6.f2293d[i8] = iF;
        }
        return i6;
    }

    @Override // X.t
    public final void D(int i4) {
        if (i4 == 0) {
            J();
        }
    }

    public final boolean J() {
        int i4 = this.f3185h;
        boolean z4 = this.f3191n;
        if (p() == 0 || this.f3193p == 0 || !this.e) {
            return false;
        }
        if (z4) {
            Q();
            P();
        } else {
            P();
            Q();
        }
        int iP = p();
        int i5 = iP - 1;
        new BitSet(i4).set(0, i4, true);
        if (this.f3189l == 1) {
            RecyclerView recyclerView = this.f2372b;
            Field field = C.f4a;
            if (recyclerView.getLayoutDirection() != 1) {
            }
        }
        if (z4) {
            iP = -1;
        } else {
            i5 = 0;
        }
        if (i5 == iP) {
            return false;
        }
        ((G) o(i5).getLayoutParams()).getClass();
        throw null;
    }

    public final int K(B b5) {
        if (p() == 0) {
            return 0;
        }
        b bVar = this.f3187j;
        boolean z4 = !this.f3195r;
        return a.e(b5, bVar, O(z4), N(z4), this, this.f3195r);
    }

    public final void L(B b5) {
        if (p() == 0) {
            return;
        }
        boolean z4 = !this.f3195r;
        View viewO = O(z4);
        View viewN = N(z4);
        if (p() == 0 || b5.a() == 0 || viewO == null || viewN == null) {
            return;
        }
        ((u) viewO.getLayoutParams()).getClass();
        throw null;
    }

    public final int M(B b5) {
        if (p() == 0) {
            return 0;
        }
        b bVar = this.f3187j;
        boolean z4 = !this.f3195r;
        return a.f(b5, bVar, O(z4), N(z4), this, this.f3195r);
    }

    public final View N(boolean z4) {
        int iF = this.f3187j.f();
        int iE = this.f3187j.e();
        View view = null;
        for (int iP = p() - 1; iP >= 0; iP--) {
            View viewO = o(iP);
            int iD = this.f3187j.d(viewO);
            int iC = this.f3187j.c(viewO);
            if (iC > iF && iD < iE) {
                if (iC <= iE || !z4) {
                    return viewO;
                }
                if (view == null) {
                    view = viewO;
                }
            }
        }
        return view;
    }

    public final View O(boolean z4) {
        int iF = this.f3187j.f();
        int iE = this.f3187j.e();
        int iP = p();
        View view = null;
        for (int i4 = 0; i4 < iP; i4++) {
            View viewO = o(i4);
            int iD = this.f3187j.d(viewO);
            if (this.f3187j.c(viewO) > iF && iD < iE) {
                if (iD >= iF || !z4) {
                    return viewO;
                }
                if (view == null) {
                    view = viewO;
                }
            }
        }
        return view;
    }

    public final void P() {
        if (p() == 0) {
            return;
        }
        t.v(o(0));
        throw null;
    }

    public final void Q() {
        int iP = p();
        if (iP == 0) {
            return;
        }
        t.v(o(iP - 1));
        throw null;
    }

    @Override // X.t
    public final void a(String str) {
        RecyclerView recyclerView;
        if (this.f3194q != null || (recyclerView = this.f2372b) == null) {
            return;
        }
        recyclerView.b(str);
    }

    @Override // X.t
    public final boolean b() {
        return this.f3189l == 0;
    }

    @Override // X.t
    public final boolean c() {
        return this.f3189l == 1;
    }

    @Override // X.t
    public final boolean d(u uVar) {
        return uVar instanceof G;
    }

    @Override // X.t
    public final int f(B b5) {
        return K(b5);
    }

    @Override // X.t
    public final void g(B b5) {
        L(b5);
    }

    @Override // X.t
    public final int h(B b5) {
        return M(b5);
    }

    @Override // X.t
    public final int i(B b5) {
        return K(b5);
    }

    @Override // X.t
    public final void j(B b5) {
        L(b5);
    }

    @Override // X.t
    public final int k(B b5) {
        return M(b5);
    }

    @Override // X.t
    public final u l() {
        return this.f3189l == 0 ? new G(-2, -1) : new G(-1, -2);
    }

    @Override // X.t
    public final u m(Context context, AttributeSet attributeSet) {
        return new G(context, attributeSet);
    }

    @Override // X.t
    public final u n(ViewGroup.LayoutParams layoutParams) {
        return layoutParams instanceof ViewGroup.MarginLayoutParams ? new G((ViewGroup.MarginLayoutParams) layoutParams) : new G(layoutParams);
    }

    @Override // X.t
    public final int q(c cVar, B b5) {
        if (this.f3189l == 1) {
            return this.f3185h;
        }
        super.q(cVar, b5);
        return 1;
    }

    @Override // X.t
    public final int x(c cVar, B b5) {
        if (this.f3189l == 0) {
            return this.f3185h;
        }
        super.x(cVar, b5);
        return 1;
    }

    @Override // X.t
    public final boolean y() {
        return this.f3193p != 0;
    }

    @Override // X.t
    public final void z(RecyclerView recyclerView) {
        RecyclerView recyclerView2 = this.f2372b;
        if (recyclerView2 != null) {
            recyclerView2.removeCallbacks(this.f3196s);
        }
        for (int i4 = 0; i4 < this.f3185h; i4++) {
            J j4 = this.f3186i[i4];
            j4.f2299a.clear();
            j4.f2300b = Integer.MIN_VALUE;
            j4.f2301c = Integer.MIN_VALUE;
        }
        recyclerView.requestLayout();
    }
}
