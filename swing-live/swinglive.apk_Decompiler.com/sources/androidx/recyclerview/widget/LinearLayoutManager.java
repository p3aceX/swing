package androidx.recyclerview.widget;

import H0.a;
import Q.b;
import X.B;
import X.C0181l;
import X.C0182m;
import X.t;
import X.u;
import android.content.Context;
import android.os.Parcelable;
import android.util.AttributeSet;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import com.google.crypto.tink.shaded.protobuf.S;
import p1.d;

/* JADX INFO: loaded from: classes.dex */
public class LinearLayoutManager extends t {

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final int f3122h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public d f3123i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final b f3124j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final boolean f3125k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final boolean f3126l = false;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f3127m = false;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final boolean f3128n = true;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public C0182m f3129o = null;

    public LinearLayoutManager(Context context, AttributeSet attributeSet, int i4, int i5) {
        this.f3122h = 1;
        this.f3125k = false;
        C0181l c0181l = new C0181l(0);
        c0181l.f2360b = -1;
        c0181l.f2361c = Integer.MIN_VALUE;
        c0181l.f2362d = false;
        c0181l.e = false;
        C0181l c0181lW = t.w(context, attributeSet, i4, i5);
        int i6 = c0181lW.f2360b;
        if (i6 != 0 && i6 != 1) {
            throw new IllegalArgumentException(S.d(i6, "invalid orientation:"));
        }
        a(null);
        if (i6 != this.f3122h || this.f3124j == null) {
            this.f3124j = b.b(this, i6);
            this.f3122h = i6;
            H();
        }
        boolean z4 = c0181lW.f2362d;
        a(null);
        if (z4 != this.f3125k) {
            this.f3125k = z4;
            H();
        }
        Q(c0181lW.e);
    }

    @Override // X.t
    public final void A(AccessibilityEvent accessibilityEvent) {
        super.A(accessibilityEvent);
        if (p() > 0) {
            View viewP = P(0, p(), false);
            if (viewP != null) {
                ((u) viewP.getLayoutParams()).getClass();
                throw null;
            }
            accessibilityEvent.setFromIndex(-1);
            View viewP2 = P(p() - 1, -1, false);
            if (viewP2 == null) {
                accessibilityEvent.setToIndex(-1);
            } else {
                ((u) viewP2.getLayoutParams()).getClass();
                throw null;
            }
        }
    }

    @Override // X.t
    public final void B(Parcelable parcelable) {
        if (parcelable instanceof C0182m) {
            this.f3129o = (C0182m) parcelable;
            H();
        }
    }

    @Override // X.t
    public final Parcelable C() {
        C0182m c0182m = this.f3129o;
        if (c0182m != null) {
            C0182m c0182m2 = new C0182m();
            c0182m2.f2363a = c0182m.f2363a;
            c0182m2.f2364b = c0182m.f2364b;
            c0182m2.f2365c = c0182m.f2365c;
            return c0182m2;
        }
        C0182m c0182m3 = new C0182m();
        if (p() <= 0) {
            c0182m3.f2363a = -1;
            return c0182m3;
        }
        M();
        boolean z4 = this.f3126l;
        c0182m3.f2365c = z4;
        if (!z4) {
            t.v(o(z4 ? p() - 1 : 0));
            throw null;
        }
        View viewO = o(z4 ? 0 : p() - 1);
        c0182m3.f2364b = this.f3124j.e() - this.f3124j.c(viewO);
        t.v(viewO);
        throw null;
    }

    public final int J(B b5) {
        if (p() == 0) {
            return 0;
        }
        M();
        b bVar = this.f3124j;
        boolean z4 = !this.f3128n;
        return a.e(b5, bVar, O(z4), N(z4), this, this.f3128n);
    }

    public final void K(B b5) {
        if (p() == 0) {
            return;
        }
        M();
        boolean z4 = !this.f3128n;
        View viewO = O(z4);
        View viewN = N(z4);
        if (p() == 0 || b5.a() == 0 || viewO == null || viewN == null) {
            return;
        }
        ((u) viewO.getLayoutParams()).getClass();
        throw null;
    }

    public final int L(B b5) {
        if (p() == 0) {
            return 0;
        }
        M();
        b bVar = this.f3124j;
        boolean z4 = !this.f3128n;
        return a.f(b5, bVar, O(z4), N(z4), this, this.f3128n);
    }

    public final void M() {
        if (this.f3123i == null) {
            this.f3123i = new d(25);
        }
    }

    public final View N(boolean z4) {
        return this.f3126l ? P(0, p(), z4) : P(p() - 1, -1, z4);
    }

    public final View O(boolean z4) {
        return this.f3126l ? P(p() - 1, -1, z4) : P(0, p(), z4);
    }

    public final View P(int i4, int i5, boolean z4) {
        M();
        int i6 = z4 ? 24579 : 320;
        return this.f3122h == 0 ? this.f2373c.z(i4, i5, i6, 320) : this.f2374d.z(i4, i5, i6, 320);
    }

    public void Q(boolean z4) {
        a(null);
        if (this.f3127m == z4) {
            return;
        }
        this.f3127m = z4;
        H();
    }

    @Override // X.t
    public final void a(String str) {
        RecyclerView recyclerView;
        if (this.f3129o != null || (recyclerView = this.f2372b) == null) {
            return;
        }
        recyclerView.b(str);
    }

    @Override // X.t
    public final boolean b() {
        return this.f3122h == 0;
    }

    @Override // X.t
    public final boolean c() {
        return this.f3122h == 1;
    }

    @Override // X.t
    public final int f(B b5) {
        return J(b5);
    }

    @Override // X.t
    public final void g(B b5) {
        K(b5);
    }

    @Override // X.t
    public final int h(B b5) {
        return L(b5);
    }

    @Override // X.t
    public final int i(B b5) {
        return J(b5);
    }

    @Override // X.t
    public final void j(B b5) {
        K(b5);
    }

    @Override // X.t
    public final int k(B b5) {
        return L(b5);
    }

    @Override // X.t
    public u l() {
        return new u(-2, -2);
    }

    @Override // X.t
    public final boolean y() {
        return true;
    }

    @Override // X.t
    public final void z(RecyclerView recyclerView) {
    }
}
