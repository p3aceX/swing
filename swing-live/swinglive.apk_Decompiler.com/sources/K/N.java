package k;

import android.os.Build;
import android.util.Log;
import android.widget.PopupWindow;
import java.lang.reflect.Method;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class N extends AbstractC0483K implements L {

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public static final Method f5314F;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public C0779j f5315E;

    static {
        try {
            if (Build.VERSION.SDK_INT <= 28) {
                f5314F = PopupWindow.class.getDeclaredMethod("setTouchModal", Boolean.TYPE);
            }
        } catch (NoSuchMethodException unused) {
            Log.i("MenuPopupWindow", "Could not find method setTouchModal() on PopupWindow. Oh well.");
        }
    }

    @Override // k.L
    public final void a(j.j jVar, j.k kVar) {
        C0779j c0779j = this.f5315E;
        if (c0779j != null) {
            c0779j.a(jVar, kVar);
        }
    }

    @Override // k.L
    public final void l(j.j jVar, j.k kVar) {
        C0779j c0779j = this.f5315E;
        if (c0779j != null) {
            c0779j.l(jVar, kVar);
        }
    }
}
