package i;

import A.AbstractC0008h;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.os.Build;
import android.util.Log;
import android.view.InflateException;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import j.k;
import java.lang.reflect.Constructor;

/* JADX INFO: renamed from: i.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0418c {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public CharSequence f4423A;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public final /* synthetic */ C0419d f4426D;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Menu f4427a;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public boolean f4433h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f4434i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f4435j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public CharSequence f4436k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public CharSequence f4437l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f4438m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public char f4439n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4440o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public char f4441p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f4442q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f4443r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public boolean f4444s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f4445t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f4446u;
    public int v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public int f4447w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public String f4448x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public String f4449y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public CharSequence f4450z;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public ColorStateList f4424B = null;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public PorterDuff.Mode f4425C = null;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4428b = 0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4429c = 0;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4430d = 0;
    public int e = 0;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f4431f = true;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f4432g = true;

    public C0418c(C0419d c0419d, Menu menu) {
        this.f4426D = c0419d;
        this.f4427a = menu;
    }

    public final Object a(String str, Class[] clsArr, Object[] objArr) {
        try {
            Constructor<?> constructor = Class.forName(str, false, this.f4426D.f4454c.getClassLoader()).getConstructor(clsArr);
            constructor.setAccessible(true);
            return constructor.newInstance(objArr);
        } catch (Exception e) {
            Log.w("SupportMenuInflater", "Cannot instantiate class: " + str, e);
            return null;
        }
    }

    public final void b(MenuItem menuItem) {
        boolean z4 = false;
        menuItem.setChecked(this.f4444s).setVisible(this.f4445t).setEnabled(this.f4446u).setCheckable(this.f4443r >= 1).setTitleCondensed(this.f4437l).setIcon(this.f4438m);
        int i4 = this.v;
        if (i4 >= 0) {
            menuItem.setShowAsAction(i4);
        }
        String str = this.f4449y;
        C0419d c0419d = this.f4426D;
        if (str != null) {
            if (c0419d.f4454c.isRestricted()) {
                throw new IllegalStateException("The android:onClick attribute cannot be used within a restricted context");
            }
            if (c0419d.f4455d == null) {
                c0419d.f4455d = C0419d.a(c0419d.f4454c);
            }
            Object obj = c0419d.f4455d;
            String str2 = this.f4449y;
            MenuItemOnMenuItemClickListenerC0417b menuItemOnMenuItemClickListenerC0417b = new MenuItemOnMenuItemClickListenerC0417b();
            menuItemOnMenuItemClickListenerC0417b.f4421a = obj;
            Class<?> cls = obj.getClass();
            try {
                menuItemOnMenuItemClickListenerC0417b.f4422b = cls.getMethod(str2, MenuItemOnMenuItemClickListenerC0417b.f4420c);
                menuItem.setOnMenuItemClickListener(menuItemOnMenuItemClickListenerC0417b);
            } catch (Exception e) {
                InflateException inflateException = new InflateException("Couldn't resolve menu item onClick handler " + str2 + " in class " + cls.getName());
                inflateException.initCause(e);
                throw inflateException;
            }
        }
        boolean z5 = menuItem instanceof k;
        if (z5) {
        }
        if (this.f4443r >= 2 && z5) {
            k kVar = (k) menuItem;
            kVar.f5123x = (kVar.f5123x & (-5)) | 4;
        }
        String str3 = this.f4448x;
        if (str3 != null) {
            menuItem.setActionView((View) a(str3, C0419d.e, c0419d.f4452a));
            z4 = true;
        }
        int i5 = this.f4447w;
        if (i5 > 0) {
            if (z4) {
                Log.w("SupportMenuInflater", "Ignoring attribute 'itemActionViewLayout'. Action view already specified.");
            } else {
                menuItem.setActionView(i5);
            }
        }
        CharSequence charSequence = this.f4450z;
        boolean z6 = menuItem instanceof k;
        if (z6) {
            ((k) menuItem).c(charSequence);
        } else if (Build.VERSION.SDK_INT >= 26) {
            AbstractC0008h.h(menuItem, charSequence);
        }
        CharSequence charSequence2 = this.f4423A;
        if (z6) {
            ((k) menuItem).e(charSequence2);
        } else if (Build.VERSION.SDK_INT >= 26) {
            AbstractC0008h.m(menuItem, charSequence2);
        }
        char c5 = this.f4439n;
        int i6 = this.f4440o;
        if (z6) {
            ((k) menuItem).setAlphabeticShortcut(c5, i6);
        } else if (Build.VERSION.SDK_INT >= 26) {
            AbstractC0008h.g(menuItem, c5, i6);
        }
        char c6 = this.f4441p;
        int i7 = this.f4442q;
        if (z6) {
            ((k) menuItem).setNumericShortcut(c6, i7);
        } else if (Build.VERSION.SDK_INT >= 26) {
            AbstractC0008h.k(menuItem, c6, i7);
        }
        PorterDuff.Mode mode = this.f4425C;
        if (mode != null) {
            if (z6) {
                ((k) menuItem).setIconTintMode(mode);
            } else if (Build.VERSION.SDK_INT >= 26) {
                AbstractC0008h.j(menuItem, mode);
            }
        }
        ColorStateList colorStateList = this.f4424B;
        if (colorStateList != null) {
            if (z6) {
                ((k) menuItem).setIconTintList(colorStateList);
            } else if (Build.VERSION.SDK_INT >= 26) {
                AbstractC0008h.i(menuItem, colorStateList);
            }
        }
    }
}
