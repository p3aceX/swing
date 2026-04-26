package A;

import android.view.WindowInsets;

/* JADX INFO: loaded from: classes.dex */
public class L extends N {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final WindowInsets.Builder f16a = K.i();

    @Override // A.N
    public X b() {
        a();
        X xA = X.a(this.f16a.build(), null);
        xA.f33a.n(null);
        return xA;
    }

    @Override // A.N
    public void c(t.c cVar) {
        this.f16a.setStableInsets(cVar.c());
    }

    @Override // A.N
    public void d(t.c cVar) {
        this.f16a.setSystemWindowInsets(cVar.c());
    }
}
