package androidx.appcompat.widget;

import A.C;
import A.C0012l;
import A.InterfaceC0010j;
import A.InterfaceC0011k;
import A.r;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewPropertyAnimator;
import android.view.Window;
import android.widget.OverScroller;
import com.google.android.gms.common.api.f;
import com.swing.live.R;
import g.AbstractC0404a;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import k.C0485b;
import k.C0488e;
import k.InterfaceC0487d;
import k.InterfaceC0507y;
import k.RunnableC0486c;
import k.p0;
import k.v0;

/* JADX INFO: loaded from: classes.dex */
public class ActionBarOverlayLayout extends ViewGroup implements InterfaceC0010j, InterfaceC0011k {

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public static final int[] f2691E = {R.attr.actionBarSize, android.R.attr.windowContentOverlay};

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public final C0485b f2692A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final RunnableC0486c f2693B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final RunnableC0486c f2694C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public final C0012l f2695D;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2696a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ContentFrameLayout f2697b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ActionBarContainer f2698c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public InterfaceC0507y f2699d;
    public Drawable e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f2700f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f2701m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public boolean f2702n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f2703o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public boolean f2704p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f2705q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final Rect f2706r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final Rect f2707s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final Rect f2708t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final Rect f2709u;
    public final Rect v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final Rect f2710w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final Rect f2711x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public OverScroller f2712y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public ViewPropertyAnimator f2713z;

    public ActionBarOverlayLayout(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        this.f2706r = new Rect();
        this.f2707s = new Rect();
        this.f2708t = new Rect();
        this.f2709u = new Rect();
        this.v = new Rect();
        this.f2710w = new Rect();
        this.f2711x = new Rect();
        this.f2692A = new C0485b(this);
        this.f2693B = new RunnableC0486c(this, 0);
        this.f2694C = new RunnableC0486c(this, 1);
        i(context);
        this.f2695D = new C0012l();
    }

    public static boolean g(View view, Rect rect, boolean z4) {
        boolean z5;
        C0488e c0488e = (C0488e) view.getLayoutParams();
        int i4 = ((ViewGroup.MarginLayoutParams) c0488e).leftMargin;
        int i5 = rect.left;
        if (i4 != i5) {
            ((ViewGroup.MarginLayoutParams) c0488e).leftMargin = i5;
            z5 = true;
        } else {
            z5 = false;
        }
        int i6 = ((ViewGroup.MarginLayoutParams) c0488e).topMargin;
        int i7 = rect.top;
        if (i6 != i7) {
            ((ViewGroup.MarginLayoutParams) c0488e).topMargin = i7;
            z5 = true;
        }
        int i8 = ((ViewGroup.MarginLayoutParams) c0488e).rightMargin;
        int i9 = rect.right;
        if (i8 != i9) {
            ((ViewGroup.MarginLayoutParams) c0488e).rightMargin = i9;
            z5 = true;
        }
        if (z4) {
            int i10 = ((ViewGroup.MarginLayoutParams) c0488e).bottomMargin;
            int i11 = rect.bottom;
            if (i10 != i11) {
                ((ViewGroup.MarginLayoutParams) c0488e).bottomMargin = i11;
                return true;
            }
        }
        return z5;
    }

    @Override // A.InterfaceC0010j
    public final void a(View view, View view2, int i4, int i5) {
        if (i5 == 0) {
            onNestedScrollAccepted(view, view2, i4);
        }
    }

    @Override // A.InterfaceC0010j
    public final void b(ViewGroup viewGroup, int i4, int i5, int i6, int i7, int i8) {
        if (i8 == 0) {
            onNestedScroll(viewGroup, i4, i5, i6, i7);
        }
    }

    @Override // A.InterfaceC0010j
    public final void c(View view, int i4) {
        if (i4 == 0) {
            onStopNestedScroll(view);
        }
    }

