package com.google.crypto.tink.shaded.protobuf;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class f0 {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final f0 f3785f = new f0(0, new int[0], new Object[0], false);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f3786a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int[] f3787b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object[] f3788c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f3789d = -1;
    public boolean e;

    public f0(int i4, int[] iArr, Object[] objArr, boolean z4) {
        this.f3786a = i4;
        this.f3787b = iArr;
        this.f3788c = objArr;
        this.e = z4;
    }

    public static f0 c() {
        return new f0(0, new int[8], new Object[8], true);
    }

    public final void a(int i4) {
        int[] iArr = this.f3787b;
        if (i4 > iArr.length) {
            int i5 = this.f3786a;
            int i6 = (i5 / 2) + i5;
            if (i6 >= i4) {
                i4 = i6;
            }
            if (i4 < 8) {
                i4 = 8;
            }
            this.f3787b = Arrays.copyOf(iArr, i4);
            this.f3788c = Arrays.copyOf(this.f3788c, i4);
        }
    }

    public final int b() {
        int iV0;
        int iX0;
        int iR0;
        int i4 = this.f3789d;
        if (i4 != -1) {
            return i4;
        }
        int i5 = 0;
        for (int i6 = 0; i6 < this.f3786a; i6++) {
            int i7 = this.f3787b[i6];
            int i8 = i7 >>> 3;
            int i9 = i7 & 7;
            if (i9 != 0) {
                if (i9 == 1) {
                    ((Long) this.f3788c[i6]).getClass();
                    iR0 = C0306k.r0(i8);
                } else if (i9 == 2) {
                    iR0 = C0306k.o0(i8, (AbstractC0303h) this.f3788c[i6]);
                } else if (i9 == 3) {
                    iV0 = C0306k.v0(i8) * 2;
                    iX0 = ((f0) this.f3788c[i6]).b();
                } else {
                    if (i9 != 5) {
                        throw new IllegalStateException(B.c());
                    }
                    ((Integer) this.f3788c[i6]).getClass();
                    iR0 = C0306k.q0(i8);
                }
                i5 = iR0 + i5;
            } else {
                long jLongValue = ((Long) this.f3788c[i6]).longValue();
                iV0 = C0306k.v0(i8);
                iX0 = C0306k.x0(jLongValue);
            }
            i5 = iX0 + iV0 + i5;
        }
        this.f3789d = i5;
        return i5;
    }

    public final void d(int i4, Object obj) {
        if (!this.e) {
            throw new UnsupportedOperationException();
        }
        a(this.f3786a + 1);
        int[] iArr = this.f3787b;
        int i5 = this.f3786a;
        iArr[i5] = i4;
        this.f3788c[i5] = obj;
        this.f3786a = i5 + 1;
    }

    public final void e(K k4) throws io.ktor.utils.io.E {
        if (this.f3786a == 0) {
            return;
        }
        k4.getClass();
        for (int i4 = 0; i4 < this.f3786a; i4++) {
            int i5 = this.f3787b[i4];
            Object obj = this.f3788c[i4];
            int i6 = i5 >>> 3;
            int i7 = i5 & 7;
            C0306k c0306k = (C0306k) k4.f3740a;
            if (i7 == 0) {
                c0306k.H0(i6, ((Long) obj).longValue());
            } else if (i7 == 1) {
                c0306k.C0(i6, ((Long) obj).longValue());
            } else if (i7 == 2) {
                k4.a(i6, (AbstractC0303h) obj);
            } else if (i7 == 3) {
                c0306k.F0(i6, 3);
                ((f0) obj).e(k4);
                c0306k.F0(i6, 4);
            } else {
                if (i7 != 5) {
                    throw new RuntimeException(B.c());
                }
                c0306k.A0(i6, ((Integer) obj).intValue());
            }
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || !(obj instanceof f0)) {
            return false;
        }
        f0 f0Var = (f0) obj;
        int i4 = this.f3786a;
        if (i4 == f0Var.f3786a) {
            int[] iArr = this.f3787b;
            int[] iArr2 = f0Var.f3787b;
            int i5 = 0;
            while (true) {
                if (i5 >= i4) {
                    Object[] objArr = this.f3788c;
                    Object[] objArr2 = f0Var.f3788c;
                    int i6 = this.f3786a;
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
        int i4 = this.f3786a;
        int i5 = (527 + i4) * 31;
        int[] iArr = this.f3787b;
        int iHashCode = 17;
        int i6 = 17;
        for (int i7 = 0; i7 < i4; i7++) {
            i6 = (i6 * 31) + iArr[i7];
        }
        int i8 = (i5 + i6) * 31;
        Object[] objArr = this.f3788c;
        int i9 = this.f3786a;
        for (int i10 = 0; i10 < i9; i10++) {
            iHashCode = (iHashCode * 31) + objArr[i10].hashCode();
        }
        return i8 + iHashCode;
    }
}
