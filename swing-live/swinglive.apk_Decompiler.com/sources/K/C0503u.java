package k;

import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.widget.TextView;
import f.AbstractC0398a;
import y0.C0747k;

/* JADX INFO: renamed from: k.u, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0503u {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final TextView f5461a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y.e f5462b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y.e f5463c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Y.e f5464d;
    public Y.e e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Y.e f5465f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public Y.e f5466g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public Y.e f5467h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final C0505w f5468i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f5469j = 0;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f5470k = -1;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public Typeface f5471l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f5472m;

    public C0503u(TextView textView) {
        this.f5461a = textView;
        this.f5468i = new C0505w(textView);
    }

    public static Y.e c(Context context, C0498o c0498o, int i4) {
        ColorStateList colorStateListF;
        synchronized (c0498o) {
            colorStateListF = c0498o.f5420a.f(context, i4);
        }
        if (colorStateListF == null) {
            return null;
        }
        Y.e eVar = new Y.e();
        eVar.f2459b = true;
        eVar.f2460c = colorStateListF;
        return eVar;
    }

    public final void a(Drawable drawable, Y.e eVar) {
        if (drawable == null || eVar == null) {
            return;
        }
        C0498o.c(drawable, eVar, this.f5461a.getDrawableState());
    }

    public final void b() {
        Y.e eVar = this.f5462b;
        TextView textView = this.f5461a;
        if (eVar != null || this.f5463c != null || this.f5464d != null || this.e != null) {
            Drawable[] compoundDrawables = textView.getCompoundDrawables();
            a(compoundDrawables[0], this.f5462b);
            a(compoundDrawables[1], this.f5463c);
            a(compoundDrawables[2], this.f5464d);
            a(compoundDrawables[3], this.e);
        }
        if (this.f5465f == null && this.f5466g == null) {
            return;
        }
        Drawable[] compoundDrawablesRelative = textView.getCompoundDrawablesRelative();
        a(compoundDrawablesRelative[0], this.f5465f);
        a(compoundDrawablesRelative[2], this.f5466g);
    }

    /* JADX WARN: Removed duplicated region for block: B:221:0x0345  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void d(android.util.AttributeSet r26, int r27) {
        /*
            Method dump skipped, instruction units count: 929
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: k.C0503u.d(android.util.AttributeSet, int):void");
    }

    public final void e(Context context, int i4) {
        String string;
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(i4, AbstractC0398a.f4261s);
        C0747k c0747k = new C0747k(context, typedArrayObtainStyledAttributes);
        boolean zHasValue = typedArrayObtainStyledAttributes.hasValue(14);
        TextView textView = this.f5461a;
        if (zHasValue) {
            textView.setAllCaps(typedArrayObtainStyledAttributes.getBoolean(14, false));
        }
        int i5 = Build.VERSION.SDK_INT;
        if (typedArrayObtainStyledAttributes.hasValue(0) && typedArrayObtainStyledAttributes.getDimensionPixelSize(0, -1) == 0) {
            textView.setTextSize(0, 0.0f);
        }
        f(context, c0747k);
        if (i5 >= 26 && typedArrayObtainStyledAttributes.hasValue(13) && (string = typedArrayObtainStyledAttributes.getString(13)) != null) {
            textView.setFontVariationSettings(string);
        }
        c0747k.T();
        Typeface typeface = this.f5471l;
        if (typeface != null) {
            textView.setTypeface(typeface, this.f5469j);
        }
    }

    public final void f(Context context, C0747k c0747k) {
        String string;
        int i4 = this.f5469j;
        TypedArray typedArray = (TypedArray) c0747k.f6832c;
        this.f5469j = typedArray.getInt(2, i4);
        int i5 = Build.VERSION.SDK_INT;
        if (i5 >= 28) {
            int i6 = typedArray.getInt(11, -1);
            this.f5470k = i6;
            if (i6 != -1) {
                this.f5469j &= 2;
            }
        }
        if (!typedArray.hasValue(10) && !typedArray.hasValue(12)) {
            if (typedArray.hasValue(1)) {
                this.f5472m = false;
                int i7 = typedArray.getInt(1, 1);
                if (i7 == 1) {
                    this.f5471l = Typeface.SANS_SERIF;
                    return;
                } else if (i7 == 2) {
                    this.f5471l = Typeface.SERIF;
                    return;
                } else {
                    if (i7 != 3) {
                        return;
                    }
                    this.f5471l = Typeface.MONOSPACE;
                    return;
                }
            }
            return;
        }
        this.f5471l = null;
        int i8 = typedArray.hasValue(12) ? 12 : 10;
        int i9 = this.f5470k;
        int i10 = this.f5469j;
        if (!context.isRestricted()) {
            try {
                Typeface typefaceG = c0747k.G(i8, this.f5469j, new C0502t(this, i9, i10));
                if (typefaceG != null) {
                    if (i5 < 28 || this.f5470k == -1) {
                        this.f5471l = typefaceG;
                    } else {
                        this.f5471l = Typeface.create(Typeface.create(typefaceG, 0), this.f5470k, (this.f5469j & 2) != 0);
                    }
                }
                this.f5472m = this.f5471l == null;
            } catch (Resources.NotFoundException | UnsupportedOperationException unused) {
            }
        }
        if (this.f5471l != null || (string = typedArray.getString(i8)) == null) {
            return;
        }
        if (Build.VERSION.SDK_INT < 28 || this.f5470k == -1) {
            this.f5471l = Typeface.create(string, this.f5469j);
        } else {
            this.f5471l = Typeface.create(Typeface.create(string, 0), this.f5470k, (this.f5469j & 2) != 0);
        }
    }
}