    @Override // android.view.ViewGroup
    public final boolean checkLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return layoutParams instanceof C0488e;
    }

    @Override // android.view.View
    public final void draw(Canvas canvas) {
        int translationY;
        super.draw(canvas);
        if (this.e == null || this.f2700f) {
            return;
        }
        if (this.f2698c.getVisibility() == 0) {
            translationY = (int) (this.f2698c.getTranslationY() + this.f2698c.getBottom() + 0.5f);
        } else {
            translationY = 0;
        }
        this.e.setBounds(0, translationY, getWidth(), this.e.getIntrinsicHeight() + translationY);
        this.e.draw(canvas);
    }

    @Override // A.InterfaceC0011k
    public final void e(ViewGroup viewGroup, int i4, int i5, int i6, int i7, int i8, int[] iArr) {
        b(viewGroup, i4, i5, i6, i7, i8);
    }

    @Override // A.InterfaceC0010j
    public final boolean f(View view, View view2, int i4, int i5) {
        return i5 == 0 && onStartNestedScroll(view, view2, i4);
    }

    @Override // android.view.View
    public final boolean fitSystemWindows(Rect rect) {
        j();
        Field field = C.f4a;
        getWindowSystemUiVisibility();
        boolean zG = g(this.f2698c, rect, false);
        Rect rect2 = this.f2709u;
        rect2.set(rect);
        Method method = v0.f5477a;
        Rect rect3 = this.f2706r;
        if (method != null) {
            try {
                method.invoke(this, rect2, rect3);
            } catch (Exception e) {
                Log.d("ViewUtils", "Could not invoke computeFitSystemWindows", e);
            }
        }
        Rect rect4 = this.v;
        if (!rect4.equals(rect2)) {
            rect4.set(rect2);
            zG = true;
        }
        Rect rect5 = this.f2707s;
        if (!rect5.equals(rect3)) {
            rect5.set(rect3);
            zG = true;
        }
        if (zG) {
            requestLayout();
        }
        return true;
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateDefaultLayoutParams() {
        return new C0488e(-1, -1);
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateLayoutParams(AttributeSet attributeSet) {
        return new C0488e(getContext(), attributeSet);
    }

    public int getActionBarHideOffset() {
        ActionBarContainer actionBarContainer = this.f2698c;
        if (actionBarContainer != null) {
            return -((int) actionBarContainer.getTranslationY());
        }
        return 0;
    }

    @Override // android.view.ViewGroup
    public int getNestedScrollAxes() {
        C0012l c0012l = this.f2695D;
        return c0012l.f56c | c0012l.f55b;
    }

    public CharSequence getTitle() {
        j();
        return ((p0) this.f2699d).f5425a.getTitle();
    }

    public final void h() {
        removeCallbacks(this.f2693B);
        removeCallbacks(this.f2694C);
        ViewPropertyAnimator viewPropertyAnimator = this.f2713z;
        if (viewPropertyAnimator != null) {
            viewPropertyAnimator.cancel();
        }
    }

    public final void i(Context context) {
        TypedArray typedArrayObtainStyledAttributes = getContext().getTheme().obtainStyledAttributes(f2691E);
        this.f2696a = typedArrayObtainStyledAttributes.getDimensionPixelSize(0, 0);
        Drawable drawable = typedArrayObtainStyledAttributes.getDrawable(1);
        this.e = drawable;
        setWillNotDraw(drawable == null);
        typedArrayObtainStyledAttributes.recycle();
        this.f2700f = context.getApplicationInfo().targetSdkVersion < 19;
        this.f2712y = new OverScroller(context);
    }

    public final void j() {
        InterfaceC0507y wrapper;
        if (this.f2697b == null) {
            this.f2697b = (ContentFrameLayout) findViewById(R.id.action_bar_activity_content);
            this.f2698c = (ActionBarContainer) findViewById(R.id.action_bar_container);
            KeyEvent.Callback callbackFindViewById = findViewById(R.id.action_bar);
            if (callbackFindViewById instanceof InterfaceC0507y) {
                wrapper = (InterfaceC0507y) callbackFindViewById;
            } else {
                if (!(callbackFindViewById instanceof Toolbar)) {
                    throw new IllegalStateException("Can't make a decor toolbar out of ".concat(callbackFindViewById.getClass().getSimpleName()));
                }
                wrapper = ((Toolbar) callbackFindViewById).getWrapper();
            }
            this.f2699d = wrapper;
        }
    }

    @Override // android.view.View
    public final void onConfigurationChanged(Configuration configuration) {
        super.onConfigurationChanged(configuration);
        i(getContext());
        Field field = C.f4a;
        r.c(this);
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        h();
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        int childCount = getChildCount();
        int paddingLeft = getPaddingLeft();
        getPaddingRight();
        int paddingTop = getPaddingTop();
        getPaddingBottom();
        for (int i8 = 0; i8 < childCount; i8++) {
            View childAt = getChildAt(i8);
            if (childAt.getVisibility() != 8) {
                C0488e c0488e = (C0488e) childAt.getLayoutParams();
                int measuredWidth = childAt.getMeasuredWidth();
                int measuredHeight = childAt.getMeasuredHeight();
                int i9 = ((ViewGroup.MarginLayoutParams) c0488e).leftMargin + paddingLeft;
                int i10 = ((ViewGroup.MarginLayoutParams) c0488e).topMargin + paddingTop;
                childAt.layout(i9, i10, measuredWidth + i9, measuredHeight + i10);
            }
        }
    }

    @Override // android.view.View
    public final void onMeasure(int i4, int i5) {
        j();
        measureChildWithMargins(this.f2698c, i4, 0, i5, 0);
        C0488e c0488e = (C0488e) this.f2698c.getLayoutParams();
        int measuredHeight = 0;
        int iMax = Math.max(0, this.f2698c.getMeasuredWidth() + ((ViewGroup.MarginLayoutParams) c0488e).leftMargin + ((ViewGroup.MarginLayoutParams) c0488e).rightMargin);
        int iMax2 = Math.max(0, this.f2698c.getMeasuredHeight() + ((ViewGroup.MarginLayoutParams) c0488e).topMargin + ((ViewGroup.MarginLayoutParams) c0488e).bottomMargin);
        int iCombineMeasuredStates = View.combineMeasuredStates(0, this.f2698c.getMeasuredState());
        Field field = C.f4a;
        boolean z4 = (getWindowSystemUiVisibility() & 256) != 0;
        if (z4) {
            measuredHeight = this.f2696a;
            if (this.f2702n && this.f2698c.getTabContainer() != null) {
                measuredHeight += this.f2696a;
            }
        } else if (this.f2698c.getVisibility() != 8) {
            measuredHeight = this.f2698c.getMeasuredHeight();
        }
        Rect rect = this.f2706r;
        Rect rect2 = this.f2708t;
        rect2.set(rect);
        Rect rect3 = this.f2710w;
        rect3.set(this.f2709u);
        if (this.f2701m || z4) {
            rect3.top += measuredHeight;
            rect3.bottom = rect3.bottom;
        } else {
            rect2.top += measuredHeight;
            rect2.bottom = rect2.bottom;
        }
        g(this.f2697b, rect2, true);
        Rect rect4 = this.f2711x;
        if (!rect4.equals(rect3)) {
            rect4.set(rect3);
            this.f2697b.a(rect3);
        }
        measureChildWithMargins(this.f2697b, i4, 0, i5, 0);
        C0488e c0488e2 = (C0488e) this.f2697b.getLayoutParams();
        int iMax3 = Math.max(iMax, this.f2697b.getMeasuredWidth() + ((ViewGroup.MarginLayoutParams) c0488e2).leftMargin + ((ViewGroup.MarginLayoutParams) c0488e2).rightMargin);
        int iMax4 = Math.max(iMax2, this.f2697b.getMeasuredHeight() + ((ViewGroup.MarginLayoutParams) c0488e2).topMargin + ((ViewGroup.MarginLayoutParams) c0488e2).bottomMargin);
        int iCombineMeasuredStates2 = View.combineMeasuredStates(iCombineMeasuredStates, this.f2697b.getMeasuredState());
        setMeasuredDimension(View.resolveSizeAndState(Math.max(getPaddingRight() + getPaddingLeft() + iMax3, getSuggestedMinimumWidth()), i4, iCombineMeasuredStates2), View.resolveSizeAndState(Math.max(getPaddingBottom() + getPaddingTop() + iMax4, getSuggestedMinimumHeight()), i5, iCombineMeasuredStates2 << 16));
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean onNestedFling(View view, float f4, float f5, boolean z4) {
        if (!this.f2703o || !z4) {
            return false;
        }
        this.f2712y.fling(0, 0, 0, (int) f5, 0, 0, Integer.MIN_VALUE, f.API_PRIORITY_OTHER);
        if (this.f2712y.getFinalY() > this.f2698c.getHeight()) {
            h();
            this.f2694C.run();
        } else {
            h();
            this.f2693B.run();
        }
        this.f2704p = true;
        return true;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean onNestedPreFling(View view, float f4, float f5) {
        return false;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onNestedPreScroll(View view, int i4, int i5, int[] iArr) {
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onNestedScroll(View view, int i4, int i5, int i6, int i7) {
        int i8 = this.f2705q + i5;
        this.f2705q = i8;
        setActionBarHideOffset(i8);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onNestedScrollAccepted(View view, View view2, int i4) {
        this.f2695D.f55b = i4;
        this.f2705q = getActionBarHideOffset();
        h();
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean onStartNestedScroll(View view, View view2, int i4) {
        if ((i4 & 2) == 0 || this.f2698c.getVisibility() != 0) {
            return false;
        }
        return this.f2703o;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onStopNestedScroll(View view) {
        if (!this.f2703o || this.f2704p) {
            return;
        }
        if (this.f2705q <= this.f2698c.getHeight()) {
            h();
            postDelayed(this.f2693B, 600L);
        } else {
            h();
            postDelayed(this.f2694C, 600L);
        }
    }

    @Override // android.view.View
    public final void onWindowSystemUiVisibilityChanged(int i4) {
        super.onWindowSystemUiVisibilityChanged(i4);
        j();
    }

    @Override // android.view.View
    public final void onWindowVisibilityChanged(int i4) {
        super.onWindowVisibilityChanged(i4);
    }

    public void setActionBarHideOffset(int i4) {
        h();
        this.f2698c.setTranslationY(-Math.max(0, Math.min(i4, this.f2698c.getHeight())));
    }

    public void setActionBarVisibilityCallback(InterfaceC0487d interfaceC0487d) {
        if (getWindowToken() != null) {
            throw null;
        }
    }

    public void setHasNonEmbeddedTabs(boolean z4) {
        this.f2702n = z4;
    }

    public void setHideOnContentScrollEnabled(boolean z4) {
        if (z4 != this.f2703o) {
            this.f2703o = z4;
            if (z4) {
                return;
            }
            h();
            setActionBarHideOffset(0);
        }
    }

    public void setIcon(int i4) {
        j();
        p0 p0Var = (p0) this.f2699d;
        p0Var.f5428d = i4 != 0 ? AbstractC0404a.a(p0Var.f5425a.getContext(), i4) : null;
        p0Var.c();
    }

    public void setLogo(int i4) {
        j();
        p0 p0Var = (p0) this.f2699d;
        p0Var.e = i4 != 0 ? AbstractC0404a.a(p0Var.f5425a.getContext(), i4) : null;
        p0Var.c();
    }

    public void setOverlayMode(boolean z4) {
        this.f2701m = z4;
        this.f2700f = z4 && getContext().getApplicationInfo().targetSdkVersion < 19;
    }

    public void setShowingForActionMode(boolean z4) {
    }

    public void setUiOptions(int i4) {
    }

    public void setWindowCallback(Window.Callback callback) {
        j();
        ((p0) this.f2699d).f5434k = callback;
    }

    public void setWindowTitle(CharSequence charSequence) {
        j();
        p0 p0Var = (p0) this.f2699d;
        if (p0Var.f5430g) {
            return;
        }
        p0Var.f5431h = charSequence;
        if ((p0Var.f5426b & 8) != 0) {
            p0Var.f5425a.setTitle(charSequence);
        }
    }

    @Override // android.view.ViewGroup
    public final boolean shouldDelayChildPressedState() {
        return false;
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return new C0488e(layoutParams);
    }

    public void setIcon(Drawable drawable) {
        j();
        p0 p0Var = (p0) this.f2699d;
        p0Var.f5428d = drawable;
        p0Var.c();
    }

    @Override // A.InterfaceC0010j
    public final void d(int i4, int i5, int[] iArr, int i6) {
    }
}
