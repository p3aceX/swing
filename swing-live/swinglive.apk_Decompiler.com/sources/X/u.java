package X;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.ViewGroup;

/* JADX INFO: loaded from: classes.dex */
public class u extends ViewGroup.MarginLayoutParams {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Rect f2377a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f2378b;

    public u(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        this.f2377a = new Rect();
        this.f2378b = true;
    }

    public u(int i4, int i5) {
        super(i4, i5);
        this.f2377a = new Rect();
        this.f2378b = true;
    }

    public u(ViewGroup.MarginLayoutParams marginLayoutParams) {
        super(marginLayoutParams);
        this.f2377a = new Rect();
        this.f2378b = true;
    }

    public u(ViewGroup.LayoutParams layoutParams) {
        super(layoutParams);
        this.f2377a = new Rect();
        this.f2378b = true;
    }

    public u(u uVar) {
        super((ViewGroup.LayoutParams) uVar);
        this.f2377a = new Rect();
        this.f2378b = true;
    }
}
