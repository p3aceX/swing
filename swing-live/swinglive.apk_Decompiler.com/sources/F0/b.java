package f0;

import J3.i;
import android.graphics.Rect;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f4265a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f4266b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f4267c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f4268d;

    public b(Rect rect) {
        int i4 = rect.left;
        int i5 = rect.top;
        int i6 = rect.right;
        int i7 = rect.bottom;
        this.f4265a = i4;
        this.f4266b = i5;
        this.f4267c = i6;
        this.f4268d = i7;
        if (i4 > i6) {
            throw new IllegalArgumentException(B1.a.k("Left must be less than or equal to right, left: ", i4, i6, ", right: ").toString());
        }
        if (i5 > i7) {
            throw new IllegalArgumentException(B1.a.k("top must be less than or equal to bottom, top: ", i5, i7, ", bottom: ").toString());
        }
    }

    public final Rect a() {
        return new Rect(this.f4265a, this.f4266b, this.f4267c, this.f4268d);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!b.class.equals(obj != null ? obj.getClass() : null)) {
            return false;
        }
        i.c(obj, "null cannot be cast to non-null type androidx.window.core.Bounds");
        b bVar = (b) obj;
        return this.f4265a == bVar.f4265a && this.f4266b == bVar.f4266b && this.f4267c == bVar.f4267c && this.f4268d == bVar.f4268d;
    }

    public final int hashCode() {
        return (((((this.f4265a * 31) + this.f4266b) * 31) + this.f4267c) * 31) + this.f4268d;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(b.class.getSimpleName());
        sb.append(" { [");
        sb.append(this.f4265a);
        sb.append(',');
        sb.append(this.f4266b);
        sb.append(',');
        sb.append(this.f4267c);
        sb.append(',');
        return B1.a.n(sb, this.f4268d, "] }");
    }
}
