package Z0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class e extends S0.c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f2570b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f2571c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final d f2572d;

    public e(int i4, int i5, d dVar) {
        this.f2570b = i4;
        this.f2571c = i5;
        this.f2572d = dVar;
    }

    public final int b() {
        d dVar = d.f2558f;
        int i4 = this.f2571c;
        d dVar2 = this.f2572d;
        if (dVar2 == dVar) {
            return i4;
        }
        if (dVar2 == d.f2556c) {
            return i4 + 5;
        }
        if (dVar2 == d.f2557d) {
            return i4 + 5;
        }
        if (dVar2 == d.e) {
            return i4 + 5;
        }
        throw new IllegalStateException("Unknown variant");
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof e)) {
            return false;
        }
        e eVar = (e) obj;
        return eVar.f2570b == this.f2570b && eVar.b() == b() && eVar.f2572d == this.f2572d;
    }

    public final int hashCode() {
        return Objects.hash(e.class, Integer.valueOf(this.f2570b), Integer.valueOf(this.f2571c), this.f2572d);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("AES-CMAC Parameters (variant: ");
        sb.append(this.f2572d);
        sb.append(", ");
        sb.append(this.f2571c);
        sb.append("-byte tags, and ");
        return B1.a.n(sb, this.f2570b, "-byte key)");
    }
}
