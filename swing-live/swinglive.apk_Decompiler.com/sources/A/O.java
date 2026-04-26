package A;

import android.annotation.SuppressLint;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.view.WindowInsets;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public abstract class O extends V {

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public static boolean f17h = false;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public static Method f18i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public static Class f19j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public static Field f20k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public static Field f21l;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final WindowInsets f22c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public t.c[] f23d;
    public t.c e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public X f24f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public t.c f25g;

    public O(X x4, WindowInsets windowInsets) {
        super(x4);
        this.e = null;
        this.f22c = windowInsets;
    }

    private t.c r() {
        X x4 = this.f24f;
        return x4 != null ? x4.f33a.g() : t.c.e;
    }

    private t.c s(View view) {
        if (Build.VERSION.SDK_INT >= 30) {
            throw new UnsupportedOperationException("getVisibleInsets() should not be called on API >= 30. Use WindowInsets.isVisible() instead.");
        }
        if (!f17h) {
            u();
        }
        Method method = f18i;
        if (method != null && f19j != null && f20k != null) {
            try {
                Object objInvoke = method.invoke(view, new Object[0]);
                if (objInvoke == null) {
                    Log.w("WindowInsetsCompat", "Failed to get visible insets. getViewRootImpl() returned null from the provided view. This means that the view is either not attached or the method has been overridden", new NullPointerException());
                    return null;
                }
                Rect rect = (Rect) f20k.get(f21l.get(objInvoke));
                if (rect != null) {
                    return t.c.a(rect.left, rect.top, rect.right, rect.bottom);
                }
            } catch (ReflectiveOperationException e) {
                Log.e("WindowInsetsCompat", "Failed to get visible insets. (Reflection error). " + e.getMessage(), e);
            }
        }
        return null;
    }

    @SuppressLint({"PrivateApi"})
    private static void u() {
        try {
            f18i = View.class.getDeclaredMethod("getViewRootImpl", new Class[0]);
            Class<?> cls = Class.forName("android.view.View$AttachInfo");
            f19j = cls;
            f20k = cls.getDeclaredField("mVisibleInsets");
            f21l = Class.forName("android.view.ViewRootImpl").getDeclaredField("mAttachInfo");
            f20k.setAccessible(true);
            f21l.setAccessible(true);
        } catch (ReflectiveOperationException e) {
            Log.e("WindowInsetsCompat", "Failed to get visible insets. (Reflection error). " + e.getMessage(), e);
        }
        f17h = true;
    }

    @Override // A.V
    public void d(View view) {
        t.c cVarS = s(view);
        if (cVarS == null) {
            cVarS = t.c.e;
        }
        v(cVarS);
    }

    @Override // A.V
    public boolean equals(Object obj) {
        if (super.equals(obj)) {
            return Objects.equals(this.f25g, ((O) obj).f25g);
        }
        return false;
    }

    @Override // A.V
    public final t.c i() {
        if (this.e == null) {
            WindowInsets windowInsets = this.f22c;
            this.e = t.c.a(windowInsets.getSystemWindowInsetLeft(), windowInsets.getSystemWindowInsetTop(), windowInsets.getSystemWindowInsetRight(), windowInsets.getSystemWindowInsetBottom());
        }
        return this.e;
    }

    @Override // A.V
    public boolean l() {
        return this.f22c.isRound();
    }

    @Override // A.V
    @SuppressLint({"WrongConstant"})
    public boolean m(int i4) {
        for (int i5 = 1; i5 <= 256; i5 <<= 1) {
            if ((i4 & i5) != 0 && !t(i5)) {
                return false;
            }
        }
        return true;
    }

    @Override // A.V
    public void n(t.c[] cVarArr) {
        this.f23d = cVarArr;
    }

    @Override // A.V
    public void o(X x4) {
        this.f24f = x4;
    }

    public t.c q(int i4, boolean z4) {
        t.c cVarG;
        int i5;
        if (i4 == 1) {
            return z4 ? t.c.a(0, Math.max(r().f6511b, i().f6511b), 0, 0) : t.c.a(0, i().f6511b, 0, 0);
        }
        if (i4 == 2) {
            if (z4) {
                t.c cVarR = r();
                t.c cVarG2 = g();
                return t.c.a(Math.max(cVarR.f6510a, cVarG2.f6510a), 0, Math.max(cVarR.f6512c, cVarG2.f6512c), Math.max(cVarR.f6513d, cVarG2.f6513d));
            }
            t.c cVarI = i();
            X x4 = this.f24f;
            cVarG = x4 != null ? x4.f33a.g() : null;
            int iMin = cVarI.f6513d;
            if (cVarG != null) {
                iMin = Math.min(iMin, cVarG.f6513d);
            }
            return t.c.a(cVarI.f6510a, 0, cVarI.f6512c, iMin);
        }
        t.c cVar = t.c.e;
        if (i4 == 8) {
            t.c[] cVarArr = this.f23d;
            cVarG = cVarArr != null ? cVarArr[3] : null;
            if (cVarG != null) {
                return cVarG;
            }
            t.c cVarI2 = i();
            t.c cVarR2 = r();
            int i6 = cVarI2.f6513d;
            if (i6 > cVarR2.f6513d) {
                return t.c.a(0, 0, 0, i6);
            }
            t.c cVar2 = this.f25g;
            if (cVar2 != null && !cVar2.equals(cVar) && (i5 = this.f25g.f6513d) > cVarR2.f6513d) {
                return t.c.a(0, 0, 0, i5);
            }
        } else {
            if (i4 == 16) {
                return h();
            }
            if (i4 == 32) {
                return f();
            }
            if (i4 == 64) {
                return j();
            }
            if (i4 == 128) {
                X x5 = this.f24f;
                C0007g c0007gE = x5 != null ? x5.f33a.e() : e();
                if (c0007gE != null) {
                    int i7 = Build.VERSION.SDK_INT;
                    return t.c.a(i7 >= 28 ? AbstractC0006f.d(c0007gE.f49a) : 0, i7 >= 28 ? AbstractC0006f.f(c0007gE.f49a) : 0, i7 >= 28 ? AbstractC0006f.e(c0007gE.f49a) : 0, i7 >= 28 ? AbstractC0006f.c(c0007gE.f49a) : 0);
                }
            }
        }
        return cVar;
    }

    public boolean t(int i4) {
        if (i4 != 1 && i4 != 2) {
            if (i4 == 4) {
                return false;
            }
            if (i4 != 8 && i4 != 128) {
                return true;
            }
        }
        return !q(i4, false).equals(t.c.e);
    }

    public void v(t.c cVar) {
        this.f25g = cVar;
    }
}
