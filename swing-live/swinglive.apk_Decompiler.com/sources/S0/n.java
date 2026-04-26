package S0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class n extends c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1768b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1769c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f1770d;
    public final j e;

    public n(int i4, int i5, int i6, j jVar) {
        this.f1768b = i4;
        this.f1769c = i5;
        this.f1770d = i6;
        this.e = jVar;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof n)) {
            return false;
        }
        n nVar = (n) obj;
        return nVar.f1768b == this.f1768b && nVar.f1769c == this.f1769c && nVar.f1770d == this.f1770d && nVar.e == this.e;
    }

    public final int hashCode() {
        return Objects.hash(n.class, Integer.valueOf(this.f1768b), Integer.valueOf(this.f1769c), Integer.valueOf(this.f1770d), this.e);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("AesEax Parameters (variant: ");
        sb.append(this.e);
        sb.append(", ");
        sb.append(this.f1769c);
        sb.append("-byte IV, ");
        sb.append(this.f1770d);
        sb.append("-byte tag, and ");
        return B1.a.n(sb, this.f1768b, "-byte key)");
    }
}
