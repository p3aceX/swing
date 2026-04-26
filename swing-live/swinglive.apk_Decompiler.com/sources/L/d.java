package L;

import J3.i;

/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f866a;

    public d(String str) {
        i.e(str, "name");
        this.f866a = str;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof d)) {
            return false;
        }
        return i.a(this.f866a, ((d) obj).f866a);
    }

    public final int hashCode() {
        return this.f866a.hashCode();
    }

    public final String toString() {
        return this.f866a;
    }
}
