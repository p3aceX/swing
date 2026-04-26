package K;

/* JADX INFO: loaded from: classes.dex */
public abstract /* synthetic */ class j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ int[] f843a = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32};

    public static /* synthetic */ boolean a(int i4, int i5) {
        if (i4 != 0) {
            return i4 == i5;
        }
        throw null;
    }

    public static /* synthetic */ int b(int i4) {
        if (i4 != 0) {
            return i4 - 1;
        }
        throw null;
    }

    public static /* synthetic */ int[] c(int i4) {
        int[] iArr = new int[i4];
        System.arraycopy(f843a, 0, iArr, 0, i4);
        return iArr;
    }
}
