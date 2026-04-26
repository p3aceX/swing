package androidx.appcompat.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import f.AbstractC0398a;
import java.lang.ref.WeakReference;
import k.u0;

/* JADX INFO: loaded from: classes.dex */
public final class ViewStubCompat extends View {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2843a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2844b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public WeakReference f2845c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public LayoutInflater f2846d;

    public ViewStubCompat(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, 0);
        this.f2843a = 0;
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, AbstractC0398a.v, 0, 0);
        this.f2844b = typedArrayObtainStyledAttributes.getResourceId(2, -1);
        this.f2843a = typedArrayObtainStyledAttributes.getResourceId(1, 0);
        setId(typedArrayObtainStyledAttributes.getResourceId(0, -1));
        typedArrayObtainStyledAttributes.recycle();
        setVisibility(8);
        setWillNotDraw(true);
    }

    @Override // android.view.View
    public final void dispatchDraw(Canvas canvas) {
    }

    @Override // android.view.View
    public final void draw(Canvas canvas) {
    }

    public int getInflatedId() {
        return this.f2844b;
    }

    public LayoutInflater getLayoutInflater() {
        return this.f2846d;
    }

    public int getLayoutResource() {
        return this.f2843a;
    }

    @Override // android.view.View
    public final void onMeasure(int i4, int i5) {
        setMeasuredDimension(0, 0);
    }

    public void setInflatedId(int i4) {
        this.f2844b = i4;
    }

    public void setLayoutInflater(LayoutInflater layoutInflater) {
        this.f2846d = layoutInflater;
    }

    public void setLayoutResource(int i4) {
        this.f2843a = i4;
    }

    @Override // android.view.View
    public void setVisibility(int i4) {
        WeakReference weakReference = this.f2845c;
        if (weakReference != null) {
            View view = (View) weakReference.get();
            if (view == null) {
                throw new IllegalStateException("setVisibility called on un-referenced view");
            }
            view.setVisibility(i4);
            return;
        }
        super.setVisibility(i4);
        if (i4 == 0 || i4 == 4) {
            ViewParent parent = getParent();
            if (!(parent instanceof ViewGroup)) {
                throw new IllegalStateException("ViewStub must have a non-null ViewGroup viewParent");
            }
            if (this.f2843a == 0) {
                throw new IllegalArgumentException("ViewStub must have a valid layoutResource");
            }
            ViewGroup viewGroup = (ViewGroup) parent;
            LayoutInflater layoutInflaterFrom = this.f2846d;
            if (layoutInflaterFrom == null) {
                layoutInflaterFrom = LayoutInflater.from(getContext());
            }
            View viewInflate = layoutInflaterFrom.inflate(this.f2843a, viewGroup, false);
            int i5 = this.f2844b;
            if (i5 != -1) {
                viewInflate.setId(i5);
            }
            int iIndexOfChild = viewGroup.indexOfChild(this);
            viewGroup.removeViewInLayout(this);
            ViewGroup.LayoutParams layoutParams = getLayoutParams();
            if (layoutParams != null) {
                viewGroup.addView(viewInflate, iIndexOfChild, layoutParams);
            } else {
                viewGroup.addView(viewInflate, iIndexOfChild);
            }
            this.f2845c = new WeakReference(viewInflate);
        }
    }

    public void setOnInflateListener(u0 u0Var) {
    }
}
