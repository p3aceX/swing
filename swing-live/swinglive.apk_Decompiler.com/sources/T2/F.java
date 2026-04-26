package T2;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class F {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public H f1894a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Long f1895b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Long f1896c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Long f1897d;
    public Boolean e;

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && F.class == obj.getClass()) {
            F f4 = (F) obj;
            if (this.f1894a.equals(f4.f1894a) && Objects.equals(this.f1895b, f4.f1895b) && Objects.equals(this.f1896c, f4.f1896c) && Objects.equals(this.f1897d, f4.f1897d) && this.e.equals(f4.e)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f1894a, this.f1895b, this.f1896c, this.f1897d, this.e);
    }
}
