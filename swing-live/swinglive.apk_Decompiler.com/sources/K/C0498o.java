package k;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.util.Log;

/* JADX INFO: renamed from: k.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0498o {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final PorterDuff.Mode f5418b = PorterDuff.Mode.SRC_IN;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static C0498o f5419c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public P f5420a;

    public static synchronized void b() {
        if (f5419c == null) {
            C0498o c0498o = new C0498o();
            f5419c = c0498o;
            c0498o.f5420a = P.b();
            P p4 = f5419c.f5420a;
            Y0.n nVar = new Y0.n();
            synchronized (p4) {
                p4.e = nVar;
            }
        }
    }

    public static void c(Drawable drawable, Y.e eVar, int[] iArr) {
        PorterDuff.Mode mode = P.f5316f;
        if (AbstractC0508z.a(drawable) && drawable.mutate() != drawable) {
            Log.d("ResourceManagerInternal", "Mutated drawable is not the same instance as the input.");
            return;
        }
        boolean z4 = eVar.f2459b;
        if (!z4 && !eVar.f2458a) {
            drawable.clearColorFilter();
            return;
        }
        PorterDuffColorFilter porterDuffColorFilterE = null;
        ColorStateList colorStateList = z4 ? (ColorStateList) eVar.f2460c : null;
        PorterDuff.Mode mode2 = eVar.f2458a ? (PorterDuff.Mode) eVar.f2461d : P.f5316f;
        if (colorStateList != null && mode2 != null) {
            porterDuffColorFilterE = P.e(colorStateList.getColorForState(iArr, 0), mode2);
        }
        drawable.setColorFilter(porterDuffColorFilterE);
    }

    public final synchronized Drawable a(Context context, int i4) {
        return this.f5420a.c(context, i4);
    }
}
