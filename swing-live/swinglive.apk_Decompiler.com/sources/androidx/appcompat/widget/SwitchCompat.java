package androidx.appcompat.widget;

import A.C;
import android.R;
import android.animation.ObjectAnimator;
import android.content.res.ColorStateList;
import android.graphics.Canvas;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Region;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.text.TextUtils;
import android.view.ActionMode;
import android.view.VelocityTracker;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.widget.CompoundButton;
import g.AbstractC0404a;
import h.C0410a;
import java.lang.reflect.Field;
import k.AbstractC0508z;
import k.g0;
import k.v0;
import u.AbstractC0686a;

/* JADX INFO: loaded from: classes.dex */
public class SwitchCompat extends CompoundButton {

    /* JADX INFO: renamed from: S, reason: collision with root package name */
    public static final g0 f2772S = new g0(Float.class, "thumbPos");

    /* JADX INFO: renamed from: T, reason: collision with root package name */
    public static final int[] f2773T = {R.attr.state_checked};

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public float f2774A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final VelocityTracker f2775B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final int f2776C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public float f2777D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public int f2778E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public int f2779F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public int f2780G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public int f2781H;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public int f2782I;
    public int J;

    /* JADX INFO: renamed from: K, reason: collision with root package name */
    public int f2783K;

    /* JADX INFO: renamed from: L, reason: collision with root package name */
    public final TextPaint f2784L;

    /* JADX INFO: renamed from: M, reason: collision with root package name */
    public final ColorStateList f2785M;

    /* JADX INFO: renamed from: N, reason: collision with root package name */
    public StaticLayout f2786N;

    /* JADX INFO: renamed from: O, reason: collision with root package name */
    public StaticLayout f2787O;

    /* JADX INFO: renamed from: P, reason: collision with root package name */
    public final C0410a f2788P;

    /* JADX INFO: renamed from: Q, reason: collision with root package name */
    public ObjectAnimator f2789Q;

    /* JADX INFO: renamed from: R, reason: collision with root package name */
    public final Rect f2790R;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Drawable f2791a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ColorStateList f2792b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public PorterDuff.Mode f2793c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f2794d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Drawable f2795f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ColorStateList f2796m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public PorterDuff.Mode f2797n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f2798o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public boolean f2799p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f2800q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f2801r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f2802s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f2803t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public CharSequence f2804u;
    public CharSequence v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f2805w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public int f2806x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final int f2807y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public float f2808z;

