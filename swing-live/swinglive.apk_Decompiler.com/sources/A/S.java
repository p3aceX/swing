package A;

import android.view.WindowInsets;

/* JADX INFO: loaded from: classes.dex */
public class S extends Q {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public t.c f27n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public t.c f28o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public t.c f29p;

    public S(X x4, WindowInsets windowInsets) {
        super(x4, windowInsets);
        this.f27n = null;
        this.f28o = null;
        this.f29p = null;
    }

    @Override // A.V
    public t.c f() {
        if (this.f28o == null) {
            this.f28o = t.c.b(this.f22c.getMandatorySystemGestureInsets());
        }
        return this.f28o;
    }

    @Override // A.V
    public t.c h() {
        if (this.f27n == null) {
            this.f27n = t.c.b(this.f22c.getSystemGestureInsets());
        }
        return this.f27n;
    }

    @Override // A.V
    public t.c j() {
        if (this.f29p == null) {
            this.f29p = t.c.b(this.f22c.getTappableElementInsets());
        }
        return this.f29p;
    }

    @Override // A.P, A.V
    public void p(t.c cVar) {
    }
}
