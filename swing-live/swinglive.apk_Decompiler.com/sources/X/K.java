package X;

/* JADX INFO: loaded from: classes.dex */
public final class K {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2303a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2304b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2305c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2306d;
    public int e;

    public final boolean a() {
        int i4 = this.f2303a;
        int i5 = 2;
        if ((i4 & 7) != 0) {
            int i6 = this.f2306d;
            int i7 = this.f2304b;
            if (((i6 > i7 ? 1 : i6 == i7 ? 2 : 4) & i4) == 0) {
                return false;
            }
        }
        if ((i4 & 112) != 0) {
            int i8 = this.f2306d;
            int i9 = this.f2305c;
            if ((((i8 > i9 ? 1 : i8 == i9 ? 2 : 4) << 4) & i4) == 0) {
                return false;
            }
        }
        if ((i4 & 1792) != 0) {
            int i10 = this.e;
            int i11 = this.f2304b;
            if ((((i10 > i11 ? 1 : i10 == i11 ? 2 : 4) << 8) & i4) == 0) {
                return false;
            }
        }
        if ((i4 & 28672) != 0) {
            int i12 = this.e;
            int i13 = this.f2305c;
            if (i12 > i13) {
                i5 = 1;
            } else if (i12 != i13) {
                i5 = 4;
            }
            if ((i4 & (i5 << 12)) == 0) {
                return false;
            }
        }
        return true;
    }
}
