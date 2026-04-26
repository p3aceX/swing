package Y0;

import f1.C0400a;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Class f2494a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0400a f2495b;

    public p(Class cls, C0400a c0400a) {
        this.f2494a = cls;
        this.f2495b = c0400a;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof p)) {
            return false;
        }
        p pVar = (p) obj;
        return pVar.f2494a.equals(this.f2494a) && pVar.f2495b.equals(this.f2495b);
    }

    public final int hashCode() {
        return Objects.hash(this.f2494a, this.f2495b);
    }

    public final String toString() {
        return this.f2494a.getSimpleName() + ", object identifier: " + this.f2495b;
    }
}
