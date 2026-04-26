package Q3;

/* JADX INFO: loaded from: classes.dex */
public final class V extends W {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final F0 f1602c;

    public V(long j4, F0 f02) {
        super(j4);
        this.f1602c = f02;
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.f1602c.run();
    }

    @Override // Q3.W
    public final String toString() {
        return super.toString() + this.f1602c;
    }
}
