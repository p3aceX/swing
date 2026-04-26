package Y0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Class f2484a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Class f2485b;

    public l(Class cls, Class cls2) {
        this.f2484a = cls;
        this.f2485b = cls2;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof l)) {
            return false;
        }
        l lVar = (l) obj;
        return lVar.f2484a.equals(this.f2484a) && lVar.f2485b.equals(this.f2485b);
    }

    public final int hashCode() {
        return Objects.hash(this.f2484a, this.f2485b);
    }

    public final String toString() {
        return this.f2484a.getSimpleName() + " with primitive type: " + this.f2485b.getSimpleName();
    }
}
