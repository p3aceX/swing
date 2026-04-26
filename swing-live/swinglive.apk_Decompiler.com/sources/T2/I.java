package T2;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class I {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Double f1902a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Double f1903b;

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && I.class == obj.getClass()) {
            I i4 = (I) obj;
            if (this.f1902a.equals(i4.f1902a) && this.f1903b.equals(i4.f1903b)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f1902a, this.f1903b);
    }
}
