package k;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import f.AbstractC0398a;
import y0.C0747k;

/* JADX INFO: renamed from: k.F, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0478F extends ViewGroup {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f5269a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5270b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5271c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5272d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f5273f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public float f5274m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public boolean f5275n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int[] f5276o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int[] f5277p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public Drawable f5278q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f5279r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f5280s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public int f5281t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public int f5282u;

    public AbstractC0478F(Context context, AttributeSet attributeSet, int i4) {
        super(context, attributeSet, i4);
        this.f5269a = true;
        this.f5270b = -1;
        this.f5271c = 0;
        this.e = 8388659;
        C0747k c0747kP = C0747k.P(context, attributeSet, AbstractC0398a.f4251i, i4);
        TypedArray typedArray = (TypedArray) c0747kP.f6832c;
        int i5 = typedArray.getInt(1, -1);
        if (i5 >= 0) {
            setOrientation(i5);
        }
        int i6 = typedArray.getInt(0, -1);
        if (i6 >= 0) {
            setGravity(i6);
        }
        boolean z4 = typedArray.getBoolean(2, true);
        if (!z4) {
            setBaselineAligned(z4);
        }
        this.f5274m = typedArray.getFloat(4, -1.0f);
        this.f5270b = typedArray.getInt(3, -1);
        this.f5275n = typedArray.getBoolean(7, false);
        setDividerDrawable(c0747kP.F(5));
        this.f5281t = typedArray.getInt(8, 0);
        this.f5282u = typedArray.getDimensionPixelSize(6, 0);
        c0747kP.T();
    }

    public final void b(Canvas canvas, int i4) {
        this.f5278q.setBounds(getPaddingLeft() + this.f5282u, i4, (getWidth() - getPaddingRight()) - this.f5282u, this.f5280s + i4);
        this.f5278q.draw(canvas);
    }

    public final void c(Canvas canvas, int i4) {
        this.f5278q.setBounds(i4, getPaddingTop() + this.f5282u, this.f5279r + i4, (getHeight() - getPaddingBottom()) - this.f5282u);
        this.f5278q.draw(canvas);
    }

    @Override // android.view.ViewGroup
    public boolean checkLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return layoutParams instanceof C0477E;
    }

    @Override // android.view.ViewGroup
    /* JADX INFO: renamed from: d, reason: merged with bridge method [inline-methods] */
    public C0477E generateDefaultLayoutParams() {
        int i4 = this.f5272d;
        if (i4 == 0) {
            return new C0477E(-2);
        }
        if (i4 == 1) {
            return new C0477E(-1);
        }
        return null;
    }

    @Override // android.view.ViewGroup
    /* JADX INFO: renamed from: e, reason: merged with bridge method [inline-methods] */
    public C0477E generateLayoutParams(AttributeSet attributeSet) {
        return new C0477E(getContext(), attributeSet);
    }

    @Override // android.view.ViewGroup
    /* JADX INFO: renamed from: f, reason: merged with bridge method [inline-methods] */
    public C0477E generateLayoutParams(ViewGroup.LayoutParams layoutParams) {
        return new C0477E(layoutParams);
    }

    public final boolean g(int i4) {
        if (i4 == 0) {
            return (this.f5281t & 1) != 0;
        }
        if (i4 == getChildCount()) {
            return (this.f5281t & 4) != 0;
        }
        if ((this.f5281t & 2) != 0) {
            for (int i5 = i4 - 1; i5 >= 0; i5--) {
                if (getChildAt(i5).getVisibility() != 8) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override // android.view.View
    public int getBaseline() {
        int i4;
        if (this.f5270b < 0) {
            return super.getBaseline();
        }
        int childCount = getChildCount();
        int i5 = this.f5270b;
        if (childCount <= i5) {
            throw new RuntimeException("mBaselineAlignedChildIndex of LinearLayout set to an index that is out of bounds.");
        }
        View childAt = getChildAt(i5);
        int baseline = childAt.getBaseline();
        if (baseline == -1) {
            if (this.f5270b == 0) {
                return -1;
            }
            throw new RuntimeException("mBaselineAlignedChildIndex of LinearLayout points to a View that doesn't know how to get its baseline.");
        }
        int bottom = this.f5271c;
        if (this.f5272d == 1 && (i4 = this.e & 112) != 48) {
            if (i4 == 16) {
                bottom += ((((getBottom() - getTop()) - getPaddingTop()) - getPaddingBottom()) - this.f5273f) / 2;
            } else if (i4 == 80) {
                bottom = ((getBottom() - getTop()) - getPaddingBottom()) - this.f5273f;
            }
        }
        return bottom + ((ViewGroup.MarginLayoutParams) ((C0477E) childAt.getLayoutParams())).topMargin + baseline;
    }

    public int getBaselineAlignedChildIndex() {
        return this.f5270b;
    }

    public Drawable getDividerDrawable() {
        return this.f5278q;
    }

    public int getDividerPadding() {
        return this.f5282u;
    }

    public int getDividerWidth() {
        return this.f5279r;
    }

    public int getGravity() {
        return this.e;
    }

    public int getOrientation() {
        return this.f5272d;
    }

    public int getShowDividers() {
        return this.f5281t;
    }

    public int getVirtualChildCount() {
        return getChildCount();
    }

    public float getWeightSum() {
        return this.f5274m;
    }

    @Override // android.view.View
    public final void onDraw(Canvas canvas) {
        int right;
        int left;
        int i4;
        if (this.f5278q == null) {
            return;
        }
        int i5 = 0;
        if (this.f5272d == 1) {
            int virtualChildCount = getVirtualChildCount();
            while (i5 < virtualChildCount) {
                View childAt = getChildAt(i5);
                if (childAt != null && childAt.getVisibility() != 8 && g(i5)) {
                    b(canvas, (childAt.getTop() - ((ViewGroup.MarginLayoutParams) ((C0477E) childAt.getLayoutParams())).topMargin) - this.f5280s);
                }
                i5++;
            }
            if (g(virtualChildCount)) {
                View childAt2 = getChildAt(virtualChildCount - 1);
                b(canvas, childAt2 == null ? (getHeight() - getPaddingBottom()) - this.f5280s : childAt2.getBottom() + ((ViewGroup.MarginLayoutParams) ((C0477E) childAt2.getLayoutParams())).bottomMargin);
                return;
            }
            return;
        }
        int virtualChildCount2 = getVirtualChildCount();
        boolean zA = v0.a(this);
        while (i5 < virtualChildCount2) {
            View childAt3 = getChildAt(i5);
            if (childAt3 != null && childAt3.getVisibility() != 8 && g(i5)) {
                C0477E c0477e = (C0477E) childAt3.getLayoutParams();
                c(canvas, zA ? childAt3.getRight() + ((ViewGroup.MarginLayoutParams) c0477e).rightMargin : (childAt3.getLeft() - ((ViewGroup.MarginLayoutParams) c0477e).leftMargin) - this.f5279r);
            }
            i5++;
        }
        if (g(virtualChildCount2)) {
            View childAt4 = getChildAt(virtualChildCount2 - 1);
            if (childAt4 != null) {
                C0477E c0477e2 = (C0477E) childAt4.getLayoutParams();
                if (zA) {
                    left = childAt4.getLeft() - ((ViewGroup.MarginLayoutParams) c0477e2).leftMargin;
                    i4 = this.f5279r;
                    right = left - i4;
                } else {
                    right = childAt4.getRight() + ((ViewGroup.MarginLayoutParams) c0477e2).rightMargin;
                }
            } else if (zA) {
                right = getPaddingLeft();
            } else {
                left = getWidth() - getPaddingRight();
                i4 = this.f5279r;
                right = left - i4;
            }
            c(canvas, right);
        }
    }

    @Override // android.view.View
    public final void onInitializeAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        super.onInitializeAccessibilityEvent(accessibilityEvent);
        accessibilityEvent.setClassName("androidx.appcompat.widget.LinearLayoutCompat");
    }

    @Override // android.view.View
    public final void onInitializeAccessibilityNodeInfo(AccessibilityNodeInfo accessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(accessibilityNodeInfo);
        accessibilityNodeInfo.setClassName("androidx.appcompat.widget.LinearLayoutCompat");
    }

    /* JADX WARN: Removed duplicated region for block: B:29:0x009f  */
    /* JADX WARN: Removed duplicated region for block: B:58:0x0156  */
    /* JADX WARN: Removed duplicated region for block: B:61:0x015f  */
    /* JADX WARN: Removed duplicated region for block: B:73:0x018d  */
    /* JADX WARN: Removed duplicated region for block: B:76:0x01a0  */
    /* JADX WARN: Removed duplicated region for block: B:77:0x01a5  */
    @Override // android.view.ViewGroup, android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void onLayout(boolean r23, int r24, int r25, int r26, int r27) {
        /*
            Method dump skipped, instruction units count: 457
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: k.AbstractC0478F.onLayout(boolean, int, int, int, int):void");
    }

    /* JADX WARN: Removed duplicated region for block: B:228:0x04e1  */
    /* JADX WARN: Removed duplicated region for block: B:231:0x04f6  */
    /* JADX WARN: Removed duplicated region for block: B:237:0x0524  */
    /* JADX WARN: Removed duplicated region for block: B:243:0x0534  */
    /* JADX WARN: Removed duplicated region for block: B:246:0x053b  */
    /* JADX WARN: Removed duplicated region for block: B:250:0x0545  */
    /* JADX WARN: Removed duplicated region for block: B:366:0x079a  */
    @Override // android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void onMeasure(int r39, int r40) {
        /*
            Method dump skipped, instruction units count: 2148
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: k.AbstractC0478F.onMeasure(int, int):void");
    }

    public void setBaselineAligned(boolean z4) {
        this.f5269a = z4;
    }

    public void setBaselineAlignedChildIndex(int i4) {
        if (i4 >= 0 && i4 < getChildCount()) {
            this.f5270b = i4;
            return;
        }
        throw new IllegalArgumentException("base aligned child index out of range (0, " + getChildCount() + ")");
    }

    public void setDividerDrawable(Drawable drawable) {
        if (drawable == this.f5278q) {
            return;
        }
        this.f5278q = drawable;
        if (drawable != null) {
            this.f5279r = drawable.getIntrinsicWidth();
            this.f5280s = drawable.getIntrinsicHeight();
        } else {
            this.f5279r = 0;
            this.f5280s = 0;
        }
        setWillNotDraw(drawable == null);
        requestLayout();
    }

    public void setDividerPadding(int i4) {
        this.f5282u = i4;
    }

    public void setGravity(int i4) {
        if (this.e != i4) {
            if ((8388615 & i4) == 0) {
                i4 |= 8388611;
            }
            if ((i4 & 112) == 0) {
                i4 |= 48;
            }
            this.e = i4;
            requestLayout();
        }
    }

    public void setHorizontalGravity(int i4) {
        int i5 = i4 & 8388615;
        int i6 = this.e;
        if ((8388615 & i6) != i5) {
            this.e = i5 | ((-8388616) & i6);
            requestLayout();
        }
    }

    public void setMeasureWithLargestChildEnabled(boolean z4) {
        this.f5275n = z4;
    }

    public void setOrientation(int i4) {
        if (this.f5272d != i4) {
            this.f5272d = i4;
            requestLayout();
        }
    }

    public void setShowDividers(int i4) {
        if (i4 != this.f5281t) {
            requestLayout();
        }
        this.f5281t = i4;
    }

    public void setVerticalGravity(int i4) {
        int i5 = i4 & 112;
        int i6 = this.e;
        if ((i6 & 112) != i5) {
            this.e = i5 | (i6 & (-113));
            requestLayout();
        }
    }

    public void setWeightSum(float f4) {
        this.f5274m = Math.max(0.0f, f4);
    }

    @Override // android.view.ViewGroup
    public final boolean shouldDelayChildPressedState() {
        return false;
    }
}
