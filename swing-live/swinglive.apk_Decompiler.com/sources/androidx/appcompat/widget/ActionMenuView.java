package androidx.appcompat.widget;

import X.N;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.ContextThemeWrapper;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import androidx.appcompat.view.menu.ActionMenuItemView;
import com.google.android.gms.common.api.f;
import j.i;
import j.j;
import j.k;
import k.AbstractC0478F;
import k.C0477E;
import k.C0489f;
import k.C0491h;
import k.C0492i;
import k.C0494k;
import k.InterfaceC0493j;
import k.InterfaceC0495l;
import k.v0;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public class ActionMenuView extends AbstractC0478F implements i {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public int f2714A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final int f2715B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final int f2716C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public InterfaceC0495l f2717D;
    public j v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public Context f2718w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public int f2719x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public C0492i f2720y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public boolean f2721z;

    public ActionMenuView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, 0);
        setBaselineAligned(false);
        float f4 = context.getResources().getDisplayMetrics().density;
        this.f2715B = (int) (56.0f * f4);
        this.f2716C = (int) (f4 * 4.0f);
        this.f2718w = context;
        this.f2719x = 0;
    }

    public static C0494k h() {
        C0494k c0494k = new C0494k(-2);
        c0494k.f5398c = false;
        c0494k.f5268b = 16;
        return c0494k;
    }

    public static C0494k i(ViewGroup.LayoutParams layoutParams) {
        C0494k c0494k;
        if (layoutParams == null) {
            return h();
        }
        if (layoutParams instanceof C0494k) {
            C0494k c0494k2 = (C0494k) layoutParams;
            c0494k = new C0494k(c0494k2);
            c0494k.f5398c = c0494k2.f5398c;
        } else {
            c0494k = new C0494k(layoutParams);
        }
        if (c0494k.f5268b <= 0) {
            c0494k.f5268b = 16;
        }
        return c0494k;
    }

    @Override // j.i
    public final boolean a(k kVar) {
        return this.v.p(kVar, null, 0);
    }

    @Override // k.AbstractC0478F, android.view.ViewGroup
    public final boolean checkLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return layoutParams instanceof C0494k;
    }

    @Override // k.AbstractC0478F
    /* JADX INFO: renamed from: d */
    public final /* bridge */ /* synthetic */ C0477E generateDefaultLayoutParams() {
        return h();
    }

    @Override // android.view.View
    public final boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        return false;
    }

    @Override // k.AbstractC0478F
    /* JADX INFO: renamed from: e */
    public final C0477E generateLayoutParams(AttributeSet attributeSet) {
        return new C0494k(getContext(), attributeSet);
    }

    @Override // k.AbstractC0478F
    /* JADX INFO: renamed from: f */
    public final /* bridge */ /* synthetic */ C0477E generateLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return i(layoutParams);
    }

    @Override // k.AbstractC0478F, android.view.ViewGroup
    public final /* bridge */ /* synthetic */ ViewGroup.LayoutParams generateDefaultLayoutParams() {
        return h();
    }

    @Override // k.AbstractC0478F, android.view.ViewGroup
    public final /* bridge */ /* synthetic */ ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return i(layoutParams);
    }

    public Menu getMenu() {
        if (this.v == null) {
            Context context = getContext();
            j jVar = new j(context);
            this.v = jVar;
            jVar.e = new C0779j(this, 27);
            C0492i c0492i = new C0492i(context);
            this.f2720y = c0492i;
            c0492i.f5388q = true;
            c0492i.f5389r = true;
            c0492i.e = new N(20);
            this.v.b(c0492i, this.f2718w);
            C0492i c0492i2 = this.f2720y;
            c0492i2.f5384m = this;
            this.v = c0492i2.f5381c;
        }
        return this.v;
    }

    public Drawable getOverflowIcon() {
        getMenu();
        C0492i c0492i = this.f2720y;
        C0491h c0491h = c0492i.f5385n;
        if (c0491h != null) {
            return c0491h.getDrawable();
        }
        if (c0492i.f5387p) {
            return c0492i.f5386o;
        }
        return null;
    }

    public int getPopupTheme() {
        return this.f2719x;
    }

    public int getWindowAnimations() {
        return 0;
    }

    public final boolean j(int i4) {
        boolean zA = false;
        if (i4 == 0) {
            return false;
        }
        KeyEvent.Callback childAt = getChildAt(i4 - 1);
        KeyEvent.Callback childAt2 = getChildAt(i4);
        if (i4 < getChildCount() && (childAt instanceof InterfaceC0493j)) {
            zA = ((InterfaceC0493j) childAt).a();
        }
        return (i4 <= 0 || !(childAt2 instanceof InterfaceC0493j)) ? zA : ((InterfaceC0493j) childAt2).b() | zA;
    }

    @Override // android.view.View
    public final void onConfigurationChanged(Configuration configuration) {
        super.onConfigurationChanged(configuration);
        C0492i c0492i = this.f2720y;
        if (c0492i != null) {
            c0492i.f();
            C0489f c0489f = this.f2720y.f5394x;
            if (c0489f == null || !c0489f.b()) {
                return;
            }
            this.f2720y.g();
            this.f2720y.h();
        }
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        C0492i c0492i = this.f2720y;
        if (c0492i != null) {
            c0492i.g();
            C0489f c0489f = c0492i.f5395y;
            if (c0489f == null || !c0489f.b()) {
                return;
            }
            c0489f.f5135i.dismiss();
        }
    }

    @Override // k.AbstractC0478F, android.view.ViewGroup, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        int width;
        int paddingLeft;
        if (!this.f2721z) {
            super.onLayout(z4, i4, i5, i6, i7);
            return;
        }
        int childCount = getChildCount();
        int i8 = (i7 - i5) / 2;
        int dividerWidth = getDividerWidth();
        int i9 = i6 - i4;
        int paddingRight = (i9 - getPaddingRight()) - getPaddingLeft();
        boolean zA = v0.a(this);
        int i10 = 0;
        int i11 = 0;
        for (int i12 = 0; i12 < childCount; i12++) {
            View childAt = getChildAt(i12);
            if (childAt.getVisibility() != 8) {
                C0494k c0494k = (C0494k) childAt.getLayoutParams();
                if (c0494k.f5398c) {
                    int measuredWidth = childAt.getMeasuredWidth();
                    if (j(i12)) {
                        measuredWidth += dividerWidth;
                    }
                    int measuredHeight = childAt.getMeasuredHeight();
                    if (zA) {
                        paddingLeft = getPaddingLeft() + ((ViewGroup.MarginLayoutParams) c0494k).leftMargin;
                        width = paddingLeft + measuredWidth;
                    } else {
                        width = (getWidth() - getPaddingRight()) - ((ViewGroup.MarginLayoutParams) c0494k).rightMargin;
                        paddingLeft = width - measuredWidth;
                    }
                    int i13 = i8 - (measuredHeight / 2);
                    childAt.layout(paddingLeft, i13, width, measuredHeight + i13);
                    paddingRight -= measuredWidth;
                    i10 = 1;
                } else {
                    paddingRight -= (childAt.getMeasuredWidth() + ((ViewGroup.MarginLayoutParams) c0494k).leftMargin) + ((ViewGroup.MarginLayoutParams) c0494k).rightMargin;
                    j(i12);
                    i11++;
                }
            }
        }
        if (childCount == 1 && i10 == 0) {
            View childAt2 = getChildAt(0);
            int measuredWidth2 = childAt2.getMeasuredWidth();
            int measuredHeight2 = childAt2.getMeasuredHeight();
            int i14 = (i9 / 2) - (measuredWidth2 / 2);
            int i15 = i8 - (measuredHeight2 / 2);
            childAt2.layout(i14, i15, measuredWidth2 + i14, measuredHeight2 + i15);
            return;
        }
        int i16 = i11 - (i10 ^ 1);
        int iMax = Math.max(0, i16 > 0 ? paddingRight / i16 : 0);
        if (zA) {
            int width2 = getWidth() - getPaddingRight();
            for (int i17 = 0; i17 < childCount; i17++) {
                View childAt3 = getChildAt(i17);
                C0494k c0494k2 = (C0494k) childAt3.getLayoutParams();
                if (childAt3.getVisibility() != 8 && !c0494k2.f5398c) {
                    int i18 = width2 - ((ViewGroup.MarginLayoutParams) c0494k2).rightMargin;
                    int measuredWidth3 = childAt3.getMeasuredWidth();
                    int measuredHeight3 = childAt3.getMeasuredHeight();
                    int i19 = i8 - (measuredHeight3 / 2);
                    childAt3.layout(i18 - measuredWidth3, i19, i18, measuredHeight3 + i19);
                    width2 = i18 - ((measuredWidth3 + ((ViewGroup.MarginLayoutParams) c0494k2).leftMargin) + iMax);
                }
            }
            return;
        }
        int paddingLeft2 = getPaddingLeft();
        for (int i20 = 0; i20 < childCount; i20++) {
            View childAt4 = getChildAt(i20);
            C0494k c0494k3 = (C0494k) childAt4.getLayoutParams();
            if (childAt4.getVisibility() != 8 && !c0494k3.f5398c) {
                int i21 = paddingLeft2 + ((ViewGroup.MarginLayoutParams) c0494k3).leftMargin;
                int measuredWidth4 = childAt4.getMeasuredWidth();
                int measuredHeight4 = childAt4.getMeasuredHeight();
                int i22 = i8 - (measuredHeight4 / 2);
                childAt4.layout(i21, i22, i21 + measuredWidth4, measuredHeight4 + i22);
                paddingLeft2 = measuredWidth4 + ((ViewGroup.MarginLayoutParams) c0494k3).rightMargin + iMax + i21;
            }
        }
    }

    /* JADX WARN: Type inference failed for: r11v14 */
    /* JADX WARN: Type inference failed for: r11v15, types: [boolean, int] */
    /* JADX WARN: Type inference failed for: r11v17 */
    /* JADX WARN: Type inference failed for: r11v40 */
    @Override // k.AbstractC0478F, android.view.View
    public final void onMeasure(int i4, int i5) {
        int i6;
        int i7;
        ?? r11;
        int i8;
        int i9;
        j jVar;
        boolean z4 = this.f2721z;
        boolean z5 = View.MeasureSpec.getMode(i4) == 1073741824;
        this.f2721z = z5;
        if (z4 != z5) {
            this.f2714A = 0;
        }
        int size = View.MeasureSpec.getSize(i4);
        if (this.f2721z && (jVar = this.v) != null && size != this.f2714A) {
            this.f2714A = size;
            jVar.o(true);
        }
        int childCount = getChildCount();
        if (!this.f2721z || childCount <= 0) {
            for (int i10 = 0; i10 < childCount; i10++) {
                C0494k c0494k = (C0494k) getChildAt(i10).getLayoutParams();
                ((ViewGroup.MarginLayoutParams) c0494k).rightMargin = 0;
                ((ViewGroup.MarginLayoutParams) c0494k).leftMargin = 0;
            }
            super.onMeasure(i4, i5);
            return;
        }
        int mode = View.MeasureSpec.getMode(i5);
        int size2 = View.MeasureSpec.getSize(i4);
        int size3 = View.MeasureSpec.getSize(i5);
        int paddingRight = getPaddingRight() + getPaddingLeft();
        int paddingBottom = getPaddingBottom() + getPaddingTop();
        int childMeasureSpec = ViewGroup.getChildMeasureSpec(i5, paddingBottom, -2);
        int i11 = size2 - paddingRight;
        int i12 = this.f2715B;
        int i13 = i11 / i12;
        int i14 = i11 % i12;
        if (i13 == 0) {
            setMeasuredDimension(i11, 0);
            return;
        }
        int i15 = (i14 / i13) + i12;
        int childCount2 = getChildCount();
        int iMax = 0;
        int i16 = 0;
        int iMax2 = 0;
        int i17 = 0;
        boolean z6 = false;
        int i18 = 0;
        long j4 = 0;
        while (true) {
            i6 = this.f2716C;
            if (i17 >= childCount2) {
                break;
            }
            View childAt = getChildAt(i17);
            int i19 = size3;
            int i20 = paddingBottom;
            if (childAt.getVisibility() == 8) {
                i8 = i15;
            } else {
                boolean z7 = childAt instanceof ActionMenuItemView;
                i16++;
                if (z7) {
                    childAt.setPadding(i6, 0, i6, 0);
                }
                C0494k c0494k2 = (C0494k) childAt.getLayoutParams();
                c0494k2.f5402h = false;
                c0494k2.e = 0;
                c0494k2.f5399d = 0;
                c0494k2.f5400f = false;
                ((ViewGroup.MarginLayoutParams) c0494k2).leftMargin = 0;
                ((ViewGroup.MarginLayoutParams) c0494k2).rightMargin = 0;
                c0494k2.f5401g = z7 && !TextUtils.isEmpty(((ActionMenuItemView) childAt).getText());
                int i21 = c0494k2.f5398c ? 1 : i13;
                C0494k c0494k3 = (C0494k) childAt.getLayoutParams();
                int i22 = i13;
                i8 = i15;
                int iMakeMeasureSpec = View.MeasureSpec.makeMeasureSpec(View.MeasureSpec.getSize(childMeasureSpec) - i20, View.MeasureSpec.getMode(childMeasureSpec));
                ActionMenuItemView actionMenuItemView = z7 ? (ActionMenuItemView) childAt : null;
                boolean z8 = (actionMenuItemView == null || TextUtils.isEmpty(actionMenuItemView.getText())) ? false : true;
                boolean z9 = z8;
                if (i21 <= 0 || (z8 && i21 < 2)) {
                    i9 = 0;
                } else {
                    childAt.measure(View.MeasureSpec.makeMeasureSpec(i8 * i21, Integer.MIN_VALUE), iMakeMeasureSpec);
                    int measuredWidth = childAt.getMeasuredWidth();
                    i9 = measuredWidth / i8;
                    if (measuredWidth % i8 != 0) {
                        i9++;
                    }
                    if (z9 && i9 < 2) {
                        i9 = 2;
                    }
                }
                c0494k3.f5400f = !c0494k3.f5398c && z9;
                c0494k3.f5399d = i9;
                childAt.measure(View.MeasureSpec.makeMeasureSpec(i9 * i8, 1073741824), iMakeMeasureSpec);
                iMax2 = Math.max(iMax2, i9);
                if (c0494k2.f5400f) {
                    i18++;
                }
                if (c0494k2.f5398c) {
                    z6 = true;
                }
                i13 = i22 - i9;
                iMax = Math.max(iMax, childAt.getMeasuredHeight());
                if (i9 == 1) {
                    j4 |= (long) (1 << i17);
                }
            }
            i17++;
            size3 = i19;
            paddingBottom = i20;
            i15 = i8;
        }
        int i23 = size3;
        int i24 = i13;
        int i25 = i15;
        boolean z10 = z6 && i16 == 2;
        int i26 = i24;
        boolean z11 = false;
        while (i18 > 0 && i26 > 0) {
            int i27 = f.API_PRIORITY_OTHER;
            long j5 = 0;
            int i28 = 0;
            int i29 = 0;
            while (i29 < childCount2) {
                boolean z12 = z10;
                C0494k c0494k4 = (C0494k) getChildAt(i29).getLayoutParams();
                int i30 = iMax;
                if (c0494k4.f5400f) {
                    int i31 = c0494k4.f5399d;
                    if (i31 < i27) {
                        j5 = 1 << i29;
                        i27 = i31;
                        i28 = 1;
                    } else if (i31 == i27) {
                        j5 |= 1 << i29;
                        i28++;
                    }
                }
                i29++;
                iMax = i30;
                z10 = z12;
            }
            boolean z13 = z10;
            i7 = iMax;
            j4 |= j5;
            if (i28 > i26) {
                break;
            }
            int i32 = i27 + 1;
            int i33 = 0;
            while (i33 < childCount2) {
                View childAt2 = getChildAt(i33);
                C0494k c0494k5 = (C0494k) childAt2.getLayoutParams();
                boolean z14 = z6;
                long j6 = 1 << i33;
                if ((j5 & j6) != 0) {
                    if (z13 && c0494k5.f5401g) {
                        r11 = 1;
                        r11 = 1;
                        if (i26 == 1) {
                            childAt2.setPadding(i6 + i25, 0, i6, 0);
                        }
                    } else {
                        r11 = 1;
                    }
                    c0494k5.f5399d += r11;
                    c0494k5.f5402h = r11;
                    i26--;
                } else if (c0494k5.f5399d == i32) {
                    j4 |= j6;
                }
                i33++;
                z6 = z14;
            }
            iMax = i7;
            z10 = z13;
            z11 = true;
        }
        i7 = iMax;
        boolean z15 = !z6 && i16 == 1;
        if (i26 > 0 && j4 != 0 && (i26 < i16 - 1 || z15 || iMax2 > 1)) {
            float fBitCount = Long.bitCount(j4);
            if (!z15) {
                if ((j4 & 1) != 0 && !((C0494k) getChildAt(0).getLayoutParams()).f5401g) {
                    fBitCount -= 0.5f;
                }
                int i34 = childCount2 - 1;
                if ((j4 & ((long) (1 << i34))) != 0 && !((C0494k) getChildAt(i34).getLayoutParams()).f5401g) {
                    fBitCount -= 0.5f;
                }
            }
            int i35 = fBitCount > 0.0f ? (int) ((i26 * i25) / fBitCount) : 0;
            boolean z16 = z11;
            for (int i36 = 0; i36 < childCount2; i36++) {
                if ((j4 & ((long) (1 << i36))) != 0) {
                    View childAt3 = getChildAt(i36);
                    C0494k c0494k6 = (C0494k) childAt3.getLayoutParams();
                    if (childAt3 instanceof ActionMenuItemView) {
                        c0494k6.e = i35;
                        c0494k6.f5402h = true;
                        if (i36 == 0 && !c0494k6.f5401g) {
                            ((ViewGroup.MarginLayoutParams) c0494k6).leftMargin = (-i35) / 2;
                        }
                        z16 = true;
                    } else if (c0494k6.f5398c) {
                        c0494k6.e = i35;
                        c0494k6.f5402h = true;
                        ((ViewGroup.MarginLayoutParams) c0494k6).rightMargin = (-i35) / 2;
                        z16 = true;
                    } else {
                        if (i36 != 0) {
                            ((ViewGroup.MarginLayoutParams) c0494k6).leftMargin = i35 / 2;
                        }
                        if (i36 != childCount2 - 1) {
                            ((ViewGroup.MarginLayoutParams) c0494k6).rightMargin = i35 / 2;
                        }
                    }
                }
            }
            z11 = z16;
        }
        if (z11) {
            for (int i37 = 0; i37 < childCount2; i37++) {
                View childAt4 = getChildAt(i37);
                C0494k c0494k7 = (C0494k) childAt4.getLayoutParams();
                if (c0494k7.f5402h) {
                    childAt4.measure(View.MeasureSpec.makeMeasureSpec((c0494k7.f5399d * i25) + c0494k7.e, 1073741824), childMeasureSpec);
                }
            }
        }
        setMeasuredDimension(i11, mode != 1073741824 ? i7 : i23);
    }

    public void setExpandedActionViewsExclusive(boolean z4) {
        this.f2720y.v = z4;
    }

    public void setOnMenuItemClickListener(InterfaceC0495l interfaceC0495l) {
        this.f2717D = interfaceC0495l;
    }

    public void setOverflowIcon(Drawable drawable) {
        getMenu();
        C0492i c0492i = this.f2720y;
        C0491h c0491h = c0492i.f5385n;
        if (c0491h != null) {
            c0491h.setImageDrawable(drawable);
        } else {
            c0492i.f5387p = true;
            c0492i.f5386o = drawable;
        }
    }

    public void setOverflowReserved(boolean z4) {
    }

    public void setPopupTheme(int i4) {
        if (this.f2719x != i4) {
            this.f2719x = i4;
            if (i4 == 0) {
                this.f2718w = getContext();
            } else {
                this.f2718w = new ContextThemeWrapper(getContext(), i4);
            }
        }
    }

    public void setPresenter(C0492i c0492i) {
        this.f2720y = c0492i;
        c0492i.f5384m = this;
        this.v = c0492i.f5381c;
    }

    @Override // k.AbstractC0478F, android.view.ViewGroup
    public final ViewGroup.LayoutParams generateLayoutParams(AttributeSet attributeSet) {
        return new C0494k(getContext(), attributeSet);
    }
}
