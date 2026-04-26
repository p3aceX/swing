package A;

import a.AbstractC0184a;
import android.view.View;
import android.view.Window;
import android.view.WindowInsetsController;

/* JADX INFO: loaded from: classes.dex */
public final class a0 extends AbstractC0184a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final WindowInsetsController f36b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Window f37c;

    public a0(Window window) {
        this.f36b = window.getInsetsController();
        this.f37c = window;
    }

    @Override // a.AbstractC0184a
    public final void V(boolean z4) {
        Window window = this.f37c;
        if (z4) {
            if (window != null) {
                View decorView = window.getDecorView();
                decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() | 16);
            }
            this.f36b.setSystemBarsAppearance(16, 16);
            return;
        }
        if (window != null) {
            View decorView2 = window.getDecorView();
            decorView2.setSystemUiVisibility(decorView2.getSystemUiVisibility() & (-17));
        }
        this.f36b.setSystemBarsAppearance(0, 16);
    }

    @Override // a.AbstractC0184a
    public final void W(boolean z4) {
        Window window = this.f37c;
        if (z4) {
            if (window != null) {
                View decorView = window.getDecorView();
                decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() | 8192);
            }
            this.f36b.setSystemBarsAppearance(8, 8);
            return;
        }
        if (window != null) {
            View decorView2 = window.getDecorView();
            decorView2.setSystemUiVisibility(decorView2.getSystemUiVisibility() & (-8193));
        }
        this.f36b.setSystemBarsAppearance(0, 8);
    }
}
