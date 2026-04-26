package t;

import android.graphics.Insets;

/* JADX INFO: loaded from: classes.dex */
public final class c {
    public static final c e = new c(0, 0, 0, 0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6510a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6511b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6512c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f6513d;

    public c(int i4, int i5, int i6, int i7) {
        this.f6510a = i4;
        this.f6511b = i5;
        this.f6512c = i6;
        this.f6513d = i7;
    }

    public static c a(int i4, int i5, int i6, int i7) {
        return (i4 == 0 && i5 == 0 && i6 == 0 && i7 == 0) ? e : new c(i4, i5, i6, i7);
    }

    public static c b(Insets insets) {
        return a(insets.left, insets.top, insets.right, insets.bottom);
    }

    public final Insets c() {
        return AbstractC0670b.a(this.f6510a, this.f6511b, this.f6512c, this.f6513d);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || c.class != obj.getClass()) {
            return false;
        }
        c cVar = (c) obj;
        return this.f6513d == cVar.f6513d && this.f6510a == cVar.f6510a && this.f6512c == cVar.f6512c && this.f6511b == cVar.f6511b;
    }

    public final int hashCode() {
        return (((((this.f6510a * 31) + this.f6511b) * 31) + this.f6512c) * 31) + this.f6513d;
    }

    public final String toString() {
        return "Insets{left=" + this.f6510a + ", top=" + this.f6511b + ", right=" + this.f6512c + ", bottom=" + this.f6513d + '}';
    }
}
