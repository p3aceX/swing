package k0;

import A.J;
import A.L;
import A.M;
import A.X;
import J3.i;
import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Point;
import android.graphics.Rect;
import android.inputmethodservice.InputMethodService;
import android.os.Build;
import android.view.Display;
import android.view.WindowManager;
import androidx.window.extensions.layout.FoldingFeature;
import androidx.window.extensions.layout.WindowLayoutInfo;
import i0.j;
import i0.k;
import i0.n;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public abstract class e {
    public static i0.c a(k kVar, FoldingFeature foldingFeature) {
        i0.b bVar;
        i0.b bVar2;
        int type = foldingFeature.getType();
        if (type == 1) {
            bVar = i0.b.f4461m;
        } else {
            if (type != 2) {
                return null;
            }
            bVar = i0.b.f4462n;
        }
        int state = foldingFeature.getState();
        if (state == 1) {
            bVar2 = i0.b.e;
        } else {
            if (state != 2) {
                return null;
            }
            bVar2 = i0.b.f4460f;
        }
        Rect bounds = foldingFeature.getBounds();
        i.d(bounds, "oemFeature.bounds");
        int i4 = bounds.left;
        int i5 = bounds.top;
        int i6 = bounds.right;
        int i7 = bounds.bottom;
        if (i4 > i6) {
            throw new IllegalArgumentException(B1.a.k("Left must be less than or equal to right, left: ", i4, i6, ", right: ").toString());
        }
        if (i5 > i7) {
            throw new IllegalArgumentException(B1.a.k("top must be less than or equal to bottom, top: ", i5, i7, ", bottom: ").toString());
        }
        Rect rectA = kVar.f4483a.a();
        int i8 = i7 - i5;
        if (i8 == 0 && i6 - i4 == 0) {
            return null;
        }
        int i9 = i6 - i4;
        if (i9 != rectA.width() && i8 != rectA.height()) {
            return null;
        }
        if (i9 < rectA.width() && i8 < rectA.height()) {
            return null;
        }
        if (i9 == rectA.width() && i8 == rectA.height()) {
            return null;
        }
        Rect bounds2 = foldingFeature.getBounds();
        i.d(bounds2, "oemFeature.bounds");
        return new i0.c(new f0.b(bounds2), bVar, bVar2);
    }

    public static j b(Context context, WindowLayoutInfo windowLayoutInfo) throws Exception {
        k kVar;
        i.e(windowLayoutInfo, "info");
        int i4 = Build.VERSION.SDK_INT;
        if (i4 < 30) {
            if (i4 < 29 || !(context instanceof Activity)) {
                throw new UnsupportedOperationException("Display Features are only supported after Q. Display features for non-Activity contexts are not expected to be reported on devices running Q.");
            }
            int i5 = n.f4486b;
            return c(n.a((Activity) context), windowLayoutInfo);
        }
        int i6 = n.f4486b;
        if (i4 < 30) {
            Context baseContext = context;
            while (baseContext instanceof ContextWrapper) {
                boolean z4 = baseContext instanceof Activity;
                if (!z4 && !(baseContext instanceof InputMethodService)) {
                    ContextWrapper contextWrapper = (ContextWrapper) baseContext;
                    if (contextWrapper.getBaseContext() != null) {
                        baseContext = contextWrapper.getBaseContext();
                        i.d(baseContext, "iterator.baseContext");
                    }
                }
                if (z4) {
                    kVar = n.a((Activity) context);
                } else {
                    if (!(baseContext instanceof InputMethodService)) {
                        throw new IllegalArgumentException(context + " is not a UiContext");
                    }
                    Object systemService = context.getSystemService("window");
                    i.c(systemService, "null cannot be cast to non-null type android.view.WindowManager");
                    Display defaultDisplay = ((WindowManager) systemService).getDefaultDisplay();
                    i.d(defaultDisplay, "wm.defaultDisplay");
                    Point point = new Point();
                    defaultDisplay.getRealSize(point);
                    Rect rect = new Rect(0, 0, point.x, point.y);
                    int i7 = Build.VERSION.SDK_INT;
                    X xB = (i7 >= 30 ? new M() : i7 >= 29 ? new L() : new J()).b();
                    i.d(xB, "Builder().build()");
                    kVar = new k(new f0.b(rect), xB);
                }
            }
            throw new IllegalArgumentException("Context " + context + " is not a UiContext");
        }
        WindowManager windowManager = (WindowManager) context.getSystemService(WindowManager.class);
        X xA = X.a(windowManager.getCurrentWindowMetrics().getWindowInsets(), null);
        Rect bounds = windowManager.getCurrentWindowMetrics().getBounds();
        i.d(bounds, "wm.currentWindowMetrics.bounds");
        kVar = new k(new f0.b(bounds), xA);
        return c(kVar, windowLayoutInfo);
    }

    public static j c(k kVar, WindowLayoutInfo windowLayoutInfo) {
        i0.c cVarA;
        i.e(windowLayoutInfo, "info");
        List<FoldingFeature> displayFeatures = windowLayoutInfo.getDisplayFeatures();
        i.d(displayFeatures, "info.displayFeatures");
        ArrayList arrayList = new ArrayList();
        for (FoldingFeature foldingFeature : displayFeatures) {
            if (foldingFeature instanceof FoldingFeature) {
                i.d(foldingFeature, "feature");
                cVarA = a(kVar, foldingFeature);
            } else {
                cVarA = null;
            }
            if (cVarA != null) {
                arrayList.add(cVarA);
            }
        }
        return new j(arrayList);
    }
}
