package k;

import android.R;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.TextDirectionHeuristic;
import android.text.TextDirectionHeuristics;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.ActionMode;
import android.view.View;
import android.view.ViewParent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.textclassifier.TextClassificationManager;
import android.view.textclassifier.TextClassifier;
import android.widget.TextView;
import e1.AbstractC0367g;
import g.AbstractC0404a;
import java.util.Arrays;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import y.AbstractC0736c;
import y.C0735b;

/* JADX INFO: renamed from: k.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0504v extends TextView implements F.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0497n f5473a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0503u f5474b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final com.google.android.gms.common.internal.r f5475c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Future f5476d;

    public C0504v(Context context, AttributeSet attributeSet) {
        this(context, attributeSet, R.attr.textViewStyle);
    }

    public final void d() {
        Future future = this.f5476d;
        if (future == null) {
            return;
        }
        try {
            this.f5476d = null;
            if (future.get() != null) {
                throw new ClassCastException();
            }
            if (Build.VERSION.SDK_INT >= 29) {
                throw null;
            }
            H0.a.G(this);
            throw null;
        } catch (InterruptedException | ExecutionException unused) {
        }
    }

    @Override // android.widget.TextView, android.view.View
    public final void drawableStateChanged() {
        super.drawableStateChanged();
        C0497n c0497n = this.f5473a;
        if (c0497n != null) {
            c0497n.a();
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.b();
        }
    }

    @Override // android.widget.TextView
    public int getAutoSizeMaxTextSize() {
        if (F.c.f391g) {
            return super.getAutoSizeMaxTextSize();
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            return Math.round(c0503u.f5468i.e);
        }
        return -1;
    }

    @Override // android.widget.TextView
    public int getAutoSizeMinTextSize() {
        if (F.c.f391g) {
            return super.getAutoSizeMinTextSize();
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            return Math.round(c0503u.f5468i.f5483d);
        }
        return -1;
    }

    @Override // android.widget.TextView
    public int getAutoSizeStepGranularity() {
        if (F.c.f391g) {
            return super.getAutoSizeStepGranularity();
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            return Math.round(c0503u.f5468i.f5482c);
        }
        return -1;
    }

    @Override // android.widget.TextView
    public int[] getAutoSizeTextAvailableSizes() {
        if (F.c.f391g) {
            return super.getAutoSizeTextAvailableSizes();
        }
        C0503u c0503u = this.f5474b;
        return c0503u != null ? c0503u.f5468i.f5484f : new int[0];
    }

    @Override // android.widget.TextView
    @SuppressLint({"WrongConstant"})
    public int getAutoSizeTextType() {
        if (F.c.f391g) {
            return super.getAutoSizeTextType() == 1 ? 1 : 0;
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            return c0503u.f5468i.f5480a;
        }
        return 0;
    }

    @Override // android.widget.TextView
    public int getFirstBaselineToTopHeight() {
        return getPaddingTop() - getPaint().getFontMetricsInt().top;
    }

    @Override // android.widget.TextView
    public int getLastBaselineToBottomHeight() {
        return getPaddingBottom() + getPaint().getFontMetricsInt().bottom;
    }

    public ColorStateList getSupportBackgroundTintList() {
        Y.e eVar;
        C0497n c0497n = this.f5473a;
        if (c0497n == null || (eVar = c0497n.e) == null) {
            return null;
        }
        return (ColorStateList) eVar.f2460c;
    }

    public PorterDuff.Mode getSupportBackgroundTintMode() {
        Y.e eVar;
        C0497n c0497n = this.f5473a;
        if (c0497n == null || (eVar = c0497n.e) == null) {
            return null;
        }
        return (PorterDuff.Mode) eVar.f2461d;
    }

    public ColorStateList getSupportCompoundDrawablesTintList() {
        Y.e eVar = this.f5474b.f5467h;
        if (eVar != null) {
            return (ColorStateList) eVar.f2460c;
        }
        return null;
    }

    public PorterDuff.Mode getSupportCompoundDrawablesTintMode() {
        Y.e eVar = this.f5474b.f5467h;
        if (eVar != null) {
            return (PorterDuff.Mode) eVar.f2461d;
        }
        return null;
    }

    @Override // android.widget.TextView
    public CharSequence getText() {
        d();
        return super.getText();
    }

    @Override // android.widget.TextView
    public TextClassifier getTextClassifier() {
        com.google.android.gms.common.internal.r rVar;
        if (Build.VERSION.SDK_INT >= 28 || (rVar = this.f5475c) == null) {
            return super.getTextClassifier();
        }
        TextClassifier textClassifier = (TextClassifier) rVar.f3598c;
        if (textClassifier != null) {
            return textClassifier;
        }
        TextClassificationManager textClassificationManager = (TextClassificationManager) ((C0504v) rVar.f3597b).getContext().getSystemService(TextClassificationManager.class);
        return textClassificationManager != null ? textClassificationManager.getTextClassifier() : TextClassifier.NO_OP;
    }

    public C0735b getTextMetricsParamsCompat() {
        return H0.a.G(this);
    }

    @Override // android.widget.TextView, android.view.View
    public final InputConnection onCreateInputConnection(EditorInfo editorInfo) {
        InputConnection inputConnectionOnCreateInputConnection = super.onCreateInputConnection(editorInfo);
        if (inputConnectionOnCreateInputConnection != null && editorInfo.hintText == null) {
            for (ViewParent parent = getParent(); parent instanceof View; parent = parent.getParent()) {
            }
        }
        return inputConnectionOnCreateInputConnection;
    }

    @Override // android.widget.TextView, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        super.onLayout(z4, i4, i5, i6, i7);
        C0503u c0503u = this.f5474b;
        if (c0503u == null || F.c.f391g) {
            return;
        }
        c0503u.f5468i.a();
    }

    @Override // android.widget.TextView, android.view.View
    public void onMeasure(int i4, int i5) {
        d();
        super.onMeasure(i4, i5);
    }

    @Override // android.widget.TextView
    public final void onTextChanged(CharSequence charSequence, int i4, int i5, int i6) {
        super.onTextChanged(charSequence, i4, i5, i6);
        C0503u c0503u = this.f5474b;
        if (c0503u == null || F.c.f391g) {
            return;
        }
        C0505w c0505w = c0503u.f5468i;
        if (c0505w.f5480a != 0) {
            c0505w.a();
        }
    }

    @Override // android.widget.TextView
    public final void setAutoSizeTextTypeUniformWithConfiguration(int i4, int i5, int i6, int i7) {
        if (F.c.f391g) {
            super.setAutoSizeTextTypeUniformWithConfiguration(i4, i5, i6, i7);
            return;
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            C0505w c0505w = c0503u.f5468i;
            DisplayMetrics displayMetrics = c0505w.f5488j.getResources().getDisplayMetrics();
            c0505w.i(TypedValue.applyDimension(i7, i4, displayMetrics), TypedValue.applyDimension(i7, i5, displayMetrics), TypedValue.applyDimension(i7, i6, displayMetrics));
            if (c0505w.g()) {
                c0505w.a();
            }
        }
    }

    @Override // android.widget.TextView
    public final void setAutoSizeTextTypeUniformWithPresetSizes(int[] iArr, int i4) {
        if (F.c.f391g) {
            super.setAutoSizeTextTypeUniformWithPresetSizes(iArr, i4);
            return;
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            C0505w c0505w = c0503u.f5468i;
            c0505w.getClass();
            int length = iArr.length;
            if (length > 0) {
                int[] iArrCopyOf = new int[length];
                if (i4 == 0) {
                    iArrCopyOf = Arrays.copyOf(iArr, length);
                } else {
                    DisplayMetrics displayMetrics = c0505w.f5488j.getResources().getDisplayMetrics();
                    for (int i5 = 0; i5 < length; i5++) {
                        iArrCopyOf[i5] = Math.round(TypedValue.applyDimension(i4, iArr[i5], displayMetrics));
                    }
                }
                c0505w.f5484f = C0505w.b(iArrCopyOf);
                if (!c0505w.h()) {
                    throw new IllegalArgumentException("None of the preset sizes is valid: " + Arrays.toString(iArr));
                }
            } else {
                c0505w.f5485g = false;
            }
            if (c0505w.g()) {
                c0505w.a();
            }
        }
    }

    @Override // android.widget.TextView
    public void setAutoSizeTextTypeWithDefaults(int i4) {
        if (F.c.f391g) {
            super.setAutoSizeTextTypeWithDefaults(i4);
            return;
        }
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            C0505w c0505w = c0503u.f5468i;
            if (i4 == 0) {
                c0505w.f5480a = 0;
                c0505w.f5483d = -1.0f;
                c0505w.e = -1.0f;
                c0505w.f5482c = -1.0f;
                c0505w.f5484f = new int[0];
                c0505w.f5481b = false;
                return;
            }
            if (i4 != 1) {
                c0505w.getClass();
                throw new IllegalArgumentException(com.google.crypto.tink.shaded.protobuf.S.d(i4, "Unknown auto-size text type: "));
            }
            DisplayMetrics displayMetrics = c0505w.f5488j.getResources().getDisplayMetrics();
            c0505w.i(TypedValue.applyDimension(2, 12.0f, displayMetrics), TypedValue.applyDimension(2, 112.0f, displayMetrics), 1.0f);
            if (c0505w.g()) {
                c0505w.a();
            }
        }
    }

    @Override // android.view.View
    public void setBackgroundDrawable(Drawable drawable) {
        super.setBackgroundDrawable(drawable);
        C0497n c0497n = this.f5473a;
        if (c0497n != null) {
            c0497n.f5415c = -1;
            c0497n.d(null);
            c0497n.a();
        }
    }

    @Override // android.view.View
    public void setBackgroundResource(int i4) {
        super.setBackgroundResource(i4);
        C0497n c0497n = this.f5473a;
        if (c0497n != null) {
            c0497n.c(i4);
        }
    }

    @Override // android.widget.TextView
    public final void setCompoundDrawables(Drawable drawable, Drawable drawable2, Drawable drawable3, Drawable drawable4) {
        super.setCompoundDrawables(drawable, drawable2, drawable3, drawable4);
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.b();
        }
    }

    @Override // android.widget.TextView
    public final void setCompoundDrawablesRelative(Drawable drawable, Drawable drawable2, Drawable drawable3, Drawable drawable4) {
        super.setCompoundDrawablesRelative(drawable, drawable2, drawable3, drawable4);
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.b();
        }
    }

    @Override // android.widget.TextView
    public final void setCompoundDrawablesRelativeWithIntrinsicBounds(Drawable drawable, Drawable drawable2, Drawable drawable3, Drawable drawable4) {
        super.setCompoundDrawablesRelativeWithIntrinsicBounds(drawable, drawable2, drawable3, drawable4);
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.b();
        }
    }

    @Override // android.widget.TextView
    public final void setCompoundDrawablesWithIntrinsicBounds(Drawable drawable, Drawable drawable2, Drawable drawable3, Drawable drawable4) {
        super.setCompoundDrawablesWithIntrinsicBounds(drawable, drawable2, drawable3, drawable4);
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.b();
        }
    }

    @Override // android.widget.TextView
    public void setCustomSelectionActionModeCallback(ActionMode.Callback callback) {
        super.setCustomSelectionActionModeCallback(H0.a.j0(callback, this));
    }

    @Override // android.widget.TextView
    public void setFirstBaselineToTopHeight(int i4) {
        if (Build.VERSION.SDK_INT >= 28) {
            super.setFirstBaselineToTopHeight(i4);
        } else {
            H0.a.b0(this, i4);
        }
    }

    @Override // android.widget.TextView
    public void setLastBaselineToBottomHeight(int i4) {
        if (Build.VERSION.SDK_INT >= 28) {
            super.setLastBaselineToBottomHeight(i4);
        } else {
            H0.a.c0(this, i4);
        }
    }

    @Override // android.widget.TextView
    public void setLineHeight(int i4) {
        if (i4 < 0) {
            throw new IllegalArgumentException();
        }
        if (i4 != getPaint().getFontMetricsInt(null)) {
            setLineSpacing(i4 - r0, 1.0f);
        }
    }

    public void setPrecomputedText(AbstractC0736c abstractC0736c) {
        if (Build.VERSION.SDK_INT >= 29) {
            throw null;
        }
        H0.a.G(this);
        throw null;
    }

    public void setSupportBackgroundTintList(ColorStateList colorStateList) {
        C0497n c0497n = this.f5473a;
        if (c0497n != null) {
            c0497n.e(colorStateList);
        }
    }

    public void setSupportBackgroundTintMode(PorterDuff.Mode mode) {
        C0497n c0497n = this.f5473a;
        if (c0497n != null) {
            c0497n.f(mode);
        }
    }

    public void setSupportCompoundDrawablesTintList(ColorStateList colorStateList) {
        C0503u c0503u = this.f5474b;
        if (c0503u.f5467h == null) {
            c0503u.f5467h = new Y.e();
        }
        Y.e eVar = c0503u.f5467h;
        eVar.f2460c = colorStateList;
        eVar.f2459b = colorStateList != null;
        c0503u.f5462b = eVar;
        c0503u.f5463c = eVar;
        c0503u.f5464d = eVar;
        c0503u.e = eVar;
        c0503u.f5465f = eVar;
        c0503u.f5466g = eVar;
        c0503u.b();
    }

    public void setSupportCompoundDrawablesTintMode(PorterDuff.Mode mode) {
        C0503u c0503u = this.f5474b;
        if (c0503u.f5467h == null) {
            c0503u.f5467h = new Y.e();
        }
        Y.e eVar = c0503u.f5467h;
        eVar.f2461d = mode;
        eVar.f2458a = mode != null;
        c0503u.f5462b = eVar;
        c0503u.f5463c = eVar;
        c0503u.f5464d = eVar;
        c0503u.e = eVar;
        c0503u.f5465f = eVar;
        c0503u.f5466g = eVar;
        c0503u.b();
    }

    @Override // android.widget.TextView
    public final void setTextAppearance(Context context, int i4) {
        super.setTextAppearance(context, i4);
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.e(context, i4);
        }
    }

    @Override // android.widget.TextView
    public void setTextClassifier(TextClassifier textClassifier) {
        com.google.android.gms.common.internal.r rVar;
        if (Build.VERSION.SDK_INT >= 28 || (rVar = this.f5475c) == null) {
            super.setTextClassifier(textClassifier);
        } else {
            rVar.f3598c = textClassifier;
        }
    }

    public void setTextFuture(Future<AbstractC0736c> future) {
        this.f5476d = future;
        if (future != null) {
            requestLayout();
        }
    }

    public void setTextMetricsParamsCompat(C0735b c0735b) {
        TextDirectionHeuristic textDirectionHeuristic;
        TextDirectionHeuristic textDirectionHeuristic2 = c0735b.f6800b;
        TextDirectionHeuristic textDirectionHeuristic3 = TextDirectionHeuristics.FIRSTSTRONG_RTL;
        int i4 = 1;
        if (textDirectionHeuristic2 != textDirectionHeuristic3 && textDirectionHeuristic2 != (textDirectionHeuristic = TextDirectionHeuristics.FIRSTSTRONG_LTR)) {
            if (textDirectionHeuristic2 == TextDirectionHeuristics.ANYRTL_LTR) {
                i4 = 2;
            } else if (textDirectionHeuristic2 == TextDirectionHeuristics.LTR) {
                i4 = 3;
            } else if (textDirectionHeuristic2 == TextDirectionHeuristics.RTL) {
                i4 = 4;
            } else if (textDirectionHeuristic2 == TextDirectionHeuristics.LOCALE) {
                i4 = 5;
            } else if (textDirectionHeuristic2 == textDirectionHeuristic) {
                i4 = 6;
            } else if (textDirectionHeuristic2 == textDirectionHeuristic3) {
                i4 = 7;
            }
        }
        setTextDirection(i4);
        getPaint().set(c0735b.f6799a);
        F.m.e(this, c0735b.f6801c);
        F.m.h(this, c0735b.f6802d);
    }

    @Override // android.widget.TextView
    public final void setTextSize(int i4, float f4) {
        boolean z4 = F.c.f391g;
        if (z4) {
            super.setTextSize(i4, f4);
            return;
        }
        C0503u c0503u = this.f5474b;
        if (c0503u == null || z4) {
            return;
        }
        C0505w c0505w = c0503u.f5468i;
        if (c0505w.f5480a != 0) {
            return;
        }
        c0505w.f(i4, f4);
    }

    @Override // android.widget.TextView
    public final void setTypeface(Typeface typeface, int i4) {
        Typeface typefaceCreate;
        if (typeface == null || i4 <= 0) {
            typefaceCreate = null;
        } else {
            Context context = getContext();
            AbstractC0367g abstractC0367g = t.d.f6514a;
            if (context == null) {
                throw new IllegalArgumentException("Context cannot be null");
            }
            typefaceCreate = Typeface.create(typeface, i4);
        }
        if (typefaceCreate != null) {
            typeface = typefaceCreate;
        }
        super.setTypeface(typeface, i4);
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0504v(Context context, AttributeSet attributeSet, int i4) {
        super(context, attributeSet, i4);
        i0.a(context);
        C0497n c0497n = new C0497n(this);
        this.f5473a = c0497n;
        c0497n.b(attributeSet, i4);
        C0503u c0503u = new C0503u(this);
        this.f5474b = c0503u;
        c0503u.d(attributeSet, i4);
        c0503u.b();
        com.google.android.gms.common.internal.r rVar = new com.google.android.gms.common.internal.r(10, false);
        rVar.f3597b = this;
        this.f5475c = rVar;
    }

    @Override // android.widget.TextView
    public final void setCompoundDrawablesRelativeWithIntrinsicBounds(int i4, int i5, int i6, int i7) {
        Context context = getContext();
        setCompoundDrawablesRelativeWithIntrinsicBounds(i4 != 0 ? AbstractC0404a.a(context, i4) : null, i5 != 0 ? AbstractC0404a.a(context, i5) : null, i6 != 0 ? AbstractC0404a.a(context, i6) : null, i7 != 0 ? AbstractC0404a.a(context, i7) : null);
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.b();
        }
    }

    @Override // android.widget.TextView
    public final void setCompoundDrawablesWithIntrinsicBounds(int i4, int i5, int i6, int i7) {
        Context context = getContext();
        setCompoundDrawablesWithIntrinsicBounds(i4 != 0 ? AbstractC0404a.a(context, i4) : null, i5 != 0 ? AbstractC0404a.a(context, i5) : null, i6 != 0 ? AbstractC0404a.a(context, i6) : null, i7 != 0 ? AbstractC0404a.a(context, i7) : null);
        C0503u c0503u = this.f5474b;
        if (c0503u != null) {
            c0503u.b();
        }
    }
}
