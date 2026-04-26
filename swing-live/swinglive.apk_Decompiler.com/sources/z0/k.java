package Z0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class k extends S0.c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f2580b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f2581c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final d f2582d;
    public final d e;

    public k(int i4, int i5, d dVar, d dVar2) {
        this.f2580b = i4;
        this.f2581c = i5;
        this.f2582d = dVar;
        this.e = dVar2;
    }

    public final int b() {
        d dVar = d.f2567o;
        int i4 = this.f2581c;
        d dVar2 = this.f2582d;
        if (dVar2 == dVar) {
            return i4;
        }
        if (dVar2 == d.f2564l) {
            return i4 + 5;
        }
        if (dVar2 == d.f2565m) {
            return i4 + 5;
        }
        if (dVar2 == d.f2566n) {
            return i4 + 5;
        }
        throw new IllegalStateException("Unknown variant");
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof k)) {
            return false;
        }
        k kVar = (k) obj;
        return kVar.f2580b == this.f2580b && kVar.b() == b() && kVar.f2582d == this.f2582d && kVar.e == this.e;
    }

    public final int hashCode() {
        return Objects.hash(k.class, Integer.valueOf(this.f2580b), Integer.valueOf(this.f2581c), this.f2582d, this.e);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("HMAC Parameters (variant: ");
        sb.append(this.f2582d);
        sb.append(", hashType: ");
        sb.append(this.e);
        sb.append(", ");
        sb.append(this.f2581c);
        sb.append("-byte tags, and ");
        return B1.a.n(sb, this.f2580b, "-byte key)");
    }
}
