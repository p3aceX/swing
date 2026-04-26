package androidx.datastore.preferences.protobuf;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class b0 {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final b0 f2954f = new b0(0, new int[0], new Object[0], false);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2955a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int[] f2956b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object[] f2957c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2958d = -1;
    public boolean e;

    public b0(int i4, int[] iArr, Object[] objArr, boolean z4) {
        this.f2955a = i4;
        this.f2956b = iArr;
        this.f2957c = objArr;
        this.e = z4;
    }

    public final void a(int i4) {
        int[] iArr = this.f2956b;
        if (i4 > iArr.length) {
            int i5 = this.f2955a;
            int i6 = (i5 / 2) + i5;
            if (i6 >= i4) {
                i4 = i6;
            }
            if (i4 < 8) {
                i4 = 8;
            }
            this.f2956b = Arrays.copyOf(iArr, i4);
            this.f2957c = Arrays.copyOf(this.f2957c, i4);
        }
    }

    public final int b() {
        int iV0;
        int iX0;
        int iV02;
        int i4 = this.f2958d;
        if (i4 != -1) {
            return i4;
        }
        int i5 = 0;
        for (int i6 = 0; i6 < this.f2955a; i6++) {
            int i7 = this.f2956b[i6];
            int i8 = i7 >>> 3;
            int i9 = i7 & 7;
            if (i9 != 0) {
                if (i9 == 1) {
                    ((Long) this.f2957c[i6]).getClass();
                    iV02 = C0200k.v0(i8) + 8;
                } else if (i9 == 2) {
                    iV02 = C0200k.t0(i8, (C0196g) this.f2957c[i6]);
                } else if (i9 == 3) {
                    iV0 = C0200k.v0(i8) * 2;
                    iX0 = ((b0) this.f2957c[i6]).b();
                } else {
                    if (i9 != 5) {
                        throw new IllegalStateException(C0213y.b());
                    }
                    ((Integer) this.f2957c[i6]).getClass();
                    iV02 = C0200k.v0(i8) + 4;
                }
                i5 = iV02 + i5;
            } else {
                long jLongValue = ((Long) this.f2957c[i6]).longValue();
                iV0 = C0200k.v0(i8);
                iX0 = C0200k.x0(jLongValue);
            }
            i5 = iX0 + iV0 + i5;
        }
        this.f2958d = i5;
        return i5;
    }

    public final void c(int i4, Object obj) {
        if (!this.e) {
            throw new UnsupportedOperationException();
        }
        a(this.f2955a + 1);
        int[] iArr = this.f2956b;
        int i5 = this.f2955a;
        iArr[i5] = i4;
        this.f2957c[i5] = obj;
        this.f2955a = i5 + 1;
    }

    public final void d(D d5) {
        if (this.f2955a == 0) {
            return;
        }
        d5.getClass();
        for (int i4 = 0; i4 < this.f2955a; i4++) {
            int i5 = this.f2956b[i4];
            Object obj = this.f2957c[i4];
            int i6 = i5 >>> 3;
            int i7 = i5 & 7;
            C0200k c0200k = (C0200k) d5.f2898a;
            if (i7 == 0) {
                c0200k.R0(i6, ((Long) obj).longValue());
            } else if (i7 == 1) {
                c0200k.H0(i6, ((Long) obj).longValue());
            } else if (i7 == 2) {
                c0200k.D0(i6, (C0196g) obj);
            } else if (i7 == 3) {
                c0200k.O0(i6, 3);
                ((b0) obj).d(d5);
                c0200k.O0(i6, 4);
            } else {
                if (i7 != 5) {
                    throw new RuntimeException(C0213y.b());
                }
                c0200k.F0(i6, ((Integer) obj).intValue());
            }
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || !(obj instanceof b0)) {
            return false;
        }
        b0 b0Var = (b0) obj;
        int i4 = this.f2955a;
        if (i4 == b0Var.f2955a) {
            int[] iArr = this.f2956b;
            int[] iArr2 = b0Var.f2956b;
            int i5 = 0;
            while (true) {
                if (i5 >= i4) {
                    Object[] objArr = this.f2957c;
                    Object[] objArr2 = b0Var.f2957c;
                    int i6 = this.f2955a;
                    for (int i7 = 0; i7 < i6; i7++) {
                        if (objArr[i7].equals(objArr2[i7])) {
                        }
                    }
                    return true;
                }
                if (iArr[i5] != iArr2[i5]) {
                    break;
                }
                i5++;
            }
        }
        return false;
    }

    public final int hashCode() {
        int i4 = this.f2955a;
        int i5 = (527 + i4) * 31;
        int[] iArr = this.f2956b;
        int iHashCode = 17;
        int i6 = 17;
        for (int i7 = 0; i7 < i4; i7++) {
            i6 = (i6 * 31) + iArr[i7];
        }
        int i8 = (i5 + i6) * 31;
        Object[] objArr = this.f2957c;
        int i9 = this.f2955a;
        for (int i10 = 0; i10 < i9; i10++) {
            iHashCode = (iHashCode * 31) + objArr[i10].hashCode();
        }
        return i8 + iHashCode;
    }
}
