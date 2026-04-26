package l3;

import x3.AbstractC0729i;

/* JADX INFO: loaded from: classes.dex */
public final class O {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5670a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final M f5671b;

    public O(String str, M m4) {
        this.f5670a = str;
        this.f5671b = m4;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof O)) {
            return false;
        }
        if (this == obj) {
            return true;
        }
        O o4 = (O) obj;
        return e1.k.n(AbstractC0729i.T(this.f5670a, this.f5671b), AbstractC0729i.T(o4.f5670a, o4.f5671b));
    }

    public final int hashCode() {
        return AbstractC0729i.T(this.f5670a, this.f5671b).hashCode();
    }

    public final String toString() {
        return "StringListResult(jsonEncodedValue=" + this.f5670a + ", type=" + this.f5671b + ")";
    }
}
