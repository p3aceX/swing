package R;

import D2.B;
import androidx.lifecycle.n;
import androidx.lifecycle.u;
import androidx.lifecycle.v;
import y0.C0740d;

/* JADX INFO: loaded from: classes.dex */
public final class a extends u {

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final C0740d f1674l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public n f1675m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public B f1676n;

    public a(C0740d c0740d) {
        this.f1674l = c0740d;
        if (c0740d.f6813a != null) {
            throw new IllegalStateException("There is already a listener registered");
        }
        c0740d.f6813a = this;
    }

    @Override // androidx.lifecycle.u
    public final void e() {
        C0740d c0740d = this.f1674l;
        c0740d.f6814b = true;
        c0740d.f6816d = false;
        c0740d.f6815c = false;
        c0740d.f6820i.drainPermits();
        c0740d.c();
    }

    @Override // androidx.lifecycle.u
    public final void f() {
        this.f1674l.f6814b = false;
    }

    @Override // androidx.lifecycle.u
    public final void g(v vVar) {
        super.g(vVar);
        this.f1675m = null;
        this.f1676n = null;
    }

    public final void i() {
        n nVar = this.f1675m;
        B b5 = this.f1676n;
        if (nVar == null || b5 == null) {
            return;
        }
        super.g(b5);
        d(nVar, b5);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder(64);
        sb.append("LoaderInfo{");
        sb.append(Integer.toHexString(System.identityHashCode(this)));
        sb.append(" #0 : ");
        Class<?> cls = this.f1674l.getClass();
        sb.append(cls.getSimpleName());
        sb.append("{");
        sb.append(Integer.toHexString(System.identityHashCode(cls)));
        sb.append("}}");
        return sb.toString();
    }
}
