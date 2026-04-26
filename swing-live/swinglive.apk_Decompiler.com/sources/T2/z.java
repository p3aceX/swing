package T2;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class z {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public I f2012a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public B f2013b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public D f2014c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Boolean f2015d;
    public Boolean e;

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && z.class == obj.getClass()) {
            z zVar = (z) obj;
            if (this.f2012a.equals(zVar.f2012a) && this.f2013b.equals(zVar.f2013b) && this.f2014c.equals(zVar.f2014c) && this.f2015d.equals(zVar.f2015d) && this.e.equals(zVar.e)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f2012a, this.f2013b, this.f2014c, this.f2015d, this.e);
    }
}
