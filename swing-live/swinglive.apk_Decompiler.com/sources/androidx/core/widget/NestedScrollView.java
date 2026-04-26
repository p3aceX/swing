package androidx.core.widget;

import A.AbstractC0019t;
import A.C;
import A.C0004d;
import A.C0009i;
import A.C0012l;
import A.InterfaceC0011k;
import F.e;
import F.h;
import F.i;
import F.j;
import F.k;
import a.AbstractC0184a;
import android.R;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.os.Build;
import android.os.Parcelable;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.FocusFinder;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.animation.AnimationUtils;
import android.widget.EdgeEffect;
import android.widget.FrameLayout;
import android.widget.OverScroller;
import com.google.android.gms.common.api.f;
import java.lang.reflect.Field;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public class NestedScrollView extends FrameLayout implements InterfaceC0011k {

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public static final float f2867H = (float) (Math.log(0.78d) / Math.log(0.9d));

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public static final h f2868I = new h();
    public static final int[] J = {R.attr.fillViewport};

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public int f2869A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public int f2870B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public k f2871C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public final C0012l f2872D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public final C0009i f2873E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public float f2874F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public final C0004d f2875G;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final float f2876a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public long f2877b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Rect f2878c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final OverScroller f2879d;
    public final EdgeEffect e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final EdgeEffect f2880f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f2881m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public boolean f2882n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f2883o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public View f2884p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public boolean f2885q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public VelocityTracker f2886r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public boolean f2887s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f2888t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final int f2889u;
    public final int v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final int f2890w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public int f2891x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final int[] f2892y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public final int[] f2893z;

    public NestedScrollView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, com.swing.live.R.attr.nestedScrollViewStyle);
        this.f2878c = new Rect();
        this.f2882n = true;
        this.f2883o = false;
        this.f2884p = null;
        this.f2885q = false;
        this.f2888t = true;
        this.f2891x = -1;
        this.f2892y = new int[2];
        this.f2893z = new int[2];
        this.f2875G = new C0004d(getContext(), new C0779j(this, 3));
        int i4 = Build.VERSION.SDK_INT;
        this.e = i4 >= 31 ? e.a(context, attributeSet) : new EdgeEffect(context);
        this.f2880f = i4 >= 31 ? e.a(context, attributeSet) : new EdgeEffect(context);
        this.f2876a = context.getResources().getDisplayMetrics().density * 160.0f * 386.0878f * 0.84f;
        this.f2879d = new OverScroller(getContext());
        setFocusable(true);
        setDescendantFocusability(262144);
        setWillNotDraw(false);
        ViewConfiguration viewConfiguration = ViewConfiguration.get(getContext());
        this.f2889u = viewConfiguration.getScaledTouchSlop();
        this.v = viewConfiguration.getScaledMinimumFlingVelocity();
        this.f2890w = viewConfiguration.getScaledMaximumFlingVelocity();
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, J, com.swing.live.R.attr.nestedScrollViewStyle, 0);
        setFillViewport(typedArrayObtainStyledAttributes.getBoolean(0, false));
        typedArrayObtainStyledAttributes.recycle();
        this.f2872D = new C0012l();
        this.f2873E = new C0009i(this);
        setNestedScrollingEnabled(true);
        C.a(this, f2868I);
    }

    public static boolean k(View view, NestedScrollView nestedScrollView) {
        if (view == nestedScrollView) {
            return true;
        }
        Object parent = view.getParent();
        return (parent instanceof ViewGroup) && k((View) parent, nestedScrollView);
    }

    @Override // A.InterfaceC0010j
    public final void a(View view, View view2, int i4, int i5) {
        C0012l c0012l = this.f2872D;
        if (i5 == 1) {
            c0012l.f56c = i4;
        } else {
            c0012l.f55b = i4;
        }
        u(2, i5);
    }

    @Override // android.view.ViewGroup
    public final void addView(View view) {
        if (getChildCount() > 0) {
            throw new IllegalStateException("ScrollView can host only one direct child");
        }
        super.addView(view);
    }

    @Override // A.InterfaceC0010j
    public final void b(ViewGroup viewGroup, int i4, int i5, int i6, int i7, int i8) {
        m(i7, i8, null);
    }

    @Override // A.InterfaceC0010j
    public final void c(View view, int i4) {
        C0012l c0012l = this.f2872D;
        if (i4 == 1) {
            c0012l.f56c = 0;
        } else {
            c0012l.f55b = 0;
        }
        w(i4);
    }

    @Override // android.view.View
    public final int computeHorizontalScrollExtent() {
        return super.computeHorizontalScrollExtent();
    }

    @Override // android.view.View
    public final int computeHorizontalScrollOffset() {
        return super.computeHorizontalScrollOffset();
    }

    @Override // android.view.View
    public final int computeHorizontalScrollRange() {
        return super.computeHorizontalScrollRange();
    }

    /* JADX WARN: Removed duplicated region for block: B:22:0x0083  */
    /* JADX WARN: Removed duplicated region for block: B:24:0x00a8  */
    /* JADX WARN: Removed duplicated region for block: B:38:0x00e5  */
    /* JADX WARN: Removed duplicated region for block: B:40:0x00e9  */
    @Override // android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void computeScroll() {
        /*
            Method dump skipped, instruction units count: 237
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.core.widget.NestedScrollView.computeScroll():void");
    }

    @Override // android.view.View
    public final int computeVerticalScrollExtent() {
        return super.computeVerticalScrollExtent();
    }

    @Override // android.view.View
    public final int computeVerticalScrollOffset() {
        return Math.max(0, super.computeVerticalScrollOffset());
    }

    @Override // android.view.View
    public final int computeVerticalScrollRange() {
        int childCount = getChildCount();
        int height = (getHeight() - getPaddingBottom()) - getPaddingTop();
        if (childCount == 0) {
            return height;
        }
        View childAt = getChildAt(0);
        int bottom = childAt.getBottom() + ((FrameLayout.LayoutParams) childAt.getLayoutParams()).bottomMargin;
        int scrollY = getScrollY();
        int iMax = Math.max(0, bottom - height);
        return scrollY < 0 ? bottom - scrollY : scrollY > iMax ? (scrollY - iMax) + bottom : bottom;
    }

    @Override // A.InterfaceC0010j
    public final void d(int i4, int i5, int[] iArr, int i6) {
        this.f2873E.c(i4, i5, iArr, null, i6);
    }

    /* JADX WARN: Removed duplicated region for block: B:26:0x0065  */
    /* JADX WARN: Removed duplicated region for block: B:42:0x00a1  */
    /* JADX WARN: Removed duplicated region for block: B:57:0x00cb A[RETURN] */
    @Override // android.view.ViewGroup, android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean dispatchKeyEvent(android.view.KeyEvent r7) {
        /*
            Method dump skipped, instruction units count: 205
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.core.widget.NestedScrollView.dispatchKeyEvent(android.view.KeyEvent):boolean");
    }

    @Override // android.view.View
    public final boolean dispatchNestedFling(float f4, float f5, boolean z4) {
        return this.f2873E.a(f4, f5, z4);
    }

    @Override // android.view.View
    public final boolean dispatchNestedPreFling(float f4, float f5) {
        return this.f2873E.b(f4, f5);
    }

    @Override // android.view.View
    public final boolean dispatchNestedPreScroll(int i4, int i5, int[] iArr, int[] iArr2) {
        return this.f2873E.c(i4, i5, iArr, iArr2, 0);
    }

    @Override // android.view.View
    public final boolean dispatchNestedScroll(int i4, int i5, int i6, int i7, int[] iArr) {
        return this.f2873E.d(i4, i5, i6, i7, iArr, 0, null);
    }

    @Override // android.view.View
    public final void draw(Canvas canvas) {
        int paddingLeft;
        super.draw(canvas);
        int scrollY = getScrollY();
        EdgeEffect edgeEffect = this.e;
        int paddingLeft2 = 0;
        if (!edgeEffect.isFinished()) {
            int iSave = canvas.save();
            int width = getWidth();
            int height = getHeight();
            int iMin = Math.min(0, scrollY);
            if (i.a(this)) {
                width -= getPaddingRight() + getPaddingLeft();
                paddingLeft = getPaddingLeft();
            } else {
                paddingLeft = 0;
            }
            if (i.a(this)) {
                height -= getPaddingBottom() + getPaddingTop();
                iMin += getPaddingTop();
            }
            canvas.translate(paddingLeft, iMin);
            edgeEffect.setSize(width, height);
            if (edgeEffect.draw(canvas)) {
                postInvalidateOnAnimation();
            }
            canvas.restoreToCount(iSave);
        }
        EdgeEffect edgeEffect2 = this.f2880f;
        if (edgeEffect2.isFinished()) {
            return;
        }
        int iSave2 = canvas.save();
        int width2 = getWidth();
        int height2 = getHeight();
        int iMax = Math.max(getScrollRange(), scrollY) + height2;
        if (i.a(this)) {
            width2 -= getPaddingRight() + getPaddingLeft();
            paddingLeft2 = getPaddingLeft();
        }
        if (i.a(this)) {
            height2 -= getPaddingBottom() + getPaddingTop();
            iMax -= getPaddingBottom();
        }
        canvas.translate(paddingLeft2 - width2, iMax);
        canvas.rotate(180.0f, width2, 0.0f);
        edgeEffect2.setSize(width2, height2);
        if (edgeEffect2.draw(canvas)) {
            postInvalidateOnAnimation();
        }
        canvas.restoreToCount(iSave2);
    }

    @Override // A.InterfaceC0011k
    public final void e(ViewGroup viewGroup, int i4, int i5, int i6, int i7, int i8, int[] iArr) {
        m(i7, i8, iArr);
    }

    @Override // A.InterfaceC0010j
    public final boolean f(View view, View view2, int i4, int i5) {
        return (i4 & 2) != 0;
    }

    public final boolean g(int i4) {
        View viewFindFocus = findFocus();
        if (viewFindFocus == this) {
            viewFindFocus = null;
        }
        View viewFindNextFocus = FocusFinder.getInstance().findNextFocus(this, viewFindFocus, i4);
        int maxScrollAmount = getMaxScrollAmount();
        if (viewFindNextFocus == null || !l(viewFindNextFocus, maxScrollAmount, getHeight())) {
            if (i4 == 33 && getScrollY() < maxScrollAmount) {
                maxScrollAmount = getScrollY();
            } else if (i4 == 130 && getChildCount() > 0) {
                View childAt = getChildAt(0);
                maxScrollAmount = Math.min((childAt.getBottom() + ((FrameLayout.LayoutParams) childAt.getLayoutParams()).bottomMargin) - ((getHeight() + getScrollY()) - getPaddingBottom()), maxScrollAmount);
            }
            if (maxScrollAmount == 0) {
                return false;
            }
            if (i4 != 130) {
                maxScrollAmount = -maxScrollAmount;
            }
            r(maxScrollAmount, 0, 1, true);
        } else {
            Rect rect = this.f2878c;
            viewFindNextFocus.getDrawingRect(rect);
            offsetDescendantRectToMyCoords(viewFindNextFocus, rect);
            r(h(rect), 0, 1, true);
            viewFindNextFocus.requestFocus(i4);
        }
        if (viewFindFocus != null && viewFindFocus.isFocused() && !l(viewFindFocus, 0, getHeight())) {
            int descendantFocusability = getDescendantFocusability();
            setDescendantFocusability(131072);
            requestFocus();
            setDescendantFocusability(descendantFocusability);
        }
        return true;
    }

    @Override // android.view.View
    public float getBottomFadingEdgeStrength() {
        if (getChildCount() == 0) {
            return 0.0f;
        }
        View childAt = getChildAt(0);
        FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
        int verticalFadingEdgeLength = getVerticalFadingEdgeLength();
        int bottom = ((childAt.getBottom() + layoutParams.bottomMargin) - getScrollY()) - (getHeight() - getPaddingBottom());
        if (bottom < verticalFadingEdgeLength) {
            return bottom / verticalFadingEdgeLength;
        }
        return 1.0f;
    }

    public int getMaxScrollAmount() {
        return (int) (getHeight() * 0.5f);
    }

    @Override // android.view.ViewGroup
    public int getNestedScrollAxes() {
        C0012l c0012l = this.f2872D;
        return c0012l.f56c | c0012l.f55b;
    }

    public int getScrollRange() {
        if (getChildCount() <= 0) {
            return 0;
        }
        View childAt = getChildAt(0);
        FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
        return Math.max(0, ((childAt.getHeight() + layoutParams.topMargin) + layoutParams.bottomMargin) - ((getHeight() - getPaddingTop()) - getPaddingBottom()));
    }

    @Override // android.view.View
    public float getTopFadingEdgeStrength() {
        if (getChildCount() == 0) {
            return 0.0f;
        }
        int verticalFadingEdgeLength = getVerticalFadingEdgeLength();
        int scrollY = getScrollY();
        if (scrollY < verticalFadingEdgeLength) {
            return scrollY / verticalFadingEdgeLength;
        }
        return 1.0f;
    }

    public float getVerticalScrollFactorCompat() {
        if (this.f2874F == 0.0f) {
            TypedValue typedValue = new TypedValue();
            Context context = getContext();
            if (!context.getTheme().resolveAttribute(R.attr.listPreferredItemHeight, typedValue, true)) {
                throw new IllegalStateException("Expected theme to define listPreferredItemHeight.");
            }
            this.f2874F = typedValue.getDimension(context.getResources().getDisplayMetrics());
        }
        return this.f2874F;
    }

    public final int h(Rect rect) {
        if (getChildCount() == 0) {
            return 0;
        }
        int height = getHeight();
        int scrollY = getScrollY();
        int i4 = scrollY + height;
        int verticalFadingEdgeLength = getVerticalFadingEdgeLength();
        if (rect.top > 0) {
            scrollY += verticalFadingEdgeLength;
        }
        View childAt = getChildAt(0);
        FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
        int i5 = rect.bottom < (childAt.getHeight() + layoutParams.topMargin) + layoutParams.bottomMargin ? i4 - verticalFadingEdgeLength : i4;
        int i6 = rect.bottom;
        if (i6 > i5 && rect.top > scrollY) {
            return Math.min(rect.height() > height ? rect.top - scrollY : rect.bottom - i5, (childAt.getBottom() + layoutParams.bottomMargin) - i4);
        }
        if (rect.top >= scrollY || i6 >= i5) {
            return 0;
        }
        return Math.max(rect.height() > height ? 0 - (i5 - rect.bottom) : 0 - (scrollY - rect.top), -getScrollY());
    }

    @Override // android.view.View
    public final boolean hasNestedScrollingParent() {
        return this.f2873E.f(0);
    }

    public final void i(int i4) {
        if (getChildCount() > 0) {
            this.f2879d.fling(getScrollX(), getScrollY(), 0, i4, 0, 0, Integer.MIN_VALUE, f.API_PRIORITY_OTHER, 0, 0);
            u(2, 1);
            this.f2870B = getScrollY();
            postInvalidateOnAnimation();
        }
    }

    @Override // android.view.View
    public final boolean isNestedScrollingEnabled() {
        return this.f2873E.f53d;
    }

    public final boolean j(int i4) {
        int childCount;
        boolean z4 = i4 == 130;
        int height = getHeight();
        Rect rect = this.f2878c;
        rect.top = 0;
        rect.bottom = height;
        if (z4 && (childCount = getChildCount()) > 0) {
            View childAt = getChildAt(childCount - 1);
            int paddingBottom = getPaddingBottom() + childAt.getBottom() + ((FrameLayout.LayoutParams) childAt.getLayoutParams()).bottomMargin;
            rect.bottom = paddingBottom;
            rect.top = paddingBottom - height;
        }
        return q(i4, rect.top, rect.bottom);
    }

    public final boolean l(View view, int i4, int i5) {
        Rect rect = this.f2878c;
        view.getDrawingRect(rect);
        offsetDescendantRectToMyCoords(view, rect);
        return rect.bottom + i4 >= getScrollY() && rect.top - i4 <= getScrollY() + i5;
    }

    public final void m(int i4, int i5, int[] iArr) {
        int scrollY = getScrollY();
        scrollBy(0, i4);
        int scrollY2 = getScrollY() - scrollY;
        if (iArr != null) {
            iArr[1] = iArr[1] + scrollY2;
        }
        this.f2873E.d(0, scrollY2, 0, i4 - scrollY2, null, i5, iArr);
    }

    @Override // android.view.ViewGroup
    public final void measureChild(View view, int i4, int i5) {
        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
        view.measure(ViewGroup.getChildMeasureSpec(i4, getPaddingRight() + getPaddingLeft(), layoutParams.width), View.MeasureSpec.makeMeasureSpec(0, 0));
    }

    @Override // android.view.ViewGroup
    public final void measureChildWithMargins(View view, int i4, int i5, int i6, int i7) {
        ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
        view.measure(ViewGroup.getChildMeasureSpec(i4, getPaddingRight() + getPaddingLeft() + marginLayoutParams.leftMargin + marginLayoutParams.rightMargin + i5, marginLayoutParams.width), View.MeasureSpec.makeMeasureSpec(marginLayoutParams.topMargin + marginLayoutParams.bottomMargin, 0));
    }

    public final void n(MotionEvent motionEvent) {
        int actionIndex = motionEvent.getActionIndex();
        if (motionEvent.getPointerId(actionIndex) == this.f2891x) {
            int i4 = actionIndex == 0 ? 1 : 0;
            this.f2881m = (int) motionEvent.getY(i4);
            this.f2891x = motionEvent.getPointerId(i4);
            VelocityTracker velocityTracker = this.f2886r;
            if (velocityTracker != null) {
                velocityTracker.clear();
            }
        }
    }

    public final boolean o(int i4, int i5, int i6, int i7) {
        int i8;
        boolean z4;
        int i9;
        boolean z5;
        getOverScrollMode();
        super.computeHorizontalScrollRange();
        super.computeHorizontalScrollExtent();
        computeVerticalScrollRange();
        super.computeVerticalScrollExtent();
        int i10 = i6 + i4;
        if (i5 <= 0 && i5 >= 0) {
            i8 = i5;
            z4 = false;
        } else {
            i8 = 0;
            z4 = true;
        }
        if (i10 > i7) {
            i9 = i7;
        } else {
            if (i10 >= 0) {
                i9 = i10;
                z5 = false;
                if (z5 && !this.f2873E.f(1)) {
                    this.f2879d.springBack(i8, i9, 0, 0, 0, getScrollRange());
                }
                super.scrollTo(i8, i9);
                return !z4 || z5;
            }
            i9 = 0;
        }
        z5 = true;
        if (z5) {
            this.f2879d.springBack(i8, i9, 0, 0, 0, getScrollRange());
        }
        super.scrollTo(i8, i9);
        if (z4) {
        }
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onAttachedToWindow() {
        super.onAttachedToWindow();
        this.f2883o = false;
    }

    /* JADX WARN: Removed duplicated region for block: B:110:0x01db  */
    /* JADX WARN: Removed duplicated region for block: B:144:0x02bd  */
    /* JADX WARN: Removed duplicated region for block: B:145:0x02c5  */
    /* JADX WARN: Removed duplicated region for block: B:53:0x00df  */
    /* JADX WARN: Removed duplicated region for block: B:65:0x010a  */
    @Override // android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean onGenericMotionEvent(android.view.MotionEvent r31) {
        /*
            Method dump skipped, instruction units count: 877
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.core.widget.NestedScrollView.onGenericMotionEvent(android.view.MotionEvent):boolean");
    }

    /* JADX WARN: Removed duplicated region for block: B:34:0x0083  */
    /* JADX WARN: Removed duplicated region for block: B:62:0x0117  */
    @Override // android.view.ViewGroup
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean onInterceptTouchEvent(android.view.MotionEvent r13) {
        /*
            Method dump skipped, instruction units count: 309
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.core.widget.NestedScrollView.onInterceptTouchEvent(android.view.MotionEvent):boolean");
    }

    @Override // android.widget.FrameLayout, android.view.ViewGroup, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        int measuredHeight;
        super.onLayout(z4, i4, i5, i6, i7);
        int i8 = 0;
        this.f2882n = false;
        View view = this.f2884p;
        if (view != null && k(view, this)) {
            View view2 = this.f2884p;
            Rect rect = this.f2878c;
            view2.getDrawingRect(rect);
            offsetDescendantRectToMyCoords(view2, rect);
            int iH = h(rect);
            if (iH != 0) {
                scrollBy(0, iH);
            }
        }
        this.f2884p = null;
        if (!this.f2883o) {
            if (this.f2871C != null) {
                scrollTo(getScrollX(), this.f2871C.f408a);
                this.f2871C = null;
            }
            if (getChildCount() > 0) {
                View childAt = getChildAt(0);
                FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
                measuredHeight = childAt.getMeasuredHeight() + layoutParams.topMargin + layoutParams.bottomMargin;
            } else {
                measuredHeight = 0;
            }
            int paddingTop = ((i7 - i5) - getPaddingTop()) - getPaddingBottom();
            int scrollY = getScrollY();
            if (paddingTop < measuredHeight && scrollY >= 0) {
                i8 = paddingTop + scrollY > measuredHeight ? measuredHeight - paddingTop : scrollY;
            }
            if (i8 != scrollY) {
                scrollTo(getScrollX(), i8);
            }
        }
        scrollTo(getScrollX(), getScrollY());
        this.f2883o = true;
    }

    @Override // android.widget.FrameLayout, android.view.View
    public final void onMeasure(int i4, int i5) {
        super.onMeasure(i4, i5);
        if (this.f2887s && View.MeasureSpec.getMode(i5) != 0 && getChildCount() > 0) {
            View childAt = getChildAt(0);
            FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
            int measuredHeight = childAt.getMeasuredHeight();
            int measuredHeight2 = (((getMeasuredHeight() - getPaddingTop()) - getPaddingBottom()) - layoutParams.topMargin) - layoutParams.bottomMargin;
            if (measuredHeight < measuredHeight2) {
                childAt.measure(ViewGroup.getChildMeasureSpec(i4, getPaddingRight() + getPaddingLeft() + layoutParams.leftMargin + layoutParams.rightMargin, layoutParams.width), View.MeasureSpec.makeMeasureSpec(measuredHeight2, 1073741824));
            }
        }
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean onNestedFling(View view, float f4, float f5, boolean z4) {
        if (z4) {
            return false;
        }
        dispatchNestedFling(0.0f, f5, true);
        i((int) f5);
        return true;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean onNestedPreFling(View view, float f4, float f5) {
        return this.f2873E.b(f4, f5);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onNestedPreScroll(View view, int i4, int i5, int[] iArr) {
        this.f2873E.c(i4, i5, iArr, null, 0);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onNestedScroll(View view, int i4, int i5, int i6, int i7) {
        m(i7, 0, null);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onNestedScrollAccepted(View view, View view2, int i4) {
        a(view, view2, i4, 0);
    }

    @Override // android.view.View
    public final void onOverScrolled(int i4, int i5, boolean z4, boolean z5) {
        super.scrollTo(i4, i5);
    }

    @Override // android.view.ViewGroup
    public final boolean onRequestFocusInDescendants(int i4, Rect rect) {
        if (i4 == 2) {
            i4 = 130;
        } else if (i4 == 1) {
            i4 = 33;
        }
        View viewFindNextFocus = rect == null ? FocusFinder.getInstance().findNextFocus(this, null, i4) : FocusFinder.getInstance().findNextFocusFromRect(this, rect, i4);
        if (viewFindNextFocus != null && l(viewFindNextFocus, 0, getHeight())) {
            return viewFindNextFocus.requestFocus(i4, rect);
        }
        return false;
    }

    @Override // android.view.View
    public final void onRestoreInstanceState(Parcelable parcelable) {
        if (!(parcelable instanceof k)) {
            super.onRestoreInstanceState(parcelable);
            return;
        }
        k kVar = (k) parcelable;
        super.onRestoreInstanceState(kVar.getSuperState());
        this.f2871C = kVar;
        requestLayout();
    }

    @Override // android.view.View
    public final Parcelable onSaveInstanceState() {
        k kVar = new k(super.onSaveInstanceState());
        kVar.f408a = getScrollY();
        return kVar;
    }

    @Override // android.view.View
    public final void onScrollChanged(int i4, int i5, int i6, int i7) {
        super.onScrollChanged(i4, i5, i6, i7);
    }

    @Override // android.view.View
    public final void onSizeChanged(int i4, int i5, int i6, int i7) {
        super.onSizeChanged(i4, i5, i6, i7);
        View viewFindFocus = findFocus();
        if (viewFindFocus == null || this == viewFindFocus || !l(viewFindFocus, 0, i7)) {
            return;
        }
        Rect rect = this.f2878c;
        viewFindFocus.getDrawingRect(rect);
        offsetDescendantRectToMyCoords(viewFindFocus, rect);
        int iH = h(rect);
        if (iH != 0) {
            if (this.f2888t) {
                t(0, iH, false);
            } else {
                scrollBy(0, iH);
            }
        }
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean onStartNestedScroll(View view, View view2, int i4) {
        return f(view, view2, i4, 0);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void onStopNestedScroll(View view) {
        c(view, 0);
    }

    @Override // android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        ViewParent parent;
        if (this.f2886r == null) {
            this.f2886r = VelocityTracker.obtain();
        }
        int actionMasked = motionEvent.getActionMasked();
        if (actionMasked == 0) {
            this.f2869A = 0;
        }
        MotionEvent motionEventObtain = MotionEvent.obtain(motionEvent);
        float f4 = 0.0f;
        motionEventObtain.offsetLocation(0.0f, this.f2869A);
        if (actionMasked != 0) {
            EdgeEffect edgeEffect = this.f2880f;
            EdgeEffect edgeEffect2 = this.e;
            if (actionMasked == 1) {
                VelocityTracker velocityTracker = this.f2886r;
                velocityTracker.computeCurrentVelocity(1000, this.f2890w);
                int yVelocity = (int) velocityTracker.getYVelocity(this.f2891x);
                if (Math.abs(yVelocity) >= this.v) {
                    if (AbstractC0184a.I(edgeEffect2) != 0.0f) {
                        if (s(edgeEffect2, yVelocity)) {
                            edgeEffect2.onAbsorb(yVelocity);
                        } else {
                            i(-yVelocity);
                        }
                    } else if (AbstractC0184a.I(edgeEffect) != 0.0f) {
                        int i4 = -yVelocity;
                        if (s(edgeEffect, i4)) {
                            edgeEffect.onAbsorb(i4);
                        } else {
                            i(i4);
                        }
                    } else {
                        int i5 = -yVelocity;
                        float f5 = i5;
                        if (!this.f2873E.b(0.0f, f5)) {
                            dispatchNestedFling(0.0f, f5, true);
                            i(i5);
                        }
                    }
                } else if (this.f2879d.springBack(getScrollX(), getScrollY(), 0, 0, 0, getScrollRange())) {
                    postInvalidateOnAnimation();
                }
                this.f2891x = -1;
                this.f2885q = false;
                VelocityTracker velocityTracker2 = this.f2886r;
                if (velocityTracker2 != null) {
                    velocityTracker2.recycle();
                    this.f2886r = null;
                }
                w(0);
                this.e.onRelease();
                this.f2880f.onRelease();
            } else if (actionMasked == 2) {
                int iFindPointerIndex = motionEvent.findPointerIndex(this.f2891x);
                if (iFindPointerIndex == -1) {
                    Log.e("NestedScrollView", "Invalid pointerId=" + this.f2891x + " in onTouchEvent");
                } else {
                    int y4 = (int) motionEvent.getY(iFindPointerIndex);
                    int i6 = this.f2881m - y4;
                    float x4 = motionEvent.getX(iFindPointerIndex) / getWidth();
                    float height = i6 / getHeight();
                    if (AbstractC0184a.I(edgeEffect2) != 0.0f) {
                        float f6 = -AbstractC0184a.S(edgeEffect2, -height, x4);
                        if (AbstractC0184a.I(edgeEffect2) == 0.0f) {
                            edgeEffect2.onRelease();
                        }
                        f4 = f6;
                    } else if (AbstractC0184a.I(edgeEffect) != 0.0f) {
                        float fS = AbstractC0184a.S(edgeEffect, height, 1.0f - x4);
                        if (AbstractC0184a.I(edgeEffect) == 0.0f) {
                            edgeEffect.onRelease();
                        }
                        f4 = fS;
                    }
                    int iRound = Math.round(f4 * getHeight());
                    if (iRound != 0) {
                        invalidate();
                    }
                    int i7 = i6 - iRound;
                    if (!this.f2885q && Math.abs(i7) > this.f2889u) {
                        ViewParent parent2 = getParent();
                        if (parent2 != null) {
                            parent2.requestDisallowInterceptTouchEvent(true);
                        }
                        this.f2885q = true;
                        i7 = i7 > 0 ? i7 - this.f2889u : i7 + this.f2889u;
                    }
                    if (this.f2885q) {
                        int iR = r(i7, (int) motionEvent.getX(iFindPointerIndex), 0, false);
                        this.f2881m = y4 - iR;
                        this.f2869A += iR;
                    }
                }
            } else if (actionMasked == 3) {
                if (this.f2885q && getChildCount() > 0 && this.f2879d.springBack(getScrollX(), getScrollY(), 0, 0, 0, getScrollRange())) {
                    postInvalidateOnAnimation();
                }
                this.f2891x = -1;
                this.f2885q = false;
                VelocityTracker velocityTracker3 = this.f2886r;
                if (velocityTracker3 != null) {
                    velocityTracker3.recycle();
                    this.f2886r = null;
                }
                w(0);
                this.e.onRelease();
                this.f2880f.onRelease();
            } else if (actionMasked == 5) {
                int actionIndex = motionEvent.getActionIndex();
                this.f2881m = (int) motionEvent.getY(actionIndex);
                this.f2891x = motionEvent.getPointerId(actionIndex);
            } else if (actionMasked == 6) {
                n(motionEvent);
                this.f2881m = (int) motionEvent.getY(motionEvent.findPointerIndex(this.f2891x));
            }
        } else {
            if (getChildCount() == 0) {
                return false;
            }
            if (this.f2885q && (parent = getParent()) != null) {
                parent.requestDisallowInterceptTouchEvent(true);
            }
            if (!this.f2879d.isFinished()) {
                this.f2879d.abortAnimation();
                w(1);
            }
            int y5 = (int) motionEvent.getY();
            int pointerId = motionEvent.getPointerId(0);
            this.f2881m = y5;
            this.f2891x = pointerId;
            u(2, 0);
        }
        VelocityTracker velocityTracker4 = this.f2886r;
        if (velocityTracker4 != null) {
            velocityTracker4.addMovement(motionEventObtain);
        }
        motionEventObtain.recycle();
        return true;
    }

    public final void p(int i4) {
        boolean z4 = i4 == 130;
        int height = getHeight();
        Rect rect = this.f2878c;
        if (z4) {
            rect.top = getScrollY() + height;
            int childCount = getChildCount();
            if (childCount > 0) {
                View childAt = getChildAt(childCount - 1);
                int paddingBottom = getPaddingBottom() + childAt.getBottom() + ((FrameLayout.LayoutParams) childAt.getLayoutParams()).bottomMargin;
                if (rect.top + height > paddingBottom) {
                    rect.top = paddingBottom - height;
                }
            }
        } else {
            int scrollY = getScrollY() - height;
            rect.top = scrollY;
            if (scrollY < 0) {
                rect.top = 0;
            }
        }
        int i5 = rect.top;
        int i6 = height + i5;
        rect.bottom = i6;
        q(i4, i5, i6);
    }

    /* JADX WARN: Removed duplicated region for block: B:32:0x0068  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean q(int r18, int r19, int r20) {
        /*
            r17 = this;
            r0 = r17
            r1 = r18
            r2 = r19
            r3 = r20
            int r4 = r0.getHeight()
            int r5 = r0.getScrollY()
            int r4 = r4 + r5
            r6 = 33
            if (r1 != r6) goto L17
            r6 = 1
            goto L18
        L17:
            r6 = 0
        L18:
            r9 = 2
            java.util.ArrayList r9 = r0.getFocusables(r9)
            int r10 = r9.size()
            r11 = 0
            r12 = 0
            r13 = 0
        L24:
            if (r12 >= r10) goto L6c
            java.lang.Object r14 = r9.get(r12)
            android.view.View r14 = (android.view.View) r14
            int r15 = r14.getTop()
            int r7 = r14.getBottom()
            if (r2 >= r7) goto L69
            if (r15 >= r3) goto L69
            if (r2 >= r15) goto L3f
            if (r7 >= r3) goto L3f
            r16 = 1
            goto L41
        L3f:
            r16 = 0
        L41:
            if (r11 != 0) goto L47
            r11 = r14
            r13 = r16
            goto L69
        L47:
            if (r6 == 0) goto L4f
            int r8 = r11.getTop()
            if (r15 < r8) goto L57
        L4f:
            if (r6 != 0) goto L59
            int r8 = r11.getBottom()
            if (r7 <= r8) goto L59
        L57:
            r7 = 1
            goto L5a
        L59:
            r7 = 0
        L5a:
            if (r13 == 0) goto L61
            if (r16 == 0) goto L69
            if (r7 == 0) goto L69
            goto L68
        L61:
            if (r16 == 0) goto L66
            r11 = r14
            r13 = 1
            goto L69
        L66:
            if (r7 == 0) goto L69
        L68:
            r11 = r14
        L69:
            int r12 = r12 + 1
            goto L24
        L6c:
            if (r11 != 0) goto L6f
            r11 = r0
        L6f:
            if (r2 < r5) goto L75
            if (r3 > r4) goto L75
            r7 = 0
            goto L82
        L75:
            if (r6 == 0) goto L7b
            int r2 = r2 - r5
        L78:
            r3 = 0
            r4 = 1
            goto L7e
        L7b:
            int r2 = r3 - r4
            goto L78
        L7e:
            r0.r(r2, r3, r4, r4)
            r7 = r4
        L82:
            android.view.View r2 = r0.findFocus()
            if (r11 == r2) goto L8b
            r11.requestFocus(r1)
        L8b:
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.core.widget.NestedScrollView.q(int, int, int):boolean");
    }

    public final int r(int i4, int i5, int i6, boolean z4) {
        int i7;
        int i8;
        boolean z5;
        VelocityTracker velocityTracker;
        if (i6 == 1) {
            u(2, i6);
        }
        boolean zC = this.f2873E.c(0, i4, this.f2893z, this.f2892y, i6);
        int[] iArr = this.f2893z;
        int[] iArr2 = this.f2892y;
        if (zC) {
            i7 = i4 - iArr[1];
            i8 = iArr2[1];
        } else {
            i7 = i4;
            i8 = 0;
        }
        int scrollY = getScrollY();
        int scrollRange = getScrollRange();
        int overScrollMode = getOverScrollMode();
        boolean z6 = (overScrollMode == 0 || (overScrollMode == 1 && getScrollRange() > 0)) && !z4;
        boolean z7 = o(i7, 0, scrollY, scrollRange) && !this.f2873E.f(i6);
        int scrollY2 = getScrollY() - scrollY;
        iArr[1] = 0;
        this.f2873E.d(0, scrollY2, 0, i7 - scrollY2, this.f2892y, i6, iArr);
        int i9 = i8 + iArr2[1];
        int i10 = i7 - iArr[1];
        int i11 = scrollY + i10;
        EdgeEffect edgeEffect = this.f2880f;
        EdgeEffect edgeEffect2 = this.e;
        if (i11 < 0) {
            if (z6) {
                AbstractC0184a.S(edgeEffect2, (-i10) / getHeight(), i5 / getWidth());
                if (!edgeEffect.isFinished()) {
                    edgeEffect.onRelease();
                }
            }
        } else if (i11 > scrollRange && z6) {
            AbstractC0184a.S(edgeEffect, i10 / getHeight(), 1.0f - (i5 / getWidth()));
            if (!edgeEffect2.isFinished()) {
                edgeEffect2.onRelease();
            }
        }
        if (edgeEffect2.isFinished() && edgeEffect.isFinished()) {
            z5 = z7;
        } else {
            postInvalidateOnAnimation();
            z5 = false;
        }
        if (z5 && i6 == 0 && (velocityTracker = this.f2886r) != null) {
            velocityTracker.clear();
        }
        if (i6 == 1) {
            w(i6);
            edgeEffect2.onRelease();
            edgeEffect.onRelease();
        }
        return i9;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void requestChildFocus(View view, View view2) {
        if (this.f2882n) {
            this.f2884p = view2;
        } else {
            Rect rect = this.f2878c;
            view2.getDrawingRect(rect);
            offsetDescendantRectToMyCoords(view2, rect);
            int iH = h(rect);
            if (iH != 0) {
                scrollBy(0, iH);
            }
        }
        super.requestChildFocus(view, view2);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final boolean requestChildRectangleOnScreen(View view, Rect rect, boolean z4) {
        rect.offset(view.getLeft() - view.getScrollX(), view.getTop() - view.getScrollY());
        int iH = h(rect);
        boolean z5 = iH != 0;
        if (z5) {
            if (z4) {
                scrollBy(0, iH);
                return z5;
            }
            t(0, iH, false);
        }
        return z5;
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final void requestDisallowInterceptTouchEvent(boolean z4) {
        VelocityTracker velocityTracker;
        if (z4 && (velocityTracker = this.f2886r) != null) {
            velocityTracker.recycle();
            this.f2886r = null;
        }
        super.requestDisallowInterceptTouchEvent(z4);
    }

    @Override // android.view.View, android.view.ViewParent
    public final void requestLayout() {
        this.f2882n = true;
        super.requestLayout();
    }

    public final boolean s(EdgeEffect edgeEffect, int i4) {
        if (i4 > 0) {
            return true;
        }
        float fI = AbstractC0184a.I(edgeEffect) * getHeight();
        float fAbs = Math.abs(-i4) * 0.35f;
        float f4 = this.f2876a * 0.015f;
        double dLog = Math.log(fAbs / f4);
        double d5 = f2867H;
        return ((float) (Math.exp((d5 / (d5 - 1.0d)) * dLog) * ((double) f4))) < fI;
    }

    @Override // android.view.View
    public final void scrollTo(int i4, int i5) {
        if (getChildCount() > 0) {
            View childAt = getChildAt(0);
            FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
            int width = (getWidth() - getPaddingLeft()) - getPaddingRight();
            int width2 = childAt.getWidth() + layoutParams.leftMargin + layoutParams.rightMargin;
            int height = (getHeight() - getPaddingTop()) - getPaddingBottom();
            int height2 = childAt.getHeight() + layoutParams.topMargin + layoutParams.bottomMargin;
            if (width >= width2 || i4 < 0) {
                i4 = 0;
            } else if (width + i4 > width2) {
                i4 = width2 - width;
            }
            if (height >= height2 || i5 < 0) {
                i5 = 0;
            } else if (height + i5 > height2) {
                i5 = height2 - height;
            }
            if (i4 == getScrollX() && i5 == getScrollY()) {
                return;
            }
            super.scrollTo(i4, i5);
        }
    }

    public void setFillViewport(boolean z4) {
        if (z4 != this.f2887s) {
            this.f2887s = z4;
            requestLayout();
        }
    }

    @Override // android.view.View
    public void setNestedScrollingEnabled(boolean z4) {
        C0009i c0009i = this.f2873E;
        if (c0009i.f53d) {
            Field field = C.f4a;
            AbstractC0019t.z(c0009i.f52c);
        }
        c0009i.f53d = z4;
    }

    public void setSmoothScrollingEnabled(boolean z4) {
        this.f2888t = z4;
    }

    @Override // android.widget.FrameLayout, android.view.ViewGroup
    public final boolean shouldDelayChildPressedState() {
        return true;
    }

    @Override // android.view.View
    public final boolean startNestedScroll(int i4) {
        return this.f2873E.g(i4, 0);
    }

    @Override // android.view.View
    public final void stopNestedScroll() {
        w(0);
    }

    public final void t(int i4, int i5, boolean z4) {
        if (getChildCount() == 0) {
            return;
        }
        if (AnimationUtils.currentAnimationTimeMillis() - this.f2877b > 250) {
            View childAt = getChildAt(0);
            FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
            int height = childAt.getHeight() + layoutParams.topMargin + layoutParams.bottomMargin;
            int height2 = (getHeight() - getPaddingTop()) - getPaddingBottom();
            int scrollY = getScrollY();
            this.f2879d.startScroll(getScrollX(), scrollY, 0, Math.max(0, Math.min(i5 + scrollY, Math.max(0, height - height2))) - scrollY, 250);
            if (z4) {
                u(2, 1);
            } else {
                w(1);
            }
            this.f2870B = getScrollY();
            postInvalidateOnAnimation();
        } else {
            if (!this.f2879d.isFinished()) {
                this.f2879d.abortAnimation();
                w(1);
            }
            scrollBy(i4, i5);
        }
        this.f2877b = AnimationUtils.currentAnimationTimeMillis();
    }

    public final void u(int i4, int i5) {
        this.f2873E.g(2, i5);
    }

    public final boolean v(MotionEvent motionEvent) {
        boolean z4;
        EdgeEffect edgeEffect = this.e;
        if (AbstractC0184a.I(edgeEffect) != 0.0f) {
            AbstractC0184a.S(edgeEffect, 0.0f, motionEvent.getX() / getWidth());
            z4 = true;
        } else {
            z4 = false;
        }
        EdgeEffect edgeEffect2 = this.f2880f;
        if (AbstractC0184a.I(edgeEffect2) == 0.0f) {
            return z4;
        }
        AbstractC0184a.S(edgeEffect2, 0.0f, 1.0f - (motionEvent.getX() / getWidth()));
        return true;
    }

    public final void w(int i4) {
        this.f2873E.h(i4);
    }

    @Override // android.view.ViewGroup
    public final void addView(View view, int i4) {
        if (getChildCount() <= 0) {
            super.addView(view, i4);
            return;
        }
        throw new IllegalStateException("ScrollView can host only one direct child");
    }

    @Override // android.view.ViewGroup, android.view.ViewManager
    public final void addView(View view, ViewGroup.LayoutParams layoutParams) {
        if (getChildCount() <= 0) {
            super.addView(view, layoutParams);
            return;
        }
        throw new IllegalStateException("ScrollView can host only one direct child");
    }

    @Override // android.view.ViewGroup
    public final void addView(View view, int i4, ViewGroup.LayoutParams layoutParams) {
        if (getChildCount() <= 0) {
            super.addView(view, i4, layoutParams);
            return;
        }
        throw new IllegalStateException("ScrollView can host only one direct child");
    }

    public void setOnScrollChangeListener(j jVar) {
    }
}
