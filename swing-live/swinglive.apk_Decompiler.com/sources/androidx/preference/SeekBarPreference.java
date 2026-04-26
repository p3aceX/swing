package androidx.preference;

import U.a;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import com.swing.live.R;

/* JADX INFO: loaded from: classes.dex */
public class SeekBarPreference extends Preference {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final int f3116n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final int f3117o;

    public SeekBarPreference(Context context, AttributeSet attributeSet) {
        super(context, attributeSet, R.attr.seekBarPreferenceStyle);
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, a.f2083i, R.attr.seekBarPreferenceStyle, 0);
        int i4 = typedArrayObtainStyledAttributes.getInt(3, 0);
        int i5 = typedArrayObtainStyledAttributes.getInt(1, 100);
        i5 = i5 < i4 ? i4 : i5;
        if (i5 != this.f3116n) {
            this.f3116n = i5;
        }
        int i6 = typedArrayObtainStyledAttributes.getInt(4, 0);
        if (i6 != this.f3117o) {
            this.f3117o = Math.min(this.f3116n - i4, Math.abs(i6));
        }
        typedArrayObtainStyledAttributes.getBoolean(2, true);
        typedArrayObtainStyledAttributes.getBoolean(5, false);
        typedArrayObtainStyledAttributes.getBoolean(6, false);
        typedArrayObtainStyledAttributes.recycle();
    }

    @Override // androidx.preference.Preference
    public final Object c(TypedArray typedArray, int i4) {
        return Integer.valueOf(typedArray.getInt(i4, 0));
    }
}
