package Q0;

/* JADX INFO: loaded from: classes.dex */
public final class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1534a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final long f1535b;

    public k(int i4, long j4) {
        this.f1534a = i4;
        this.f1535b = j4;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof k)) {
            return false;
        }
        k kVar = (k) obj;
        return this.f1534a == kVar.f1534a && this.f1535b == kVar.f1535b;
    }

    public final int hashCode() {
        int i4 = this.f1534a ^ 1000003;
        long j4 = this.f1535b;
        return (i4 * 1000003) ^ ((int) (j4 ^ (j4 >>> 32)));
    }

    public final String toString() {
        return "EventRecord{eventType=" + this.f1534a + ", eventTimestamp=" + this.f1535b + "}";
    }
}
