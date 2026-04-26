package w3;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public final class d implements Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Throwable f6720a;

    public d(Throwable th) {
        J3.i.e(th, "exception");
        this.f6720a = th;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof d) {
            return J3.i.a(this.f6720a, ((d) obj).f6720a);
        }
        return false;
    }

    public final int hashCode() {
        return this.f6720a.hashCode();
    }

    public final String toString() {
        return "Failure(" + this.f6720a + ')';
    }
}
