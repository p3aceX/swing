package y2;

/* JADX INFO: loaded from: classes.dex */
public final class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f6921a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6922b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6923c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f6924d;
    public final long e;

    public l(long j4, int i4, int i5, boolean z4, long j5) {
        this.f6921a = j4;
        this.f6922b = i4;
        this.f6923c = i5;
        this.f6924d = z4;
        this.e = j5;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof l)) {
            return false;
        }
        l lVar = (l) obj;
        return this.f6921a == lVar.f6921a && this.f6922b == lVar.f6922b && this.f6923c == lVar.f6923c && this.f6924d == lVar.f6924d && this.e == lVar.e;
    }

    public final int hashCode() {
        return Long.hashCode(this.e) + ((Boolean.hashCode(this.f6924d) + B1.a.h(this.f6923c, B1.a.h(this.f6922b, Long.hashCode(this.f6921a) * 31, 31), 31)) * 31);
    }

    public final String toString() {
        return "StreamStats(bitrate=" + this.f6921a + ", fps=" + this.f6922b + ", droppedFrames=" + this.f6923c + ", isConnected=" + this.f6924d + ", elapsedSeconds=" + this.e + ')';
    }
}
