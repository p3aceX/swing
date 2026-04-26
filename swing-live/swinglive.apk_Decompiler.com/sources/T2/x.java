package T2;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class x {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f2005a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public y f2006b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Long f2007c;

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && x.class == obj.getClass()) {
            x xVar = (x) obj;
            if (this.f2005a.equals(xVar.f2005a) && this.f2006b.equals(xVar.f2006b) && this.f2007c.equals(xVar.f2007c)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f2005a, this.f2006b, this.f2007c);
    }
}
