package S0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class t extends c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1782b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final j f1783c;

    public t(int i4, j jVar) {
        this.f1782b = i4;
        this.f1783c = jVar;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof t)) {
            return false;
        }
        t tVar = (t) obj;
        return tVar.f1782b == this.f1782b && tVar.f1783c == this.f1783c;
    }

    public final int hashCode() {
        return Objects.hash(t.class, Integer.valueOf(this.f1782b), this.f1783c);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("AesGcmSiv Parameters (variant: ");
        sb.append(this.f1783c);
        sb.append(", ");
        return B1.a.n(sb, this.f1782b, "-byte key)");
    }
}
