package androidx.appcompat.widget;

import A.C;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.swing.live.R;
import f.AbstractC0398a;
import g.AbstractC0404a;
import java.lang.reflect.Field;
import k.v0;

/* JADX INFO: loaded from: classes.dex */
public class ActionBarContextView extends ViewGroup {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2680a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f2681b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f2682c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public CharSequence f2683d;
    public CharSequence e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public View f2684f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public LinearLayout f2685m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public TextView f2686n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public TextView f2687o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final int f2688p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final int f2689q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public boolean f2690r;

    public ActionBarContextView(Context context, AttributeSet attributeSet) {
        int resourceId;
        super(context, attributeSet, R.attr.actionModeStyle);
        TypedValue typedValue = new TypedValue();
        if (context.getTheme().resolveAttribute(R.attr.actionBarPopupTheme, typedValue, true) && typedValue.resourceId != 0) {
            new ContextThemeWrapper(context, typedValue.resourceId);
        }
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, AbstractC0398a.f4247d, R.attr.actionModeStyle, 0);
        Drawable drawable = (!typedArrayObtainStyledAttributes.hasValue(0) || (resourceId = typedArrayObtainStyledAttributes.getResourceId(0, 0)) == 0) ? typedArrayObtainStyledAttributes.getDrawable(0) : AbstractC0404a.a(context, resourceId);
        Field field = C.f4a;
        setBackground(drawable);
        this.f2688p = typedArrayObtainStyledAttributes.getResourceId(5, 0);
        this.f2689q = typedArrayObtainStyledAttributes.getResourceId(4, 0);
        this.f2680a = typedArrayObtainStyledAttributes.getLayoutDimension(3, 0);
        typedArrayObtainStyledAttributes.getResourceId(2, R.layout.abc_action_mode_close_item_material);
        typedArrayObtainStyledAttributes.recycle();
    }

    public static int b(View view, int i4, int i5, int i6, boolean z4) {
        int measuredWidth = view.getMeasuredWidth();
        int measuredHeight = view.getMeasuredHeight();
        int i7 = ((i6 - measuredHeight) / 2) + i5;
        if (z4) {
            view.layout(i4 - measuredWidth, i7, i4, measuredHeight + i7);
        } else {
            view.layout(i4, i7, i4 + measuredWidth, measuredHeight + i7);
        }
        return z4 ? -measuredWidth : measuredWidth;
    }

    public final void a() {
        if (this.f2685m == null) {
            LayoutInflater.from(getContext()).inflate(R.layout.abc_action_bar_title_item, this);
            LinearLayout linearLayout = (LinearLayout) getChildAt(getChildCount() - 1);
            this.f2685m = linearLayout;
            this.f2686n = (TextView) linearLayout.findViewById(R.id.action_bar_title);
            this.f2687o = (TextView) this.f2685m.findViewById(R.id.action_bar_subtitle);
            int i4 = this.f2688p;
            if (i4 != 0) {
                this.f2686n.setTextAppearance(getContext(), i4);
            }
            int i5 = this.f2689q;
            if (i5 != 0) {
                this.f2687o.setTextAppearance(getContext(), i5);
            }
        }
        this.f2686n.setText(this.f2683d);
        this.f2687o.setText(this.e);
        boolean zIsEmpty = TextUtils.isEmpty(this.f2683d);
        boolean zIsEmpty2 = TextUtils.isEmpty(this.e);
        this.f2687o.setVisibility(!zIsEmpty2 ? 0 : 8);
        this.f2685m.setVisibility((zIsEmpty && zIsEmpty2) ? 8 : 0);
        if (this.f2685m.getParent() == null) {
            addView(this.f2685m);
        }
    }

    @Override // android.view.View
    /* JADX INFO: renamed from: c, reason: merged with bridge method [inline-methods] */
    public final void setVisibility(int i4) {
        if (i4 != getVisibility()) {
            super.setVisibility(i4);
        }
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateDefaultLayoutParams() {
        return new ViewGroup.MarginLayoutParams(-1, -2);
    }

    @Override // android.view.ViewGroup
    public final ViewGroup.LayoutParams generateLayoutParams(AttributeSet attributeSet) {
        return new ViewGroup.MarginLayoutParams(getContext(), attributeSet);
    }

    public int getAnimatedVisibility() {
        return getVisibility();
    }

    public int getContentHeight() {
        return this.f2680a;
    }

    public CharSequence getSubtitle() {
        return this.e;
    }

    public CharSequence getTitle() {
        return this.f2683d;
    }

    @Override // android.view.View
    public final void onConfigurationChanged(Configuration configuration) {
        super.onConfigurationChanged(configuration);
        TypedArray typedArrayObtainStyledAttributes = getContext().obtainStyledAttributes(null, AbstractC0398a.f4244a, R.attr.actionBarStyle, 0);
        setContentHeight(typedArrayObtainStyledAttributes.getLayoutDimension(13, 0));
        typedArrayObtainStyledAttributes.recycle();
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        super.onDetachedFromWindow();
    }

    @Override // android.view.View
    public final boolean onHoverEvent(MotionEvent motionEvent) {
        int actionMasked = motionEvent.getActionMasked();
        if (actionMasked == 9) {
            this.f2682c = false;
        }
        if (!this.f2682c) {
            boolean zOnHoverEvent = super.onHoverEvent(motionEvent);
            if (actionMasked == 9 && !zOnHoverEvent) {
                this.f2682c = true;
            }
        }
        if (actionMasked != 10 && actionMasked != 3) {
            return true;
        }
        this.f2682c = false;
        return true;
    }

    @Override // android.view.View
    public final void onInitializeAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        if (accessibilityEvent.getEventType() != 32) {
            super.onInitializeAccessibilityEvent(accessibilityEvent);
            return;
        }
        accessibilityEvent.setSource(this);
        accessibilityEvent.setClassName(getClass().getName());
        accessibilityEvent.setPackageName(getContext().getPackageName());
        accessibilityEvent.setContentDescription(this.f2683d);
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        boolean zA = v0.a(this);
        int paddingRight = zA ? (i6 - i4) - getPaddingRight() : getPaddingLeft();
        int paddingTop = getPaddingTop();
        int paddingTop2 = ((i7 - i5) - getPaddingTop()) - getPaddingBottom();
        LinearLayout linearLayout = this.f2685m;
        if (linearLayout != null && this.f2684f == null && linearLayout.getVisibility() != 8) {
            paddingRight += b(this.f2685m, paddingRight, paddingTop, paddingTop2, zA);
        }
        View view = this.f2684f;
        if (view != null) {
            b(view, paddingRight, paddingTop, paddingTop2, zA);
        }
        if (zA) {
            getPaddingLeft();
        } else {
            getPaddingRight();
        }
    }

    @Override // android.view.View
    public final void onMeasure(int i4, int i5) {
        if (View.MeasureSpec.getMode(i4) != 1073741824) {
            throw new IllegalStateException(getClass().getSimpleName().concat(" can only be used with android:layout_width=\"match_parent\" (or fill_parent)"));
        }
        if (View.MeasureSpec.getMode(i5) == 0) {
            throw new IllegalStateException(getClass().getSimpleName().concat(" can only be used with android:layout_height=\"wrap_content\""));
        }
        int size = View.MeasureSpec.getSize(i4);
        int size2 = this.f2680a;
        if (size2 <= 0) {
            size2 = View.MeasureSpec.getSize(i5);
        }
        int paddingBottom = getPaddingBottom() + getPaddingTop();
        int paddingLeft = (size - getPaddingLeft()) - getPaddingRight();
        int iMin = size2 - paddingBottom;
        int iMakeMeasureSpec = View.MeasureSpec.makeMeasureSpec(iMin, Integer.MIN_VALUE);
        LinearLayout linearLayout = this.f2685m;
        if (linearLayout != null && this.f2684f == null) {
            if (this.f2690r) {
                this.f2685m.measure(View.MeasureSpec.makeMeasureSpec(0, 0), iMakeMeasureSpec);
                int measuredWidth = this.f2685m.getMeasuredWidth();
                boolean z4 = measuredWidth <= paddingLeft;
                if (z4) {
                    paddingLeft -= measuredWidth;
                }
                this.f2685m.setVisibility(z4 ? 0 : 8);
            } else {
                linearLayout.measure(View.MeasureSpec.makeMeasureSpec(paddingLeft, Integer.MIN_VALUE), iMakeMeasureSpec);
                paddingLeft = Math.max(0, paddingLeft - linearLayout.getMeasuredWidth());
            }
        }
        View view = this.f2684f;
        if (view != null) {
            ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
            int i6 = layoutParams.width;
            int i7 = i6 != -2 ? 1073741824 : Integer.MIN_VALUE;
            if (i6 >= 0) {
                paddingLeft = Math.min(i6, paddingLeft);
            }
            int i8 = layoutParams.height;
            int i9 = i8 == -2 ? Integer.MIN_VALUE : 1073741824;
            if (i8 >= 0) {
                iMin = Math.min(i8, iMin);
            }
            this.f2684f.measure(View.MeasureSpec.makeMeasureSpec(paddingLeft, i7), View.MeasureSpec.makeMeasureSpec(iMin, i9));
        }
        if (this.f2680a > 0) {
            setMeasuredDimension(size, size2);
            return;
        }
        int childCount = getChildCount();
        int i10 = 0;
        for (int i11 = 0; i11 < childCount; i11++) {
            int measuredHeight = getChildAt(i11).getMeasuredHeight() + paddingBottom;
            if (measuredHeight > i10) {
                i10 = measuredHeight;
            }
        }
        setMeasuredDimension(size, i10);
    }

    @Override // android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        int actionMasked = motionEvent.getActionMasked();
        if (actionMasked == 0) {
            this.f2681b = false;
        }
        if (!this.f2681b) {
            boolean zOnTouchEvent = super.onTouchEvent(motionEvent);
            if (actionMasked == 0 && !zOnTouchEvent) {
                this.f2681b = true;
            }
        }
        if (actionMasked != 1 && actionMasked != 3) {
            return true;
        }
        this.f2681b = false;
        return true;
    }

    public void setContentHeight(int i4) {
        this.f2680a = i4;
    }

    public void setCustomView(View view) {
        LinearLayout linearLayout;
        View view2 = this.f2684f;
        if (view2 != null) {
            removeView(view2);
        }
        this.f2684f = view;
        if (view != null && (linearLayout = this.f2685m) != null) {
            removeView(linearLayout);
            this.f2685m = null;
        }
        if (view != null) {
            addView(view);
        }
        requestLayout();
    }

    public void setSubtitle(CharSequence charSequence) {
        this.e = charSequence;
        a();
    }

    public void setTitle(CharSequence charSequence) {
        this.f2683d = charSequence;
        a();
    }

    public void setTitleOptional(boolean z4) {
        if (z4 != this.f2690r) {
            requestLayout();
        }
        this.f2690r = z4;
    }

    @Override // android.view.ViewGroup
    public final boolean shouldDelayChildPressedState() {
        return false;
    }
}
