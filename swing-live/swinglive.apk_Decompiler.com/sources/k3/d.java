package K3;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final a f859a;

    static {
        Integer num = E3.a.f380a;
        f859a = (num == null || num.intValue() >= 34) ? new L3.a() : new b();
    }

    public abstract int a(int i4);

    public abstract int b();

    public int c(int i4, int i5) {
        int iB;
        int i6;
        int iA;
        if (i5 <= i4) {
            throw new IllegalArgumentException(("Random range is empty: [" + Integer.valueOf(i4) + ", " + Integer.valueOf(i5) + ").").toString());
        }
        int i7 = i5 - i4;
        if (i7 > 0 || i7 == Integer.MIN_VALUE) {
            if (((-i7) & i7) == i7) {
                iA = a(31 - Integer.numberOfLeadingZeros(i7));
            } else {
                do {
                    iB = b() >>> 1;
                    i6 = iB % i7;
                } while ((i7 - 1) + (iB - i6) < 0);
                iA = i6;
            }
            return i4 + iA;
        }
        while (true) {
            int iB2 = b();
            if (i4 <= iB2 && iB2 < i5) {
                return iB2;
            }
        }
    }
}
