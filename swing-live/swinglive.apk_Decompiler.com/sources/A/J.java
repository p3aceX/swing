package A;

import android.graphics.Rect;
import android.util.Log;
import android.view.WindowInsets;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;

/* JADX INFO: loaded from: classes.dex */
public final class J extends N {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static Field f11c = null;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static boolean f12d = false;
    public static Constructor e = null;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static boolean f13f = false;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public WindowInsets f14a = e();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public t.c f15b;

    private static WindowInsets e() {
        if (!f12d) {
            try {
                f11c = WindowInsets.class.getDeclaredField("CONSUMED");
            } catch (ReflectiveOperationException e4) {
                Log.i("WindowInsetsCompat", "Could not retrieve WindowInsets.CONSUMED field", e4);
            }
            f12d = true;
        }
        Field field = f11c;
        if (field != null) {
            try {
                WindowInsets windowInsets = (WindowInsets) field.get(null);
                if (windowInsets != null) {
                    return new WindowInsets(windowInsets);
                }
            } catch (ReflectiveOperationException e5) {
                Log.i("WindowInsetsCompat", "Could not get value from WindowInsets.CONSUMED field", e5);
            }
        }
        if (!f13f) {
            try {
                e = WindowInsets.class.getConstructor(Rect.class);
            } catch (ReflectiveOperationException e6) {
                Log.i("WindowInsetsCompat", "Could not retrieve WindowInsets(Rect) constructor", e6);
            }
            f13f = true;
        }
        Constructor constructor = e;
        if (constructor != null) {
            try {
                return (WindowInsets) constructor.newInstance(new Rect());
            } catch (ReflectiveOperationException e7) {
                Log.i("WindowInsetsCompat", "Could not invoke WindowInsets(Rect) constructor", e7);
            }
        }
        return null;
    }

    @Override // A.N
    public X b() {
        a();
        X xA = X.a(this.f14a, null);
        V v = xA.f33a;
        v.n(null);
        v.p(this.f15b);
        return xA;
    }

    @Override // A.N
    public void c(t.c cVar) {
        this.f15b = cVar;
    }

    @Override // A.N
    public void d(t.c cVar) {
        WindowInsets windowInsets = this.f14a;
        if (windowInsets != null) {
            this.f14a = windowInsets.replaceSystemWindowInsets(cVar.f6510a, cVar.f6511b, cVar.f6512c, cVar.f6513d);
        }
    }
}
