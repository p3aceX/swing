package A;

import a.AbstractC0184a;
import android.view.View;
import android.view.Window;

/* JADX INFO: loaded from: classes.dex */
public class Y extends AbstractC0184a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Window f34b;

    public Y(Window window) {
        this.f34b = window;
    }

    @Override // a.AbstractC0184a
    public final void W(boolean z4) {
        Window window = this.f34b;
        if (!z4) {
            View decorView = window.getDecorView();
            decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() & (-8193));
        } else {
            window.clearFlags(67108864);
            window.addFlags(Integer.MIN_VALUE);
            View decorView2 = window.getDecorView();
            decorView2.setSystemUiVisibility(decorView2.getSystemUiVisibility() | 8192);
        }
    }
}
