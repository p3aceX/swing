package B1;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f108a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f109b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f110c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f111d;

    public b(int i4, int i5, long j4, boolean z4) {
        this.f108a = i4;
        this.f109b = i5;
        this.f110c = j4;
        this.f111d = z4;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof b)) {
            return false;
        }
        b bVar = (b) obj;
        return this.f108a == bVar.f108a && this.f109b == bVar.f109b && this.f110c == bVar.f110c && this.f111d == bVar.f111d;
    }

    public final int hashCode() {
        return Boolean.hashCode(this.f111d) + ((Long.hashCode(this.f110c) + a.h(this.f109b, Integer.hashCode(this.f108a) * 31, 31)) * 31);
    }

    public final String toString() {
        return "Info(offset=" + this.f108a + ", size=" + this.f109b + ", timestamp=" + this.f110c + ", isKeyFrame=" + this.f111d + ")";
    }
}
