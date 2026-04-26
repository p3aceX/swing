package w3;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public final class g implements Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6725a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6726b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6727c;

    public g(String str, String str2, String str3) {
        this.f6725a = str;
        this.f6726b = str2;
        this.f6727c = str3;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof g)) {
            return false;
        }
        g gVar = (g) obj;
        return this.f6725a.equals(gVar.f6725a) && this.f6726b.equals(gVar.f6726b) && this.f6727c.equals(gVar.f6727c);
    }

    public final int hashCode() {
        return this.f6727c.hashCode() + ((this.f6726b.hashCode() + (this.f6725a.hashCode() * 31)) * 31);
    }

    public final String toString() {
        return "(" + ((Object) this.f6725a) + ", " + ((Object) this.f6726b) + ", " + ((Object) this.f6727c) + ')';
    }
}
