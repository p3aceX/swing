package i0;

import A.X;

/* JADX INFO: loaded from: classes.dex */
public final class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final f0.b f4483a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final X f4484b;

    public k(f0.b bVar, X x4) {
        J3.i.e(x4, "_windowInsetsCompat");
        this.f4483a = bVar;
        this.f4484b = x4;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!k.class.equals(obj != null ? obj.getClass() : null)) {
            return false;
        }
        J3.i.c(obj, "null cannot be cast to non-null type androidx.window.layout.WindowMetrics");
        k kVar = (k) obj;
        return J3.i.a(this.f4483a, kVar.f4483a) && J3.i.a(this.f4484b, kVar.f4484b);
    }

    public final int hashCode() {
        return this.f4484b.hashCode() + (this.f4483a.hashCode() * 31);
    }

    public final String toString() {
        return "WindowMetrics( bounds=" + this.f4483a + ", windowInsetsCompat=" + this.f4484b + ')';
    }
}
