package S0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class q extends c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1775b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1776c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f1777d;
    public final j e;

    public q(int i4, int i5, int i6, j jVar) {
        this.f1775b = i4;
        this.f1776c = i5;
        this.f1777d = i6;
        this.e = jVar;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof q)) {
            return false;
        }
        q qVar = (q) obj;
        return qVar.f1775b == this.f1775b && qVar.f1776c == this.f1776c && qVar.f1777d == this.f1777d && qVar.e == this.e;
    }

    public final int hashCode() {
        return Objects.hash(q.class, Integer.valueOf(this.f1775b), Integer.valueOf(this.f1776c), Integer.valueOf(this.f1777d), this.e);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("AesGcm Parameters (variant: ");
        sb.append(this.e);
        sb.append(", ");
        sb.append(this.f1776c);
        sb.append("-byte IV, ");
        sb.append(this.f1777d);
        sb.append("-byte tag, and ");
        return B1.a.n(sb, this.f1775b, "-byte key)");
    }
}
