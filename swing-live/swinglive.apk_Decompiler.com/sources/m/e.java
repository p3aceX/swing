package M;

/* JADX INFO: loaded from: classes.dex */
public final class e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f902a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final long f903b;

    public e(long j4, long j5) {
        if (j5 == 0) {
            this.f902a = 0L;
            this.f903b = 1L;
        } else {
            this.f902a = j4;
            this.f903b = j5;
        }
    }

    public final String toString() {
        return this.f902a + "/" + this.f903b;
    }
}
