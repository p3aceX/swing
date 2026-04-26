package androidx.appcompat.widget;

import A.C;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.ActionMode;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import com.swing.live.R;
import f.AbstractC0398a;
import java.lang.reflect.Field;
import k.C0484a;
import k.S;

/* JADX INFO: loaded from: classes.dex */
public class ActionBarContainer extends FrameLayout {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f2672a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public View f2673b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public View f2674c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Drawable f2675d;
    public Drawable e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Drawable f2676f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final boolean f2677m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public boolean f2678n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final int f2679o;

    public ActionBarContainer(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        C0484a c0484a = new C0484a(this);
        Field field = C.f4a;
        setBackground(c0484a);
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, AbstractC0398a.f4244a);
        boolean z4 = false;
        this.f2675d = typedArrayObtainStyledAttributes.getDrawable(0);
        this.e = typedArrayObtainStyledAttributes.getDrawable(2);
        this.f2679o = typedArrayObtainStyledAttributes.getDimensionPixelSize(13, -1);
        if (getId() == R.id.split_action_bar) {
            this.f2677m = true;
            this.f2676f = typedArrayObtainStyledAttributes.getDrawable(1);
        }
        typedArrayObtainStyledAttributes.recycle();
        if (!this.f2677m ? !(this.f2675d != null || this.e != null) : this.f2676f == null) {
            z4 = true;
        }
        setWillNotDraw(z4);
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void drawableStateChanged() {
        super.drawableStateChanged();
        Drawable drawable = this.f2675d;
        if (drawable != null && drawable.isStateful()) {
            this.f2675d.setState(getDrawableState());
        }
        Drawable drawable2 = this.e;
        if (drawable2 != null && drawable2.isStateful()) {
            this.e.setState(getDrawableState());
        }
        Drawable drawable3 = this.f2676f;
        if (drawable3 == null || !drawable3.isStateful()) {
            return;
        }
        this.f2676f.setState(getDrawableState());
    }

    public View getTabContainer() {
        return null;
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void jumpDrawablesToCurrentState() {
        super.jumpDrawablesToCurrentState();
        Drawable drawable = this.f2675d;
        if (drawable != null) {
            drawable.jumpToCurrentState();
        }
        Drawable drawable2 = this.e;
        if (drawable2 != null) {
            drawable2.jumpToCurrentState();
        }
        Drawable drawable3 = this.f2676f;
        if (drawable3 != null) {
            drawable3.jumpToCurrentState();
        }
    }

    @Override // android.view.View
    public final void onFinishInflate() {
        super.onFinishInflate();
        this.f2673b = findViewById(R.id.action_bar);
        this.f2674c = findViewById(R.id.action_context_bar);
    }

    @Override // android.view.View
    public final boolean onHoverEvent(MotionEvent motionEvent) {
        super.onHoverEvent(motionEvent);
        return true;
    }

    @Override // android.view.ViewGroup
    public final boolean onInterceptTouchEvent(MotionEvent motionEvent) {
        return this.f2672a || super.onInterceptTouchEvent(motionEvent);
    }

    @Override // android.widget.FrameLayout, android.view.ViewGroup, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        super.onLayout(z4, i4, i5, i6, i7);
        boolean z5 = true;
        if (this.f2677m) {
            Drawable drawable = this.f2676f;
            if (drawable != null) {
                drawable.setBounds(0, 0, getMeasuredWidth(), getMeasuredHeight());
            } else {
                z5 = false;
            }
        } else {
            if (this.f2675d == null) {
                z5 = false;
            } else if (this.f2673b.getVisibility() == 0) {
                this.f2675d.setBounds(this.f2673b.getLeft(), this.f2673b.getTop(), this.f2673b.getRight(), this.f2673b.getBottom());
            } else {
                View view = this.f2674c;
                if (view == null || view.getVisibility() != 0) {
                    this.f2675d.setBounds(0, 0, 0, 0);
                } else {
                    this.f2675d.setBounds(this.f2674c.getLeft(), this.f2674c.getTop(), this.f2674c.getRight(), this.f2674c.getBottom());
                }
            }
            this.f2678n = false;
        }
        if (z5) {
            invalidate();
        }
    }

