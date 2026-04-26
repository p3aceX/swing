package W0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class c extends R0.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f2260b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final b f2261c;

    public c(int i4, b bVar) {
        this.f2260b = i4;
        this.f2261c = bVar;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof c)) {
            return false;
        }
        c cVar = (c) obj;
        return cVar.f2260b == this.f2260b && cVar.f2261c == this.f2261c;
    }

    public final int hashCode() {
        return Objects.hash(c.class, Integer.valueOf(this.f2260b), this.f2261c);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("AesSiv Parameters (variant: ");
        sb.append(this.f2261c);
        sb.append(", ");
        return B1.a.n(sb, this.f2260b, "-byte key)");
    }
}
