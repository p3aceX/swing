package k;

/* JADX INFO: loaded from: classes.dex */
public final class Q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5323a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5324b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5325c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5326d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f5327f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f5328g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public boolean f5329h;

    public final void a(int i4, int i5) {
        this.f5325c = i4;
        this.f5326d = i5;
        this.f5329h = true;
        if (this.f5328g) {
            if (i5 != Integer.MIN_VALUE) {
                this.f5323a = i5;
            }
            if (i4 != Integer.MIN_VALUE) {
                this.f5324b = i4;
                return;
            }
            return;
        }
        if (i4 != Integer.MIN_VALUE) {
            this.f5323a = i4;
        }
        if (i5 != Integer.MIN_VALUE) {
            this.f5324b = i5;
        }
    }
}
