package i0;

import A.J;
import A.L;
import A.M;
import A.X;
import android.app.Activity;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Point;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.view.Display;
import android.view.DisplayCutout;
import android.view.WindowManager;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import m0.C0545a;
import x3.C0724d;

/* JADX INFO: loaded from: classes.dex */
public final class n implements l {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ int f4486b = 0;

    static {
        new ArrayList(new C0724d(new Integer[]{1, 2, 4, 8, 16, 32, 64, 128}, true));
    }

    public static k a(Activity activity) throws Exception {
        Rect rect;
        X xB;
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 30) {
            rect = ((WindowManager) activity.getSystemService(WindowManager.class)).getCurrentWindowMetrics().getBounds();
            J3.i.d(rect, "wm.currentWindowMetrics.bounds");
        } else {
            if (i4 >= 29) {
                Configuration configuration = activity.getResources().getConfiguration();
                try {
                    Field declaredField = Configuration.class.getDeclaredField("windowConfiguration");
                    declaredField.setAccessible(true);
                    Object obj = declaredField.get(configuration);
                    Object objInvoke = obj.getClass().getDeclaredMethod("getBounds", new Class[0]).invoke(obj, new Object[0]);
                    J3.i.c(objInvoke, "null cannot be cast to non-null type android.graphics.Rect");
                    rect = new Rect((Rect) objInvoke);
                } catch (IllegalAccessException e) {
                    Log.w("n", e);
                    rect = b(activity);
                } catch (NoSuchFieldException e4) {
                    Log.w("n", e4);
                    rect = b(activity);
                } catch (NoSuchMethodException e5) {
                    Log.w("n", e5);
                    rect = b(activity);
                } catch (InvocationTargetException e6) {
                    Log.w("n", e6);
                    rect = b(activity);
                }
            } else if (i4 >= 28) {
                rect = b(activity);
            } else {
                rect = new Rect();
                Display defaultDisplay = activity.getWindowManager().getDefaultDisplay();
                defaultDisplay.getRectSize(rect);
                if (!activity.isInMultiWindowMode()) {
                    Point point = new Point();
                    defaultDisplay.getRealSize(point);
                    Resources resources = activity.getResources();
                    int identifier = resources.getIdentifier("navigation_bar_height", "dimen", "android");
                    int dimensionPixelSize = identifier > 0 ? resources.getDimensionPixelSize(identifier) : 0;
                    int i5 = rect.bottom + dimensionPixelSize;
                    if (i5 == point.y) {
                        rect.bottom = i5;
                    } else {
                        int i6 = rect.right + dimensionPixelSize;
                        if (i6 == point.x) {
                            rect.right = i6;
                        }
                    }
                }
            }
        }
        int i7 = Build.VERSION.SDK_INT;
        if (i7 < 30) {
            xB = (i7 >= 30 ? new M() : i7 >= 29 ? new L() : new J()).b();
            J3.i.d(xB, "{\n            WindowInse…ilder().build()\n        }");
        } else {
            if (i7 < 30) {
                throw new Exception("Incompatible SDK version");
            }
            xB = C0545a.f5762a.a(activity);
        }
        return new k(new f0.b(rect), xB);
    }

    public static Rect b(Activity activity) {
        Object obj;
        Rect rect = new Rect();
        Configuration configuration = activity.getResources().getConfiguration();
        try {
            Field declaredField = Configuration.class.getDeclaredField("windowConfiguration");
            declaredField.setAccessible(true);
            Object obj2 = declaredField.get(configuration);
            if (activity.isInMultiWindowMode()) {
                Object objInvoke = obj2.getClass().getDeclaredMethod("getBounds", new Class[0]).invoke(obj2, new Object[0]);
                J3.i.c(objInvoke, "null cannot be cast to non-null type android.graphics.Rect");
                rect.set((Rect) objInvoke);
            } else {
                Object objInvoke2 = obj2.getClass().getDeclaredMethod("getAppBounds", new Class[0]).invoke(obj2, new Object[0]);
                J3.i.c(objInvoke2, "null cannot be cast to non-null type android.graphics.Rect");
                rect.set((Rect) objInvoke2);
            }
        } catch (IllegalAccessException e) {
            Log.w("n", e);
            activity.getWindowManager().getDefaultDisplay().getRectSize(rect);
        } catch (NoSuchFieldException e4) {
            Log.w("n", e4);
            activity.getWindowManager().getDefaultDisplay().getRectSize(rect);
        } catch (NoSuchMethodException e5) {
            Log.w("n", e5);
            activity.getWindowManager().getDefaultDisplay().getRectSize(rect);
        } catch (InvocationTargetException e6) {
            Log.w("n", e6);
            activity.getWindowManager().getDefaultDisplay().getRectSize(rect);
        }
        Display defaultDisplay = activity.getWindowManager().getDefaultDisplay();
        Point point = new Point();
        J3.i.d(defaultDisplay, "currentDisplay");
        defaultDisplay.getRealSize(point);
        if (!activity.isInMultiWindowMode()) {
            Resources resources = activity.getResources();
            int identifier = resources.getIdentifier("navigation_bar_height", "dimen", "android");
            int dimensionPixelSize = identifier > 0 ? resources.getDimensionPixelSize(identifier) : 0;
            int i4 = rect.bottom + dimensionPixelSize;
            if (i4 == point.y) {
                rect.bottom = i4;
            } else {
                int i5 = rect.right + dimensionPixelSize;
                if (i5 == point.x) {
                    rect.right = i5;
                } else if (rect.left == dimensionPixelSize) {
                    rect.left = 0;
                }
            }
        }
        if ((rect.width() < point.x || rect.height() < point.y) && !activity.isInMultiWindowMode()) {
            try {
                Constructor<?> constructor = Class.forName("android.view.DisplayInfo").getConstructor(new Class[0]);
                constructor.setAccessible(true);
                Object objNewInstance = constructor.newInstance(new Object[0]);
                Method declaredMethod = defaultDisplay.getClass().getDeclaredMethod("getDisplayInfo", objNewInstance.getClass());
                declaredMethod.setAccessible(true);
                declaredMethod.invoke(defaultDisplay, objNewInstance);
                Field declaredField2 = objNewInstance.getClass().getDeclaredField("displayCutout");
                declaredField2.setAccessible(true);
                obj = declaredField2.get(objNewInstance);
            } catch (ClassNotFoundException e7) {
                Log.w("n", e7);
            } catch (IllegalAccessException e8) {
                Log.w("n", e8);
            } catch (InstantiationException e9) {
                Log.w("n", e9);
            } catch (NoSuchFieldException e10) {
                Log.w("n", e10);
            } catch (NoSuchMethodException e11) {
                Log.w("n", e11);
            } catch (InvocationTargetException e12) {
                Log.w("n", e12);
            }
            DisplayCutout displayCutoutJ = m.p(obj) ? m.j(obj) : null;
            if (displayCutoutJ != null) {
                if (rect.left == displayCutoutJ.getSafeInsetLeft()) {
                    rect.left = 0;
                }
                if (point.x - rect.right == displayCutoutJ.getSafeInsetRight()) {
                    rect.right = displayCutoutJ.getSafeInsetRight() + rect.right;
                }
                if (rect.top == displayCutoutJ.getSafeInsetTop()) {
                    rect.top = 0;
                }
                if (point.y - rect.bottom == displayCutoutJ.getSafeInsetBottom()) {
                    rect.bottom = displayCutoutJ.getSafeInsetBottom() + rect.bottom;
                }
            }
        }
        return rect;
    }
}
