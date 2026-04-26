package w3;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f6721a;

    public static final Throwable a(Object obj) {
        if (obj instanceof d) {
            return ((d) obj).f6720a;
        }
        return null;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof e) {
            return J3.i.a(this.f6721a, ((e) obj).f6721a);
        }
        return false;
    }

    public final int hashCode() {
        Object obj = this.f6721a;
        if (obj == null) {
            return 0;
        }
        return obj.hashCode();
    }

    public final String toString() {
        Object obj = this.f6721a;
        if (obj instanceof d) {
            return ((d) obj).toString();
        }
        return "Success(" + obj + ')';
    }
}
