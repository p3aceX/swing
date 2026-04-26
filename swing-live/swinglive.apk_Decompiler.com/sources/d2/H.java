package D2;

/* JADX INFO: loaded from: classes.dex */
public final class H {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f163a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object[] f164b;

    public /* synthetic */ H(int i4, Object[] objArr) {
        this.f163a = i4;
        this.f164b = objArr;
    }

    public H(int i4) {
        if (i4 <= 0) {
            throw new IllegalArgumentException("The max pool size must be > 0");
        }
        this.f164b = new Object[i4];
    }
}