    /* JADX WARN: Removed duplicated region for block: B:39:0x0101  */
    /* JADX WARN: Removed duplicated region for block: B:41:0x0107  */
    /* JADX WARN: Removed duplicated region for block: B:42:0x010a  */
    /* JADX WARN: Removed duplicated region for block: B:45:0x0116  */
    /* JADX WARN: Removed duplicated region for block: B:50:0x012f  */
    /* JADX WARN: Removed duplicated region for block: B:55:0x013b  */
    /* JADX WARN: Removed duplicated region for block: B:58:0x0140  */
    /* JADX WARN: Removed duplicated region for block: B:73:0x016b  */
    /* JADX WARN: Removed duplicated region for block: B:76:0x017c  */
    /* JADX WARN: Removed duplicated region for block: B:77:0x0194  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public SwitchCompat(android.content.Context r13, android.util.AttributeSet r14) {
        /*
            Method dump skipped, instruction units count: 447
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.appcompat.widget.SwitchCompat.<init>(android.content.Context, android.util.AttributeSet):void");
    }

    private boolean getTargetCheckedState() {
        return this.f2777D > 0.5f;
    }

    private int getThumbOffset() {
        return (int) (((v0.a(this) ? 1.0f - this.f2777D : this.f2777D) * getThumbScrollRange()) + 0.5f);
    }

    private int getThumbScrollRange() {
        Drawable drawable = this.f2795f;
        if (drawable == null) {
            return 0;
        }
        Rect rect = this.f2790R;
        drawable.getPadding(rect);
        Drawable drawable2 = this.f2791a;
        Rect rectB = drawable2 != null ? AbstractC0508z.b(drawable2) : AbstractC0508z.f5489a;
        return ((((this.f2778E - this.f2780G) - rect.left) - rect.right) - rectB.left) - rectB.right;
    }

    public final void a() {
        Drawable drawable = this.f2791a;
        if (drawable != null) {
            if (this.f2794d || this.e) {
                Drawable drawableMutate = drawable.mutate();
                this.f2791a = drawableMutate;
                if (this.f2794d) {
                    AbstractC0686a.h(drawableMutate, this.f2792b);
                }
                if (this.e) {
                    AbstractC0686a.i(this.f2791a, this.f2793c);
                }
                if (this.f2791a.isStateful()) {
                    this.f2791a.setState(getDrawableState());
                }
            }
        }
    }

    public final void b() {
        Drawable drawable = this.f2795f;
        if (drawable != null) {
            if (this.f2798o || this.f2799p) {
                Drawable drawableMutate = drawable.mutate();
                this.f2795f = drawableMutate;
                if (this.f2798o) {
                    AbstractC0686a.h(drawableMutate, this.f2796m);
                }
                if (this.f2799p) {
                    AbstractC0686a.i(this.f2795f, this.f2797n);
                }
                if (this.f2795f.isStateful()) {
                    this.f2795f.setState(getDrawableState());
                }
            }
        }
    }

    public final StaticLayout c(CharSequence charSequence) {
        C0410a c0410a = this.f2788P;
        if (c0410a != null) {
            charSequence = c0410a.getTransformation(charSequence, this);
        }
        CharSequence charSequence2 = charSequence;
        return new StaticLayout(charSequence2, this.f2784L, charSequence2 != null ? (int) Math.ceil(Layout.getDesiredWidth(charSequence2, r2)) : 0, Layout.Alignment.ALIGN_NORMAL, 1.0f, 0.0f, true);
    }

    @Override // android.view.View
    public final void draw(Canvas canvas) {
        int i4;
        int i5;
        int i6 = this.f2781H;
        int i7 = this.f2782I;
        int i8 = this.J;
        int i9 = this.f2783K;
        int thumbOffset = getThumbOffset() + i6;
        Drawable drawable = this.f2791a;
        Rect rectB = drawable != null ? AbstractC0508z.b(drawable) : AbstractC0508z.f5489a;
        Drawable drawable2 = this.f2795f;
        Rect rect = this.f2790R;
        if (drawable2 != null) {
            drawable2.getPadding(rect);
            int i10 = rect.left;
            thumbOffset += i10;
            if (rectB != null) {
                int i11 = rectB.left;
                if (i11 > i10) {
                    i6 += i11 - i10;
                }
                int i12 = rectB.top;
                int i13 = rect.top;
                i4 = i12 > i13 ? (i12 - i13) + i7 : i7;
                int i14 = rectB.right;
                int i15 = rect.right;
                if (i14 > i15) {
                    i8 -= i14 - i15;
                }
                int i16 = rectB.bottom;
                int i17 = rect.bottom;
                if (i16 > i17) {
                    i5 = i9 - (i16 - i17);
                }
                this.f2795f.setBounds(i6, i4, i8, i5);
            } else {
                i4 = i7;
            }
            i5 = i9;
            this.f2795f.setBounds(i6, i4, i8, i5);
        }
        Drawable drawable3 = this.f2791a;
        if (drawable3 != null) {
            drawable3.getPadding(rect);
            int i18 = thumbOffset - rect.left;
            int i19 = thumbOffset + this.f2780G + rect.right;
            this.f2791a.setBounds(i18, i7, i19, i9);
            Drawable background = getBackground();
            if (background != null) {
                AbstractC0686a.f(background, i18, i7, i19, i9);
            }
        }
        super.draw(canvas);
    }

    @Override // android.widget.CompoundButton, android.widget.TextView, android.view.View
    public final void drawableHotspotChanged(float f4, float f5) {
        super.drawableHotspotChanged(f4, f5);
        Drawable drawable = this.f2791a;
        if (drawable != null) {
            AbstractC0686a.e(drawable, f4, f5);
        }
        Drawable drawable2 = this.f2795f;
        if (drawable2 != null) {
            AbstractC0686a.e(drawable2, f4, f5);
        }
    }

    @Override // android.widget.CompoundButton, android.widget.TextView, android.view.View
    public final void drawableStateChanged() {
        super.drawableStateChanged();
        int[] drawableState = getDrawableState();
        Drawable drawable = this.f2791a;
        boolean state = (drawable == null || !drawable.isStateful()) ? false : drawable.setState(drawableState);
        Drawable drawable2 = this.f2795f;
        if (drawable2 != null && drawable2.isStateful()) {
            state |= drawable2.setState(drawableState);
        }
        if (state) {
            invalidate();
        }
    }

    @Override // android.widget.CompoundButton, android.widget.TextView
    public int getCompoundPaddingLeft() {
        if (!v0.a(this)) {
            return super.getCompoundPaddingLeft();
        }
        int compoundPaddingLeft = super.getCompoundPaddingLeft() + this.f2778E;
        return !TextUtils.isEmpty(getText()) ? compoundPaddingLeft + this.f2802s : compoundPaddingLeft;
    }

    @Override // android.widget.CompoundButton, android.widget.TextView
    public int getCompoundPaddingRight() {
        if (v0.a(this)) {
            return super.getCompoundPaddingRight();
        }
        int compoundPaddingRight = super.getCompoundPaddingRight() + this.f2778E;
        return !TextUtils.isEmpty(getText()) ? compoundPaddingRight + this.f2802s : compoundPaddingRight;
    }

    public boolean getShowText() {
        return this.f2805w;
    }

    public boolean getSplitTrack() {
        return this.f2803t;
    }

    public int getSwitchMinWidth() {
        return this.f2801r;
    }

    public int getSwitchPadding() {
        return this.f2802s;
    }

    public CharSequence getTextOff() {
        return this.v;
    }

    public CharSequence getTextOn() {
        return this.f2804u;
    }

    public Drawable getThumbDrawable() {
        return this.f2791a;
    }

    public int getThumbTextPadding() {
        return this.f2800q;
    }

    public ColorStateList getThumbTintList() {
        return this.f2792b;
    }

    public PorterDuff.Mode getThumbTintMode() {
        return this.f2793c;
    }

    public Drawable getTrackDrawable() {
        return this.f2795f;
    }

    public ColorStateList getTrackTintList() {
        return this.f2796m;
    }

    public PorterDuff.Mode getTrackTintMode() {
        return this.f2797n;
    }

    @Override // android.widget.CompoundButton, android.widget.TextView, android.view.View
    public final void jumpDrawablesToCurrentState() {
        super.jumpDrawablesToCurrentState();
        Drawable drawable = this.f2791a;
        if (drawable != null) {
            drawable.jumpToCurrentState();
        }
        Drawable drawable2 = this.f2795f;
        if (drawable2 != null) {
            drawable2.jumpToCurrentState();
        }
        ObjectAnimator objectAnimator = this.f2789Q;
        if (objectAnimator == null || !objectAnimator.isStarted()) {
            return;
        }
        this.f2789Q.end();
        this.f2789Q = null;
    }

    @Override // android.widget.CompoundButton, android.widget.TextView, android.view.View
    public final int[] onCreateDrawableState(int i4) {
        int[] iArrOnCreateDrawableState = super.onCreateDrawableState(i4 + 1);
        if (isChecked()) {
            View.mergeDrawableStates(iArrOnCreateDrawableState, f2773T);
        }
        return iArrOnCreateDrawableState;
    }

    @Override // android.widget.CompoundButton, android.widget.TextView, android.view.View
    public final void onDraw(Canvas canvas) {
        int width;
        super.onDraw(canvas);
        Drawable drawable = this.f2795f;
        Rect rect = this.f2790R;
        if (drawable != null) {
            drawable.getPadding(rect);
        } else {
            rect.setEmpty();
        }
        int i4 = this.f2782I;
        int i5 = this.f2783K;
        int i6 = i4 + rect.top;
        int i7 = i5 - rect.bottom;
        Drawable drawable2 = this.f2791a;
        if (drawable != null) {
            if (!this.f2803t || drawable2 == null) {
                drawable.draw(canvas);
            } else {
                Rect rectB = AbstractC0508z.b(drawable2);
                drawable2.copyBounds(rect);
                rect.left += rectB.left;
                rect.right -= rectB.right;
                int iSave = canvas.save();
                canvas.clipRect(rect, Region.Op.DIFFERENCE);
                drawable.draw(canvas);
                canvas.restoreToCount(iSave);
            }
        }
        int iSave2 = canvas.save();
        if (drawable2 != null) {
            drawable2.draw(canvas);
        }
        StaticLayout staticLayout = getTargetCheckedState() ? this.f2786N : this.f2787O;
        if (staticLayout != null) {
            int[] drawableState = getDrawableState();
            ColorStateList colorStateList = this.f2785M;
            TextPaint textPaint = this.f2784L;
            if (colorStateList != null) {
                textPaint.setColor(colorStateList.getColorForState(drawableState, 0));
            }
            textPaint.drawableState = drawableState;
            if (drawable2 != null) {
                Rect bounds = drawable2.getBounds();
                width = bounds.left + bounds.right;
            } else {
                width = getWidth();
            }
            canvas.translate((width / 2) - (staticLayout.getWidth() / 2), ((i6 + i7) / 2) - (staticLayout.getHeight() / 2));
            staticLayout.draw(canvas);
        }
        canvas.restoreToCount(iSave2);
    }

    @Override // android.view.View
    public final void onInitializeAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        super.onInitializeAccessibilityEvent(accessibilityEvent);
        accessibilityEvent.setClassName("android.widget.Switch");
    }

    @Override // android.view.View
    public final void onInitializeAccessibilityNodeInfo(AccessibilityNodeInfo accessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(accessibilityNodeInfo);
        accessibilityNodeInfo.setClassName("android.widget.Switch");
        CharSequence charSequence = isChecked() ? this.f2804u : this.v;
        if (TextUtils.isEmpty(charSequence)) {
            return;
        }
        CharSequence text = accessibilityNodeInfo.getText();
        if (TextUtils.isEmpty(text)) {
            accessibilityNodeInfo.setText(charSequence);
            return;
        }
        StringBuilder sb = new StringBuilder();
        sb.append(text);
        sb.append(' ');
        sb.append(charSequence);
        accessibilityNodeInfo.setText(sb);
    }

    @Override // android.widget.TextView, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        int iMax;
        int width;
        int paddingLeft;
        int height;
        int paddingTop;
        super.onLayout(z4, i4, i5, i6, i7);
        int iMax2 = 0;
        if (this.f2791a != null) {
            Drawable drawable = this.f2795f;
            Rect rect = this.f2790R;
            if (drawable != null) {
                drawable.getPadding(rect);
            } else {
                rect.setEmpty();
            }
            Rect rectB = AbstractC0508z.b(this.f2791a);
            iMax = Math.max(0, rectB.left - rect.left);
            iMax2 = Math.max(0, rectB.right - rect.right);
        } else {
            iMax = 0;
        }
        if (v0.a(this)) {
            paddingLeft = getPaddingLeft() + iMax;
            width = ((this.f2778E + paddingLeft) - iMax) - iMax2;
        } else {
            width = (getWidth() - getPaddingRight()) - iMax2;
            paddingLeft = (width - this.f2778E) + iMax + iMax2;
        }
        int gravity = getGravity() & 112;
        if (gravity == 16) {
            int height2 = ((getHeight() + getPaddingTop()) - getPaddingBottom()) / 2;
            int i8 = this.f2779F;
            int i9 = height2 - (i8 / 2);
            height = i8 + i9;
            paddingTop = i9;
        } else if (gravity != 80) {
            paddingTop = getPaddingTop();
            height = this.f2779F + paddingTop;
        } else {
            height = getHeight() - getPaddingBottom();
            paddingTop = height - this.f2779F;
        }
        this.f2781H = paddingLeft;
        this.f2782I = paddingTop;
        this.f2783K = height;
        this.J = width;
    }

    @Override // android.widget.TextView, android.view.View
    public final void onMeasure(int i4, int i5) {
        int intrinsicWidth;
        int intrinsicHeight;
        int iMax;
        if (this.f2805w) {
            if (this.f2786N == null) {
                this.f2786N = c(this.f2804u);
            }
            if (this.f2787O == null) {
                this.f2787O = c(this.v);
            }
        }
        Drawable drawable = this.f2791a;
        int intrinsicHeight2 = 0;
        Rect rect = this.f2790R;
        if (drawable != null) {
            drawable.getPadding(rect);
            intrinsicWidth = (this.f2791a.getIntrinsicWidth() - rect.left) - rect.right;
            intrinsicHeight = this.f2791a.getIntrinsicHeight();
        } else {
            intrinsicWidth = 0;
            intrinsicHeight = 0;
        }
        if (this.f2805w) {
            iMax = (this.f2800q * 2) + Math.max(this.f2786N.getWidth(), this.f2787O.getWidth());
        } else {
            iMax = 0;
        }
        this.f2780G = Math.max(iMax, intrinsicWidth);
        Drawable drawable2 = this.f2795f;
        if (drawable2 != null) {
            drawable2.getPadding(rect);
            intrinsicHeight2 = this.f2795f.getIntrinsicHeight();
        } else {
            rect.setEmpty();
        }
        int iMax2 = rect.left;
        int iMax3 = rect.right;
        Drawable drawable3 = this.f2791a;
        if (drawable3 != null) {
            Rect rectB = AbstractC0508z.b(drawable3);
            iMax2 = Math.max(iMax2, rectB.left);
            iMax3 = Math.max(iMax3, rectB.right);
        }
        int iMax4 = Math.max(this.f2801r, (this.f2780G * 2) + iMax2 + iMax3);
        int iMax5 = Math.max(intrinsicHeight2, intrinsicHeight);
        this.f2778E = iMax4;
        this.f2779F = iMax5;
        super.onMeasure(i4, i5);
        if (getMeasuredHeight() < iMax5) {
            setMeasuredDimension(getMeasuredWidthAndState(), iMax5);
        }
    }

    @Override // android.view.View
    public final void onPopulateAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        super.onPopulateAccessibilityEvent(accessibilityEvent);
        CharSequence charSequence = isChecked() ? this.f2804u : this.v;
        if (charSequence != null) {
            accessibilityEvent.getText().add(charSequence);
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:40:0x008c  */
    @Override // android.widget.TextView, android.view.View
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean onTouchEvent(android.view.MotionEvent r10) {
        /*
            Method dump skipped, instruction units count: 325
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.appcompat.widget.SwitchCompat.onTouchEvent(android.view.MotionEvent):boolean");
    }

    @Override // android.widget.CompoundButton, android.widget.Checkable
    public void setChecked(boolean z4) {
        super.setChecked(z4);
        boolean zIsChecked = isChecked();
        if (getWindowToken() != null) {
            Field field = C.f4a;
            if (isLaidOut()) {
                ObjectAnimator objectAnimatorOfFloat = ObjectAnimator.ofFloat(this, f2772S, zIsChecked ? 1.0f : 0.0f);
                this.f2789Q = objectAnimatorOfFloat;
                objectAnimatorOfFloat.setDuration(250L);
                this.f2789Q.setAutoCancel(true);
                this.f2789Q.start();
                return;
            }
        }
        ObjectAnimator objectAnimator = this.f2789Q;
        if (objectAnimator != null) {
            objectAnimator.cancel();
        }
        setThumbPosition(zIsChecked ? 1.0f : 0.0f);
    }

    @Override // android.widget.TextView
    public void setCustomSelectionActionModeCallback(ActionMode.Callback callback) {
        super.setCustomSelectionActionModeCallback(H0.a.j0(callback, this));
    }

    public void setShowText(boolean z4) {
        if (this.f2805w != z4) {
            this.f2805w = z4;
            requestLayout();
        }
    }

    public void setSplitTrack(boolean z4) {
        this.f2803t = z4;
        invalidate();
    }

    public void setSwitchMinWidth(int i4) {
        this.f2801r = i4;
        requestLayout();
    }

    public void setSwitchPadding(int i4) {
        this.f2802s = i4;
        requestLayout();
    }

    public void setSwitchTypeface(Typeface typeface) {
        TextPaint textPaint = this.f2784L;
        if ((textPaint.getTypeface() == null || textPaint.getTypeface().equals(typeface)) && (textPaint.getTypeface() != null || typeface == null)) {
            return;
        }
        textPaint.setTypeface(typeface);
        requestLayout();
        invalidate();
    }

    public void setTextOff(CharSequence charSequence) {
        this.v = charSequence;
        requestLayout();
    }

    public void setTextOn(CharSequence charSequence) {
        this.f2804u = charSequence;
        requestLayout();
    }

    public void setThumbDrawable(Drawable drawable) {
        Drawable drawable2 = this.f2791a;
        if (drawable2 != null) {
            drawable2.setCallback(null);
        }
        this.f2791a = drawable;
        if (drawable != null) {
            drawable.setCallback(this);
        }
        requestLayout();
    }

    public void setThumbPosition(float f4) {
        this.f2777D = f4;
        invalidate();
    }

    public void setThumbResource(int i4) {
        setThumbDrawable(AbstractC0404a.a(getContext(), i4));
    }

    public void setThumbTextPadding(int i4) {
        this.f2800q = i4;
        requestLayout();
    }

    public void setThumbTintList(ColorStateList colorStateList) {
        this.f2792b = colorStateList;
        this.f2794d = true;
        a();
    }

    public void setThumbTintMode(PorterDuff.Mode mode) {
        this.f2793c = mode;
        this.e = true;
        a();
    }

    public void setTrackDrawable(Drawable drawable) {
        Drawable drawable2 = this.f2795f;
        if (drawable2 != null) {
            drawable2.setCallback(null);
        }
        this.f2795f = drawable;
        if (drawable != null) {
            drawable.setCallback(this);
        }
        requestLayout();
    }

    public void setTrackResource(int i4) {
        setTrackDrawable(AbstractC0404a.a(getContext(), i4));
    }

    public void setTrackTintList(ColorStateList colorStateList) {
        this.f2796m = colorStateList;
        this.f2798o = true;
        b();
    }

    public void setTrackTintMode(PorterDuff.Mode mode) {
        this.f2797n = mode;
        this.f2799p = true;
        b();
    }

    @Override // android.widget.CompoundButton, android.widget.Checkable
    public final void toggle() {
        setChecked(!isChecked());
    }

    @Override // android.widget.CompoundButton, android.widget.TextView, android.view.View
    public final boolean verifyDrawable(Drawable drawable) {
        return super.verifyDrawable(drawable) || drawable == this.f2791a || drawable == this.f2795f;
    }
}
