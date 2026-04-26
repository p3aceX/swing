package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0304i extends T0.d {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f3795c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f3796d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f3797f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f3798g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f3799h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f3800i = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;

    public C0304i(byte[] bArr, int i4, int i5, boolean z4) {
        this.f3795c = bArr;
        this.f3796d = i5 + i4;
        this.f3797f = i4;
        this.f3798g = i4;
    }

    @Override // T0.d
    public final String A() throws B {
        int iJ = J();
        if (iJ > 0) {
            int i4 = this.f3796d;
            int i5 = this.f3797f;
            if (iJ <= i4 - i5) {
                String str = new String(this.f3795c, i5, iJ, AbstractC0320z.f3839a);
                this.f3797f += iJ;
                return str;
            }
        }
        if (iJ == 0) {
            return "";
        }
        if (iJ < 0) {
            throw B.e();
        }
        throw B.g();
    }

    @Override // T0.d
    public final String B() throws B {
        int iJ = J();
        if (iJ > 0) {
            int i4 = this.f3796d;
            int i5 = this.f3797f;
            if (iJ <= i4 - i5) {
                String strV = r0.f3834a.v(this.f3795c, i5, iJ);
                this.f3797f += iJ;
                return strV;
            }
        }
        if (iJ == 0) {
            return "";
        }
        if (iJ <= 0) {
            throw B.e();
        }
        throw B.g();
    }

    @Override // T0.d
    public final int C() throws B {
        if (g()) {
            this.f3799h = 0;
            return 0;
        }
        int iJ = J();
        this.f3799h = iJ;
        if ((iJ >>> 3) != 0) {
            return iJ;
        }
        throw B.a();
    }

    @Override // T0.d
    public final int D() {
        return J();
    }

    @Override // T0.d
    public final long E() {
        return K();
    }

    public final int H() throws B {
        int i4 = this.f3797f;
        if (this.f3796d - i4 < 4) {
            throw B.g();
        }
        this.f3797f = i4 + 4;
        byte[] bArr = this.f3795c;
        return ((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16);
    }

    public final long I() throws B {
        int i4 = this.f3797f;
        if (this.f3796d - i4 < 8) {
            throw B.g();
        }
        this.f3797f = i4 + 8;
        byte[] bArr = this.f3795c;
        return ((((long) bArr[i4 + 7]) & 255) << 56) | (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48);
    }

    public final int J() {
        int i4;
        int i5 = this.f3797f;
        int i6 = this.f3796d;
        if (i6 != i5) {
            int i7 = i5 + 1;
            byte[] bArr = this.f3795c;
            byte b5 = bArr[i5];
            if (b5 >= 0) {
                this.f3797f = i7;
                return b5;
            }
            if (i6 - i7 >= 9) {
                int i8 = i5 + 2;
                int i9 = (bArr[i7] << 7) ^ b5;
                if (i9 < 0) {
                    i4 = i9 ^ (-128);
                } else {
                    int i10 = i5 + 3;
                    int i11 = (bArr[i8] << 14) ^ i9;
                    if (i11 >= 0) {
                        i4 = i11 ^ 16256;
                    } else {
                        int i12 = i5 + 4;
                        int i13 = i11 ^ (bArr[i10] << 21);
                        if (i13 < 0) {
                            i4 = (-2080896) ^ i13;
                        } else {
                            i10 = i5 + 5;
                            byte b6 = bArr[i12];
                            int i14 = (i13 ^ (b6 << 28)) ^ 266354560;
                            if (b6 < 0) {
                                i12 = i5 + 6;
                                if (bArr[i10] < 0) {
                                    i10 = i5 + 7;
                                    if (bArr[i12] < 0) {
                                        i12 = i5 + 8;
                                        if (bArr[i10] < 0) {
                                            i10 = i5 + 9;
                                            if (bArr[i12] < 0) {
                                                int i15 = i5 + 10;
                                                if (bArr[i10] >= 0) {
                                                    i8 = i15;
                                                    i4 = i14;
                                                }
                                            }
                                        }
                                    }
                                }
                                i4 = i14;
                            }
                            i4 = i14;
                        }
                        i8 = i12;
                    }
                    i8 = i10;
                }
                this.f3797f = i8;
                return i4;
            }
        }
        return (int) L();
    }

    public final long K() {
        long j4;
        long j5;
        long j6;
        long j7;
        int i4 = this.f3797f;
        int i5 = this.f3796d;
        if (i5 != i4) {
            int i6 = i4 + 1;
            byte[] bArr = this.f3795c;
            byte b5 = bArr[i4];
            if (b5 >= 0) {
                this.f3797f = i6;
                return b5;
            }
            if (i5 - i6 >= 9) {
                int i7 = i4 + 2;
                int i8 = (bArr[i6] << 7) ^ b5;
                if (i8 < 0) {
                    j4 = i8 ^ (-128);
                } else {
                    int i9 = i4 + 3;
                    int i10 = (bArr[i7] << 14) ^ i8;
                    if (i10 >= 0) {
                        j4 = i10 ^ 16256;
                        i7 = i9;
                    } else {
                        int i11 = i4 + 4;
                        int i12 = i10 ^ (bArr[i9] << 21);
                        if (i12 < 0) {
                            j7 = (-2080896) ^ i12;
                        } else {
                            long j8 = i12;
                            i7 = i4 + 5;
                            long j9 = j8 ^ (((long) bArr[i11]) << 28);
                            if (j9 >= 0) {
                                j6 = 266354560;
                            } else {
                                i11 = i4 + 6;
                                long j10 = j9 ^ (((long) bArr[i7]) << 35);
                                if (j10 < 0) {
                                    j5 = -34093383808L;
                                } else {
                                    i7 = i4 + 7;
                                    j9 = j10 ^ (((long) bArr[i11]) << 42);
                                    if (j9 >= 0) {
                                        j6 = 4363953127296L;
                                    } else {
                                        i11 = i4 + 8;
                                        j10 = j9 ^ (((long) bArr[i7]) << 49);
                                        if (j10 < 0) {
                                            j5 = -558586000294016L;
                                        } else {
                                            i7 = i4 + 9;
                                            long j11 = (j10 ^ (((long) bArr[i11]) << 56)) ^ 71499008037633920L;
                                            if (j11 < 0) {
                                                int i13 = i4 + 10;
                                                if (bArr[i7] >= 0) {
                                                    i7 = i13;
                                                }
                                            }
                                            j4 = j11;
                                        }
                                    }
                                }
                                j7 = j5 ^ j10;
                            }
                            j4 = j6 ^ j9;
                        }
                        i7 = i11;
                        j4 = j7;
                    }
                }
                this.f3797f = i7;
                return j4;
            }
        }
        return L();
    }

    public final long L() throws B {
        long j4 = 0;
        for (int i4 = 0; i4 < 64; i4 += 7) {
            int i5 = this.f3797f;
            if (i5 == this.f3796d) {
                throw B.g();
            }
            this.f3797f = i5 + 1;
            byte b5 = this.f3795c[i5];
            j4 |= ((long) (b5 & 127)) << i4;
            if ((b5 & 128) == 0) {
                return j4;
            }
        }
        throw B.d();
    }

    public final void M() {
        int i4 = this.f3796d + this.e;
        this.f3796d = i4;
        int i5 = i4 - this.f3798g;
        int i6 = this.f3800i;
        if (i5 <= i6) {
            this.e = 0;
            return;
        }
        int i7 = i5 - i6;
        this.e = i7;
        this.f3796d = i4 - i7;
    }

    @Override // T0.d
    public final void b(int i4) throws B {
        if (this.f3799h != i4) {
            throw new B("Protocol message end-group tag did not match expected tag.");
        }
    }

    @Override // T0.d
    public final int f() {
        return this.f3797f - this.f3798g;
    }

    @Override // T0.d
    public final boolean g() {
        return this.f3797f == this.f3796d;
    }

    @Override // T0.d
    public final void j(int i4) {
        this.f3800i = i4;
        M();
    }

    @Override // T0.d
    public final int l(int i4) {
        if (i4 < 0) {
            throw B.e();
        }
        int iF = f() + i4;
        if (iF < 0) {
            throw B.f();
        }
        int i5 = this.f3800i;
        if (iF > i5) {
            throw B.g();
        }
        this.f3800i = iF;
        M();
        return i5;
    }

    @Override // T0.d
    public final boolean m() {
        return K() != 0;
    }

    /* JADX WARN: Removed duplicated region for block: B:15:0x002f  */
    @Override // T0.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final com.google.crypto.tink.shaded.protobuf.C0302g o() throws com.google.crypto.tink.shaded.protobuf.B {
        /*
            r4 = this;
            int r0 = r4.J()
            byte[] r1 = r4.f3795c
            if (r0 <= 0) goto L19
            int r2 = r4.f3796d
            int r3 = r4.f3797f
            int r2 = r2 - r3
            if (r0 > r2) goto L19
            com.google.crypto.tink.shaded.protobuf.g r1 = com.google.crypto.tink.shaded.protobuf.AbstractC0303h.h(r1, r3, r0)
            int r2 = r4.f3797f
            int r2 = r2 + r0
            r4.f3797f = r2
            return r1
        L19:
            if (r0 != 0) goto L1e
            com.google.crypto.tink.shaded.protobuf.g r0 = com.google.crypto.tink.shaded.protobuf.AbstractC0303h.f3791b
            return r0
        L1e:
            if (r0 <= 0) goto L2f
            int r2 = r4.f3796d
            int r3 = r4.f3797f
            int r2 = r2 - r3
            if (r0 > r2) goto L2f
            int r0 = r0 + r3
            r4.f3797f = r0
            byte[] r0 = java.util.Arrays.copyOfRange(r1, r3, r0)
            goto L35
        L2f:
            if (r0 > 0) goto L42
            if (r0 != 0) goto L3d
            byte[] r0 = com.google.crypto.tink.shaded.protobuf.AbstractC0320z.f3840b
        L35:
            com.google.crypto.tink.shaded.protobuf.g r1 = com.google.crypto.tink.shaded.protobuf.AbstractC0303h.f3791b
            com.google.crypto.tink.shaded.protobuf.g r1 = new com.google.crypto.tink.shaded.protobuf.g
            r1.<init>(r0)
            return r1
        L3d:
            com.google.crypto.tink.shaded.protobuf.B r0 = com.google.crypto.tink.shaded.protobuf.B.e()
            throw r0
        L42:
            com.google.crypto.tink.shaded.protobuf.B r0 = com.google.crypto.tink.shaded.protobuf.B.g()
            throw r0
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.crypto.tink.shaded.protobuf.C0304i.o():com.google.crypto.tink.shaded.protobuf.g");
    }

    @Override // T0.d
    public final double p() {
        return Double.longBitsToDouble(I());
    }

    @Override // T0.d
    public final int q() {
        return J();
    }

    @Override // T0.d
    public final int r() {
        return H();
    }

    @Override // T0.d
    public final long s() {
        return I();
    }

    @Override // T0.d
    public final float t() {
        return Float.intBitsToFloat(H());
    }

    @Override // T0.d
    public final int u() {
        return J();
    }

    @Override // T0.d
    public final long v() {
        return K();
    }

    @Override // T0.d
    public final int w() {
        return H();
    }

    @Override // T0.d
    public final long x() {
        return I();
    }

    @Override // T0.d
    public final int y() {
        return T0.d.d(J());
    }

    @Override // T0.d
    public final long z() {
        return T0.d.e(K());
    }
}
