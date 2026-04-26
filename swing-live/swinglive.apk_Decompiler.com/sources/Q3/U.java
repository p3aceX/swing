package Q3;

/* JADX INFO: loaded from: classes.dex */
public final class U extends W {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0141m f1600c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Y f1601d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public U(Y y4, long j4, C0141m c0141m) {
        super(j4);
        this.f1601d = y4;
        this.f1600c = c0141m;
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.f1600c.B(this.f1601d);
    }

    @Override // Q3.W
    public final String toString() {
        return super.toString() + this.f1600c;
    }
}
