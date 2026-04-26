package A;

import android.view.View;
import android.view.Window;

/* JADX INFO: loaded from: classes.dex */
public final class Z extends Y {
    @Override // a.AbstractC0184a
    public final void V(boolean z4) {
        Window window = this.f34b;
        if (!z4) {
            View decorView = window.getDecorView();
            decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() & (-17));
        } else {
            window.clearFlags(134217728);
            window.addFlags(Integer.MIN_VALUE);
            View decorView2 = window.getDecorView();
            decorView2.setSystemUiVisibility(decorView2.getSystemUiVisibility() | 16);
        }
    }
}
