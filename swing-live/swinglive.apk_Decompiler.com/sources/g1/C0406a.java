package g1;

/* JADX INFO: renamed from: g1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0406a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f4298a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final long f4299b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f4300c;

    public C0406a(long j4, long j5, long j6) {
        this.f4298a = j4;
        this.f4299b = j5;
        this.f4300c = j6;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj instanceof C0406a) {
            C0406a c0406a = (C0406a) obj;
            if (this.f4298a == c0406a.f4298a && this.f4299b == c0406a.f4299b && this.f4300c == c0406a.f4300c) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        long j4 = this.f4298a;
        long j5 = this.f4299b;
        int i4 = (((((int) (j4 ^ (j4 >>> 32))) ^ 1000003) * 1000003) ^ ((int) (j5 ^ (j5 >>> 32)))) * 1000003;
        long j6 = this.f4300c;
        return i4 ^ ((int) ((j6 >>> 32) ^ j6));
    }

    public final String toString() {
        return "StartupTime{epochMillis=" + this.f4298a + ", elapsedRealtime=" + this.f4299b + ", uptimeMillis=" + this.f4300c + "}";
    }
}