    @Override // android.widget.FrameLayout, android.view.View
    public final void onMeasure(int i4, int i5) {
        int i6;
        if (this.f2673b == null && View.MeasureSpec.getMode(i5) == Integer.MIN_VALUE && (i6 = this.f2679o) >= 0) {
            i5 = View.MeasureSpec.makeMeasureSpec(Math.min(i6, View.MeasureSpec.getSize(i5)), Integer.MIN_VALUE);
        }
        super.onMeasure(i4, i5);
        if (this.f2673b == null) {
            return;
        }
        View.MeasureSpec.getMode(i5);
    }

    @Override // android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        super.onTouchEvent(motionEvent);
        return true;
    }

    public void setPrimaryBackground(Drawable drawable) {
        Drawable drawable2 = this.f2675d;
        if (drawable2 != null) {
            drawable2.setCallback(null);
            unscheduleDrawable(this.f2675d);
        }
        this.f2675d = drawable;
        if (drawable != null) {
            drawable.setCallback(this);
            View view = this.f2673b;
            if (view != null) {
                this.f2675d.setBounds(view.getLeft(), this.f2673b.getTop(), this.f2673b.getRight(), this.f2673b.getBottom());
            }
        }
        boolean z4 = false;
        if (!this.f2677m ? !(this.f2675d != null || this.e != null) : this.f2676f == null) {
            z4 = true;
        }
        setWillNotDraw(z4);
        invalidate();
        invalidateOutline();
    }

    public void setSplitBackground(Drawable drawable) {
        Drawable drawable2;
        Drawable drawable3 = this.f2676f;
        if (drawable3 != null) {
            drawable3.setCallback(null);
            unscheduleDrawable(this.f2676f);
        }
        this.f2676f = drawable;
        boolean z4 = this.f2677m;
        boolean z5 = false;
        if (drawable != null) {
            drawable.setCallback(this);
            if (z4 && (drawable2 = this.f2676f) != null) {
                drawable2.setBounds(0, 0, getMeasuredWidth(), getMeasuredHeight());
            }
        }
        if (!z4 ? !(this.f2675d != null || this.e != null) : this.f2676f == null) {
            z5 = true;
        }
        setWillNotDraw(z5);
        invalidate();
        invalidateOutline();
    }

    public void setStackedBackground(Drawable drawable) {
        Drawable drawable2 = this.e;
        if (drawable2 != null) {
            drawable2.setCallback(null);
            unscheduleDrawable(this.e);
        }
        this.e = drawable;
        if (drawable != null) {
            drawable.setCallback(this);
            if (this.f2678n && this.e != null) {
                throw null;
            }
        }
        boolean z4 = false;
        if (!this.f2677m ? !(this.f2675d != null || this.e != null) : this.f2676f == null) {
            z4 = true;
        }
        setWillNotDraw(z4);
        invalidate();
        invalidateOutline();
    }

    public void setTransitioning(boolean z4) {
        this.f2672a = z4;
        setDescendantFocusability(z4 ? 393216 : 262144);
    }

    @Override // android.view.View
    public void setVisibility(int i4) {
        super.setVisibility(i4);
        boolean z4 = i4 == 0;
        Drawable drawable = this.f2675d;
        if (drawable != null) {
            drawable.setVisible(z4, false);
        }
        Drawable drawable2 = this.e;
        if (drawable2 != null) {
            drawable2.setVisible(z4, false);
        }
        Drawable drawable3 = this.f2676f;
        if (drawable3 != null) {
            drawable3.setVisible(z4, false);
        }
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final ActionMode startActionModeForChild(View view, ActionMode.Callback callback) {
        return null;
    }

    @Override // android.view.View
    public final boolean verifyDrawable(Drawable drawable) {
        Drawable drawable2 = this.f2675d;
        boolean z4 = this.f2677m;
        if (drawable == drawable2 && !z4) {
            return true;
        }
        if (drawable == this.e && this.f2678n) {
            return true;
        }
        return (drawable == this.f2676f && z4) || super.verifyDrawable(drawable);
    }

    @Override // android.view.ViewGroup, android.view.ViewParent
    public final ActionMode startActionModeForChild(View view, ActionMode.Callback callback, int i4) {
        if (i4 != 0) {
            return super.startActionModeForChild(view, callback, i4);
        }
        return null;
    }

    public void setTabContainer(S s4) {
    }
}
