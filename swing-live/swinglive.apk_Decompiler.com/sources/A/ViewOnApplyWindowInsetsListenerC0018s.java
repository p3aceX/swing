package A;

import android.os.Build;
import android.view.View;
import android.view.WindowInsets;

/* JADX INFO: renamed from: A.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ViewOnApplyWindowInsetsListenerC0018s implements View.OnApplyWindowInsetsListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public X f65a = null;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ View f66b;

    public ViewOnApplyWindowInsetsListenerC0018s(View view, InterfaceC0013m interfaceC0013m) {
        this.f66b = view;
    }

    @Override // android.view.View.OnApplyWindowInsetsListener
    public WindowInsets onApplyWindowInsets(View view, WindowInsets windowInsets) {
        X xA = X.a(windowInsets, view);
        if (Build.VERSION.SDK_INT < 30) {
            AbstractC0019t.a(windowInsets, this.f66b);
            if (xA.equals(this.f65a)) {
                throw null;
            }
        }
        this.f65a = xA;
        throw null;
    }
}
