package A;

import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.view.WindowInsets;
import com.swing.live.R;

/* JADX INFO: renamed from: A.t, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0019t {
    public static void a(WindowInsets windowInsets, View view) {
        View.OnApplyWindowInsetsListener onApplyWindowInsetsListener = (View.OnApplyWindowInsetsListener) view.getTag(R.id.tag_window_insets_animation_callback);
        if (onApplyWindowInsetsListener != null) {
            onApplyWindowInsetsListener.onApplyWindowInsets(view, windowInsets);
        }
    }

    public static X b(View view, X x4, Rect rect) {
        V v = x4.f33a;
        WindowInsets windowInsets = v instanceof O ? ((O) v).f22c : null;
        if (windowInsets != null) {
            return X.a(view.computeSystemWindowInsets(windowInsets, rect), view);
        }
        rect.setEmpty();
        return x4;
    }

    public static boolean c(View view, float f4, float f5, boolean z4) {
        return view.dispatchNestedFling(f4, f5, z4);
    }

    public static boolean d(View view, float f4, float f5) {
        return view.dispatchNestedPreFling(f4, f5);
    }

    public static boolean e(View view, int i4, int i5, int[] iArr, int[] iArr2) {
        return view.dispatchNestedPreScroll(i4, i5, iArr, iArr2);
    }

    public static boolean f(View view, int i4, int i5, int i6, int i7, int[] iArr) {
        return view.dispatchNestedScroll(i4, i5, i6, i7, iArr);
    }

    public static ColorStateList g(View view) {
        return view.getBackgroundTintList();
    }

    public static PorterDuff.Mode h(View view) {
        return view.getBackgroundTintMode();
    }

    public static float i(View view) {
        return view.getElevation();
    }

    public static X j(View view) {
        if (!I.f10d || !view.isAttachedToWindow()) {
            return null;
        }
        try {
            Object obj = I.f7a.get(view.getRootView());
            if (obj == null) {
                return null;
            }
            Rect rect = (Rect) I.f8b.get(obj);
            Rect rect2 = (Rect) I.f9c.get(obj);
            if (rect == null || rect2 == null) {
                return null;
            }
            int i4 = Build.VERSION.SDK_INT;
            N m4 = i4 >= 30 ? new M() : i4 >= 29 ? new L() : new J();
            m4.c(t.c.a(rect.left, rect.top, rect.right, rect.bottom));
            m4.d(t.c.a(rect2.left, rect2.top, rect2.right, rect2.bottom));
            X xB = m4.b();
            xB.f33a.o(xB);
            xB.f33a.d(view.getRootView());
            return xB;
        } catch (IllegalAccessException e) {
            Log.w("WindowInsetsCompat", "Failed to get insets from AttachInfo. " + e.getMessage(), e);
            return null;
        }
    }

    public static String k(View view) {
        return view.getTransitionName();
    }

    public static float l(View view) {
        return view.getTranslationZ();
    }

    public static float m(View view) {
        return view.getZ();
    }

    public static boolean n(View view) {
        return view.hasNestedScrollingParent();
    }

    public static boolean o(View view) {
        return view.isImportantForAccessibility();
    }

    public static boolean p(View view) {
        return view.isNestedScrollingEnabled();
    }

    public static void q(View view, ColorStateList colorStateList) {
        view.setBackgroundTintList(colorStateList);
    }

    public static void r(View view, PorterDuff.Mode mode) {
        view.setBackgroundTintMode(mode);
    }

    public static void s(View view, float f4) {
        view.setElevation(f4);
    }

    public static void t(View view, boolean z4) {
        view.setNestedScrollingEnabled(z4);
    }

    public static void u(View view, InterfaceC0013m interfaceC0013m) {
        if (Build.VERSION.SDK_INT < 30) {
            view.setTag(R.id.tag_on_apply_window_listener, interfaceC0013m);
        }
        if (interfaceC0013m == null) {
            view.setOnApplyWindowInsetsListener((View.OnApplyWindowInsetsListener) view.getTag(R.id.tag_window_insets_animation_callback));
        } else {
            view.setOnApplyWindowInsetsListener(new ViewOnApplyWindowInsetsListenerC0018s(view, interfaceC0013m));
        }
    }

    public static void v(View view, String str) {
        view.setTransitionName(str);
    }

    public static void w(View view, float f4) {
        view.setTranslationZ(f4);
    }

    public static void x(View view, float f4) {
        view.setZ(f4);
    }

    public static boolean y(View view, int i4) {
        return view.startNestedScroll(i4);
    }

    public static void z(View view) {
        view.stopNestedScroll();
    }
}
