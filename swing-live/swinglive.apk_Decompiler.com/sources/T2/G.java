package T2;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class G {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Double f1898a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Double f1899b;

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && G.class == obj.getClass()) {
            G g4 = (G) obj;
            if (this.f1898a.equals(g4.f1898a) && this.f1899b.equals(g4.f1899b)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f1898a, this.f1899b);
    }
}
