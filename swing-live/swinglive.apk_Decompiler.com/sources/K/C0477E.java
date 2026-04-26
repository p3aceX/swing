package k;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.ViewGroup;
import f.AbstractC0398a;

/* JADX INFO: renamed from: k.E, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0477E extends ViewGroup.MarginLayoutParams {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final float f5267a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5268b;

    public C0477E(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        this.f5268b = -1;
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, AbstractC0398a.f4252j);
        this.f5267a = typedArrayObtainStyledAttributes.getFloat(3, 0.0f);
        this.f5268b = typedArrayObtainStyledAttributes.getInt(0, -1);
        typedArrayObtainStyledAttributes.recycle();
    }

    public C0477E(int i4) {
        super(i4, -2);
        this.f5268b = -1;
        this.f5267a = 0.0f;
    }

    public C0477E(ViewGroup.LayoutParams layoutParams) {
        super(layoutParams);
        this.f5268b = -1;
    }
}
