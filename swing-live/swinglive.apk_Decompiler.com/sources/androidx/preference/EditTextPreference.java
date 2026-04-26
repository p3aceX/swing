package androidx.preference;

import U.a;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import com.swing.live.R;
import p1.d;
import s.AbstractC0658b;

/* JADX INFO: loaded from: classes.dex */
public class EditTextPreference extends DialogPreference {
    /* JADX WARN: Illegal instructions before constructor call */
    public EditTextPreference(Context context, AttributeSet attributeSet) {
        int iA = AbstractC0658b.a(context, R.attr.editTextPreferenceStyle, android.R.attr.editTextPreferenceStyle);
        super(context, attributeSet, iA);
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, a.f2078c, iA, 0);
        if (typedArrayObtainStyledAttributes.getBoolean(0, typedArrayObtainStyledAttributes.getBoolean(0, false))) {
            if (d.f6185b == null) {
                d.f6185b = new d(18);
            }
            this.f3115m = d.f6185b;
        }
        typedArrayObtainStyledAttributes.recycle();
    }

    @Override // androidx.preference.Preference
    public final Object c(TypedArray typedArray, int i4) {
        return typedArray.getString(i4);
    }
}
