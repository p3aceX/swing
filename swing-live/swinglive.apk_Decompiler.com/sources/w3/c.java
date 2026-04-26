package w3;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public final class c implements Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f6718a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f6719b;

    public c(Object obj, Object obj2) {
        this.f6718a = obj;
        this.f6719b = obj2;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof c)) {
            return false;
        }
        c cVar = (c) obj;
        return J3.i.a(this.f6718a, cVar.f6718a) && J3.i.a(this.f6719b, cVar.f6719b);
    }

    public final int hashCode() {
        Object obj = this.f6718a;
        int iHashCode = (obj == null ? 0 : obj.hashCode()) * 31;
        Object obj2 = this.f6719b;
        return iHashCode + (obj2 != null ? obj2.hashCode() : 0);
    }

    public final String toString() {
        return "(" + this.f6718a + ", " + this.f6719b + ')';
    }
}
