package X;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Rect;
import android.os.Parcelable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import androidx.recyclerview.widget.RecyclerView;
import java.lang.reflect.Field;
import java.util.ArrayList;
import u1.C0690c;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class t {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0747k f2371a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public RecyclerView f2372b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final D2.v f2373c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final D2.v f2374d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f2375f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f2376g;

    public t() {
        C0779j c0779j = new C0779j(this, 21);
        B.k kVar = new B.k(this, 18);
        this.f2373c = new D2.v((L) c0779j);
        this.f2374d = new D2.v(kVar);
        this.e = false;
    }

    public static int e(int i4, int i5, int i6) {
        int mode = View.MeasureSpec.getMode(i4);
        int size = View.MeasureSpec.getSize(i4);
        return mode != Integer.MIN_VALUE ? mode != 1073741824 ? Math.max(i5, i6) : size : Math.min(size, Math.max(i5, i6));
    }

    public static void v(View view) {
        ((u) view.getLayoutParams()).getClass();
        throw null;
    }

    public static C0181l w(Context context, AttributeSet attributeSet, int i4, int i5) {
        C0181l c0181l = new C0181l(1);
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, W.a.f2255a, i4, i5);
        c0181l.f2360b = typedArrayObtainStyledAttributes.getInt(0, 1);
        c0181l.f2361c = typedArrayObtainStyledAttributes.getInt(9, 1);
        c0181l.f2362d = typedArrayObtainStyledAttributes.getBoolean(8, false);
        c0181l.e = typedArrayObtainStyledAttributes.getBoolean(10, false);
        typedArrayObtainStyledAttributes.recycle();
        return c0181l;
    }

    public void A(AccessibilityEvent accessibilityEvent) {
        RecyclerView recyclerView = this.f2372b;
        J1.c cVar = recyclerView.f3155a;
        B b5 = recyclerView.f3162d0;
        if (recyclerView == null || accessibilityEvent == null) {
            return;
        }
        boolean z4 = true;
        if (!recyclerView.canScrollVertically(1) && !this.f2372b.canScrollVertically(-1) && !this.f2372b.canScrollHorizontally(-1) && !this.f2372b.canScrollHorizontally(1)) {
            z4 = false;
        }
        accessibilityEvent.setScrollable(z4);
        this.f2372b.getClass();
    }

    public abstract void B(Parcelable parcelable);

    public abstract Parcelable C();

    public final void E() {
        int iP = p() - 1;
        if (iP < 0) {
            return;
        }
        RecyclerView.j(o(iP));
        throw null;
    }

    public final void F(J1.c cVar) {
        int size = ((ArrayList) cVar.f787f).size();
        int i4 = size - 1;
        ArrayList arrayList = (ArrayList) cVar.f787f;
        if (i4 >= 0) {
            arrayList.get(i4).getClass();
            throw new ClassCastException();
        }
        arrayList.clear();
        if (size > 0) {
            this.f2372b.invalidate();
        }
    }

    public final boolean G(RecyclerView recyclerView, View view, Rect rect, boolean z4, boolean z5) {
        boolean z6;
        boolean z7;
        int iS = s();
        int iU = u();
        int iT = this.f2375f - t();
        int iR = this.f2376g - r();
        int left = (view.getLeft() + rect.left) - view.getScrollX();
        int top = (view.getTop() + rect.top) - view.getScrollY();
        int iWidth = rect.width() + left;
        int iHeight = rect.height() + top;
        int i4 = left - iS;
        int iMin = Math.min(0, i4);
        int i5 = top - iU;
        int iMin2 = Math.min(0, i5);
        int i6 = iWidth - iT;
        int iMax = Math.max(0, i6);
        int iMax2 = Math.max(0, iHeight - iR);
        RecyclerView recyclerView2 = this.f2372b;
        Field field = A.C.f4a;
        if (recyclerView2.getLayoutDirection() != 1) {
            if (iMin == 0) {
                iMin = Math.min(i4, iMax);
            }
            iMax = iMin;
        } else if (iMax == 0) {
            iMax = Math.max(iMin, i6);
        }
        if (iMin2 == 0) {
            iMin2 = Math.min(i5, iMax2);
        }
        int[] iArr = {iMax, iMin2};
        int i7 = iArr[0];
        int i8 = iArr[1];
        if (z5) {
            View focusedChild = recyclerView.getFocusedChild();
            if (focusedChild == null) {
                return false;
            }
            int iS2 = s();
            int iU2 = u();
            int iT2 = this.f2375f - t();
            int iR2 = this.f2376g - r();
            Rect rect2 = this.f2372b.f3171m;
            int[] iArr2 = RecyclerView.n0;
            u uVar = (u) focusedChild.getLayoutParams();
            Rect rect3 = uVar.f2377a;
            z6 = false;
            z7 = true;
            rect2.set((focusedChild.getLeft() - rect3.left) - ((ViewGroup.MarginLayoutParams) uVar).leftMargin, (focusedChild.getTop() - rect3.top) - ((ViewGroup.MarginLayoutParams) uVar).topMargin, focusedChild.getRight() + rect3.right + ((ViewGroup.MarginLayoutParams) uVar).rightMargin, focusedChild.getBottom() + rect3.bottom + ((ViewGroup.MarginLayoutParams) uVar).bottomMargin);
            if (rect2.left - i7 >= iT2 || rect2.right - i7 <= iS2 || rect2.top - i8 >= iR2 || rect2.bottom - i8 <= iU2) {
                return false;
            }
        } else {
            z6 = false;
            z7 = true;
        }
        if (i7 == 0 && i8 == 0) {
            return z6;
        }
        if (z4) {
            recyclerView.scrollBy(i7, i8);
            return z7;
        }
        recyclerView.r(i7, i8);
        return z7;
    }

    public final void H() {
        RecyclerView recyclerView = this.f2372b;
        if (recyclerView != null) {
            recyclerView.requestLayout();
        }
    }

    public final void I(RecyclerView recyclerView) {
        if (recyclerView == null) {
            this.f2372b = null;
            this.f2371a = null;
            this.f2375f = 0;
            this.f2376g = 0;
            return;
        }
        this.f2372b = recyclerView;
        this.f2371a = recyclerView.f3161d;
        this.f2375f = recyclerView.getWidth();
        this.f2376g = recyclerView.getHeight();
    }

    public abstract void a(String str);

    public abstract boolean b();

    public abstract boolean c();

    public boolean d(u uVar) {
        return uVar != null;
    }

    public abstract int f(B b5);

    public abstract void g(B b5);

    public abstract int h(B b5);

    public abstract int i(B b5);

    public abstract void j(B b5);

    public abstract int k(B b5);

    public abstract u l();

    public u m(Context context, AttributeSet attributeSet) {
        return new u(context, attributeSet);
    }

    public u n(ViewGroup.LayoutParams layoutParams) {
        return layoutParams instanceof u ? new u((u) layoutParams) : layoutParams instanceof ViewGroup.MarginLayoutParams ? new u((ViewGroup.MarginLayoutParams) layoutParams) : new u(layoutParams);
    }

    public final View o(int i4) {
        C0747k c0747k = this.f2371a;
        if (c0747k == null) {
            return null;
        }
        int i5 = -1;
        if (i4 >= 0) {
            int childCount = ((RecyclerView) ((C0690c) c0747k.f6831b).f6642b).getChildCount();
            int i6 = i4;
            while (true) {
                if (i6 >= childCount) {
                    break;
                }
                C0171b c0171b = (C0171b) c0747k.f6832c;
                int iA = i4 - (i6 - c0171b.a(i6));
                if (iA == 0) {
                    i5 = i6;
                    while (c0171b.b(i5)) {
                        i5++;
                    }
                } else {
                    i6 += iA;
                }
            }
        }
        return ((RecyclerView) ((C0690c) c0747k.f6831b).f6642b).getChildAt(i5);
    }

    public final int p() {
        C0747k c0747k = this.f2371a;
        if (c0747k != null) {
            return ((RecyclerView) ((C0690c) c0747k.f6831b).f6642b).getChildCount() - ((ArrayList) c0747k.f6833d).size();
        }
        return 0;
    }

    public int q(J1.c cVar, B b5) {
        RecyclerView recyclerView = this.f2372b;
        if (recyclerView == null) {
            return 1;
        }
        recyclerView.getClass();
        return 1;
    }

    public final int r() {
        RecyclerView recyclerView = this.f2372b;
        if (recyclerView != null) {
            return recyclerView.getPaddingBottom();
        }
        return 0;
    }

    public final int s() {
        RecyclerView recyclerView = this.f2372b;
        if (recyclerView != null) {
            return recyclerView.getPaddingLeft();
        }
        return 0;
    }

    public final int t() {
        RecyclerView recyclerView = this.f2372b;
        if (recyclerView != null) {
            return recyclerView.getPaddingRight();
        }
        return 0;
    }

    public final int u() {
        RecyclerView recyclerView = this.f2372b;
        if (recyclerView != null) {
            return recyclerView.getPaddingTop();
        }
        return 0;
    }

    public int x(J1.c cVar, B b5) {
        RecyclerView recyclerView = this.f2372b;
        if (recyclerView == null) {
            return 1;
        }
        recyclerView.getClass();
        return 1;
    }

    public abstract boolean y();

    public abstract void z(RecyclerView recyclerView);

    public void D(int i4) {
    }
}
