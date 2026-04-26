package q2;

import n2.EnumC0559b;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final EnumC0559b f6265a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final short f6266b;

    public b(EnumC0559b enumC0559b, short s4) {
        this.f6265a = enumC0559b;
        this.f6266b = s4;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof b)) {
            return false;
        }
        b bVar = (b) obj;
        return this.f6265a == bVar.f6265a && this.f6266b == bVar.f6266b;
    }

    public final int hashCode() {
        return Boolean.hashCode(false) + ((Short.hashCode(this.f6266b) + (this.f6265a.hashCode() * 31)) * 31);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("Track(codec=");
        sb.append(this.f6265a);
        sb.append(", pid=");
        return B1.a.n(sb, this.f6266b, ", discontinuity=false)");
    }
}
