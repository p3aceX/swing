package k;

import android.R;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.TypedArray;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.ActionMode;
import android.view.View;
import android.view.ViewParent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.widget.AutoCompleteTextView;
import g.AbstractC0404a;
import y0.C0747k;

/* JADX INFO: renamed from: k.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0496m extends AutoCompleteTextView {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final int[] f5408c = {R.attr.popupBackground};

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0497n f5409a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0503u f5410b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public AbstractC0496m(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, com.swing.live.R.attr.autoCompleteTextViewStyle);
        i0.a(context);
        C0747k c0747kP = C0747k.P(getContext(), attributeSet, f5408c, com.swing.live.R.attr.autoCompleteTextViewStyle);
        if (((TypedArray) c0747kP.f6832c).hasValue(0)) {
            setDropDownBackgroundDrawable(c0747kP.F(0));
        }
        c0747kP.T();
        C0497n c0497n = new C0497n(this);
        this.f5409a = c0497n;
        c0497n.b(attributeSet, com.swing.live.R.attr.autoCompleteTextViewStyle);
        C0503u c0503u = new C0503u(this);
        this.f5410b = c0503u;
        c0503u.d(attributeSet, com.swing.live.R.attr.autoCompleteTextViewStyle);
        c0503u.b();
    }

    @Override // android.widget.TextView, android.view.View
    public final void drawableStateChanged() {
        super.drawableStateChanged();
        C0497n c0497n = this.f5409a;
        if (c0497n != null) {
            c0497n.a();
        }
        C0503u c0503u = this.f5410b;
        if (c0503u != null) {
            c0503u.b();
        }
    }

    public ColorStateList getSupportBackgroundTintList() {
        Y.e eVar;
        C0497n c0497n = this.f5409a;
        if (c0497n == null || (eVar = c0497n.e) == null) {
            return null;
        }
        return (ColorStateList) eVar.f2460c;
    }

    public PorterDuff.Mode getSupportBackgroundTintMode() {
        Y.e eVar;
        C0497n c0497n = this.f5409a;
        if (c0497n == null || (eVar = c0497n.e) == null) {
            return null;
        }
        return (PorterDuff.Mode) eVar.f2461d;
    }

    @Override // android.widget.TextView, android.view.View
    public InputConnection onCreateInputConnection(EditorInfo editorInfo) {
        InputConnection inputConnectionOnCreateInputConnection = super.onCreateInputConnection(editorInfo);
        if (inputConnectionOnCreateInputConnection != null && editorInfo.hintText == null) {
            for (ViewParent parent = getParent(); parent instanceof View; parent = parent.getParent()) {
            }
        }
        return inputConnectionOnCreateInputConnection;
    }

    @Override // android.view.View
    public void setBackgroundDrawable(Drawable drawable) {
        super.setBackgroundDrawable(drawable);
        C0497n c0497n = this.f5409a;
        if (c0497n != null) {
            c0497n.f5415c = -1;
            c0497n.d(null);
            c0497n.a();
        }
    }

    @Override // android.view.View
    public void setBackgroundResource(int i4) {
        super.setBackgroundResource(i4);
        C0497n c0497n = this.f5409a;
        if (c0497n != null) {
            c0497n.c(i4);
        }
    }

    @Override // android.widget.TextView
    public void setCustomSelectionActionModeCallback(ActionMode.Callback callback) {
        super.setCustomSelectionActionModeCallback(H0.a.j0(callback, this));
    }

    @Override // android.widget.AutoCompleteTextView
    public void setDropDownBackgroundResource(int i4) {
        setDropDownBackgroundDrawable(AbstractC0404a.a(getContext(), i4));
    }

    public void setSupportBackgroundTintList(ColorStateList colorStateList) {
        C0497n c0497n = this.f5409a;
        if (c0497n != null) {
            c0497n.e(colorStateList);
        }
    }

    public void setSupportBackgroundTintMode(PorterDuff.Mode mode) {
        C0497n c0497n = this.f5409a;
        if (c0497n != null) {
            c0497n.f(mode);
        }
    }

    @Override // android.widget.TextView
    public final void setTextAppearance(Context context, int i4) {
        super.setTextAppearance(context, i4);
        C0503u c0503u = this.f5410b;
        if (c0503u != null) {
            c0503u.e(context, i4);
        }
    }
}
