package A;

import android.view.View;
import android.view.WindowInsets;

/* JADX INFO: loaded from: classes.dex */
public final class U extends S {

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final /* synthetic */ int f30q = 0;

    static {
        X.a(WindowInsets.CONSUMED, null);
    }

    public U(X x4, WindowInsets windowInsets) {
        super(x4, windowInsets);
    }

    @Override // A.O, A.V
    public boolean m(int i4) {
        return this.f22c.isVisible(W.a(i4));
    }

    @Override // A.O, A.V
    public final void d(View view) {
    }
}
