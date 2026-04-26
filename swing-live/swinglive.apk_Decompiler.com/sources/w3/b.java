package w3;

/* JADX INFO: loaded from: classes.dex */
public final class b implements Comparable {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final b f6716b = new b();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6717a = 131605;

    @Override // java.lang.Comparable
    public final int compareTo(Object obj) {
        b bVar = (b) obj;
        J3.i.e(bVar, "other");
        return this.f6717a - bVar.f6717a;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        b bVar = obj instanceof b ? (b) obj : null;
        return bVar != null && this.f6717a == bVar.f6717a;
    }

    public final int hashCode() {
        return this.f6717a;
    }

    public final String toString() {
        return "2.2.21";
    }
}
