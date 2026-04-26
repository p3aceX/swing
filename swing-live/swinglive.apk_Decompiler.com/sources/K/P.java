package k;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.util.TypedValue;
import c0.AbstractC0249a;
import com.swing.live.R;
import java.lang.ref.WeakReference;
import java.util.WeakHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class P {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static P f5317g;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public WeakHashMap f5319a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final WeakHashMap f5320b = new WeakHashMap(0);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public TypedValue f5321c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f5322d;
    public Y0.n e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final PorterDuff.Mode f5316f = PorterDuff.Mode.SRC_IN;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public static final O f5318h = new O(6);

    public static synchronized P b() {
        try {
            if (f5317g == null) {
                f5317g = new P();
            }
        } catch (Throwable th) {
            throw th;
        }
        return f5317g;
    }

    public static synchronized PorterDuffColorFilter e(int i4, PorterDuff.Mode mode) {
        PorterDuffColorFilter porterDuffColorFilter;
        O o4 = f5318h;
        o4.getClass();
        int i5 = (31 + i4) * 31;
        porterDuffColorFilter = (PorterDuffColorFilter) o4.get(Integer.valueOf(mode.hashCode() + i5));
        if (porterDuffColorFilter == null) {
            porterDuffColorFilter = new PorterDuffColorFilter(i4, mode);
        }
        return porterDuffColorFilter;
    }

    public final Drawable a(Context context, int i4) {
        Drawable drawableNewDrawable;
        Object obj;
        if (this.f5321c == null) {
            this.f5321c = new TypedValue();
        }
        TypedValue typedValue = this.f5321c;
        context.getResources().getValue(i4, typedValue, true);
        long j4 = (((long) typedValue.assetCookie) << 32) | ((long) typedValue.data);
        synchronized (this) {
            n.e eVar = (n.e) this.f5320b.get(context);
            drawableNewDrawable = null;
            if (eVar != null) {
                int iB = n.d.b(eVar.f5837b, eVar.f5839d, j4);
                if (iB < 0 || (obj = eVar.f5838c[iB]) == n.e.e) {
                    obj = null;
                }
                WeakReference weakReference = (WeakReference) obj;
                if (weakReference != null) {
                    Drawable.ConstantState constantState = (Drawable.ConstantState) weakReference.get();
                    if (constantState != null) {
                        drawableNewDrawable = constantState.newDrawable(context.getResources());
                    } else {
                        int iB2 = n.d.b(eVar.f5837b, eVar.f5839d, j4);
                        if (iB2 >= 0) {
                            Object[] objArr = eVar.f5838c;
                            Object obj2 = objArr[iB2];
                            Object obj3 = n.e.e;
                            if (obj2 != obj3) {
                                objArr[iB2] = obj3;
                                eVar.f5836a = true;
                            }
                        }
                    }
                }
            }
        }
        if (drawableNewDrawable != null) {
            return drawableNewDrawable;
        }
        LayerDrawable layerDrawable = null;
        if (this.e != null && i4 == R.drawable.abc_cab_background_top_material) {
            layerDrawable = new LayerDrawable(new Drawable[]{c(context, R.drawable.abc_cab_background_internal_bg), c(context, R.drawable.abc_cab_background_top_mtrl_alpha)});
        }
        if (layerDrawable == null) {
            return layerDrawable;
        }
        layerDrawable.setChangingConfigurations(typedValue.changingConfigurations);
        synchronized (this) {
            try {
                Drawable.ConstantState constantState2 = layerDrawable.getConstantState();
                if (constantState2 != null) {
                    n.e eVar2 = (n.e) this.f5320b.get(context);
                    if (eVar2 == null) {
                        eVar2 = new n.e();
                        this.f5320b.put(context, eVar2);
                    }
                    eVar2.b(new WeakReference(constantState2), j4);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return layerDrawable;
    }

    public final synchronized Drawable c(Context context, int i4) {
        return d(context, i4);
    }

    public final synchronized Drawable d(Context context, int i4) {
        Drawable drawableA;
        try {
            if (!this.f5322d) {
                this.f5322d = true;
                Drawable drawableC = c(context, R.drawable.abc_vector_test);
                if (drawableC == null || (!(drawableC instanceof AbstractC0249a) && !"android.graphics.drawable.VectorDrawable".equals(drawableC.getClass().getName()))) {
                    this.f5322d = false;
                    throw new IllegalStateException("This app has been built with an incorrect configuration. Please configure your build for VectorDrawableCompat.");
                }
            }
            drawableA = a(context, i4);
            if (drawableA == null) {
                drawableA = r.h.getDrawable(context, i4);
            }
            if (drawableA != null) {
                drawableA = g(context, i4, drawableA);
            }
            if (drawableA != null) {
                Rect rect = AbstractC0508z.f5489a;
            }
        } catch (Throwable th) {
            throw th;
        }
        return drawableA;
    }

    public final synchronized ColorStateList f(Context context, int i4) {
        ColorStateList colorStateList;
        n.l lVar;
        WeakHashMap weakHashMap = this.f5319a;
        ColorStateList colorStateListD = null;
        colorStateList = (weakHashMap == null || (lVar = (n.l) weakHashMap.get(context)) == null) ? null : (ColorStateList) lVar.b(i4, null);
        if (colorStateList == null) {
            Y0.n nVar = this.e;
            if (nVar != null) {
                colorStateListD = nVar.d(context, i4);
            }
            if (colorStateListD != null) {
                if (this.f5319a == null) {
                    this.f5319a = new WeakHashMap();
                }
                n.l lVar2 = (n.l) this.f5319a.get(context);
                if (lVar2 == null) {
                    lVar2 = new n.l();
                    this.f5319a.put(context, lVar2);
                }
                lVar2.a(i4, colorStateListD);
            }
            colorStateList = colorStateListD;
        }
        return colorStateList;
    }

    /* JADX WARN: Removed duplicated region for block: B:52:0x00ee  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.graphics.drawable.Drawable g(android.content.Context r8, int r9, android.graphics.drawable.Drawable r10) {
        /*
            Method dump skipped, instruction units count: 275
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: k.P.g(android.content.Context, int, android.graphics.drawable.Drawable):android.graphics.drawable.Drawable");
    }
}
