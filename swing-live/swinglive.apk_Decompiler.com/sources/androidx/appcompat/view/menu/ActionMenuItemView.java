package androidx.appcompat.view.menu;

import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import e1.AbstractC0367g;
import f.AbstractC0398a;
import j.a;
import j.b;
import j.i;
import j.j;
import j.k;
import j.q;
import k.C0504v;
import k.InterfaceC0493j;

/* JADX INFO: loaded from: classes.dex */
public class ActionMenuItemView extends C0504v implements q, View.OnClickListener, InterfaceC0493j {
    public k e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public CharSequence f2646f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public Drawable f2647m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public i f2648n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public a f2649o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public b f2650p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public boolean f2651q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public boolean f2652r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final int f2653s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public int f2654t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final int f2655u;

    public ActionMenuItemView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, 0);
        Resources resources = context.getResources();
        this.f2651q = e();
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, AbstractC0398a.f4246c, 0, 0);
        this.f2653s = typedArrayObtainStyledAttributes.getDimensionPixelSize(0, 0);
        typedArrayObtainStyledAttributes.recycle();
        this.f2655u = (int) ((resources.getDisplayMetrics().density * 32.0f) + 0.5f);
        setOnClickListener(this);
        this.f2654t = -1;
        setSaveEnabled(false);
    }

    @Override // k.InterfaceC0493j
    public final boolean a() {
        return !TextUtils.isEmpty(getText());
    }

    @Override // k.InterfaceC0493j
    public final boolean b() {
        return !TextUtils.isEmpty(getText()) && this.e.getIcon() == null;
    }

    @Override // j.q
    public final void c(k kVar) {
        this.e = kVar;
        setIcon(kVar.getIcon());
        setTitle(kVar.getTitleCondensed());
        setId(kVar.f5102a);
        setVisibility(kVar.isVisible() ? 0 : 8);
        setEnabled(kVar.isEnabled());
        if (kVar.hasSubMenu() && this.f2649o == null) {
            this.f2649o = new a(this);
        }
    }

    public final boolean e() {
        Configuration configuration = getContext().getResources().getConfiguration();
        int i4 = configuration.screenWidthDp;
        int i5 = configuration.screenHeightDp;
        if (i4 < 480) {
            return (i4 >= 640 && i5 >= 480) || configuration.orientation == 2;
        }
        return true;
    }

    public final void f() {
        boolean z4 = true;
        boolean z5 = !TextUtils.isEmpty(this.f2646f);
        if (this.f2647m != null && ((this.e.f5124y & 4) != 4 || (!this.f2651q && !this.f2652r))) {
            z4 = false;
        }
        boolean z6 = z5 & z4;
        setText(z6 ? this.f2646f : null);
        CharSequence charSequence = this.e.f5117q;
        if (TextUtils.isEmpty(charSequence)) {
            setContentDescription(z6 ? null : this.e.e);
        } else {
            setContentDescription(charSequence);
        }
        CharSequence charSequence2 = this.e.f5118r;
        if (TextUtils.isEmpty(charSequence2)) {
            AbstractC0367g.K(this, z6 ? null : this.e.e);
        } else {
            AbstractC0367g.K(this, charSequence2);
        }
    }

    @Override // j.q
    public k getItemData() {
        return this.e;
    }

    @Override // android.view.View.OnClickListener
    public final void onClick(View view) {
        i iVar = this.f2648n;
        if (iVar != null) {
            iVar.a(this.e);
        }
    }

    @Override // android.widget.TextView, android.view.View
    public final void onConfigurationChanged(Configuration configuration) {
        super.onConfigurationChanged(configuration);
        this.f2651q = e();
        f();
    }

    @Override // k.C0504v, android.widget.TextView, android.view.View
    public final void onMeasure(int i4, int i5) {
        int i6;
        boolean zIsEmpty = TextUtils.isEmpty(getText());
        if (!zIsEmpty && (i6 = this.f2654t) >= 0) {
            super.setPadding(i6, getPaddingTop(), getPaddingRight(), getPaddingBottom());
        }
        super.onMeasure(i4, i5);
        int mode = View.MeasureSpec.getMode(i4);
        int size = View.MeasureSpec.getSize(i4);
        int measuredWidth = getMeasuredWidth();
        int i7 = this.f2653s;
        int iMin = mode == Integer.MIN_VALUE ? Math.min(size, i7) : i7;
        if (mode != 1073741824 && i7 > 0 && measuredWidth < iMin) {
            super.onMeasure(View.MeasureSpec.makeMeasureSpec(iMin, 1073741824), i5);
        }
        if (!zIsEmpty || this.f2647m == null) {
            return;
        }
        super.setPadding((getMeasuredWidth() - this.f2647m.getBounds().width()) / 2, getPaddingTop(), getPaddingRight(), getPaddingBottom());
    }

    @Override // android.widget.TextView, android.view.View
    public final void onRestoreInstanceState(Parcelable parcelable) {
        super.onRestoreInstanceState(null);
    }

    @Override // android.widget.TextView, android.view.View
    public final boolean onTouchEvent(MotionEvent motionEvent) {
        a aVar;
        if (this.e.hasSubMenu() && (aVar = this.f2649o) != null && aVar.onTouch(this, motionEvent)) {
            return true;
        }
        return super.onTouchEvent(motionEvent);
    }

    public void setCheckable(boolean z4) {
    }

    public void setChecked(boolean z4) {
    }

    public void setExpandedFormat(boolean z4) {
        if (this.f2652r != z4) {
            this.f2652r = z4;
            k kVar = this.e;
            if (kVar != null) {
                j jVar = kVar.f5114n;
                jVar.f5090k = true;
                jVar.o(true);
            }
        }
    }

    public void setIcon(Drawable drawable) {
        this.f2647m = drawable;
        if (drawable != null) {
            int intrinsicWidth = drawable.getIntrinsicWidth();
            int intrinsicHeight = drawable.getIntrinsicHeight();
            int i4 = this.f2655u;
            if (intrinsicWidth > i4) {
                intrinsicHeight = (int) (intrinsicHeight * (i4 / intrinsicWidth));
                intrinsicWidth = i4;
            }
            if (intrinsicHeight > i4) {
                intrinsicWidth = (int) (intrinsicWidth * (i4 / intrinsicHeight));
            } else {
                i4 = intrinsicHeight;
            }
            drawable.setBounds(0, 0, intrinsicWidth, i4);
        }
        setCompoundDrawables(drawable, null, null, null);
        f();
    }

    public void setItemInvoker(i iVar) {
        this.f2648n = iVar;
    }

    @Override // android.widget.TextView, android.view.View
    public final void setPadding(int i4, int i5, int i6, int i7) {
        this.f2654t = i4;
        super.setPadding(i4, i5, i6, i7);
    }

    public void setPopupCallback(b bVar) {
        this.f2650p = bVar;
    }

    public void setTitle(CharSequence charSequence) {
        this.f2646f = charSequence;
        f();
    }
}
