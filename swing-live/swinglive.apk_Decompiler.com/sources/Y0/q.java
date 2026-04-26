package Y0;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Class f2496a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Class f2497b;

    public q(Class cls, Class cls2) {
        this.f2496a = cls;
        this.f2497b = cls2;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof q)) {
            return false;
        }
        q qVar = (q) obj;
        return qVar.f2496a.equals(this.f2496a) && qVar.f2497b.equals(this.f2497b);
    }

    public final int hashCode() {
        return Objects.hash(this.f2496a, this.f2497b);
    }

    public final String toString() {
        return this.f2496a.getSimpleName() + " with serialization type: " + this.f2497b.getSimpleName();
    }
}
