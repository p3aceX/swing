package A;

import android.view.WindowInsets;

/* JADX INFO: loaded from: classes.dex */
public class P extends O {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public t.c f26m;

    public P(X x4, WindowInsets windowInsets) {
        super(x4, windowInsets);
        this.f26m = null;
    }

    @Override // A.V
    public X b() {
        return X.a(this.f22c.consumeStableInsets(), null);
    }

    @Override // A.V
    public X c() {
        return X.a(this.f22c.consumeSystemWindowInsets(), null);
    }

    @Override // A.V
    public final t.c g() {
        if (this.f26m == null) {
            WindowInsets windowInsets = this.f22c;
            this.f26m = t.c.a(windowInsets.getStableInsetLeft(), windowInsets.getStableInsetTop(), windowInsets.getStableInsetRight(), windowInsets.getStableInsetBottom());
        }
        return this.f26m;
    }

    @Override // A.V
    public boolean k() {
        return this.f22c.isConsumed();
    }

    @Override // A.V
    public void p(t.c cVar) {
        this.f26m = cVar;
    }
}
