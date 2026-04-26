package S0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class k extends c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1760b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1761c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f1762d;
    public final j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final j f1763f;

    public k(int i4, int i5, int i6, j jVar, j jVar2) {
        this.f1760b = i4;
        this.f1761c = i5;
        this.f1762d = i6;
        this.e = jVar;
        this.f1763f = jVar2;
    }

    public final int b() {
        j jVar = j.f1743j;
        int i4 = this.f1762d;
        j jVar2 = this.e;
        if (jVar2 == jVar) {
            return i4 + 16;
        }
        if (jVar2 == j.f1741h || jVar2 == j.f1742i) {
            return i4 + 21;
        }
        throw new IllegalStateException("Unknown variant");
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof k)) {
            return false;
        }
        k kVar = (k) obj;
        return kVar.f1760b == this.f1760b && kVar.f1761c == this.f1761c && kVar.b() == b() && kVar.e == this.e && kVar.f1763f == this.f1763f;
    }

    public final int hashCode() {
        return Objects.hash(k.class, Integer.valueOf(this.f1760b), Integer.valueOf(this.f1761c), Integer.valueOf(this.f1762d), this.e, this.f1763f);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("AesCtrHmacAead Parameters (variant: ");
        sb.append(this.e);
        sb.append(", hashType: ");
        sb.append(this.f1763f);
        sb.append(", ");
        sb.append(this.f1762d);
        sb.append("-byte tags, and ");
        sb.append(this.f1760b);
        sb.append("-byte AES key, and ");
        return B1.a.n(sb, this.f1761c, "-byte HMAC key)");
    }
}
