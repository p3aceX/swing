package A;

import android.view.View;
import android.view.WindowInsets;

/* JADX INFO: renamed from: A.u, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0020u {
    public static X a(View view) {
        WindowInsets rootWindowInsets = view.getRootWindowInsets();
        if (rootWindowInsets == null) {
            return null;
        }
        X xA = X.a(rootWindowInsets, null);
        V v = xA.f33a;
        v.o(xA);
        v.d(view.getRootView());
        return xA;
    }

    public static int b(View view) {
        return view.getScrollIndicators();
    }

    public static void c(View view, int i4) {
        view.setScrollIndicators(i4);
    }

    public static void d(View view, int i4, int i5) {
        view.setScrollIndicators(i4, i5);
    }
}
