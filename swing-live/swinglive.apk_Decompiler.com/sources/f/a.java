package F;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f381a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f382b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public float f383c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public float f384d;
    public long e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public long f385f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public long f386g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public float f387h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f388i;

    public final float a(long j4) {
        if (j4 < this.e) {
            return 0.0f;
        }
        long j5 = this.f386g;
        if (j5 < 0 || j4 < j5) {
            return g.b((j4 - r0) / this.f381a, 0.0f, 1.0f) * 0.5f;
        }
        float f4 = this.f387h;
        return (g.b((j4 - j5) / this.f388i, 0.0f, 1.0f) * f4) + (1.0f - f4);
    }
}
