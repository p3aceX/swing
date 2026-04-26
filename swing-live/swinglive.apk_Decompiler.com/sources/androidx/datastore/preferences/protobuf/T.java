package androidx.datastore.preferences.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class T {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0209u f2933a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f2934b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object[] f2935c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f2936d;

    public T(AbstractC0209u abstractC0209u, String str, Object[] objArr) {
        this.f2933a = abstractC0209u;
        this.f2934b = str;
        this.f2935c = objArr;
        char cCharAt = str.charAt(0);
        if (cCharAt < 55296) {
            this.f2936d = cCharAt;
            return;
        }
        int i4 = cCharAt & 8191;
        int i5 = 1;
        int i6 = 13;
        while (true) {
            int i7 = i5 + 1;
            char cCharAt2 = str.charAt(i5);
            if (cCharAt2 < 55296) {
                this.f2936d = i4 | (cCharAt2 << i6);
                return;
            } else {
                i4 |= (cCharAt2 & 8191) << i6;
                i6 += 13;
                i5 = i7;
            }
        }
    }

    public final int a() {
        int i4 = this.f2936d;
        if ((i4 & 1) != 0) {
            return 1;
        }
        return (i4 & 4) == 4 ? 3 : 2;
    }
}
